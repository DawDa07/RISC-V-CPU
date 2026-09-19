"""CPU-level cocotb tests for the single-cycle RV32I core.

Each test loads an assembled program from ``programs/*.hex`` into instruction
memory, releases reset, runs until the PC parks in a spin loop (``j .``), then
compares the register file and data memory against expected values.

Programs are built from ``programs/*.S`` with ``make -C programs`` (requires
riscv64-elf-binutils); the generated ``.hex`` files are committed so the tests
also run without the toolchain.
"""

import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

MASK32 = 0xFFFFFFFF
PROG_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "programs")

# JAL x0, 0 encoding: unconditional self-jump used as the program halt.
JAL_X0_SELF = 0x0000006F

# Instruction encodings for the smoke test
ADDI_X1_X0_1 = 0x00100093  # addi x1, x0, 1
ADDI_X2_X1_1 = 0x00108113  # addi x2, x1, 1


# =============================================================================
# Helpers
# =============================================================================

def _imem(dut):
    return dut.u_imem.u_behav_macro.memory_array


def _dmem(dut):
    return dut.u_dmem.u_behav_macro.memory_array


def _regs(dut):
    return dut.u_reg_file.registers


def start_clock(dut):
    """Start a 10 ns clock for this test.

    Prefer a fresh Clock per test: a single shared Clock across the regression
    makes Icarus 13 shut down during later tests' VPI backdoor deposits into
    IMEM/RF (cocotb 2.0.1). Drivers share the same period; starts are issued
    while reset is held so edges stay aligned.
    """
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())


def read_hex(name):
    """Return the list of 32-bit words in ``programs/<name>``."""
    words = []
    with open(os.path.join(PROG_DIR, name)) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("@") or line.startswith("//"):
                continue
            words.append(int(line, 16) & MASK32)
    return words


def load_hex(dut, name):
    """Backdoor-load a program into IMEM; zero the remaining words."""
    mem = _imem(dut)
    words = read_hex(name)
    depth = len(mem)
    assert len(words) <= depth, f"{name} has {len(words)} words, IMEM depth is {depth}"
    for i in range(depth):
        mem[i].value = words[i] if i < len(words) else 0
    return len(words)


def clear_state(dut):
    """Zero the register file and DMEM so unwritten locations read as 0."""
    regs = _regs(dut)
    for i in range(32):
        regs[i].value = 0
    dmem = _dmem(dut)
    for i in range(len(dmem)):
        dmem[i].value = 0


def pc(dut):
    return int(dut.u_pc_reg.pc_q_o.value) & MASK32


def reg(dut, n):
    """Architectural register read (x0 hardwired through the RF read mux)."""
    if n == 0:
        return 0
    return int(_regs(dut)[n].value) & MASK32


def reg_storage(dut, n):
    """Raw RF storage cell — use to catch illegal writes into registers[0]."""
    return int(_regs(dut)[n].value) & MASK32


def dmem_word(dut, addr):
    assert addr % 4 == 0, f"dmem_word needs a word-aligned address, got 0x{addr:X}"
    return int(_dmem(dut)[addr >> 2].value) & MASK32


def imem_word(dut, addr):
    assert addr % 4 == 0, f"imem_word needs a word-aligned address, got 0x{addr:X}"
    return int(_imem(dut)[addr >> 2].value) & MASK32


def is_self_jump(word):
    """True for ``jal x0, 0`` / ``j .`` (unconditional jump to self)."""
    return (word & MASK32) == JAL_X0_SELF


async def run_until_spin(dut, max_cycles=400):
    """Clock until PC is stable, then require a self-jump at that PC."""
    prev = None
    same = 0
    cur = None
    for cycle in range(1, max_cycles + 1):
        await RisingEdge(dut.clk_i)
        await Timer(1, unit="ns")
        cur = pc(dut)
        if cur == prev:
            same += 1
            if same >= 2:
                word = imem_word(dut, cur)
                assert is_self_jump(word), (
                    f"PC stuck at 0x{cur:08X} but instr is 0x{word:08X}, "
                    f"expected jal x0,0 (0x{JAL_X0_SELF:08X})"
                )
                return cur, cycle
        else:
            same = 0
        prev = cur
    raise AssertionError(
        f"PC never settled into a spin loop within {max_cycles} cycles "
        f"(last PC=0x{cur:08X})"
    )


async def run_program(dut, name, regs=None, mem=None, final_pc=None, max_cycles=400):
    """Load ``name``, run to the spin loop, and check regs/mem/final PC.

    ``final_pc`` is required so a mid-program hang cannot false-pass.
    """
    if final_pc is None:
        raise ValueError(f"{name}: final_pc is required")

    regs = regs or {}
    mem = mem or {}

    start_clock(dut)

    # Hold reset, then deposit. Use Timer (not clock edges) so VPI writes are
    # not coincident with a sampling edge — that has crashed Icarus mid-suite.
    dut.rst_ni.value = 0
    await Timer(20, unit="ns")
    n_words = load_hex(dut, name)
    clear_state(dut)
    await Timer(1, unit="ns")
    got = int(dut.u_pc_reg.pc_q_o.value) & MASK32
    assert got == 0, f"PC not cleared by reset: 0x{got:08X}"
    dut.rst_ni.value = 1

    spin_pc, cycles = await run_until_spin(dut, max_cycles)
    dut._log.info(
        f"{name}: {n_words} words, spinning at PC=0x{spin_pc:08X} after {cycles} cycles"
    )

    assert spin_pc == final_pc, (
        f"{name}: expected spin at 0x{final_pc:08X}, got 0x{spin_pc:08X}"
    )

    errors = []
    for n in sorted(regs):
        got = reg(dut, n)
        exp = regs[n] & MASK32
        if got != exp:
            errors.append(f"x{n}: expected 0x{exp:08X}, got 0x{got:08X}")
    for addr in sorted(mem):
        got = dmem_word(dut, addr)
        exp = mem[addr] & MASK32
        if got != exp:
            errors.append(f"dmem[0x{addr:03X}]: expected 0x{exp:08X}, got 0x{got:08X}")

    assert not errors, f"{name} failed:\n  " + "\n  ".join(errors)
    dut._log.info(f"PASS: {name} ({len(regs)} regs, {len(mem)} mem words checked)")


# =============================================================================
# Tests
# =============================================================================

@cocotb.test()
async def smoke_cpu_addi_test(dut):
    """Reset, backdoor two ADDI instructions, check RF writes."""

    start_clock(dut)

    dut.rst_ni.value = 0
    await Timer(20, unit="ns")
    mem = _imem(dut)
    for i in range(len(mem)):
        mem[i].value = 0
    mem[0].value = ADDI_X1_X0_1
    mem[1].value = ADDI_X2_X1_1
    clear_state(dut)
    await Timer(1, unit="ns")
    assert (int(dut.u_pc_reg.pc_q_o.value) & MASK32) == 0
    dut.rst_ni.value = 1

    await RisingEdge(dut.clk_i)
    await Timer(1, unit="ns")
    assert reg(dut, 1) == 1, f"After first ADDI expected x1=1, got {reg(dut, 1)}"

    await RisingEdge(dut.clk_i)
    await Timer(1, unit="ns")
    assert reg(dut, 2) == 2, f"After second ADDI expected x2=2, got {reg(dut, 2)}"

    dut.rst_ni.value = 0
    await Timer(10, unit="ns")

    dut._log.info("PASS: smoke (fetch/decode/RF writeback)")


@cocotb.test()
async def test_alu_r(dut):
    """R-type ALU: add/sub/sll/slt/sltu/xor/srl/sra/or/and."""
    await run_program(
        dut, "alu_r.hex",
        regs={
            1: 7, 2: 0xFFFFFFFD, 3: 0x80000000, 4: 1,
            10: 4, 11: 10, 12: 128, 13: 1, 14: 0,
            15: 0xFFFFFFFA, 16: 0x01000000, 17: 0xFF000000,
            5: 0xFFFFFFFF, 6: 5, 7: 0, 8: 1, 9: 0x7FFFFFFF,
        },
        final_pc=0x44,
    )


@cocotb.test()
async def test_alu_i(dut):
    """I-type ALU: addi/slti/sltiu/xori/ori/andi/slli/srli/srai."""
    await run_program(
        dut, "alu_i.hex",
        regs={
            1: 0xFFFFFF9C, 10: 50, 11: 1, 12: 0, 13: 0, 14: 1,
            15: 99, 16: 0xFFFFFFFC, 17: 156,
            5: 0xFFFFF9C0, 6: 15, 7: 0xFFFFFFFF, 8: 2047, 9: 0xFFFFF800,
        },
        final_pc=0x38,
    )


@cocotb.test()
async def test_upper(dut):
    """LUI / AUIPC including PC-relative results."""
    await run_program(
        dut, "upper.hex",
        regs={
            10: 0x12345000, 11: 0x4, 12: 0x1008, 13: 0xFFFFF000,
            14: 0xFFFFEFFF, 15: 0x80000000, 16: 0xFFFFF018,
        },
        final_pc=0x1C,
    )


@cocotb.test()
async def test_mem(dut):
    """Loads/stores across all byte lanes with sign/zero extension."""
    await run_program(
        dut, "mem.hex",
        regs={
            1: 0x100, 2: 0xDEADBEEF,
            10: 0xDEADBEEF, 11: 0xFFFFFFEF, 12: 0xEF, 13: 0xFFFFFFBE,
            14: 0xAD, 15: 0xFFFFFFDE, 16: 0xFFFFBEEF, 17: 0xDEAD,
            3: 0x11, 4: 0x22, 5: 0x44332211, 6: 0xABCD1234,
            7: 0xFFFFABCD, 8: 0x1234, 9: 0xDEADBEEF,
        },
        mem={0x100: 0xDEADBEEF, 0x104: 0x44332211, 0x108: 0xDEADBEEF},
        final_pc=0x84,
    )


@cocotb.test()
async def test_branch(dut):
    """All six conditional branches, taken/not-taken, loop, signed overflow."""
    await run_program(
        dut, "branch.hex",
        regs={
            1: 5, 2: 0xFFFFFFFB, 3: 5, 4: 0x80000000, 5: 0x7FFFFFFF,
            10: 16,   # checks passed
            11: 0,    # checks failed
            14: 0,    # id of last failing check
            12: 55,   # loop sum
            13: 0,    # loop counter
        },
        final_pc=0x154,
    )


@cocotb.test()
async def test_jump(dut):
    """JAL/JALR: link = PC+4, JALR clears bit 0, call/return."""
    await run_program(
        dut, "jump.hex",
        regs={1: 0x04, 2: 0x1D, 3: 0x1C, 4: 0x20, 5: 0x34, 10: 31, 11: 0},
        final_pc=0x44,
    )


@cocotb.test()
async def test_x0(dut):
    """x0 stays zero on every write path; PC+4 write-back via JAL."""
    await run_program(
        dut, "x0.hex",
        regs={1: 0x10, 2: 77, 10: 0, 11: 0, 12: 77, 13: 0, 14: 1, 15: 0x38, 16: 0x38},
        mem={0x10: 0, 0x14: 77},
        final_pc=0x3C,
    )
    # Catch illegal writes into the physical x0 storage cell (read mux alone
    # would still return 0 via the rs==0 bypass).
    got = reg_storage(dut, 0)
    assert got == 0, f"registers[0] storage corrupted: 0x{got:08X}"

import random
import cocotb
from cocotb.triggers import Timer

from instr_mem_wrapper_uarch import InstructionMemory


@cocotb.test()
async def automated_instr_mem_wrapper_test(dut):
    """Verify Instruction Fetch, byte-to-word alignment, and bounds."""

    golden_imem = InstructionMemory()

    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000

    HW_DEPTH = int(dut.DEPTH.value)

    dut._log.info("Backdoor loading instructions into behavioral memory...")

    mem_array_handle = dut.u_behav_macro.memory_array

    min_instr = MIN_VAL
    golden_imem.load_instruction(0x00000000, min_instr)
    mem_array_handle[0].value = min_instr

    max_instr = MAX_VAL
    golden_imem.load_instruction(0x00000004, max_instr)
    mem_array_handle[1].value = max_instr

    golden_imem.load_instruction(0x00000008, 0x00100093)  # ADDI x1, x0, 1
    mem_array_handle[2].value = 0x00100093

    golden_imem.load_instruction(0x0000000C, 0x00208133)  # ADD x2, x1, x2
    mem_array_handle[3].value = 0x00208133

    test_cases = [
        ("Absolute Min Boundary (Boot Addr)", MIN_VAL),
        ("Absolute Max Boundary Instruction", 0x00000004),
        ("Standard Fetch (PC=8)", 0x00000008),
        ("Standard Fetch (PC=12)", 0x0000000C),
        ("Unaligned PC (Hardware ignores bottom bits)", 0x00000009),
        ("Out-of-Bounds Max PC Boundary", MAX_VAL),
    ]

    for i in range(10):
        random_word_idx = random.randint(4, HW_DEPTH - 1)
        rand_pc = random_word_idx * 4
        rand_instr = random.randint(MIN_VAL, MAX_VAL)

        golden_imem.load_instruction(rand_pc, rand_instr)
        mem_array_handle[random_word_idx].value = rand_instr

        test_cases.append((f"Random Valid Fetch {i}", rand_pc))

    dut._log.info("Starting Instruction Fetch Verification...")

    await Timer(1, unit="ns")

    for desc, pc in test_cases:
        dut.pc_i.value = pc
        await Timer(1, unit="ns")

        hw_instr = int(dut.instr_o.value) & MAX_VAL

        aligned_pc = pc & 0xFFFFFFFC
        exp_instr = golden_imem.read(aligned_pc)

        if (aligned_pc // 4) >= HW_DEPTH:
            exp_instr = 0

        assert hw_instr == exp_instr, \
            f"FAIL ({desc})! Exp: 0x{exp_instr:08X} | Act: 0x{hw_instr:08X} at PC: {pc}"

        dut._log.info(f"PASS: {desc} | PC: 0x{pc:08X} | Instr: 0x{hw_instr:08X}")

    dut._log.info("SUCCESS: Instruction Memory perfectly byte-aligned and bounds checked!")

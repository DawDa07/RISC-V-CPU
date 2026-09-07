import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


# addi x1, x0, 1
ADDI_X1_X0_1 = 0x00100093
# addi x2, x1, 1
ADDI_X2_X1_1 = 0x00108113


@cocotb.test()
async def smoke_cpu_addi_test(dut):
    """Reset, backdoor two ADDI instructions, check RF writes."""

    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())

    mem = dut.u_imem.u_behav_macro.memory_array
    mem[0].value = ADDI_X1_X0_1
    mem[1].value = ADDI_X2_X1_1

    dut._log.info("Applying active-low reset...")
    dut.rst_ni.value = 0
    await Timer(20, unit="ns")

    pc_reset = int(dut.u_pc_reg.pc_q_o.value) & 0xFFFFFFFF
    assert pc_reset == 0, f"PC reset failed: got 0x{pc_reset:08X}"

    dut.rst_ni.value = 1

    # Rising edge with PC=0: write x1 from addi x1,x0,1 and advance PC to 4
    await RisingEdge(dut.clk_i)
    await Timer(1, unit="ns")
    x1 = int(dut.u_reg_file.registers[1].value) & 0xFFFFFFFF
    assert x1 == 1, f"After first ADDI expected x1=1, got {x1}"
    dut._log.info("PASS: addi x1, x0, 1 -> x1=1")

    # Rising edge with PC=4: write x2 from addi x2,x1,1
    await RisingEdge(dut.clk_i)
    await Timer(1, unit="ns")
    x2 = int(dut.u_reg_file.registers[2].value) & 0xFFFFFFFF
    assert x2 == 2, f"After second ADDI expected x2=2, got {x2}"
    dut._log.info("PASS: addi x2, x1, 1 -> x2=2")

    dut._log.info("SUCCESS: CPU smoke test passed (fetch/decode/RF writeback).")

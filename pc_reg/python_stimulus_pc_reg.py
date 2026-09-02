import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from pc_reg_uarch import module_pc_reg_capture, module_pc_reg_reset


@cocotb.test()
async def automated_pc_reg_test(dut):
    """Verify the PC Register with strict max/min boundaries and reset behavior."""

    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())

    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000

    dut._log.info("Applying active-low reset...")
    dut.rst_ni.value = 0
    dut.pc_d_i.value = MAX_VAL

    await Timer(15, unit="ns")

    hw_reset_val = int(dut.pc_q_o.value) & MAX_VAL
    exp_reset = module_pc_reg_reset()
    assert hw_reset_val == exp_reset, (
        f"FAIL! PC did not reset to 0x{exp_reset:08X}, got 0x{hw_reset_val:08X}"
    )
    dut._log.info("PASS: Reset cleanly forced PC to absolute minimum boundary (0x00000000)")

    dut.rst_ni.value = 1
    await RisingEdge(dut.clk_i)

    test_cases = [
        ("Standard Address Step", 0x00001004),
        ("Standard Address Jump", 0x00002000),
        ("Absolute Maximum Boundary", MAX_VAL),
        ("Absolute Minimum Boundary", MIN_VAL),
        ("Alternating Bits (0x55..)", 0x55555555),
        ("Alternating Bits (0xAA..)", 0xAAAAAAAA),
    ]

    for i in range(10):
        test_cases.append((f"Random Fuzz {i}", random.randint(MIN_VAL, MAX_VAL)))

    dut._log.info("Starting PC Register sequential verification...")

    for desc, d_val in test_cases:
        dut.pc_d_i.value = d_val
        await RisingEdge(dut.clk_i)
        await Timer(1, unit="ns")

        hw_q = int(dut.pc_q_o.value) & MAX_VAL
        exp_q = module_pc_reg_capture(d_val)

        assert hw_q == exp_q, f"FAIL ({desc})! Exp: 0x{exp_q:08X} | Act: 0x{hw_q:08X}"
        dut._log.info(f"PASS: {desc} | pc_q_o: 0x{hw_q:08X}")

    dut._log.info("SUCCESS: All sequential captures and boundary tests passed!")

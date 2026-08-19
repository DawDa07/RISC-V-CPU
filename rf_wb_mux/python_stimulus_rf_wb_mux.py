import cocotb
from cocotb.triggers import Timer
from cocotb.types import LogicArray

# Mirror cpu_sv_package::wb_sel_e in Python
SEL_ALU = 0b00
SEL_LAU = 0b01
SEL_PC4 = 0b10


def python_rf_wb_mux(alu_res_i, lau_res_i, pc_plus_4_i, d2r_sel_i):
    """python model for rf_wb_mux"""
    if d2r_sel_i == SEL_ALU:
        return alu_res_i
    if d2r_sel_i == SEL_LAU:
        return lau_res_i
    if d2r_sel_i == SEL_PC4:
        return pc_plus_4_i
    return 0


async def drive_mux(dut, alu, lau, pc4, sel):
    dut.alu_res_i.value = alu
    dut.lau_res_i.value = lau
    dut.pc_plus_4_i.value = pc4
    dut.d2r_sel_i.value = sel
    await Timer(1, unit="ns")


@cocotb.test()
async def test_mux_x_state(dut):
    """Observe hardware behavior when the select line goes to X."""
    await drive_mux(dut, 0xFFFFFFFF, 0x00000000, 0x0000000F, SEL_ALU)

    assert int(dut.rf_wd_o.value) == 0xFFFFFFFF, \
        "Expected ALU path before injecting X on select"

    dut.d2r_sel_i.value = LogicArray("XX")
    await Timer(1, unit="ns")

    dut._log.info(f"Output with X select: {dut.rf_wd_o.value}")


@cocotb.test()
async def golden_model_mux_test(dut):
    """Verify all enum selects and the default case against the golden model."""
    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000

    test_cases = [
        (MAX_VAL, MIN_VAL, MIN_VAL, SEL_ALU, "SEL_ALU"),
        (MIN_VAL, MAX_VAL, MIN_VAL, SEL_LAU, "SEL_LAU"),
        (MIN_VAL, MIN_VAL, MAX_VAL, SEL_PC4, "SEL_PC4"),
        (0xAAAAAAAA, 0x55555555, 0x12345678, 0b11, "invalid select"),
    ]

    for alu, lau, pc4, sel, label in test_cases:
        await drive_mux(dut, alu, lau, pc4, sel)

        expected = python_rf_wb_mux(alu, lau, pc4, sel)
        actual = int(dut.rf_wd_o.value)

        assert actual == expected, \
            f"{label}: got {hex(actual)}, expected {hex(expected)}"

        dut._log.info(f"PASSED {label}: rf_wd_o = {hex(actual)}")

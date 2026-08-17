import cocotb
from cocotb.triggers import Timer
from cocotb.types import LogicArray


def python_rf_wb_mux(alu_res_i, lau_res_i, pc_plus_4_i, d2r_sel_i):
    if d2r_sel_i == 0:
        return alu_res_i
    elif d2r_sel_i == 1:
        return lau_res_i
    elif d2r_sel_i == 2:
        return pc_plus_4_i
    else:
        return 0


@cocotb.test()
async def test_mux_x_state(dut):
    """Test how the hardware handles unknown X states on the select line."""
    
    # 1. Set standard data
    dut.alu_res_i.value = 0xFFFFFFFF
    dut.lau_res_i.value = 0x00000000
    dut.pc_plus_4_i.value = 0x0000000F
    
    # 2. Drive a VALID select first
    dut.d2r_sel_i.value = 0
    await Timer(1, unit="ns")
    
    # 3. Inject the 'X' state
    dut.d2r_sel_i.value = LogicArray("XX") # Inject X state
    await Timer(1, unit="ns")



@cocotb.test()
async def golden_model_mux_test(dut):
    """Verify all valid select lines against the Python Golden Model using Max/Min boundaries."""

    # Define our strict maximum and minimum boundaries for 32-bit architecture
    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000

    # Test Vectors: (alu_res, lau_res, pc_plus_4, select_line)
    test_cases = [
        (MAX_VAL, MIN_VAL, MIN_VAL, 0), # Max boundary on ALU
        (MIN_VAL, MAX_VAL, MIN_VAL, 1), # Max boundary on LAU
        (MIN_VAL, MIN_VAL, MAX_VAL, 2), # Max boundary on PC+4
        (0xAAAAAAAA, 0x55555555, 0x12345678, 3) # Invalid select line (should hit default)
    ]

    for alu, lau, pc4, sel in test_cases:
        # 1. Drive the physical SystemVerilog pins
        dut.alu_res_i.value  = alu
        dut.lau_res_i.value  = lau
        dut.pc_plus_4_i.value = pc4
        dut.d2r_sel_i.value  = sel

        # 2. Wait for combinational logic to propagate
        await Timer(1, unit="ns")

        # 3. Ask the Python Oracle what the answer should be
        expected_output = python_rf_wb_mux(alu, lau, pc4, sel)

        # 4. Read the physical hardware pin
        actual_output = int(dut.rf_wd_o.value)

        # 5. Automatically compare
        assert actual_output == expected_output, \
            f"FAIL! Hardware produced {hex(actual_output)}, but Oracle expected {hex(expected_output)}"

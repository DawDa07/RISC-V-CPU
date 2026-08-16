import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def nand_truth_table_test(dut):
    """Test the NAND gate against its full truth table."""

    test_cases = [
        (0, 0, 1),
        (0, 1, 1),
        (1, 0, 1),
        (1, 1, 0),
    ]

    for a_val, b_val, expected_y in test_cases:
        dut.a.value = a_val
        dut.b.value = b_val

        await Timer(1, unit="ns")

        actual_y = dut.y.value
        assert actual_y == expected_y, \
            f"NAND failed: a={a_val}, b={b_val}. Expected {expected_y}, got {actual_y}"

        dut._log.info(f"PASSED: NAND({a_val}, {b_val}) = {actual_y}")

# Python reference model for reg_file.sv.

MASK32 = 0xFFFFFFFF


class RegisterFile:
    """Python model matching reg_file.sv: 32 regs, x0 hardwired to 0."""

    def __init__(self):
        self.registers = [0] * 32

    def write(self, rd_i, wd_i, we_i):
        """Synchronous write: only when we_i and rd_i != 0."""
        if we_i and (rd_i != 0):
            self.registers[rd_i & 0x1F] = wd_i & MASK32

    def read_rs1(self, rs1_i):
        """Combinational read port 1; x0 always returns 0."""
        rs1 = rs1_i & 0x1F
        return 0 if rs1 == 0 else self.registers[rs1]

    def read_rs2(self, rs2_i):
        """Combinational read port 2; x0 always returns 0."""
        rs2 = rs2_i & 0x1F
        return 0 if rs2 == 0 else self.registers[rs2]

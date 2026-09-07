# Python reference model for data_mem_behavioral / data_mem_wrapper.

MASK32 = 0xFFFFFFFF


class DataMemory:
    """Word-addressed data memory with 4-bit write strobes."""

    def __init__(self, depth=1024):
        self.depth = depth
        self.memory = [0] * depth

    def _word_idx(self, addr):
        return (addr & MASK32) >> 2

    def write(self, addr, wdata, wstrobe):
        """Synchronous write with byte enables (we_i[3:0])."""
        idx = self._word_idx(addr)
        if idx >= self.depth:
            return

        word = self.memory[idx]
        data = wdata & MASK32
        strobe = wstrobe & 0xF

        if strobe & 0b0001:
            word = (word & ~0x000000FF) | (data & 0x000000FF)
        if strobe & 0b0010:
            word = (word & ~0x0000FF00) | (data & 0x0000FF00)
        if strobe & 0b0100:
            word = (word & ~0x00FF0000) | (data & 0x00FF0000)
        if strobe & 0b1000:
            word = (word & ~0xFF000000) | (data & 0xFF000000)

        self.memory[idx] = word & MASK32

    def read(self, addr):
        """Combinational read; out-of-bounds returns 0."""
        idx = self._word_idx(addr)
        if idx >= self.depth:
            return 0
        return self.memory[idx]

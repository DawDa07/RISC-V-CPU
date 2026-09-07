# Python reference model for instr_mem_behavioral / instruction fetch.

MASK32 = 0xFFFFFFFF


class InstructionMemory:
    """Byte-addressed instruction memory model (word-aligned fetches)."""

    def __init__(self, depth=1024):
        self.depth = depth
        self.memory = [0] * depth

    def load_instruction(self, byte_addr, instr):
        """Store a 32-bit instruction at a byte address (uses word index)."""
        word_idx = (byte_addr & MASK32) >> 2
        if word_idx < self.depth:
            self.memory[word_idx] = instr & MASK32

    def read(self, byte_addr):
        """Fetch instruction at byte address; out-of-bounds returns 0."""
        word_idx = (byte_addr & MASK32) >> 2
        if word_idx < self.depth:
            return self.memory[word_idx]
        return 0

# `rf_wb_mux`: Register-File Write-Back Multiplexer

3 to 1 combinational mux that chooses what gets written to the register file after an instruction finishes

## RTL diagram

![rf_wb_mux RTL block diagram](rf_wb_mux_rtl.png)

## Flowchart

```mermaid
flowchart TB
  alu["alu_res_i<br/>ALU result"]
  lau["lau_res_i<br/>load / memory data"]
  pc4["pc_plus_4_i<br/>PC + 4"]
  sel["d2r_sel_i<br/>wb_sel_e"]

  mux{"rf_wb_mux"}

  alu --> mux
  lau --> mux
  pc4 --> mux
  sel --> mux

  mux -->|SEL_ALU| out_alu["rf_wd_o = alu_res_i"]
  mux -->|SEL_LAU| out_lau["rf_wd_o = lau_res_i"]
  mux -->|SEL_PC4| out_pc4["rf_wd_o = pc_plus_4_i"]
  mux -->|default| out_z["rf_wd_o = 0"]
```

## Select table

| `d2r_sel_i` | Value   | Output `rf_wd_o` | Typical use        |
|-------------|---------|------------------|--------------------|
| `SEL_ALU`   | `2'b00` | `alu_res_i`      | `add`, `addi`, …   |
| `SEL_LAU`   | `2'b01` | `lau_res_i`      | `lw`, `lb`, …      |
| `SEL_PC4`   | `2'b10` | `pc_plus_4_i`    | `jal`, `jalr`      |
| default     | other   | `0`              | invalid / unused   |

## Files

| File | Role |
|------|------|
| `rf_wb_mux.sv` | SystemVerilog hardware |
| `python_stimulus_rf_wb_mux.py` | cocotb tests |
| `Makefile` | compile + simulate with Icarus |
| `../cpu_sv_package.sv` | shared enums (`wb_sel_e`) |


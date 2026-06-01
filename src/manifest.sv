`ifndef MANIFEST_SV
`define MANIFEST_SV

// 1. Core architectural packages/definitions
`include "risc_pkg.sv"

// 2. Leaf-level modules (No sub-module instantiations)
`include "alu.sv"
`include "branch_control.sv"
`include "control.sv"
`include "data_memory.sv"
`include "decode.sv"
`include "fetch.sv"
`include "instruction_memory.sv"
`include "register_file.sv"

// 3. Top-level wrappers and integration modules
`include "top.sv"

`endif

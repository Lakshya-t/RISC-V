`ifndef WRITEBACK_CYCLE_V
`define WRITEBACK_CYCLE_V

`include "Mux.v"

module writeback_cycle (
    input clk,
    input rst,
    input [1:0] ResultSrcW,
    input [31:0] PCPlus4W,
    input [31:0] ALU_ResultW,
    input [31:0] ReadDataW,
    output [31:0] ResultW
);

    // 3-to-1 Multiplexer to select Writeback Result
    Mux_3_by_1 result_mux (
        .a(ALU_ResultW),
        .b(ReadDataW),
        .c(PCPlus4W),
        .s(ResultSrcW),
        .d(ResultW)
    );

endmodule

`endif
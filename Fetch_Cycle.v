`ifndef FETCH_CYCLE_V
`define FETCH_CYCLE_V

`include "PC.v"
`include "PC_Adder.v"
`include "Mux.v"
`include "Instruction_Memory.v"

module Fetch_Cycle (
    input clk, 
    input rst, 
    input PCSrcE, 
    input [31:0] PCTargetE, 
    output reg [31:0] InstrD, 
    output reg [31:0] PCD, 
    output reg [31:0] PCPlus4D
);

    // Declaration of Interim Wires
    wire [31:0] PC_F, PCF, PCPlus4F, InstrF;

    // PC Multiplexer (Select PC+4 vs branch/jump destination target address)
    Mux PC_Mux (
        .a(PCPlus4F),
        .b(PCTargetE),
        .s(PCSrcE),
        .c(PC_F)
    );

    // Program Counter Register Instantiation
    PC_Module Program_Counter (
        .clk(clk),
        .rst(rst), 
        .PC(PCF), 
        .PC_Next(PC_F) 
    );

    // Instruction Memory Instantiation
    Instruction_Memory IMEM (
        .rst(rst),
        .A(PCF),
        .RD(InstrF)
    );

    // PC Adder (Calculates PC + 4)
    PC_Adder PC_adder (
        .a(PCF),
        .b(32'h00000004),
        .c(PCPlus4F)
    );

    // Sequential Pipeline Register Logic (updates at clock edge)
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            InstrD   <= 32'h00000000;
            PCD      <= 32'h00000000;
            PCPlus4D <= 32'h00000000;
        end
        else begin
            InstrD   <= InstrF;
            PCD      <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end

endmodule

`endif

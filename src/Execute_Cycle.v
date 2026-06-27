`ifndef EXECUTE_CYCLE_V
`define EXECUTE_CYCLE_V

`include "Mux.v"
`include "ALU.v"
`include "PC_Adder.v"

module execute_cycle (
    input clk, 
    input rst, 
    input RegWriteE, 
    input ALUSrcE, 
    input MemWriteE, 
    input [1:0] ResultSrcE,   // 2-bit input to support Jumps (PC+4)
    input BranchE, 
    input JumpE,              // JumpE input
    input [2:0] ALUControlE, 
    input [31:0] RD1_E, 
    input [31:0] RD2_E, 
    input [31:0] Imm_Ext_E, 
    input [4:0] RD_E, 
    input [31:0] PCE, 
    input [31:0] PCPlus4E, 
    input [31:0] ResultW, 
    input [1:0] ForwardA_E, 
    input [1:0] ForwardB_E,
    output PCSrcE,            // PC Mux selector output (Combinational)
    output [31:0] PCTargetE,  // Calculated jump/branch destination address (Combinational)
    output reg RegWriteM, 
    output reg MemWriteM, 
    output reg [1:0] ResultSrcM,  // 2-bit output
    output reg [4:0] RD_M, 
    output reg [31:0] PCPlus4M, 
    output reg [31:0] WriteDataM, 
    output reg [31:0] ALU_ResultM
);

    // Declaration of Interim Wires
    wire [31:0] Src_A, Src_B_interim, Src_B;
    wire [31:0] ResultE;
    wire ZeroE;

    // 3-by-1 Mux for Source A (ALU input A selection with forwarding)
    Mux_3_by_1 srca_mux (
        .a(RD1_E),
        .b(ResultW),
        .c(ALU_ResultM),
        .s(ForwardA_E),
        .d(Src_A)
    );

    // 3-by-1 Mux for Source B (ALU input B selection with forwarding)
    Mux_3_by_1 srcb_mux (
        .a(RD2_E),
        .b(ResultW),
        .c(ALU_ResultM),
        .s(ForwardB_E),
        .d(Src_B_interim)
    );

    // ALU Source Multiplexer (Select register operand vs immediate constant)
    Mux alu_src_mux (
        .a(Src_B_interim),
        .b(Imm_Ext_E),
        .s(ALUSrcE),
        .c(Src_B)
    );

    // Arithmetic Logic Unit (ALU) Instantiation
    ALU alu (
        .A(Src_A),
        .B(Src_B),
        .Result(ResultE),
        .ALUControl(ALUControlE),
        .OverFlow(),
        .Carry(),
        .Zero(ZeroE),
        .Negative()
    );

    // Branch Target Address Adder
    PC_Adder branch_adder (
        .a(PCE),
        .b(Imm_Ext_E),
        .c(PCTargetE)
    );

    // Sequential Pipeline Register Logic (updates at clock edge directly to output registers)
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            RegWriteM  <= 1'b0; 
            MemWriteM  <= 1'b0; 
            ResultSrcM <= 2'b00;
            RD_M       <= 5'h00;
            PCPlus4M   <= 32'h00000000; 
            WriteDataM <= 32'h00000000; 
            ALU_ResultM<= 32'h00000000;
        end
        else begin
            RegWriteM  <= RegWriteE; 
            MemWriteM  <= MemWriteE; 
            ResultSrcM <= ResultSrcE;
            RD_M       <= RD_E;
            PCPlus4M   <= PCPlus4E; 
            WriteDataM <= Src_B_interim; 
            ALU_ResultM<= ResultE;
        end
    end

    // Combinational Output Assignments
    assign PCSrcE = (ZeroE & BranchE) | JumpE;

endmodule

`endif
`ifndef DECODE_CYCLE_V
`define DECODE_CYCLE_V

`include "Control_Unit_Top.v"
`include "Register_File.v"
`include "Sign_Extend.v"

module decode_cycle (
    input clk, 
    input rst, 
    input [31:0] InstrD, 
    input [31:0] PCD, 
    input [31:0] PCPlus4D, 
    input RegWriteW, 
    input [4:0] RDW, 
    input [31:0] ResultW, 
    output reg RegWriteE, 
    output reg ALUSrcE, 
    output reg MemWriteE, 
    output reg [1:0] ResultSrcE,   // 2-bit registered output
    output reg BranchE, 
    output reg JumpE,              // Registered Jump control output
    output reg [2:0] ALUControlE, 
    output reg [31:0] RD1_E, 
    output reg [31:0] RD2_E, 
    output reg [31:0] Imm_Ext_E, 
    output reg [4:0] RD_E, 
    output reg [31:0] PCE, 
    output reg [31:0] PCPlus4E
);

    // Declare Interim Wires (outputs from the combinational blocks)
    wire RegWriteD, ALUSrcD, MemWriteD, BranchD, JumpD;
    wire [1:0] ResultSrcD;
    wire [1:0] ImmSrcD;
    wire [2:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    // 1. Control Unit Instantiation
    Control_Unit_Top control (
        .Op(InstrD[6:0]),
        .RegWrite(RegWriteD),
        .ImmSrc(ImmSrcD),
        .ALUSrc(ALUSrcD),
        .MemWrite(MemWriteD),
        .ResultSrc(ResultSrcD),     // Connected natively
        .Branch(BranchD),
        .funct3(InstrD[14:12]),
        .funct7_5(InstrD[30]),       // Connected to bit 30
        .ALUControl(ALUControlD),
        .Jump(JumpD)                // Connected natively
    );

    // 2. Register File Instantiation
    Register_File reg_file (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .A1(InstrD[19:15]),
        .A2(InstrD[24:20]),
        .A3(RDW),
        .WD3(ResultW),
        .RD1(RD1_D),
        .RD2(RD2_D)
    );

    // 3. Sign Extension Instantiation
    Sign_Extend extension (
        .In(InstrD[31:7]),           // Passing the 25-bit slice matching Sign_Extend.v port
        .Imm_Ext(Imm_Ext_D),
        .ImmSrc(ImmSrcD)
    );

    // Declaring Register Logic (updates at posedge clk directly to output registers)
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteE   <= 1'b0;
            ALUSrcE     <= 1'b0;
            MemWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            BranchE     <= 1'b0;
            JumpE       <= 1'b0;
            ALUControlE <= 3'b000;
            RD1_E       <= 32'h00000000;
            RD2_E       <= 32'h00000000;
            Imm_Ext_E   <= 32'h00000000;
            RD_E        <= 5'h00;
            PCE         <= 32'h00000000;
            PCPlus4E    <= 32'h00000000;
        end
        else begin
            RegWriteE   <= RegWriteD;
            ALUSrcE     <= ALUSrcD;
            MemWriteE   <= MemWriteD;
            ResultSrcE  <= ResultSrcD;
            BranchE     <= BranchD;
            JumpE       <= JumpD;
            ALUControlE <= ALUControlD;
            RD1_E       <= RD1_D;
            RD2_E       <= RD2_D;
            Imm_Ext_E   <= Imm_Ext_D;
            RD_E        <= InstrD[11:7]; // rd register address
            PCE         <= PCD;
            PCPlus4E    <= PCPlus4D;
        end
    end

endmodule

`endif
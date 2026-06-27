`ifndef CONTROL_UNIT_TOP_V
`define CONTROL_UNIT_TOP_V

module Control_Unit_Top (
    input [6:0] Op,
    input [2:0] funct3,
    input funct7_5,           // Bit 30 of instruction (funct7[5])
    output RegWrite,
    output [1:0] ImmSrc,
    output ALUSrc,
    output MemWrite,
    output [1:0] ResultSrc,   // 2-bit to support Jumps (PC+4)
    output Branch,
    output [2:0] ALUControl,
    output Jump
);

    // Internal wire for ALUOp
    wire [1:0] ALUOp;

    // --- Main Decoder Logic ---
    assign RegWrite = (Op == 7'b0000011 || Op == 7'b0110011 || Op == 7'b0010011 || Op == 7'b1101111) ? 1'b1 : 1'b0;
    
    assign ImmSrc   = (Op == 7'b0100011) ? 2'b01 : 
                      (Op == 7'b1100011) ? 2'b10 :    
                      (Op == 7'b1101111) ? 2'b11 : // J-type immediate
                                           2'b00 ;
                                           
    assign ALUSrc   = (Op == 7'b0000011 || Op == 7'b0100011 || Op == 7'b0010011) ? 1'b1 : 1'b0;
    
    assign MemWrite = (Op == 7'b0100011) ? 1'b1 : 1'b0;
    
    assign ResultSrc = (Op == 7'b0000011) ? 2'b01 : // Memory data
                       (Op == 7'b1101111) ? 2'b10 : // PC + 4 (for Jumps)
                                            2'b00 ; // ALU result
                                            
    assign Branch   = (Op == 7'b1100011) ? 1'b1 : 1'b0;
    
    assign Jump     = (Op == 7'b1101111) ? 1'b1 : 1'b0;
    
    assign ALUOp    = (Op == 7'b0110011) ? 2'b10 :
                      (Op == 7'b1100011) ? 2'b01 :
                                           2'b00 ;

    // --- ALU Decoder Logic ---
    assign ALUControl = (ALUOp == 2'b00) ? 3'b000 : // Add (Load/Store)
                        (ALUOp == 2'b01) ? 3'b001 : // Subtract (Branch)
                        
                        // ALUOp == 2'b10 (R-type or I-type ALU)
                        ((ALUOp == 2'b10) && (funct3 == 3'b000) && ({Op[5], funct7_5} == 2'b11)) ? 3'b001 : // Subtract
                        ((ALUOp == 2'b10) && (funct3 == 3'b000) && ({Op[5], funct7_5} != 2'b11)) ? 3'b000 : // Add / Addi
                        ((ALUOp == 2'b10) && (funct3 == 3'b010)) ? 3'b101 : // SLT
                        ((ALUOp == 2'b10) && (funct3 == 3'b110)) ? 3'b011 : // OR
                        ((ALUOp == 2'b10) && (funct3 == 3'b111)) ? 3'b010 : // AND
                                                                   3'b000 ; // Default

endmodule

`endif
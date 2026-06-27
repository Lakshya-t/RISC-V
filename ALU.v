`ifndef ALU_V
`define ALU_V

module ALU (
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUControl,
    output [31:0] Result,
    output OverFlow,
    output Carry,
    output Zero,
    output Negative
);

    wire Cout;
    wire [31:0] Sum;

    // Sum calculation (performs A + B or A - B based on LSB of ALUControl)
    assign Sum = (ALUControl[0] == 1'b0) ? (A + B) : (A + (~B + 1'b1));

    // Result multiplexing based on ALUControl selection
    assign {Cout, Result} = (ALUControl == 3'b000) ? {1'b0, Sum} :               // ADD
                             (ALUControl == 3'b001) ? {1'b0, Sum} :               // SUB
                             (ALUControl == 3'b010) ? {1'b0, A & B} :             // AND
                             (ALUControl == 3'b011) ? {1'b0, A | B} :             // OR
                             (ALUControl == 3'b101) ? {1'b0, 31'b0, Sum[31]} :    // SLT (Set Less Than)
                             33'd0;

    // Status Flags Derivation
    assign OverFlow = ((Sum[31] ^ A[31]) & (~(ALUControl[0] ^ B[31] ^ A[31])) & (~ALUControl[1]));
    assign Carry    = (~ALUControl[1]) & Cout;
    assign Zero     = &(~Result);
    assign Negative = Result[31];

endmodule

`endif
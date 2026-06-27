`ifndef INSTRUCTION_MEMORY_V
`define INSTRUCTION_MEMORY_V

module Instruction_Memory (
    input rst,
    input [31:0] A,
    output [31:0] RD
);

    // Instruction memory array declared with ascending indices to silence compile warnings
    reg [31:0] mem [0:1023];

    // Asynchronous read (word-aligned A[31:2])
    assign RD = (rst == 1'b0) ? 32'd0 : mem[A[31:2]];

    // Load instruction memory from hex file at startup
    initial begin
        $readmemh("memfile.hex", mem);
    end

endmodule

`endif
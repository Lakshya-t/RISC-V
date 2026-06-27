`ifndef DATA_MEMORY_V
`define DATA_MEMORY_V

module Data_Memory (
    input clk,
    input rst,
    input WE,
    input [31:0] A,
    input [31:0] WD,
    output [31:0] RD
);

    // Memory array declaration (1024 words of 32 bits each, ascending indices)
    reg [31:0] mem [0:1023];

    // Synchronous write logic (using word-aligned indexing A[31:2])
    always @(posedge clk) begin
        if (WE) begin
            mem[A[31:2]] <= WD;
        end
    end

    // Asynchronous read logic (using word-aligned indexing A[31:2])
    assign RD = (rst == 1'b0) ? 32'd0 : mem[A[31:2]];

    // Memory initialization
    initial begin
        mem[0] = 32'h00000000;
    end

endmodule

`endif
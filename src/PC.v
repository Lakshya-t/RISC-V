`ifndef PC_V
`define PC_V

module PC_Module (
    input clk,
    input rst,
    input [31:0] PC_Next,
    output reg [31:0] PC
);

    // Synchronous Reset Program Counter Register
    always @(posedge clk) begin
        if (rst == 1'b0)
            PC <= 32'h00000000;
        else 
            PC <= PC_Next;
    end

endmodule

`endif

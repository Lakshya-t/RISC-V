`ifndef REGISTER_FILE_V
`define REGISTER_FILE_V

module Register_File (
    input clk,
    input rst,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] Register [31:0];
    integer i;

    // Asynchronous reads
    // Register x0 is hardwired to 0 in RISC-V
    assign RD1 = (rst == 1'b0) ? 32'h00000000 : ((A1 == 5'b00000) ? 32'h00000000 : Register[A1]);
    assign RD2 = (rst == 1'b0) ? 32'h00000000 : ((A2 == 5'b00000) ? 32'h00000000 : Register[A2]);

    // Synchronous write on falling edge of clock to prevent RAW hazards in same cycle
    always @(negedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (i = 0; i < 32; i = i + 1) begin
                Register[i] <= 32'h00000000;
            end
        end else if (WE3 && (A3 != 5'b00000)) begin
            Register[A3] <= WD3;
        end
    end

endmodule

`endif
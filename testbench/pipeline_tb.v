module tb();

    reg clk = 0, rst;
    
    // Clock generator (period = 100 ns)
    always begin
        clk = ~clk;
        #50;
    end

    // Stimulus block
    initial begin
        rst <= 1'b0;
        #200;
        rst <= 1'b1;
        #1000;
        $finish;    
    end

    // VCD Dump for Waveform viewing
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    // Device Under Test (DUT) Instantiation
    Pipeline_top dut (
        .clk(clk),
        .rst(rst)
    );

endmodule
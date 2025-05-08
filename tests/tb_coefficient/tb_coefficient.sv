module coefficient_unit_tb;
    parameter SAMPLE_WIDTH = 24;
    parameter CLK_PERIOD = 10;
    
    logic clk = 0;
    logic reset;
    logic start;
    logic ready;
    logic [SAMPLE_WIDTH-1:0] cutoff_freq;
    logic signed [SAMPLE_WIDTH-1:0] b0, b1, b2, a1, a2;
    
    coefficient_unit uut (.*);
    
    always #(CLK_PERIOD/2) clk = ~clk;
    
    function real q816_to_float(input signed [23:0] val);
        return $itor(val) / 65536.0;
    endfunction
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, coefficient_unit_tb);
        
        reset = 1;
        start = 0;
        cutoff_freq = 0;
        #100 reset = 0;
        
        $display("\n=== Starting Tests ===");
        
        // Test sequence
        test_case(69,   "Min cutoff");
        test_case(500,  "Mid cutoff");
        test_case(1024, "Max cutoff");
        
        #100 $display("\n=== Tests Complete ===");
        $finish;
    end
    
    task test_case(input [SAMPLE_WIDTH-1:0] freq, input string desc);
        $display("\n[Test] %s: %0dHz", desc, freq);
        cutoff_freq = freq;
        start = 1;
        #(CLK_PERIOD);
        start = 0;
        
        wait(ready);
        
        $display("Coefficients:");
        $display("b0: %0d (%.6f)", b0, q816_to_float(b0));
        $display("b1: %0d", b1);
        $display("b2: %0d (%.6f)", b2, q816_to_float(b2));
        $display("a1: %0d (%.6f)", a1, q816_to_float(a1));
        $display("a2: %0d (%.6f)", a2, q816_to_float(a2));
        
        #20;
    endtask
endmodule
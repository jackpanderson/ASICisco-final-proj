module cutoff_freq_tb;
    parameter SAMPLE_WIDTH = 24;
    parameter FC_MAX = 1024;
    parameter FC_MIN = 69;

    reg [SAMPLE_WIDTH-1:0] env_avg;
    reg [3:0] filter_strength_ratio;
    wire [SAMPLE_WIDTH-1:0] cutoff_freq;

    cutoff_freq_unit #(
        .SAMPLE_WIDTH(SAMPLE_WIDTH),
        .FC_MAX(FC_MAX),
        .FC_MIN(FC_MIN),
        .TYPICAL_ENV(1_000_000)  // Proper scaling for 24-bit
    ) uut (.*);

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, cutoff_freq_tb);
        
        $display("Time\tEnv\t\tStrength\tCutoff\tNote");
        $display("--------------------------------------------");
        
        // Test sequence
        #10 env_avg = 0;               filter_strength_ratio = 0;  // Min
        #10 env_avg = 1_000_000;       filter_strength_ratio = 8;  // Mid
        #10 env_avg = 10_000_000;      filter_strength_ratio = 15; // High
        #10 env_avg = 16_777_215;      filter_strength_ratio = 15; // Max (2^24-1)
        
        // Strength sweep at mid envelope
        #10 env_avg = 1_000_000; filter_strength_ratio = 1;
        #10 filter_strength_ratio = 4;
        #10 filter_strength_ratio = 8;
        #10 filter_strength_ratio = 12;
        #10 filter_strength_ratio = 15;
        
        // Envelope sweep at max strength
        #10 env_avg = 100_000;   filter_strength_ratio = 15;
        #10 env_avg = 500_000;
        #10 env_avg = 1_000_000;
        #10 env_avg = 5_000_000;
        #10 env_avg = 10_000_000;
        
        #10 $finish;
    end

    always @(env_avg or filter_strength_ratio) begin
        #1 $display("%0t\t%8d\t%2d\t\t%4d\t%s", 
                   $time, env_avg, filter_strength_ratio, cutoff_freq,
                   (cutoff_freq >= FC_MAX) ? "MAX!" : "");
    end
endmodule
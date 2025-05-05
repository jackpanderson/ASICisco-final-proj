module wah #(parameter SAMPLE_WIDTH = 24) 
            (input [SAMPLE_WIDTH - 1: 0] sample_in,
            input system_clock, //96MHz
            input rst,   //Active high reset
            input [3:0]                  filter_strength_ratio,
             output [SAMPLE_WIDTH - 1: 0] filter_out);
    
    // Sample 96KHz clock
    logic sample_clock;

    //Envelope average
    logic [SAMPLE_WIDTH - 1:0] env_average;

    logic [SAMPLE_WIDTH - 1: 0] cutoff_freq; // In digital frequency, fixed point, 24b tot, 16b float precision

    clock_divider clocky (.in_clk(system_clock),
                          .rst(rst),
                          .out_clk(sample_clock));
    
    envelope_analyzer env (.sample_in(sample_in),
                           .sample_clock(sample_clock),
                           .rst(rst),
                           .out_sample(env_average));
    
    cutoff_freq_unit cutoff (.env_avg(env_average),
                             .filter_strength_ratio(filter_strength_ratio),
                             .cutoff_freq(cutoff_freq));


endmodule
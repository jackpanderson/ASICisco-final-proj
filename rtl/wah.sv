module wah #(parameter SAMPLE_WIDTH = 24) 
            (input [SAMPLE_WIDTH - 1: 0] sample_in,
            input system_clock, //96MHz
            input rst,   //Active high reset
            input [3:0]                  filter_strength_ratio,
             output [SAMPLE_WIDTH - 1: 0] filter_out);
    
    // Sample 96KHz clock
    logic sample_clock;


    typedef enum logic [0:0] {
    IDLE,       
    COEFF_CALC
    } state_t;

    //Envelope average
    logic [SAMPLE_WIDTH - 1:0] env_average;

    logic [SAMPLE_WIDTH - 1: 0] digital_cutoff_freq; // In digital frequency, fixed point, 24b tot, 16b float precision


    logic [SAMPLE_WIDTH - 1: 0] a0, a1, a2, b0, b1, b2;
    clock_divider clocky (.in_clk(system_clock),
                          .rst(rst),
                          .out_clk(sample_clock));
    
    envelope_analyzer env (.sample_in(sample_in),
                           .sample_clock(sample_clock),
                           .rst(rst),
                           .out_sample(env_average));
    
    cutoff_freq_unit cutoff (.env_avg(env_average),
                             .filter_strength_ratio(filter_strength_ratio),
                             .digital_cutoff_freq(digital_cutoff_freq));
    coefficient_unit coeff (.clk(clk),
                            .sample_clock(sample_clock),
                            .reset(reset),
                            .start(start),
                            .digital_cutoff_freq(digital_cutoff_freq),
                            .ready(ready),
                            .b0(b0),
                            .b1(b1),
                            .b2(b2),
                            .a0(a0),
                            .a1(a1),
                            .a2(a2));

    filter_pipeline filt (.sample_clock(sample_clock),
                          .reset(reset),
                          .a0(a0),
                          .a1(a1),
                          .a2(a2),
                          .b0(b0),
                          .b1(b1),
                          .b2(b2),
                          .sample_in(sample_in),
                          .sample_out(filter_out));
    


endmodule
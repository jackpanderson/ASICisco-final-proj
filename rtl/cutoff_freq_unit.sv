module cutoff_freq_unit # (parameter SAMPLE_WIDTH = 24,
                           parameter FC_MAX = 1024, // Shifted right 16 bits, we got our max baby
                           parameter FC_MIN = 69) // (maybe should be 68 but sex!) 100Hz 16 bits of floating precision, 8b of integer
                        (input [SAMPLE_WIDTH - 1] env_avg,
                        input [3:0] filter_strength_ratio, // If zero, she shits and also dies
                        output [SAMPLE_WIDTH - 1] cutoff_freq)


    logic [SAMPLE_WIDTH - 1 : 0] shifted_input;
    logic [SAMPLE_WIDTH - 1] control_calc;
    
    assign control_calc = filter_strength_ratio * 32'd4096;

    assign shifted_input = env_avg >> 8; 
    assign cutoff_freq = shifted_input * control_calc * FC_MAX;

endmodule
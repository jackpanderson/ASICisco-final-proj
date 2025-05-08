module cutoff_freq_unit #(
    parameter SAMPLE_WIDTH = 24,
    parameter FC_MAX = 1024, 
    parameter FC_MIN = 69,
    parameter TYPICAL_ENV = 1_000_000  // More appropriate for 24-bit range
)(
    input [SAMPLE_WIDTH-1:0] env_avg,
    input [3:0] filter_strength_ratio,
    output logic [SAMPLE_WIDTH-1:0] cutoff_freq
);
    localparam FC_RANGE = FC_MAX - FC_MIN;
    
    // Normalize to 0.0-1.0 range (Q16 fixed point)
    wire [31:0] env_scaled = (env_avg < TYPICAL_ENV) ? 
                           (env_avg * 65536 / TYPICAL_ENV) :
                           65536;  // Cap at 1.0
    
    // Apply control (1-15 → 0.1-1.0)
    wire [31:0] controlled = (env_scaled * ({28'b0, filter_strength_ratio}+ 1)) / 16;
    
    // Calculate final frequency
    wire [31:0] freq_calc = FC_MIN + (controlled * FC_RANGE >> 16);
    
    always_comb begin
        if (filter_strength_ratio == 0) begin
            cutoff_freq = FC_MIN;
        end else begin
            cutoff_freq = (freq_calc > FC_MAX) ? FC_MAX : 
                         (freq_calc < FC_MIN) ? FC_MIN :
                         freq_calc[SAMPLE_WIDTH-1:0];
        end
    end
endmodule
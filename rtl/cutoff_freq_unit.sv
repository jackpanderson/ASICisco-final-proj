// module cutoff_freq_unit #(
//     parameter SAMPLE_WIDTH = 24,
//     parameter FC_MAX = 20000, 
//     parameter FC_MIN = 200,
//     parameter FC_MIN_DIGITAL = 24'h00035a, //200Hz -> converted to digital freq
//     parameter FC_MAX_DIGITAL = 24'h014f1a, //20kHz -> converted to digital freq

//     parameter TYPICAL_ENV = 1_000_000  // More appropriate for 24-bit range
// )(
//     input [SAMPLE_WIDTH-1:0] env_avg,
//     input [3:0] filter_strength_ratio,
//     output logic [SAMPLE_WIDTH-1:0] digital_cutoff_freq //Q8.16 fixed point
// );


//     localparam FC_RANGE = FC_MAX_DIGITAL - FC_MIN_DIGITAL;
    
//      // Normalize to 0.0-1.0 range (Q16 fixed point)
//      wire [31:0] env_scaled = (env_avg < TYPICAL_ENV) ? 
//                             (env_avg * 65536 / TYPICAL_ENV) :
//                             65536;  // Cap at 1.0
    
//     // Apply control (1-15 → 0.1-1.0)
//     wire [31:0] controlled = (env_scaled * ({28'b0, filter_strength_ratio} + 1)) / 16;
    
//     // Calculate final frequency
//     // wire [31:0] freq_calc = FC_MIN_DIGITAL + (controlled * FC_RANGE >> 16);
//     wire [31:0] freq_calc = {8'b0, FC_MIN_DIGITAL} + (controlled * FC_RANGE >> 16);
    
//     always_comb begin
//         if (filter_strength_ratio == 0) begin
//             digital_cutoff_freq = FC_MIN_DIGITAL;
//         end else begin
//             digital_cutoff_freq = (freq_calc > FC_MAX_DIGITAL) ? FC_MAX_DIGITAL : 
//                          (freq_calc < FC_MIN_DIGITAL) ? FC_MIN_DIGITAL :
//                          freq_calc[SAMPLE_WIDTH-1:0];
//         end
//     end


// endmodule\

module cutoff_freq_unit #(
    parameter SAMPLE_WIDTH = 24,
    parameter FC_MAX = 20000, 
    parameter FC_MIN = 200,
    parameter FC_MIN_DIGITAL = 24'h00035a, // 200Hz
    parameter FC_MAX_DIGITAL = 24'h014f1a, // 20kHz
    parameter TYPICAL_ENV = 1_000_000
)(
    input [SAMPLE_WIDTH-1:0] env_avg,
    input [3:0] filter_strength_ratio,
    output logic [SAMPLE_WIDTH-1:0] digital_cutoff_freq
);

    localparam FC_RANGE = FC_MAX_DIGITAL - FC_MIN_DIGITAL;
    
    // Improved envelope scaling with better dynamic range
    wire [31:0] env_scaled = (env_avg * 65536) / TYPICAL_ENV;
    
    // Apply non-linear mapping for better sensitivity
    wire [31:0] env_mapped = (env_scaled * env_scaled) / 65536; // Quadratic response
    
    // Enhanced control scaling (1-15 → 0.1-1.5)
    wire [31:0] controlled = (env_mapped * ({28'b0, filter_strength_ratio} + 10)) / 16;
    
    // Calculate final frequency with full range utilization
    wire [31:0] freq_calc = {8'b0, FC_MIN_DIGITAL} + 
                           ((controlled * FC_RANGE) >> 16);
    
    always_comb begin
        if (filter_strength_ratio == 0) begin
            digital_cutoff_freq = FC_MIN_DIGITAL;
        end else begin
            digital_cutoff_freq = (freq_calc > FC_MAX_DIGITAL) ? FC_MAX_DIGITAL : 
                                (freq_calc < FC_MIN_DIGITAL) ? FC_MIN_DIGITAL :
                                freq_calc[SAMPLE_WIDTH-1:0];
        end
    end

endmodule
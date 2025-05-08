module coefficient_unit #(
    parameter SAMPLE_WIDTH = 24,
    parameter FC_MAX = 1024,
    parameter FC_MIN = 69
)(
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic [SAMPLE_WIDTH-1:0] cutoff_freq,
    output logic ready,
    output logic signed [SAMPLE_WIDTH-1:0] b0,  // Q8.16
    output logic signed [SAMPLE_WIDTH-1:0] b1,  // Q8.16
    output logic signed [SAMPLE_WIDTH-1:0] b2,  // Q8.16
    output logic signed [SAMPLE_WIDTH-1:0] a1,  // Q8.16
    output logic signed [SAMPLE_WIDTH-1:0] a2   // Q8.16
);

    // Constants for Q8.16 scaling
    localparam Q16 = 65536;  // 2^16
    localparam MAX_A1 = 2 * Q16 - 1;  // +2.0 in Q8.16
    localparam MIN_A1 = -2 * Q16;     // -2.0 in Q8.16

    // CORDIC outputs (Q1.23 format)
    logic signed [23:0] sin_out, cos_out;
    logic cordic_ready;

    // Angle scaling (0 to π mapped to 0 to 2^24-1)
    logic [23:0] angle_scaled = (cutoff_freq * 24'sh800000) / FC_MAX;

    cordic_sin_cos #(.ITERATIONS(16)) cordic (
        .clk(clk),
        .reset(reset),
        .start(start),
        .angle_in(angle_scaled),
        .ready(cordic_ready),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );

    // Coefficient calculation - PROPERLY SCALED FOR Q8.16
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            {b0, b1, b2, a1, a2} <= '0;
            ready <= 0;
        end
        else if (cordic_ready) begin
            // Bandpass coefficients (example)
            b0 <= (sin_out >>> 7);  // Q1.23 -> Q8.16 (/128)
            b1 <= 0;
            b2 <= -b0;
            
            // a1 = -2*r*cos(w) - MUST BE BETWEEN -2.0 and 2.0 in Q8.16
            a1 <= (-cos_out << 1);  // Q1.23 -> Q8.16 (*2)
            
            // a2 = r^2 (where r < 1.0)
            a2 <= (cos_out >>> 9);  // Q1.23 -> Q8.16 (/512)
            
            ready <= 1;
        end
        else begin
            ready <= 0;
        end
    end

    // Range checking assertions (for simulation)
    always @(posedge clk) begin
        if (ready) begin
            if (a1 > MAX_A1 || a1 < MIN_A1) begin
                $error("a1 out of range! Value: %0d", a1);
            end
            if (a2 > Q16-1 || a2 < -Q16) begin
                $error("a2 out of range! Value: %0d", a2);
            end
        end
    end
endmodule
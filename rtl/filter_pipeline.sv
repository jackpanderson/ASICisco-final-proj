module filter_pipeline #(
    parameter SAMPLE_WIDTH = 24
)(
    input  logic                  sample_clock,
    input  logic                  reset,
    input  logic signed [23:0]    a0, a1, a2,
    input  logic signed [23:0]    b0, b1, b2,
    input  logic        [23:0]    sample_in,
    output logic signed [23:0]    sample_out
);

    // Registers to store past samples (inputs and outputs)
    logic signed [23:0] x1, x2;  // Previous inputs
    logic signed [23:0] y1, y2;  // Previous outputs

    // Intermediate results (48-bit because 24 x 24 = 48)
    logic signed [47:0] acc;
    logic signed [47:0] mul_b0, mul_b1, mul_b2;
    logic signed [47:0] mul_a1, mul_a2;

    // Sign-extend input sample
    logic signed [23:0] sample_in_signed;
    assign sample_in_signed = $signed(sample_in);

    // Combinational filter equation
    always_comb begin
        // Multiply input terms
        mul_b0 = sample_in_signed * b0;
        mul_b1 = x1 * b1;
        mul_b2 = x2 * b2;

        // Multiply feedback terms (note: subtracted in DF2 structure)
        mul_a1 = y1 * a1;
        mul_a2 = y2 * a2;

        // Compute full accumulator: b0*x[n] + b1*x[n-1] + b2*x[n-2] - a1*y[n-1] - a2*y[n-2]
        acc = mul_b0 + mul_b1 + mul_b2 - mul_a1 - mul_a2;

        // Apply gain a0 and scale back down from Q8.16
        acc = (acc * a0) >>> 16;

        // Truncate result to 24-bit output (signed)
        sample_out = acc[39:16];  // Take middle 24 bits
    end

    // Sequential pipeline: update state
    always_ff @(posedge sample_clock or posedge reset) begin
        if (reset) begin
            x1 <= 0;
            x2 <= 0;
            y1 <= 0;
            y2 <= 0;
        end else begin
            x2 <= x1;
            x1 <= sample_in_signed;
            y2 <= y1;
            y1 <= sample_out;
        end
    end

endmodule

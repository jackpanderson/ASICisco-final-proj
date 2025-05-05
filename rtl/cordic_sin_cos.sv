// TEST THIS!! THIS IS CHAT


module cordic_sincos #(
    parameter integer ITERATIONS = 16,     // Number of CORDIC iterations
    parameter integer DATA_WIDTH = 32      // Fixed-point width (Q1.31 suggested)
)(
    input  logic signed [DATA_WIDTH-1:0] angle, // Input angle in radians (Q1.31, scaled to ±π/2)
    input  logic clk,
    input  logic rst,
    input  logic start,                      // Start signal
    output logic done,                       // Done signal
    output logic signed [DATA_WIDTH-1:0] sin_out,
    output logic signed [DATA_WIDTH-1:0] cos_out
);

    // === Internal Constants ===
    // Arctangent lookup table (in Q1.31 format)
    logic signed [DATA_WIDTH-1:0] atan_table[0:ITERATIONS-1];

    initial begin
        integer i;
        for (i = 0; i < ITERATIONS; i = i + 1) begin
            atan_table[i] = $rtoi($atan(1.0 / (1 << i)) * (1 << 31) / $acos(-1)); // π radians = 2^31
        end
    end

    // CORDIC gain compensation constant in Q1.31 (precomputed or constant)
    localparam signed [DATA_WIDTH-1:0] CORDIC_GAIN = 32'sd1304381788; // ≈ 0.60725293 * 2^31

    // === Registers ===
    logic [4:0] i;
    logic signed [DATA_WIDTH-1:0] x, y, z;
    logic running;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            i <= 0;
            x <= 0;
            y <= 0;
            z <= 0;
            running <= 0;
            done <= 0;
        end else begin
            if (start && !running) begin
                // Initialize vector (CORDIC_GAIN, 0), rotate by angle
                x <= CORDIC_GAIN;
                y <= 0;
                z <= angle;
                i <= 0;
                running <= 1;
                done <= 0;
            end else if (running) begin
                logic signed [DATA_WIDTH-1:0] x_shift, y_shift;

                x_shift = x >>> i;
                y_shift = y >>> i;

                if (z >= 0) begin
                    x <= x - y_shift;
                    y <= y + x_shift;
                    z <= z - atan_table[i];
                end else begin
                    x <= x + y_shift;
                    y <= y - x_shift;
                    z <= z + atan_table[i];
                end

                i <= i + 1;

                if (i == ITERATIONS - 1) begin
                    running <= 0;
                    done <= 1;
                end
            end else begin
                done <= 0;
            end
        end
    end

    // Output results
    assign cos_out = x;
    assign sin_out = y;

endmodule

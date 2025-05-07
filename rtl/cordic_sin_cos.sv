// Module takes in an angle in radians in Q8.16 fixed point form, outputs sin and cosine of that angle in ~16 cycles

module cordic_sin_cos #(
    parameter logic [4:0] ITERATIONS = 5'd16
)(
    input  logic             clk, //Main system clock
    input  logic             reset, //Active high reset
    input  logic             start, // Indicates a request to start calculation
    input  logic signed [23:0] angle_in, // Q8.16
    output logic             ready,  // output high when sin/cos output is ready
    output logic signed [23:0] sin_out,  // Q8.16
    output logic signed [23:0] cos_out   // Q8.16
);

    localparam logic [23:0] CORDIC_GAIN = 24'h0009B74; // ≈ 0.60725293 in Q8.16

    logic signed [23:0] atan_table [0:15];
    initial begin
        atan_table[ 0] = 24'h0000C90F; //Store all of the needed arctans for CORDIC calculation
        atan_table[ 1] = 24'h000076B1;
        atan_table[ 2] = 24'h00003EB6;
        atan_table[ 3] = 24'h00001FD5;
        atan_table[ 4] = 24'h000010FB;
        atan_table[ 5] = 24'h00000821;
        atan_table[ 6] = 24'h00000410;
        atan_table[ 7] = 24'h00000208;
        atan_table[ 8] = 24'h00000104;
        atan_table[ 9] = 24'h00000082;
        atan_table[10] = 24'h00000041;
        atan_table[11] = 24'h00000020;
        atan_table[12] = 24'h00000010;
        atan_table[13] = 24'h00000008;
        atan_table[14] = 24'h00000004;
        atan_table[15] = 24'h00000002;
    end

    typedef enum logic [1:0] {
        IDLE, ROTATE, DONE //3 states, waiting for input, doing the CORDIC thing, or done
    } state_t;

    state_t state;
    logic [4:0] i; // index for arctan table

    logic signed [23:0] x, y, z; 
    logic signed [23:0] x_new, y_new, z_new;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            i <= 0;
            x <= 0;
            y <= 0;
            z <= 0;
            ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    if (start) begin
                        x <= CORDIC_GAIN;
                        y <= 0;
                        z <= angle_in;
                        i <= 0;
                        state <= ROTATE;
                    end
                end

                ROTATE: begin
                    cos_out <= 0;
                    sin_out <= 0;
                    if (i < ITERATIONS) begin
                        if (z[23] == 0) begin
                            x_new = x - (y >>> i);
                            y_new = y + (x >>> i);
                            z_new = z - atan_table[i[3:0]];
                        end else begin
                            x_new = x + (y >>> i);
                            y_new = y - (x >>> i);
                            z_new = z + atan_table[i[3:0]];
                        end
                        x <= x_new;
                        y <= y_new;
                        z <= z_new;
                        i <= i + 1;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    cos_out <= x;
                    sin_out <= y;
                    ready <= 1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

module coefficient_unit #(
    parameter SAMPLE_WIDTH = 24,
    //parameter FC_MAX = 1024, //
    //parameter FC_MIN = 69, //0.00052083333
    parameter LOWPASS_Q_FACTOR = 1,
    parameter logic signed [23:0] ONE_IN_FIXED_POINT = 010000,
    parameter F_SAMP = 96000
)(
    input  clk,
    input sample_clock,
    input  logic reset,
    input  logic start,
    input  logic [SAMPLE_WIDTH-1:0] digital_cutoff_freq,
    output logic ready,
    output logic signed [SAMPLE_WIDTH - 1:0] b0,  // Q8.16
    output logic signed [SAMPLE_WIDTH - 1:0] b1,  // Q8.16
    output logic signed [SAMPLE_WIDTH - 1:0] b2,  // Q8.16
    output logic signed [SAMPLE_WIDTH - 1:0] a0,  // Q8.16
    output logic signed [SAMPLE_WIDTH - 1:0] a1,  // Q8.16
    output logic signed [SAMPLE_WIDTH - 1:0] a2   // Q8.16
);

    logic signed [25:0] b_temp;  // or 31:0 for safety

    typedef enum logic [1:0] {
    IDLE,       // 2'b00
    TRIG_CALC,       // 2'b01
    COEFF_CALC      // 2'b10
    } state_t;

    state_t curr_state;

    // Constants for Q8.16 scaling
    localparam Q16 = 65536;  // 2^16
    localparam MAX_A1 = 2 * Q16 - 1;  // +2.0 in Q8.16
    localparam MIN_A1 = -2 * Q16;     // -2.0 in Q8.16

    // CORDIC outputs (Q1.23 format)
    logic signed [23:0] sin_out, cos_out, alpha;
    logic cordic_ready, cordic_start;

    assign alpha = -(sin_out <<< 1);

   

    // Angle scaling (0 to π mapped to 0 to 2^24-1)
    // logic [23:0] angle_scaled = (cutoff_freq * 24'sh800000) / FC_MAX;

    cordic_sin_cos #(.ITERATIONS(16)) cordic (
        .clk(clk),
        .reset(reset),
        .start(cordic_start),
        .angle_in(digital_cutoff_freq),
        .ready(cordic_ready),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );

    /////TESTING

    // Define a minimum pole radius (e.g., 0.99 instead of 1.0)
//localparam logic [23:0] POLE_RADIUS_LIMIT = 24'h7F0000; // Q8.16 value ~0.996 (experimentally adjust)

// Limit alpha to enforce stability
// Define pole radius limit in signed Q8.16 (e.g., 0.99 = 24'h7F0000)
localparam logic signed [23:0] POLE_RADIUS_LIMIT = 24'h7F0000; // ~0.996 in Q8.16

// // Signed comparison to clamp alpha
// logic signed [23:0] alpha_limited;
// assign alpha_limited = 
//     (alpha > POLE_RADIUS_LIMIT)  ? POLE_RADIUS_LIMIT :
//     (alpha < -POLE_RADIUS_LIMIT) ? -POLE_RADIUS_LIMIT :
//     alpha;


    //END



    // Coefficient calculation - PROPERLY SCALED FOR Q8.16
    always_ff @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            a0 <= 0;
            a1 <= 0;
            a2 <= 0;
            b0 <= 0;
            b1 <= 0;
            b2 <= 0;
            curr_state <= IDLE;
            ready <= 0;
        end
        else 
        begin
            case (curr_state)
            IDLE: 
            begin
                if (start) 
                begin
                    cordic_start <= 1;
                    curr_state <= TRIG_CALC;
                    ready <= 1'b0;
                end
                else 
                begin
                    ready <= 1'b1;
                end
            end
            
            TRIG_CALC: 
            begin
                if (cordic_ready)
                begin
                    curr_state <= COEFF_CALC;
                end
            end
            COEFF_CALC: 
            begin
                b0 <= (ONE_IN_FIXED_POINT - cos_out) >>> 1;
                b1 <= -(ONE_IN_FIXED_POINT - cos_out);
                b2 <= (ONE_IN_FIXED_POINT - cos_out) >>> 1;
                a0 <= ONE_IN_FIXED_POINT + alpha;
                a1 <= -(cos_out <<< 1);
                a2 <= ONE_IN_FIXED_POINT - alpha;
                curr_state <= IDLE;
            end
            // DONE: 
            // begin
            //     done <= 1'b0;
            //     if ()
            // end
            default:
            begin
                b0 <= 0;
                b1 <= 0;
                b2 <= 0;
                a0 <= 0;
                a1 <= 0;
                a2 <= 0;
                ready <= 0;
                curr_state <= IDLE;
            end
            endcase
        end

    end
endmodule
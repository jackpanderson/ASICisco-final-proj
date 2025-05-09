module filter_pipeline #(
    parameter SAMPLE_WIDTH = 24)
    (input sample_clock,
     input reset,
    input [SAMPLE_WIDTH - 1:0]a0,  //Invert these bitch! :)
     input [SAMPLE_WIDTH - 1:0]a1,
     input [SAMPLE_WIDTH - 1:0]a2,
     input [SAMPLE_WIDTH - 1:0]b0,
     input [SAMPLE_WIDTH - 1:0]b1,
     input [SAMPLE_WIDTH - 1:0]b2,
     input [SAMPLE_WIDTH - 1:0] sample_in,
     output [SAMPLE_WIDTH - 1:0] sample_out)
    
// y[n] = b[0]x[n] + b[1]x[n-1] + ... + b[N]x[n-N] - a[1]y[n-1] - a[2]y[n-2]
logic [SAMPLE_WIDTH - 1 : 0] aNeg1, aNeg2, bNeg1, bNeg2; //aNeg* = *th previous output, bNeg* = *th previous input

always_comb 
begin
    assign sample_out = a0 * (b0 * sample_in + b1 * bNeg1 + b2 * bNeg2 + aNeg1 * a1 + aNeg2 * a2);
end

always_ff @ (posedge sample_clock, posedge reset)
begin
    if (reset)
    begin
        aNeg1 <= 0;
        aNeg2 <= 0;
        bNeg1 <= 0;
        bNeg2 <= 0;
        sample_out <= 0;
    end

    else 
    begin
        aNeg2 <= aNeg1;
        aNeg1 <= sample_out;
        bNeg2 <= bNeg1;
        bNeg1 <= sample_in;
    end

end


endmodule
module envelope_analyzer #(parameter SAMPLE_WIDTH = 24) 
                         (input [SAMPLE_WIDTH - 1 : 0] sample_in,
                          input sample_clock, //96KHz
                          input rst,       //ACtive HIGH!!!11!!!!!1!!1
                          output [SAMPLE_WIDTH - 1:0]  out_sample)

    logic [SAMPLE_WIDTH - 1 : 0] prev_samples [7:0]; 
    logic [SAMPLE_WIDTH - 1 + 3] aCUMulator;

    always_comb 
    begin
        assign aCUMulator = prev_samples[0] +
                            prev_samples[1] + 
                            prev_samples[2] +
                            prev_samples[3] + 
                            prev_samples[4] +
                            prev_samples[5] +
                            prev_samples[6] +
                            prev_samples[7];
        assign out_sample = (aCUMulator >> 3)[SAMPLE_WIDTH -1:0];   
    end

    always_ff (@ posedge sample_clock, posedge rst) 
    begin
        if (rst) 
        begin
            prev_samples[0] <= 0;
            prev_samples[1] <= 0;
            prev_samples[2] <= 0;
            prev_samples[3] <= 0;
            prev_samples[4] <= 0;
            prev_samples[5] <= 0;
            prev_samples[6] <= 0;
            prev_samples[7] <= 0;
            aCUMulator <= 0;
        end

        else 
        begin
            prev_samples[0] <= sample_in;
            prev_samples[1] <= prev_samples[0];
            prev_samples[2] <= prev_samples[1];
            prev_samples[3] <= prev_samples[2];
            prev_samples[4] <= prev_samples[3];
            prev_samples[5] <= prev_samples[4];
            prev_samples[6] <= prev_samples[5];
            prev_samples[7] <= prev_samples[6];
        end
    end

endmodule
module envelope_analyzer #(parameter SAMPLE_WIDTH = 24) 
                         (input [SAMPLE_WIDTH - 1 : 0] sample_in,
                          input sample_clock, //96KHz
                          input rst,       //ACtive HIGH!!!11!!!!!1!!1
                          output reg [SAMPLE_WIDTH - 1:0]  out_sample);

    logic [SAMPLE_WIDTH - 1 : 0] prev_samples [7:0]; 
    logic [SAMPLE_WIDTH - 1 + 3 : 0] aCUMulator, shift_acum;

    always_comb 
    begin
         aCUMulator = {3'b0, prev_samples[0]} +
                            {3'b0, prev_samples[1]} +
                            {3'b0, prev_samples[2]} +
                            {3'b0, prev_samples[3]} +
                            {3'b0, prev_samples[4]} +
                            {3'b0, prev_samples[5]} +
                            {3'b0, prev_samples[6]} +
                            {3'b0, prev_samples[7]};
                            
         shift_acum = aCUMulator >> 3;
         out_sample = shift_acum[SAMPLE_WIDTH - 1:0];   
    end

    // always_ff @ (posedge sample_clock, posedge rst) 
    always_ff @ (posedge sample_clock) 
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
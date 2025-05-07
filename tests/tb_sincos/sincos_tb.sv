`timescale 1ns/1ps

module sincos_tb;

    logic clk;
    logic reset;
    initial clk = 0;
    always #5 clk = ~clk;

    logic start;
    logic signed [23:0] angle_in;
    logic ready;
    logic signed [23:0] sin_out;
    logic signed [23:0] cos_out;

    cordic_sin_cos dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .angle_in(angle_in),
        .ready(ready),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );

    function real q8_16_to_real(input logic signed [23:0] val);
        return val / 65536.0;
    endfunction

    task apply_angle(input logic signed [23:0] angle);
        @(posedge clk);
        start = 1;
        angle_in = angle;
        @(posedge clk);
        start = 0;
        wait (ready == 1);
        $display("Angle: %f rad | sin: %f | cos: %f",
            q8_16_to_real(angle),
            q8_16_to_real(sin_out),
            q8_16_to_real(cos_out));
    endtask

    initial 
    begin
        $dumpfile("waveform.vcd");  // Name of the dump file
        $dumpvars(0, cordic_sincos_tb);  // Dump all variables in this module and below

    end

    initial begin
        reset = 1;
        start = 0;
        angle_in = 0;
        @(posedge clk);
        reset = 0;
        repeat (2) @(posedge clk);

        apply_angle(24'sd0);             // 0
        apply_angle(24'h0000C90F);       // π/4
        apply_angle(24'h0001921F);       // π/2
        apply_angle(24'h0003243F);       // π
        apply_angle(-24'sd0 - 24'h0000C90F); // -π/4
        apply_angle(-24'sd0 - 24'h0001921F); // -π/2

        #20 $finish;
    end

endmodule

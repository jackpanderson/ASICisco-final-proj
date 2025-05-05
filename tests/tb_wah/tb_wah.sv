`timescale 1ns / 1ps

module wah_tb;

    // Parameters
    localparam SAMPLE_WIDTH = 24;
    localparam CLK_PERIOD = 10.42; // 96MHz clock → ~10.42 ns

    // DUT signals
    logic [SAMPLE_WIDTH-1:0] sample_in;
    logic system_clock;
    logic rst;
    logic [3:0] filter_strength_ratio;
    logic [SAMPLE_WIDTH-1:0] filter_out;

    // Instantiate Device Under Test
    wah #(.SAMPLE_WIDTH(SAMPLE_WIDTH)) dut (
        .sample_in(sample_in),
        .system_clock(system_clock),
        .rst(rst),
        .filter_strength_ratio(filter_strength_ratio),
        .filter_out(filter_out)
    );

    initial begin
    $dumpfile("waveform.vcd");   // Name of your VCD file
    $dumpvars(0, wah_tb);        // Dump everything in wah_tb hierarchy
    end

    // Clock generation (96 MHz)
    always begin
        system_clock = 0;
        #(CLK_PERIOD/2);
        system_clock = 1;
        #(CLK_PERIOD/2);
    end

    // Stimulus
    initial begin
        // Init values
        rst = 1;
        sample_in = 0;
        filter_strength_ratio = 4'd8;

        // Wait some cycles with reset asserted
        #100;
        rst = 0;

        // Simple input waveform
        repeat (100) begin
            sample_in = sample_in + 24'd1000;
            #10417; // ~1 sample per 96kHz → ~10.417 us
        end

        $finish;
    end

    // Optional: monitor output
    initial begin
        $display("Time\tSample\tFilterOut");
        $monitor("%0t\t%0d\t%0d", $time, sample_in, filter_out);
    end

endmodule

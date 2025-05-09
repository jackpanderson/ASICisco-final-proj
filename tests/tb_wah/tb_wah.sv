module tb_wah;
    parameter SAMPLE_WIDTH = 24;
    parameter CLK_PERIOD = 10.417; // 96 MHz -> 10.417 ns

    logic [SAMPLE_WIDTH-1:0] sample_in;
    logic system_clock = 0;
    logic rst = 1;
    logic [3:0] filter_strength_ratio = 4'd4;
    logic [SAMPLE_WIDTH-1:0] filter_out;
    logic ready_out;

    // Instantiate DUT
    wah dut (
        .sample_in(sample_in),
        .system_clock(system_clock),
        .rst(rst),
        .filter_strength_ratio(filter_strength_ratio),
        .filter_out(filter_out),
        .ready_out(ready_out)
    );

    // Generate 96 MHz clock
    always #(CLK_PERIOD/2) system_clock = ~system_clock;

    // Sample memory
    logic [SAMPLE_WIDTH-1:0] sample_mem [0:99999]; // Load up to 100k samples
    int idx = 0;

    // Load samples
    initial begin
        $readmemh("wav_data.hex", sample_mem);
        $dumpfile("waveform.vcd");  // Name of the dump file
        $dumpvars(0, cordic_sincos_tb);  // Dump all variables in this module and below
    end

    // Stimulus
    initial begin
        rst = 1;
        repeat(10) @(posedge system_clock);
        rst = 0;


        forever begin
            @(posedge dut.sample_clock);
            sample_in = sample_mem[idx];
            idx++;
        end
    end

    // Optional: Save output to file
    integer f;
    initial begin
        f = $fopen("filtered_output.hex", "w");
        forever begin
            @(posedge dut.sample_clock);
            if (ready_out) begin
                $fwrite(f, "%06x\n", filter_out);
            end
        end
    end

endmodule

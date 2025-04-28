localparam int OUT_THICKNESS = 180; //Need like 180 bits to store 255th fib num
`timescale 1ps/1ps
module tb_fib;

// Input vars
logic clk = 0;
logic rst_n, vld_in, rdy_out;
logic [7:0] fib_in;

// Output vars
// logic [31:0] fib_out;
logic [OUT_THICKNESS - 1:0] fib_out;
logic rdy_in, vld_out;




// Instantiate Design 
fib #(.FIB_OUT_WIDTH(OUT_THICKNESS)) Fib (.*);

// Sample to drive clock
localparam CLK_PERIOD = 10;
always begin
    #(CLK_PERIOD/2) 
    clk<=~clk;
end

// Necessary to create Waveform
initial begin
    // Name as needed
    $dumpfile("tb_fib.vcd");
    $dumpvars(0);
end

always begin
    // Test Goes Here
    rst_n <= 0; //reset system
    #10 // wait
    rst_n <= 1; //Init reset
    #10

    for (logic [8:0] i = 0; i < 256; i++) // Loop thru everything 0-255
    begin
        testFib(i[7:0]); //Run task
        wait(rdy_in); //Wait for output to be valid
    end
    
    $finish();
end

function logic [OUT_THICKNESS-1:0] fib(input logic [7:0] fib_in);
    // I was too 349 Siu-brained, just did it linearly lmao
    logic [OUT_THICKNESS - 1:0] onePrev, twoPrev, temp;
    logic [8:0] i, thiccFib;
    thiccFib = {1'b0, fib_in}; //Prevents overflow in the loop

    if (fib_in == 0)
        return 0;

    else if (fib_in == 1)
        return 1;

    else 
    begin
        onePrev = 0;
        twoPrev = 1;

        for (i = 2; i <= thiccFib; i++) 
        begin
            temp = onePrev + twoPrev;
            onePrev = twoPrev;
            twoPrev = temp;
        end

        return twoPrev;
    end
endfunction



task testFib(input logic [7:0] inFib);
    //rdy_out <= 0;
    fib_in <= inFib; //Update fib_in

    #10            // wait a cycle...
    vld_in <= 1'b1;  // Assert that fib_in is valid
    @ (negedge rdy_in)
    vld_in <= 0; 
    @ (posedge vld_out) //Wait for output to be valud
    assert (fib_out == fib(inFib)) else $error("Failed. fib_out is %d, should be %d", fib_out, fib(inFib));
    #10 //Wait a cycle before reading, allow state transition
    rdy_out <= 1; //"read output"
    #10       // Allow cycle for state transition,
    rdy_out <= 0; // "Stop reading output"
    #10;

  endtask

endmodule



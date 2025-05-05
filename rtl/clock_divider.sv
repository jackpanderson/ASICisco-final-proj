module clock_divider (input in_clk,
                      input rst,
                      output out_clk)
[9:0] logic counter;

always_ff (@ posedge in_clk, @ posedge rst)
begin
    if (rst)
        counter <= 0;
        out_clk <= 0;
    else
    begin
        counter <= counter + 1;
    end
    
    if (counter == 500)
    begin
        out_clk <= ~out_clk;
    end
end

endmodule
module clock_divider (input in_clk,
                      input rst,
                      output reg out_clk);
logic [8:0] counter;

always_ff @(posedge in_clk, posedge rst)
begin
    if (rst)
    begin
        counter <= 0;
        out_clk <= 0;
    end
    else
    begin
        counter <= counter + 1;
    end
    
    if (counter == 500)
    begin
        counter <= 0;
        out_clk <= ~out_clk;
    end
end

endmodule
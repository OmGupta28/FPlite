module tb_ds;

logic clk;
logic reset;
logic enable;
logic [23 : 0] A;
logic [7 : 0] expo;

decimal_shifter dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    enable = 0;
    A = 24'b0;
    repeat(2)@(posedge clk);
    reset = 0;

    enable = 1;
    A = 24'h1ACB_FF;
    @(posedge clk);
    enable = 0;

    repeat(5)@(posedge clk);

    enable = 1;
    A = 24'h01CB_FF;
    @(posedge clk);
    enable = 0;

    repeat(12)@(posedge clk);
    $finish;
end

endmodule
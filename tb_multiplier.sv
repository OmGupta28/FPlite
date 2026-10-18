module tb_multiplier;

logic clk;
logic reset;
logic enable;
logic [31 : 0] A;
logic [31 : 0] B;
logic [31 : 0] Result;

multiplier dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    enable = 0;
    A = 32'b0;
    B = 32'b0;
    repeat(2)@(posedge clk);
    reset = 0;

    A = 32'b0_0100_1100_10101111111111110011001;
    B = 32'b0_0100_0011_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b0_0111_1100_11101111111111110011000;
    B = 32'b0_0101_0011_11101100001110110001000;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b0_1101_1101_10101111111111110011001;
    B = 32'b0_1110_0000_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b0_0000_0000_10101111111111110011001;
    B = 32'b0_0000_0000_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b0_1101_1101_10101111110001110011001;
    B = 32'b0_1101_1101_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b1_1101_1101_10101111110001110011001;
    B = 32'b0_1101_1101_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b0_1101_1101_10101111111111110011001;
    B = 32'b1_1110_0000_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;

    repeat(10)@(posedge clk);

    A = 32'b1_1101_1101_10101111111111110011001;
    B = 32'b1_1110_0000_10101100001110110001001;
    repeat(2)@(posedge clk);
    enable = 1;
    @(posedge clk);
    enable = 0;


    repeat(10)@(posedge clk);
    $finish;
end

endmodule
module decimal_shifter (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [23 : 0] A,
    output logic [7 : 0] expo
);

typedef enum logic [2 : 0] {
    IDLE       = 3'b000,
    COMPUTE    = 3'b001,
    RES        = 3'b100
} state_t;

state_t state_curr;

logic [4 : 0] expo_counter;
logic [23 : 0] A_reg;

always_ff @(posedge clk) begin
    if (reset) begin
        expo <= 8'b0;
        state_curr <= IDLE;
        expo_counter <= 5'd23;
        A_reg <= 24'b0;
    end
    else begin
        case (state_curr)
            IDLE: begin
                if (enable) begin
                    A_reg <= A;
                    state_curr <= COMPUTE;
                    expo_counter <= 5'd23;
                end
            end
            COMPUTE: begin
                if ((1 ^ A[expo_counter]) == 0) begin
                    state_curr <= RES;
                    expo_counter <= 5'd23;
                end
                else begin
                    expo <= expo + 1;
                    expo_counter <= expo_counter - 1;
                end
            end
            RES: begin
                expo <= 8'b0;
                state_curr <= IDLE;
            end 
            default: state_curr <= IDLE;
        endcase
    end
end
endmodule
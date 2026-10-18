module multiplier (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [31 : 0] A,
    input logic [31 : 0] B,
    output logic [31 : 0] Result
);

logic sign_val_a;
logic [7 : 0] exponent_a; // E' 
// E = E' - 127
logic [23 : 0] significand_a;

logic sign_val_b;
logic [7 : 0] exponent_b; // E' 
// E = E' - 127
logic [23 : 0] significand_b;

logic [7 : 0] shift_counter;

logic [48 : 0] intermediate_result;
logic sticky;
logic guard;

logic [7 : 0] debug_expo;

assign debug_expo = Result[30 : 23];

typedef enum logic [2 : 0] {
    IDLE       = 3'b000,
    CHECK      = 3'b001,
    MULTIPLY   = 3'b010,
    NORMALIZE  = 3'b011,
    ROUND      = 3'b100,
    RES        = 3'b101
} state_t;

state_t state_curr;

always_ff @(posedge clk) begin
    if (reset) begin
        Result <= 32'b0;
        sign_val_a <= 1'b0;
        exponent_a <= 8'b0;
        significand_a <= 24'b0;
        sign_val_b <= 1'b0;
        exponent_b <= 8'b0;
        significand_b <= 24'b0;
        intermediate_result <= 49'b0;
        sticky <= 1'b0;
        guard  <= 1'b0;
        state_curr <= IDLE;
    end
    else begin
        case (state_curr)
            IDLE: begin
                sign_val_a <= A[31];
                sign_val_b <= B[31];
                exponent_a <= A[30 : 23];
                exponent_b <= B[30 : 23];
                significand_a[22 : 0] <= A[22 : 0];
                significand_b[22 : 0] <= B[22 : 0]; 
                significand_a[23] <= 1'b0;
                significand_b[23] <= 1'b0;
                sticky <= 1'b0;
                guard  <= 1'b0;
                intermediate_result[48] <= 1'b0;
                if (enable) begin
                    state_curr <= CHECK;
                    Result <= 32'b0;
                end
            end
            CHECK:  begin
                if (exponent_a == 8'hFF || exponent_b == 8'hFF) begin
                    if (significand_a != 23'b0 || significand_b != 23'b0) begin
                        Result = 32'h0;
                        state_curr <= IDLE; 
                    end
                end
                else if ((exponent_a > 0 && exponent_a < 8'hFF) && (exponent_b > 0 && exponent_b < 8'hFF)) begin
                    significand_a[23] <= 1'b1;
                    significand_b[23] <= 1'b1;
                    state_curr <= MULTIPLY;
                end
                else if (exponent_a == 0 || exponent_b == 0) begin
                    if (exponent_a == 8'b0 && exponent_b != 8'b0) begin
                        significand_a[23] <= 1'b0;
                        significand_b[23] <= 1'b1;
                    end
                    else if (exponent_b == 8'b0 && exponent_a != 8'b0) begin
                        significand_a[23] <= 1'b1;
                        significand_b[23] <= 1'b0;
                    end
                    else if (exponent_a == 8'b0 && exponent_b == 8'b0) begin
                        significand_a[23] <= 1'b0;
                        significand_b[23] <= 1'b0;                        
                    end
                    state_curr <= MULTIPLY;
                end
            end
            MULTIPLY: begin
                Result[31] <= sign_val_a ^ sign_val_b;
                intermediate_result <= significand_a * significand_b;
                Result[30 : 23] <= exponent_a + exponent_b - 127;
                state_curr <= NORMALIZE;
            end
            NORMALIZE: begin
                if (intermediate_result[47]) begin
                    guard <= intermediate_result[0];
                    sticky <= intermediate_result[0]; //since only 1 right shift took place both will be the same
                    intermediate_result <= intermediate_result >> 1;
                    Result[30 : 23] <= Result[30 : 23] + 1;
                end
                state_curr <= ROUND;
            end
            ROUND: begin
                sticky <= sticky | intermediate_result[22 : 0] | guard;
                guard <= intermediate_result[22];
                state_curr <= RES;
                Result[22 : 0] <= intermediate_result[45 : 23];
            end
            RES: begin
                if (guard) begin
                    Result[22 : 0] <= Result[22 : 0] + 1;
                end
                state_curr <= IDLE;
            end 
            default: state_curr <= IDLE;
        endcase
    end
end
    
endmodule
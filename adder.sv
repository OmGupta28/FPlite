module adder (
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

logic [7 : 0] difference;
logic [7 : 0] shift_counter;

typedef enum logic [2 : 0] {
    IDLE       = 3'b000,
    CHECK      = 3'b001,
    ADD        = 3'b010,
    NORMALIZE  = 3'b011,
    RES        = 3'b100
} state_t;

state_t state_curr;

always_comb begin 
    if (state_curr == IDLE) begin
       difference = ((exponent_a - 127) < (exponent_b - 127)) ? ((exponent_b - 127) - (exponent_a - 127)) : ((exponent_a - 127) - (exponent_b - 127));  
    end
end

always_ff @(posedge clk) begin
    if (reset) begin
        Result <= 32'b0;
        sign_val_a <= 1'b0;
        exponent_a <= 8'b0;
        significand_a <= 24'b0;
        sign_val_b <= 1'b0;
        exponent_b <= 8'b0;
        significand_b <= 24'b0;
        shift_counter <= 8'b0;
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
                if (enable) begin
                    state_curr <= CHECK;
                end
                shift_counter <= difference;
                Result <= 32'b0;
            end
            CHECK: begin
                if (exponent_a == 8'hFF || exponent_b == 8'hFF) begin
                    if (significand_a != 23'b0 || significand_b != 23'b0) begin
                        Result = 32'h0;
                        state_curr <= IDLE; 
                    end
                end
                else if ((exponent_a > 0 && exponent_a < 8'hFF) && (exponent_b > 0 && exponent_b < 8'hFF)) begin
                    significand_a[23] <= 1'b1;
                    significand_b[23] <= 1'b1;
                    state_curr <= ADD;
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
                    state_curr <= ADD;
                end
            end
            ADD: begin
                if (shift_counter != 8'b0) begin
                   shift_counter <= shift_counter - 1; 
                    if ((exponent_a - 127) < (exponent_b - 127)) begin
                        significand_a <= significand_a >> 1;
                        exponent_a    <= exponent_a + 1;
                    end
                    else if ((exponent_b - 127) < (exponent_a - 127)) begin
                        significand_b <= significand_b >> 1;
                        exponent_b    <= exponent_b + 1;
                    end
                end
                else begin
                    Result <= significand_a + significand_b;
                    state_curr <= NORMALIZE;
                end
            end
            NORMALIZE: begin 
                if (Result[24]) begin //if 1 then carry was generated
                    Result <= Result << 1;
                    exponent_a <= exponent_a - 1; //both exponents will have the same value so it doesnt matter
                end
                state_curr <= RES;
            end
            RES: begin
                Result[30 : 23] <= exponent_a; 
                state_curr <= IDLE;
            end 
            default: state_curr <= IDLE;
        endcase
    end
end
endmodule
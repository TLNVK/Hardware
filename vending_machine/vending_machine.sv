
//Simple vending machine in systemverilog
module vending_machine (
    input  logic       clk,
    input  logic       reset,

    // money inputs
    input  logic       r_05,   // 5 rupees
    input  logic       r_10,     // 10 rupees
    input  logic       r_20,  // 20 rupees

    // item select inputs
    input  logic       selectB,  // 50 rupees
    input  logic       selectA,  // 25 rupees
    input  logic       selectC,  // 75 rupees

    // outputs
    output logic       dispenseA,
    output logic       dispenseB,
    output logic       dispenseC,
    output logic [7:0] change
);

    // item prices
    localparam PRICE_A = 8'd25;
    localparam PRICE_B = 8'd50;
    localparam PRICE_C = 8'd75;

    logic [7:0] credit;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            credit <= 0;
        end else begin
            if (r_05)  credit <= credit + 5;
            if (r_10)    credit <= credit + 10;
            if (r_25) credit <= credit + 25;
        end
    end

    // vending logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            dispenseA <= 0;
            dispenseB <= 0;
            dispenseC <= 0;
            change     <= 0;
        end else begin
            // default values 
            dispenseA <= 0;
            dispenseB <= 0;
            dispenseC <= 0;
            change     <= 0;

            // item A
            if (selectA && credit >= PRICE_A) begin
                dispenseA <= 1;
                change    <= credit - PRICE_A;
                credit    <= 0;
            end

            // item B
            else if (selectB && credit >= PRICE_B) begin
                dispenseB <= 1;
                change    <= credit - PRICE_B;
                credit    <= 0;
            end

            // item C
            else if (selectC && credit >= PRICE_C) begin
                dispenseC <= 1;
                change    <= credit - PRICE_C;
                credit    <= 0;
            end
        end
    end

endmodule

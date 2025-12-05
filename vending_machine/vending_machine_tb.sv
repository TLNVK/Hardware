`timescale 1ns/1ps

module tb_vending_machine;

    logic clk = 0;
    logic reset;

    logic r_05, r_10, r_20;
    logic selectA, selectB, selectC;

    logic dispenseA, dispenseB, dispenseC;
    logic [7:0] change;

    // DUT
    vending_machine dut (
        .clk(clk),
        .reset(reset),
        .r_05(r_05),
        .r_10(r_10),
        .r_20(r_20),
        .selectA(selectA),
        .selectB(selectB),
        .selectC(selectC),
        .dispenseA(dispenseA),
        .dispenseB(dispenseB),
        .dispenseC(dispenseC),
        .change(change)
    );

    // clock gen.
    always #5 clk = ~clk;

    // 1 = 5 rupees, 2 = 10 rupees, 3 = 20 rupees
    task automatic money_input(input int money_code);
        begin
            r_05 = 0;
            r_10 = 0;
            r_20 = 0;

            case (money_code)
                1: r_05  = 1;
                2: r_10    = 1;
                3: r_20 = 1;
                default: ; // ignore invalid vals
            endcase

            #10;

            // reset all coin inputs
            r_05 = 0;
            r_10 = 0;
            r_20 = 0;
        end
    endtask

    initial begin

        // initial vals.
        r_05 = 0; r_10 = 0; r_20 = 0;
        selectA = 0; selectB = 0; selectC = 0;

        reset = 1; #20;
        reset = 0; #10;

        money_input(3);
        #10 selectA = 1;
        #10 selectA = 0;
        #20;

        money_input(3);
        money_input(3);
        #10 selectB = 1;
        #10 selectB = 0;
        #20;

        // case 3
        money_input(3);
        money_input(3);
        money_input(3);
        #10 selectC = 1;
        #10 selectC = 0;
        #20;

        // case 4 (over paying)
        money_input(3);
        money_input(3);
        money_input(3);
        money_input(3);  
        #10 selectA = 1;  
        #10 selectA = 0;
        #20;

        $display("end of simulation");
        $finish;
    end

endmodule

module controller_tb;

    logic clk = 0;
    logic rst;
    logic [2:0] dest_floor;
    logic finish;

    // DUT
    controller dut (
        .clk(clk),
        .rst(rst),
        .dest_floor(dest_floor),
        .finish(finish)
    );

    // clock generator
    always #5 clk = ~clk; // 10ns period

    initial begin
        $display("simulation start");
        
        rst = 1;
        dest_floor = 0; 
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        // Move to floor 3
        dest_floor = 3;
        wait (finish);
        $display("Reached floor 3 at time %0t", $time);

        // Move to floor 1
        dest_floor = 1;
        wait (finish);
        $display("Reached floor 1 at time %0t", $time);

        // Move to floor 5
        dest_floor = 5;
        wait (finish);
        $display("Reached floor 5 at time %0t", $time);

        $display("end of simulation");
        $stop;
    end

endmodule

module uart_tx #(
    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 115200
)(
    input  logic clk,
    input  logic rst,
    input  logic [7:0] data_in,
    input  logic start,
    output logic tx,
    output logic busy
);

    localparam int CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] {
        IDLE, START, DATA, STOP
    } state_t;

    state_t state = IDLE;

    logic [7:0] data_reg;
    int bit_index = 0;
    int clk_count = 0;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;
            busy      <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        data_reg <= data_in;
                        state    <= START;
                        busy     <= 1'b1;
                        clk_count <= 0;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count++;
                    else begin
                        clk_count <= 0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count++;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7)
                            bit_index++;
                        else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count++;
                    else begin
                        clk_count <= 0;
                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule

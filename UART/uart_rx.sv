module uart_rx #(
    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 115200
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,
    output logic [7:0] data_out,
    output logic data_valid
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
            state      <= IDLE;
            data_valid <= 0;
            clk_count  <= 0;
            bit_index  <= 0;
        end else begin
            case (state)

                IDLE: begin
                    data_valid <= 0;
                    if (rx == 0) begin
                        state <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT/2)) begin
                        if (rx == 0) begin
                            clk_count <= 0;
                            state <= DATA;
                        end else
                            state <= IDLE;
                    end else
                        clk_count++;
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count++;
                    else begin
                        clk_count <= 0;
                        data_reg[bit_index] <= rx;
                        if (bit_index < 7)
                            bit_index++;
                        else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT-1)
                        clk_count++;
                    else begin
                        data_out <= data_reg;
                        data_valid <= 1;
                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule

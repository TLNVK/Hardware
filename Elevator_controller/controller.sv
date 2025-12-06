module controller (
    input logic clk, rst,
    input [2:0] dest_floor,
    output finish
);
    //10 clock cycles for each floor increment or decrement
    typedef enum logic[1:0] {stationary, up, down} states;

    typedef enum logic [2:0] {bottom = 0, first = 1, second = 2, third = 3, fourth = 4, fifth = 5} floors;

    
    typedef struct packed {
        states state;
        floors floor;
    } state_var;

    state_var current_state, next_state;
    logic [3:0] clocks, next_clocks;

    always_ff @(posedge clk) begin // state transition
        if(rst)begin
            current_state.state <= stationary;
            current_state.floor <= bottom;
            clocks <= 0;
        end
        else begin
            current_state <= next_state;
            clocks <= next_clocks;
        end
    end

    always_comb begin //next state calculation
        next_state = current_state;
        next_clocks = clocks;
        if(current_state.floor < dest_floor)begin
            if(clocks < 10)begin
                next_clocks = clocks + 1;
                next_state.state = up;
                next_state.floor = current_state.floor;
            end
            else if(clocks == 10)begin
                next_clocks = 0;
                next_state.state = up;
                next_state.floor = current_state.floor + 1;
            end
        end
        else if(current_state.floor > dest_floor)begin
            if(clocks < 10)begin
                next_clocks = clocks + 1;
                next_state.state = down;
                next_state.floor = current_state.floor;
            end
            else if(clocks == 10)begin
                next_clocks = 0;
                next_state.state = down;
                next_state.floor = current_state.floor - 1;
            end
        end
        else begin
            next_state.state = stationary;
            next_state.floor = current_state.floor;
            next_clocks = 0;
        end
    end

    always_comb begin //output driving
        if(current_state.floor == dest_floor)begin
            finish = 1'b1;
        end
        else
            finish = 1'b0;
    end
    
endmodule
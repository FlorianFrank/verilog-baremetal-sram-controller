`timescale 1ns / 1ps
//% \addtogroup memctr Memory Controller
//% @{

//% @brief This module is responsible to write from an Rohm FRAM memory module.
//% It sets the OE, WE, CS as well as the address and datalines accordingly. 
//% @author Florian Frank
//% @copyright University of Passau - Chair of Computer Engineering
module memory_write_top_module #(
    parameter integer INPUT_FREQUENCY=100,
    parameter integer ADDRESS_BUS_SIZE=32,
    parameter integer DATA_BUS_SIZE=16,
    parameter integer CLOCK_CONFIG_WIDTH=16
) (
    //% Input clock to trigger the always block executing the state machine.	
    input wire clk,

    input wire reset,

    input wire start,

    //% Input value which should be written to the memory module.
    input wire [DATA_BUS_SIZE-1:0] value,

    input wire[ADDRESS_BUS_SIZE-1:0] address,

    input wire[CLOCK_CONFIG_WIDTH-1:0] teleh,

    //% Data lines to write the values to.
    output reg[DATA_BUS_SIZE-1:0] dlines,
    //% Address lines to select the specific cell.
    output reg[ADDRESS_BUS_SIZE-1:0] alines,
    //% Chip enable signal which is set accordingly.
    output reg ce,
    //% Output enable signal set by the memory controller.
    output reg oe,
    //% Write enable signal set by the memory controller.
    output reg we,
    //% Wire indicating that the data was written.

    output reg active,

    output reg ready
);


    //% Calculates the length of the notification pulse to synchroize between FREQ_CLK1 of the management module and FREQ_CLK2 of the memory controller.
    reg [CLOCK_CONFIG_WIDTH-1:0] STEP_SIZE_IN_NS = 1000000000/(INPUT_FREQUENCY *1e6) * 2;

    reg [CLOCK_CONFIG_WIDTH-1:0] counter = 0;
    reg [3:0] state_reg;
    

    parameter INITIALIZE    = 0;
    parameter SET_ADDRESS 	= 1;
    parameter ACTIVATE_CE   = 2;
    parameter ACTIVATE_WE   = 3;
    parameter SET_DATA 	    = 4;
    parameter FINISH        = 5;
    parameter MAX_NR_STATES = 6;

    //% @brief The task increments the state up to NOTIFY_MANAGEMENT_CONTROLLER and restarts with the first state IDLE.
    task inc_state;
        begin
            if(state_reg < MAX_NR_STATES)
                state_reg <= state_reg + 3'h1;
            else
                state_reg <= 3'h0;
        end
    endtask

    function is_time_expired;
        input [CLOCK_CONFIG_WIDTH-1:0] time_to_wait;
        begin
            if(time_to_wait == 0) is_time_expired = 1;
            else begin
                if((counter * STEP_SIZE_IN_NS) >= (time_to_wait - STEP_SIZE_IN_NS)) begin
                    counter = 0;
                    is_time_expired = 1;
                end
                else begin
                    is_time_expired = 0;
                    counter = counter + 1;
                end
            end
        end
    endfunction



    reg [DATA_BUS_SIZE-1:0] value_tmp;
    reg [ADDRESS_BUS_SIZE-1:0] address_tmp;
    reg [CLOCK_CONFIG_WIDTH-1:0] teleh_tmp;


    //% Initial block initializes all values to the default values.
    initial begin

        value_tmp   <= 0;
        address_tmp <= 0;
        teleh_tmp   <= 0;

        ready       <= 0;
        active      <= 0;
        alines      <= 15'h0;
        dlines      <= 8'h0;
        we 		    <= 1;
        oe 		    <= 1;
        ce 		    <= 1;

        counter    <= 0;
        state_reg  <= 0;
    end



    //% @brief Always block executes a write operation per time using a constant value and iterates the address after each loop.
    always @ (posedge clk) begin

        case (state_reg)
            INITIALIZE: begin
                ready <= 0;
                if(start == 1) begin
                    value_tmp <= value;
                    address_tmp <= address;
                    teleh_tmp <= teleh;

                    ce <= 1;
                    oe <= 1;
                    we <= 1;
                    inc_state();
                    active <= 1;
                end else active <= 0;
            end

            SET_ADDRESS: begin
                alines <= address_tmp;
                if(is_time_expired(0))
                    inc_state();

            end

            ACTIVATE_CE: begin
                ce <= 0;
                if(is_time_expired(0))
                    inc_state();
            end

            ACTIVATE_WE: begin
                we <= 0;
                if(is_time_expired(teleh_tmp))
                    inc_state();
            end

            SET_DATA: begin
                dlines <= value_tmp;
                if(is_time_expired(0))
                    inc_state();
            end

            FINISH: begin
                ce <= 1;
                we <= 1;
                oe <= 1;
                ready <= 1;
                active <= 0;
                if(is_time_expired(0))
                    inc_state();
            end
        endcase
    end

endmodule
//% @}
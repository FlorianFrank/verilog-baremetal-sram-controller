`timescale 1ns / 1ps
//% \addtogroup memctr Memory Controller
//% @{

//% @brief This module is responsible to write from an Rohm FRAM memory module.
//% It sets the OE, WE, CS as well as the address and datalines accordingly. 
//% @author Florian Frank
//% @copyright University of Passau - Chair of Computer Engineering
module memory_write_top_module #(
    parameter integer FREQ_CLK1=100,
    parameter integer FREQ_CLK2=400,
    parameter integer ADDRESS_BUS_SIZE=15,
    parameter integer DATA_BUS_SIZE=64,
    parameter integer DATA_BUS_SIZE_OUT=8,
    parameter integer CLOCK_CONFIG_WIDTH=16
) (
    //% Input clock to trigger the always block executing the state machine.	
    input wire clk,

    input wire reset,

    input wire start,

    //% Input value which should be written to the memory module.
    input wire [DATA_BUS_SIZE-1:0] value,
    
    input wire mode,
    
    
    input wire [DATA_BUS_SIZE_OUT-1:0] puf_value_in,

    input wire[ADDRESS_BUS_SIZE-1:0] address,

    input wire[CLOCK_CONFIG_WIDTH-1:0] teleh,

    //% Data lines to write the values to.
    output reg[DATA_BUS_SIZE_OUT-1:0] dlines,
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
    reg [CLOCK_CONFIG_WIDTH-1:0] STEP_SIZE_IN_NS = 1000000000/(FREQ_CLK2 *1e6) * 2;

    reg [CLOCK_CONFIG_WIDTH-1:0] counter = 0;
    reg [3:0] state_reg;
    reg[7:0] round_ctr = 0;
    

    parameter INITIALIZE    = 0;
    parameter NEXT_ROUND    = 1;
    parameter SET_ADDRESS 	= 2;
    parameter ACTIVATE_CE   = 3;
    parameter ACTIVATE_WE   = 4;
    parameter SET_DATA 	    = 5;
    parameter FINISH        = 6;
    parameter MAX_NR_STATES = 7;


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
    reg [DATA_BUS_SIZE_OUT-1:0] out_value;
    
    
    reg [ADDRESS_BUS_SIZE-1:0] address_tmp;
    reg [CLOCK_CONFIG_WIDTH-1:0] teleh_tmp;
    
    reg[7:0] clk_sync_ctr = 0;
    reg[7:0] clock_buff_ctr = 0;


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
        clk_sync_ctr <= 0;
    end
    
    



    //% @brief Always block executes a write operation per time using a constant value and iterates the address after each loop.
    always @ (posedge clk) begin

        case (state_reg)
            INITIALIZE: begin
                ready <= 0;
                if(start == 1) begin
                    value_tmp <= value;
                    out_value <= puf_value_in;
                    address_tmp <= address;
                    teleh_tmp <= teleh;

                    ce <= 1;
                    oe <= 1;
                    we <= 1;
                    if(mode == 0) // Simple forward mode
                        state_reg <= NEXT_ROUND;
                    else    // PUF MODE 
                        state_reg <= SET_ADDRESS;
                    active <= 1;
                    clock_buff_ctr <= 0;
                end else active <= 0;
            end
            
            NEXT_ROUND: begin
                ce <= 1;
                we <= 1;
                oe <= 1;
                out_value <= value_tmp[clock_buff_ctr*DATA_BUS_SIZE_OUT+:DATA_BUS_SIZE_OUT];
                address_tmp <= address_tmp + 1;
            end

            SET_ADDRESS: begin
                clock_buff_ctr <= clock_buff_ctr + 1; 
                alines <= address_tmp;
                if(is_time_expired(0))
                    state_reg <= ACTIVATE_CE;
            end

            ACTIVATE_CE: begin
                ce <= 0;
                if(is_time_expired(0))
                    state_reg <= ACTIVATE_WE;
            end

            ACTIVATE_WE: begin
                we <= 0;
                if(is_time_expired(teleh_tmp))
                    state_reg <= SET_DATA;
            end

            SET_DATA: begin
                dlines <= out_value;
                if(is_time_expired(0)) begin
                 if(mode == 0 && clock_buff_ctr < DATA_BUS_SIZE/DATA_BUS_SIZE_OUT)
                    state_reg <= NEXT_ROUND;
                 else 
                    state_reg <= FINISH;
                end
            end

            FINISH: begin
                ce <= 1;
                we <= 1;
                oe <= 1;


                if(clk_sync_ctr < FREQ_CLK2/FREQ_CLK1) begin
                    clk_sync_ctr <= clk_sync_ctr + 1;
                    ready <= 1;
                end else begin
                     clk_sync_ctr <= 0;
                     ready <= 0;
                     active <= 0;
                    state_reg <= INITIALIZE;
                end
            end
        endcase
    end

endmodule
//% @}
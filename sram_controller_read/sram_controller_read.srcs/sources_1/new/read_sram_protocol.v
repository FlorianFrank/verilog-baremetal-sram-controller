`timescale 1ns / 1ps
`include "state_machine_definitions.vh"

//% \addtogroup memctr Memory Controller
//% @{


//% @brief This module is responsible to set the timing of the cs and 
//% It sets the OE, WE, CS as well as the address and datalines accordingly. 
//% @author Florian Frank
//% @copyright University of Passau - Chair of Computer Engineering
module read_sram_protocol #(
    //% Clock frequency which drives this module (is required to calculate the right timing)
    parameter integer CLK_FREQUENCY=400,
    parameter integer ADDRESS_BUS_SIZE=32,
    parameter integer DATA_BUS_SIZE=16,
    parameter integer IDLE_TIME=4,
    
    parameter integer SEPERATE_OE_CE=0,
    
    parameter integer TSETUP=1,
    parameter integer TAS=1,
    parameter integer TOECE=1,
    parameter integer TPRC=1,
    parameter integer TNEXT=1
    )(
    //% Input clock which drives this module.
    input wire clk,

    input wire reset,

    input wire start,

    output reg[DATA_BUS_SIZE-1:0] value,

    inout wire[DATA_BUS_SIZE-1:0] dlines,


    //% chip enable (connect this to the chip enable of the memory chip)
    output reg ce,
    //% output enable (connect this to the chip enable of the memory chip)
    output reg oe,
    //% this signal is raised for one clock cycle after the reading process is finished
    output reg signal_done = 0,

    output reg active,

    output reg ready
);


    //% This parameter stores the time to wait between when reading from the memory (OE phase)
    //% e.g. tELEH (70ns) * 10 / ((10000/CLK_FREQUENCY))/ 2 (reaction only to the low -> high transision of the clock) = 14  
    //% So a counter needs to count up to 14 with a frequency of 400 MHz to satisfy the 70 ns OE phase
    reg[7:0] WAIT_TIME = 0;

    //% This variable stores the timing counter to match the tELEH timing behavior.
    reg[7:0] timing_ctr = 0;

    //% This register specifies the current state of the state machine.
    reg [3:0]state = `STATE_IDLE;

    integer counter;

    initial begin
        state <= `STATE_IDLE;
        timing_ctr <= WAIT_TIME;

        active <= 1;
        signal_done <= 0;
        oe <= 1;
        ce <= 1;
        value <= 16'h0;
        counter <= 0;
    end
    
    function is_time_expired;
        input integer time_to_wait;
        begin
            if(time_to_wait == 0) begin 
                is_time_expired = 1;
                counter = 0;
                end 
            else begin
                if(counter >= time_to_wait) begin
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


    reg[3:0] finished_ctr = 0;

    //% @brief The always block executes the state machine to set the OE and CE  values accordingly.
    always@(posedge clk) begin
        case (state)
            // Wait for incomming read request
            `STATE_IDLE:
            begin
                signal_done <= 0;
                oe <= 1;
                ce <= 1;
                if (start == 1)
                    begin
                        timing_ctr <= TPRC*10/((10000/CLK_FREQUENCY)); 
                        active <= 1;
                        signal_done <= 0;
                        if(is_time_expired(TSETUP-1)) begin
                            if (SEPERATE_OE_CE == 1)
                                state <= `STATE_SET_CE;
                            else 
                                state <= `STATE_SET_CE_OE;
                       end
                    end
                else active <= 0;
                ready <= 0;
            end

            `STATE_SET_CE:
            begin
                ce <= 0;
                // delay could be inserted here if necessary using the STATE_DELAY
                // in combination with the next_state register

                // for the LAPIS FRAM, we don't need a delay here which is why go
                // directly to the next state: STATE_SET_OE
                if(is_time_expired(TOECE-1))
                    state <= `STATE_SET_OE;
            end

            `STATE_SET_OE:
            begin
                oe <= 0;
                // for the LAPIS FRAM, we need to wait 70 ns before the data is valid
                // after OE has been set to low
                // to achieve this we have to wait 7 clock cycles (á 10ns assuming a 100 MHz clock)
                if(is_time_expired(TOECE-1))
                state <= `STATE_READ_DATA;
            end
            
            `STATE_SET_CE_OE:
            begin
                oe <= 0;
                ce <= 0;
                if(is_time_expired(TPRC-1))
                    state <= `STATE_READ_DATA;            
            end

            // Use counter to wait for the read latency
            `STATE_READ_DATA:
            begin
                    value <= dlines;
                    state <= `STATE_FINISHED;
            end

            `STATE_FINISHED: begin
                oe <= 1;
                ce <= 1;
                active <= 0;
                ready <= 1;
                if(finished_ctr < IDLE_TIME) begin
                    signal_done <= 1;
                    finished_ctr <= finished_ctr + 1;
                end
                else begin
                    state <= `STATE_IDLE;
                    finished_ctr <= 0;
                   end
              end
        endcase
    end
    
endmodule
//% @}
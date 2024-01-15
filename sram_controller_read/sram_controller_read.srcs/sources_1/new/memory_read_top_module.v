`timescale 1ns / 1ps

`include "state_machine_definitions.vh"

//% \addtogroup memctr Memory Controller
//% @brief Contains all modules which are responsible to read and write from the memory module.
//% @{

//% @brief This module is responsible to read from an Rohm FRAM memory module.
//% It sets the OE, WE, CS as well as the address and datalines accordingly. 
//% @author Florian Frank
//% @copyright University of Passau - Chair of Computer Engineering
module memory_read_top_module #(
    //% Frequency of the clock driving the management module. (used for synchronization purposes)
    parameter FREQ_CLK1=100,
    //% Frequency of the clock driving the memory controller. (used for synchronization purposes)
    parameter FREQ_CLK2=400,
    //% Data setup time defines how much time is waited until a read operation is executed.
    parameter integer ADDRESS_BUS_SIZE=15,
    parameter integer DATA_BUS_SIZE_OUT = 16,
    parameter integer DATA_BUS_SIZE=64,
    
    parameter integer SEPERATE_OE_CE=0,
    
    parameter integer TSETUP=1,
    parameter integer TAS=1,
    parameter integer TOECE=1,
    parameter integer TPRC=1,
    parameter integer TNEXT=1
)(

    //% Input clock which drives the memory controller.
    input wire clk1,
    
    input wire clk2,

    input wire start,

    input wire reset,

    //% The value which should be read from the // TODO.
    output  reg[DATA_BUS_SIZE-1:0] value,
    

    //% Data lines from which the data should be read
    input wire[DATA_BUS_SIZE_OUT-1:0] dlines,

    input wire[ADDRESS_BUS_SIZE-1:0] address,

    //% Address lines specifying the address currently used. (only the Rohm FRAM is supported with a address width of 15 bit)
    output wire[ADDRESS_BUS_SIZE-1:0] alines,

    //% Chip enable signal.
    output wire ce,

    //% Output enable signal.
    output wire oe,

    //% Write enable signal
    output wire we,

    output reg active,

    output reg ready
);

    reg signal_start = 0;

    reg[ADDRESS_BUS_SIZE-1:0] address_tmp;

    reg [DATA_BUS_SIZE-1:0] alines_reg;
    //% set WE permantenly to HIGH, to avoid accidential write operation.
    assign we = 1;

    //% Signal form the underlysing read logic to indicate that the read operation is finished.
    wire signal_done;


    //% State counter stores the current state of the state machine used within the always block.
    reg[2:0] state;
    
    
    reg[7:0] read_ctr;
    
    
    wire[DATA_BUS_SIZE_OUT-1:0] value_tmp;
    
    integer counter;
    
    
    
    //% @brief Initial block initializes all registers at startup.
    initial begin
        state <= `IDLE;
        alines_reg <= 0;
        address_tmp <= 0;

        ready <= 0;
        active <= 0;
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
    

    reg start_triggered = 0;

    //% Always block executes the state machine.
    always @(posedge clk1)
    begin
        case(state)

            // Wait for notification from ethernet controller to start reading
            `IDLE:
            begin
                if(start == 1) begin
                    address_tmp <= address;
                    start_triggered <= 1;
                    alines_reg <= address;
                end

                if(start_triggered == 1) begin
                    active <= 1;
                    signal_start <= 0;
                        state <= `TRIGGER_READ_OPERATION;
                end else active <= 0;
                ready <= 0;
                read_ctr <= 1;
            end
            
            `NEXT_READ: begin
                address_tmp <= address_tmp + 1;
                read_ctr <= read_ctr + 1;
                state <= `TRIGGER_READ_OPERATION;
            end

            // Send trigger to read controller to start read operation
            `TRIGGER_READ_OPERATION:
            begin
                start_triggered <= 0;
                signal_start <= 1;
                state <= `WAIT_FOR_READ_FINISHED;
            end

            // Wait for finished signal
            `WAIT_FOR_READ_FINISHED:
            begin
                // Disable ethernet module
                if (signal_done == 1) begin
                    if(read_ctr > DATA_BUS_SIZE/DATA_BUS_SIZE_OUT)
                        state <= `NOTIFY_MANAGEMENT_CONTROLLER;
                    else
                        begin
                        if(is_time_expired(TNEXT-1))
                            state <= `NEXT_READ;
                        end
                    signal_start <= 0;
                    value[read_ctr*DATA_BUS_SIZE_OUT+:DATA_BUS_SIZE_OUT] <= value_tmp;
                end
            end

            // In this step a synchronization command is sent to the ethernet controller
            `NOTIFY_MANAGEMENT_CONTROLLER:
            begin
                signal_start <= 0;
                if(signal_done == 0) begin
                    state <= `IDLE;
                    ready <= 1;
                    active <= 0;
                end
            end
        endcase
    end


    // Reading module of the micro controller
    read_sram_protocol #(
    .CLK_FREQUENCY(FREQ_CLK2),
    .ADDRESS_BUS_SIZE(ADDRESS_BUS_SIZE),
    .DATA_BUS_SIZE(DATA_BUS_SIZE_OUT),
    .SEPERATE_OE_CE(SEPERATE_OE_CE),
    .TSETUP(TSETUP),
    .TAS(TAS),
    .TOECE(TOECE),
    .TPRC(TPRC))
    memorycontroller_read (
        .clk(clk2),
        .start(signal_start),
        .ce(ce),
        .oe(oe),
        .signal_done(signal_done),
        .value(value_tmp),
        .dlines(dlines));

    assign alines = alines_reg;

endmodule
//% @}
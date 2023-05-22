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
    parameter integer ADDRESS_BUS_SIZE=32,
    parameter integer DATA_BUS_SIZE=16,
    parameter integer CLOCK_CONFIG_WIDTH=16,
    //% Delay in clock cycles after each read operation.
    parameter READ_START_DELAY=5,
    //% @param Delay in clock cycles after each read operation.
    parameter IDLE_DELAY=0
)(

    //% Input clock which drives the memory controller.
    input wire clk1,
    
    input wire clk2,

    input wire start,

    input wire reset,

    //% The value which should be read from the // TODO.
    output  wire[DATA_BUS_SIZE-1:0] value,

    //% Data lines from which the data should be read
    input wire[DATA_BUS_SIZE-1:0] dlines,

    input wire[ADDRESS_BUS_SIZE-1:0] address,

    input wire[CLOCK_CONFIG_WIDTH-1:0] teleh,

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
    reg[CLOCK_CONFIG_WIDTH-1:0] teleh_tmp;

    reg [DATA_BUS_SIZE-1:0] alines_reg;
    //% set WE permantenly to HIGH, to avoid accidential write operation.
    assign we = 1;

    //% Signal form the underlysing read logic to indicate that the read operation is finished.
    wire signal_done;

    //% Clock synchronization counter counts the length of the notification pulse to match FREQ_CLK1 and FREQ_CLK2.
    integer clkCtr;

    //% State counter stores the current state of the state machine used within the always block.
    reg [2:0]state;

    //% Counter which counts the number of clock cycles to match the delay before starting to read specified by READ_START_DELAY.
    integer read_start_ctr;
    
    //% @brief Initial block initializes all registers at startup.
    initial begin
        clkCtr <= 0;
        state <= `IDLE;
        alines_reg <= 0;
        read_start_ctr <= 0;
        address_tmp <= 0;
        teleh_tmp <= 0;

        ready <= 0;
        active <= 0;
    end

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
                    teleh_tmp <= teleh;
                    start_triggered <= 1;
                    alines_reg <= address;
                end

                if(start_triggered == 1) begin
                    active <= 1;
                    clkCtr <= 0;
                    signal_start <= 0;
                        state <= `TRIGGER_READ_OPERATION;
                end else active <= 0;
                ready <= 0;
            end

            // Send trigger to read controller to start read operation
            `TRIGGER_READ_OPERATION:
            begin
                start_triggered <= 0;
                if(read_start_ctr > READ_START_DELAY)
                    begin
                        state <= `WAIT_FOR_READ_FINISHED;
                        read_start_ctr <= 0;
                    end
                else
                    begin
                        read_start_ctr <= read_start_ctr + 1;
                        signal_start <= 1;
                    end
            end

            // Wait for finished signal
            `WAIT_FOR_READ_FINISHED:
            begin
                // Disable ethernet module
                if (signal_done == 1) begin
                    state <= `NOTIFY_MANAGEMENT_CONTROLLER;
                    clkCtr <= 0;
                    signal_start <= 0;
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
    .DATA_BUS_SIZE(DATA_BUS_SIZE),
    .CLOCK_CONFIG_WIDTH(CLOCK_CONFIG_WIDTH), 
    .IDLE_TIME(FREQ_CLK2/FREQ_CLK1))
    memorycontroller_read (
        .clk(clk2),
        .teleh(teleh_tmp),
        .start(signal_start),
        .ce(ce),
        .oe(oe),
        .signal_done(signal_done),
        .value(value),
        .dlines(dlines));

    assign alines = alines_reg;

endmodule
//% @}
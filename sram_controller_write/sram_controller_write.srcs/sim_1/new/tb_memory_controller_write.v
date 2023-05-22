`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:17 07/06/2022 
// Design Name: 
// Module Name:    tb_memory_controller_write 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define INPUT_FREQUENCY 100
`define ADDRESS_BUS_SIZE 32
`define DATA_BUS_SIZE 16
`define CLOCK_CONFIG_WIDTH 16

module tb_memory_controller_write(
);



    reg clk = 0;
    reg start = 0;
    reg reset = 0;
    reg [`CLOCK_CONFIG_WIDTH-1:0] teleh = `CLOCK_CONFIG_WIDTH'd50;
    reg[`ADDRESS_BUS_SIZE-1:0] address = `ADDRESS_BUS_SIZE'h55aa55aa55;
    wire active;
    wire ready;


    reg [`DATA_BUS_SIZE-1:0] value = `DATA_BUS_SIZE'hff00;
    wire [`DATA_BUS_SIZE-1:0] dlines;
    wire [`ADDRESS_BUS_SIZE-1:0] alines;
    wire ce, oe, we;


    initial begin
        #2
        start <= 1;
        #4
        start <= 0;
        #100
        start <= 1;
        #4
        start <= 0;
        #100
        $stop;
    end

    initial begin
        forever #2 clk = ~clk;
    end

    memory_write_top_module  #(    
    .FREQ_CLK1(100),
    .FREQ_CLK2(400),
    .ADDRESS_BUS_SIZE(32),
    .DATA_BUS_SIZE(16),
    .CLOCK_CONFIG_WIDTH(16))
     memory_module_writer(.clk(clk), .start(start), .reset(reset), .value(value), .dlines(dlines), .address(address), .teleh(teleh),
        .alines(alines), .ce(ce), .oe(oe), .we(we), .active(active), .ready(ready));

    //% Input clock to trigger the always block executing the state machine.	


endmodule

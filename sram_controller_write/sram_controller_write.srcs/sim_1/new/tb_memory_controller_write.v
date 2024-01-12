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
`define DATA_BUS_SIZE 32
`define OUTPUT_DATA_BUS_SIZE 16

`define CLOCK_CONFIG_WIDTH 16

module tb_memory_controller_write(
);



    reg clk = 0;
    reg start = 0;
    reg reset = 0;
    reg[`ADDRESS_BUS_SIZE-1:0] address = `ADDRESS_BUS_SIZE'h55aa55aa;
    wire active;
    wire ready;


    reg [`DATA_BUS_SIZE-1:0] value = `DATA_BUS_SIZE'haabbccdd;
    wire [`OUTPUT_DATA_BUS_SIZE-1:0] dlines;
    wire [`ADDRESS_BUS_SIZE-1:0] alines;
    wire ce, oe, we;


    initial begin
        #2
        reset <= 1;
        #2
        reset <= 0;
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
    .ADDRESS_BUS_SIZE(`ADDRESS_BUS_SIZE),
    .DATA_BUS_SIZE(`DATA_BUS_SIZE),
    .DATA_BUS_SIZE_OUT(`OUTPUT_DATA_BUS_SIZE),
    .tnext(10),
    .CLOCK_CONFIG_WIDTH(16),
    .SEPERATE_CE(0),
    
    .TSETUP(1),
    .TAS(1),
    .TWECE(1),
    .TPWC(10),
    .tNEXT(1) 
    )
    
    
    
     memory_module_writer(.clk(clk), .start(start), .reset(reset), .value(value), .dlines(dlines), .address(address), .alines(alines), .ce(ce), .oe(oe), .we(we), .active(active), .ready(ready));


endmodule

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

module tb_memory_controller_read(
);



    reg clk1 = 0;
    reg clk2 = 0;
    reg start = 0;
    reg reset = 0;
    reg [`CLOCK_CONFIG_WIDTH-1:0] teleh = `CLOCK_CONFIG_WIDTH'd4;
    reg[`ADDRESS_BUS_SIZE-1:0] address = `ADDRESS_BUS_SIZE'h55aa55aa;
    wire active;
    wire ready;


    wire [`DATA_BUS_SIZE-1:0] value;
    reg [`DATA_BUS_SIZE-1:0] dlines = `DATA_BUS_SIZE'h55aa;
    wire [`ADDRESS_BUS_SIZE-1:0] alines;
    wire ce, oe, we;

    initial begin
        #2
        start <= 1;
        #8
        start <= 0;
        #200
   /*     address <= `DATA_BUS_SIZE'haa55;
        start <= 1;
        #8
        start <= 0;
        #7
        #800*/
        $stop;
    end

    initial begin
        forever #8 clk1 = ~clk1;
    end

    initial begin
        forever #2 clk2 = ~clk2;
    end    
       
    
    memory_read_top_module  #(
        .FREQ_CLK1(100),
        .FREQ_CLK2(400),
        
        .ADDRESS_BUS_SIZE(32),
        .DATA_BUS_SIZE(16),
        .DATA_BUS_SIZE_OUT(16),
        
        .SEPERATE_OE_CE(0),
        
        .TSETUP(1),
        .TAS(0),
        .TOECE(1),
        .TPRC(20),
        .TNEXT(1))  
    memory_module_writer(.clk1(clk1), .clk2(clk2), .start(start), .reset(reset), .value(value), .dlines(dlines), .address(address),
                           .alines(alines), .ce(ce), .oe(oe), .we(we), .active(active), .ready(ready));

endmodule

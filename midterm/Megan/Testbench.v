`timescale 1ns / 1ps

module Testbench();
    //Declare wires and registers that will interface with the module under test
    //Registers are initilized to known states. Wires cannot be initilized.                 
    reg sys_clkn=1;
    wire sys_clkp;
    wire [7:0] led;
    reg [3:0] button;
    reg [31:0] PCDATA;
    wire [7:0] StateT;
    wire FSM_Clk_reg;
    reg [31:0] START = 0;
    wire SDA, SCL;
    wire READY;
    
    //Invoke the module that we like to test
    AccMag ModuleUnderTest (.sys_clkn(sys_clkn), .sys_clkp(sys_clkp), .PCDATA(PCDATA), .State(StateT), .FSM_Clk_reg(FSM_Clk_reg), .PC_control(START), .I2C_SDA_1(SDA), .I2C_SCL_1(SCL), .READY(READY));
    
    // Generate a clock signal. The clock will change its state every 5ns.
    //Remember that the test module takes sys_clkp and sys_clkn as input clock signals.
    //From these two signals a clock signal, clk, is derived.
    //The LVDS clock signal, sys_clkn, is always in the opposite state than sys_clkp.     
    assign sys_clkp = ~sys_clkn;    
    always begin
        #5 sys_clkn = ~sys_clkn;
    end        
      
    initial begin 
            #20000 PCDATA <= 32'b00110010001000001001011100000000;           //acc on
            #20000 START <= 1; 
            #1000000  START <= 0;
            //#5000000 PCDATA <= 32'b00111100000000100000000000000000; //mag on
            //#20000 STARTW <= 1;     
            //#1000000 STARTW <= 0;                   
            #50000000 PCDATA <= 32'b00110010001010000011001100000101; //x-acc collection
            #20000 START <= 1;  
            #1000000 START <= 0;
                                                

            //#100 button <= 4'b1110;
          
    end

endmodule

`timescale 1ns / 1ps

module JTEG_Test_File(   
    output [7:0] led,
    output CVM300_SPI_CLK,
    output CVM300_SPI_EN,
    output CVM300_SPI_IN,
    input CVM300_SPI_OUT, 
    input sys_clkn,
    input sys_clkp,  
    input  [4:0] okUH,
    output [2:0] okHU,
    inout  [31:0] okUHU,
    inout  okAA      
);

    wire  ILA_Clk, ACK_bit, FSM_Clk, TrigerEvent;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire [7:0] State;
    wire [31:0] PC_control, PC_data, return;
    
    assign TrigerEvent = PC_control[0];   

    //Instantiate the module that we like to test
    SPI_FSM I2C_Test1 (        
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),           
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .State(State),
        .SPI_EN(CVM300_SPI_EN),
        .SPI_IN(CVM300_SPI_IN),
        .SPI_OUT(CVM300_SPI_OUT),
        .SPI_CLK(CVM300_SPI_CLK),
        .PC_control(PC_control),
        .PC_data(PC_data),
        .return(return),
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA)
        );
    
    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State, CVM300_SPI_CLK, CVM300_SPI_EN, CVM300_SPI_IN, CVM300_SPI_OUT}),                             
        .probe1({FSM_Clk, TrigerEvent})
        );                        
endmodule

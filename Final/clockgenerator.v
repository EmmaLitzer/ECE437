`timescale 1ns / 1ps

module ClockGenerator2(
    input sys_clkn,
    input sys_clkp,     
    input [23:0] ClkDivThreshold,
    input [23:0] mClkDivThreshold,
    output reg FSM_Clk,    
    output reg slow_clk,
    output reg ILA_Clk
    );

    //Generate high speed main clock from two differential clock signals        
    wire clk;
    reg [23:0] ClkDiv = 24'd0;  
    reg [23:0] mClkDiv = 24'd0;   
    reg [23:0] ClkDivILA = 24'd0;  
    reg [23:0] mclkdiv;
     

    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );    
         
    // Initialize the two registers used in this module  
    initial begin
        FSM_Clk = 1'b0;        
        ILA_Clk = 1'b0;
        mclkdiv = 0;
    end
 
    // We derive a clock signal that will be used for sampling signals for the ILA
    // This clock will be 10 times slower than the system clock.    
    always @(posedge clk) begin        
        if (ClkDivILA == 10) begin
            ILA_Clk <= !ILA_Clk;                       
            ClkDivILA <= 0;
        end else begin                        
            ClkDivILA <= ClkDivILA + 1'b1;
        end
    end      

    // We will derive a clock signal for the finite state machine from the ILA clock
    // This clock signal will be used to run the finite state machine for the I2C protocol
    always @(posedge ILA_Clk) begin      //20MHz  
       if (ClkDiv == ClkDivThreshold) begin
         FSM_Clk <= !FSM_Clk;                   
         ClkDiv <= 0;
       end else begin
         ClkDiv <= ClkDiv + 1'b1;             
       end
    end
    
    always @(posedge clk) begin
        mclkdiv <= mclkdiv + 1'b1;
        if (mclkdiv == 1000) begin //want slow clock used in FSM to be 100x's faster than desired 200Hz frequency of PWM 
            slow_clk <= ~slow_clk; 
            mclkdiv <= 0;
        end
    end
    /*
    always @(posedge ILA_Clk) begin      //20MHz  
       if (ClkDiv == mClkDivThreshold) begin
         mFSM_Clk <= !mFSM_Clk;                   
         mClkDiv <= 0;
       end else begin
         mClkDiv <= mClkDiv + 1'b1;             
       end
    end
    */
              
endmodule

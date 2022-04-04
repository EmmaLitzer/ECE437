`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2022 10:32:41 AM
// Design Name: 
// Module Name: Write
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Read(
        input [6:0] devaddr,
        output reg [7:0] DATAL,
        output reg [7:0] DATAH,
        input wire START,
        output wire SCLR,
        output wire SDAR,
        input  FSM_Clk,
        input  ILA_Clk,    
        output reg FSM_Clk_reg,    
        output reg ILA_Clk_reg,
        output reg [7:0] State,
        output reg ACK_bit,
        output reg error_bit,
        output DONE
    );
    
    /*
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 100;   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
    */
    
    
    reg SCL, SDA, DONEREG;
    localparam STATE_INIT = 8'd100;
    assign SCLR = SCL;
    assign SDAR = SDA;
    assign DONE = DONEREG;
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;   
    end
    
    reg [1:0] counter = 0; //how many bytes have been read
    reg [3:0] rcounter = 4'd7; //used to count how many bits of the register we're reading from we've cycled through, through subtraction
    reg datal = 0; //reading DATAL flag
    reg datah = 0; //reading DATAH flag
    reg setack = 0;

    
    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;  
        State = 8'd100; 
        error_bit = 1'b1;
    end
    
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press signal from PC is sent in, start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (START) begin
                    State <= 8'd101;
                    counter <= 3'd0;
                    rcounter <= 4'd7;
                    setack <= 0;
                    datal <= 0;
                    datah <= 0;  
                    DONEREG <= 0;                    
                 end                 
                 else begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd100;

                  end
            end            
            
            // Start FSM           
            8'd101 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd102 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd103 : begin
                  SCL <= 1'b0;
                  SDA <= devaddr[6];
                  State <= State + 1'b1;                 
            end   

            8'd104 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd105 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd106 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd107 : begin
                  SCL <= 1'b0;                 
                  SDA <= devaddr[5];
                  State <= State + 1'b1;               
            end   

            8'd108 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd109 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd110 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd111 : begin
                  SCL <= 1'b0;                 
                  SDA <= devaddr[4]; 
                  State <= State + 1'b1;                
            end   

            8'd112 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd113 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd114 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd115 : begin
                  SCL <= 1'b0;                
                  SDA <= devaddr[3]; 
                  State <= State + 1'b1;                
            end   

            8'd116 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd117 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd118 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd119 : begin
                  SCL <= 1'b0;               
                  SDA <= devaddr[2]; 
                  State <= State + 1'b1;                
            end   

            8'd120 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd121 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd122 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd123 : begin
                  SCL <= 1'b0;                 
                  SDA <= devaddr[1]; 
                  State <= State + 1'b1;                
            end   

            8'd124 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd125 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd126 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd127 : begin
                  SCL <= 1'b0;                 
                  SDA <= devaddr[0];  
                  State <= State + 1'b1;               
            end   

            8'd128 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd129 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd130 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0 - Set 1 bit to always READ (1)
            8'd131 : begin
                  SCL <= 1'b0;                 
                  SDA <= 1'b1;     
                  State <= State + 1'b1;           
            end   

            8'd132 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd133 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd134 : begin
                  SCL <= 1'b0; 
                  State <= State +1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd135 : begin
                  SCL <= 1'b0;
                  if (datal && setack) begin //set acknowledge bit to 0 after Lower Byte read
                    SDA <= 1'b0;
                  end
                  else if (datah && setack) begin //set no acknowledge after Higher Byte read
                    SDA <= 1'b1;
                  end
                  else begin
                    SDA <= 1'bz;
                  end
                  State <= State + 1'b1;                 
            end   

            8'd136 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd137 : begin
                  SCL <= 1'b1;
                  if (datal && ~setack) begin
                    DATAL[rcounter] <= SDA;
                  end
                  else if (datah && ~setack) begin
                    DATAH[rcounter] <= SDA;
                  end
                  else
                    ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd138 : begin
                  SCL <= 1'b0;
                  if (setack) begin
                        counter <= counter + 1;
                        if (counter > 0)
                            State <= 8'd141; //done reading both bytes, can stop communication
                        else
                            State <= 8'd140; //need to read next byte (higher byte)
                  end      
                  else if (datal || datah) begin
                    if (rcounter == 0) begin
                        setack <= 1;
                        State <= 8'd135; 
                    end
                    else begin
                        rcounter <= rcounter -1;
                        State <= 8'd135;                    
                    end
                  end
                  else 
                    State <= State + 1'b1;   
            end 
            
            8'd139 : begin //reading first byte of data (L- lower byte)
                datal <= 1;
                datah <= 0;
                State <= 8'd135;
            end
            
            8'd140 : begin //reading second byte of data
                datah <= 1;
                datal <= 0;
                setack <= 0;
                rcounter <= 8'd7;
                State <= 8'd135;
            end
            
            //stop bit sequence and go back to STATE_INIT           
            8'd141 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;  
                  DONEREG <= 1;                
                  State <= State + 1'b1;
            end   

            8'd142 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            8'd143 : begin //halt state
                  SCL <= 1'b1;
                  SDA <= 1'b1; 
                  if (START)        
                  State <= STATE_INIT;     
            end
            
            //If the FSM ends up in this state, there was an error in the FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end 
            
        endcase
    end
    

endmodule

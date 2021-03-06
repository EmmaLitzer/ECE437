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


module Write(
        input [6:0]      devaddr,
        input [7:0]      regaddr,
        input            START,
        output wire      WSTART,
        output wire      SCLW,
        output wire      SDAW,
        input            FSM_Clk,
        input            ILA_Clk,    
        output reg       FSM_Clk_reg,    
        output reg       ILA_Clk_reg,
        output reg [7:0] State,
        output reg       ACK_bit,
        output reg       error_bit,
        output reg       STARTR,
        input wire       RW,
        input [7:0]      wdata,
        input            RDONE,
        output reg       READY
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
    
    reg wrreg = 0; //flag signal to tell FSM that we want to write the address of the register we want to read from
    reg wrdata;
    //reg onacc, onmag;
    
    reg STARTW; 
    reg SCL, SDA;
    
    localparam STATE_INIT = 8'd0;
    assign SCLW = SCL;
    assign SDAW = SDA;
    assign WSTART = STARTW; 
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;  
        //if (RDONE) begin //need to better connect so will write again after done reading
        //    STARTR = 0;
        //end
    end

    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;  
        State = 8'd0; 
        error_bit = 1'b1;
    end
    
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press signal from PC is sent in, start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (START) begin
                    State <= 8'd1;
                    wrreg <= 0;
                    wrdata <= 0;
                    STARTR <= 0;
                    STARTW <= 1;
                 end                 
                 else begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                      if (RDONE) begin
                        READY <= 1;
                        STARTR <= 0;
                      end
                      else 
                        READY <= 0;
                  end
            end            
            
            // Start FSM           
            8'd1 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd2 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[7];
                  else if (wrdata)
                    SDA <= wdata[7];
                  else
                    SDA <= devaddr[6];
                  State <= State + 1'b1;                 
            end   

            8'd4 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd5 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd6 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[6];
                  else if (wrdata)
                    SDA <= wdata[6];                    
                  else                  
                    SDA <= devaddr[5];
                  State <= State + 1'b1;               
            end   

            8'd8 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd9 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd10 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[5];
                  else if (wrdata)
                    SDA <= wdata[5];                    
                  else                  
                    SDA <= devaddr[4]; 
                  State <= State + 1'b1;                
            end   

            8'd12 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd13 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd14 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[4];
                  else if (wrdata)
                    SDA <= wdata[4];                    
                  else                  
                    SDA <= devaddr[3]; 
                  State <= State + 1'b1;                
            end   

            8'd16 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd17 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd18 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[3];
                  else if (wrdata)
                    SDA <= wdata[3];                   
                  else                  
                    SDA <= devaddr[2]; 
                  State <= State + 1'b1;                
            end   

            8'd20 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd21 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd22 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[2];
                  else if (wrdata)
                    SDA <= wdata[2];                    
                  else                  
                    SDA <= devaddr[1]; 
                  State <= State + 1'b1;                
            end   

            8'd24 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd25 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd26 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[1];
                  else if (wrdata)
                    SDA <= wdata[1];                    
                  else                  
                    SDA <= devaddr[0];  
                  State <= State + 1'b1;               
            end   

            8'd28 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd29 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd30 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0 - Set 0 bit to always WRITE (0)
            8'd31 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= regaddr[0];
                  else if (wrdata)
                    SDA <= wdata[0];                    
                  else                  
                    SDA <= 1'b0;     
                  State <= State + 1'b1;           
            end   

            8'd32 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd33 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd34 : begin
                  SCL <= 1'b0; 
                  State <= State +1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   
            
            /*
            8'd250 : begin
                ACK_bit <= SDA; 
                  ;
                  State <= 36;
            end
            */

            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  wrreg <= 1'b1;
                  if (wrreg && RW)
                    State <= 8'd39; //go to halt state to start reading data after finish writing register we want to read from
                  else if (wrreg && ~RW)
                    State <= 8'd42; //go to write data state after finish writing register address
                  else if (wrdata)
                    State <= 8'd43; //go to stop sequence
                 else 
                    State <= 8'd3;   
            end 
            
            8'd39 : begin
                SCL <= 1'b0;
                State <= 8'd250;
            end
            
            8'd250: begin
                SDA <= 1'b1;// set SDA to 1 to prepare for repeat start signal in READ FSM
                State <= 8'd40;
            end
            
            8'd40 : begin
                wrreg <= 0;
                SCL <= 1;
                State <= State + 1'b1;
            end
            
            8'd41 : begin //halt state
                STARTR <= 1;
                STARTW <= 0;
                State <= STATE_INIT; 
            end
            
            8'd42: begin //need to go write data to FSM
                SCL <= 1'b0;
                wrreg <= 0;
                wrdata <= 1;
                State <= 8'd3;
            end
            
            //stop bit sequence and go back to STATE_INIT           
            8'd43 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;                
                  State <= State + 1'b1;
            end   

            8'd44 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            8'd45 : begin //halt state
                  SCL <= 1'b1;
                  SDA <= 1'b1; 
                  wrdata <= 0;   
                  State <= STATE_INIT;            
            end
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end 
            
        endcase
    end    
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2022 04:21:42 PM
// Design Name: 
// Module Name: SPI_FSM
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


module SPI_FSM(
        output [7:0] led,
        input  sys_clkn,
        input  sys_clkp,
        output reg FSM_Clk_reg,        
        output reg ILA_Clk_reg,
        output reg [7:0] State,
        output wire SPI_EN, 
        output wire SPI_CLK, 
        output wire SPI_IN, 
        input wire SPI_OUT, 
        //change to input using testbench//
        output wire [31:0] PC_control, 
        output wire [31:0] PC_data, //data sent in from PC with specified register address, read/write mode, and value to be written
        //*********************************//
        output wire [31:0] return, //data to send back to PC after reading
        input  wire    [4:0] okUH,
        output wire    [2:0] okHU,
        inout  wire    [31:0] okUHU,   
        inout wire okAA 

    );
    
    reg sen, sclk, sin, sout;
    reg [7:0] dataout; //register to store output data to
    reg wdataf; //flag signal to start writing data to register
    reg [3:0] counter; //counter to count how many bits have been read from register

    wire RW = PC_data[0];
    wire [6:0] regaddr = PC_data[30:24];
    wire [7:0] wdata = PC_data[23:16];
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 1; //40MHz   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;   
    end  
    
    localparam STATE_INIT       = 8'd0;    
    assign SPI_EN = sen;
    assign SPI_CLK = sclk; 
    assign SPI_IN = sin;
    assign return = dataout;
 
    initial  begin  
        State = 8'd0; 
        wdataf = 0;
        counter = 4'd7;
    end  
    
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press signal from PC is sent in, start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (PC_control[0] == 1'b1) begin
                    State <= 8'd1; 
                    wdataf <= 1'b0;
                    counter <= 4'd7;
                 end                 
                 else begin      
                      sclk <= 1'b0;     
                      sin <= 1'b0; 
                      sen <= 1'b0;     
                      State <= 8'd0;

                  end
            end            
            
            // Start SPI communication by turning on enable for half a clock cycle           
            8'd1 : begin
                  sen <= 1'b1;
                  if (wdataf) begin
                    sin <= wdata[7];
                  end
                  else begin
                    sin <= RW;
                  end 
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd2 : begin
                  //sen and sin stay the same 
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end   
            
            //start writing in register address you want to read or write from
            8'd3 : begin
                  if (wdataf) begin
                    sin <= wdata[6];
                  end
                  else begin
                    sin <= regaddr[6];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd4 : begin
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd5 : begin
                  if (wdataf) begin
                    sin <= wdata[5];
                  end
                  else begin
                    sin <= regaddr[5];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd6 : begin
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd7 : begin
                  if (wdataf) begin
                    sin <= wdata[4];
                  end
                  else begin
                    sin <= regaddr[4];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd8 : begin
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd9 : begin
                  if (wdataf) begin
                    sin <= wdata[3];
                  end
                  else begin
                    sin <= regaddr[3];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd10 : begin
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd11 : begin
                  if (wdataf) begin
                    sin <= wdata[2];
                  end
                  else begin
                    sin <= regaddr[2];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd12 : begin
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd13 : begin
                  if (wdataf) begin
                    sin <= wdata[1];
                  end
                  else begin
                    sin <= regaddr[1];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd14 : begin
                  sclk <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd15 : begin
                  if (wdataf) begin
                    sin <= wdata[0];
                  end
                  else begin
                    sin <= regaddr[0];
                  end
                  sclk <= 1'b0;
                  State <= State + 1'b1;                                
            end
            
            8'd16 : begin
                  sclk <= 1'b1;
                  if (wdataf) begin
                    State <= 8'd19;
                  end
                  else if (RW) begin //RW = 1 (writing)
                    wdataf <= 1'b1; //if writing, start entering data on SPI_IN
                    State <= 8'd1;
                  end
                  else begin //RW = 0 (reading)
                    State <= State + 1'b1;        
                  end                        
            end
            
            //if reading, start storing data from SPI_OUT
            8'd17: begin
                sin <= 1'b0;
                sclk <= 1'b0;
                State <= State + 1'b1;
            end
            
            8'd18: begin
                if (counter > 4'd7) begin //done reading, go back to STATE_INIT
                    sen <= 1'b0;
                    State <= STATE_INIT;
                end
                else begin //haven't read all 8 bits from register
                    sclk <= 1'b1;
                    dataout[counter] <= SPI_OUT;
                    counter <= counter - 1'b1;
                    State <= 8'd17;
                end
            end
            
            //finished reading all 9 bits, need to end protocol where SPI_EN is held high for half a cycle after read data is finished
            8'd19 : begin
                sin <= 1'b0;
                sclk <= 1'b0;
                sen <= 1'b1;
                State <= State + 1'b1;
            end
            
            8'd20: begin
                sen <= 1'b0; //done with protocol
                State <= STATE_INIT;
            end
            
         endcase                           
    end               
  
    
 // OK Interface
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication 
        //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 2 output endpoints, hence endPt_count = 2.
    localparam  endPt_count = 1;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
    wire okClk;
    
    //This is the OK host that allows data to be sent or recived    
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );
    
    
     okWireIn wire10 (   .okHE(okHE), 
                       .ep_addr(8'h00), 
                       .ep_dataout(PC_control)); //signal to tell FSM to start
                       
    okWireIn wire11 (   .okHE(okHE), 
                       .ep_addr(8'h01), 
                       .ep_dataout(PC_data)); //data to tell FSM to read/write, which registers, and what data
                       
    okWireOut wire20 (  .okHE(okHE), 
                   .okEH(okEHx[ 0*65 +: 65 ]),
                   .ep_addr(8'h20), 
                   .ep_datain(return));    
    

    
endmodule

`timescale 1ns / 1ps

module AccMag(
        output [7:0] led,
        input  sys_clkn,
        input  sys_clkp,
        output ADT7420_A0,
        output ADT7420_A1,
        output I2C_SCL_1,
        inout  I2C_SDA_1,        
        output reg FSM_Clk_reg,    
        output reg ILA_Clk_reg,
        output reg ACK_bit,
        output reg SCL,
        output reg SDA,
        output reg [7:0] State,
        output wire [31:0] PC_control, //input for testbench
        output wire [31:0] PCDATA, //input for testbench
        input  wire    [4:0] okUH,
        output wire    [2:0] okHU,
        inout  wire    [31:0] okUHU,   
        inout wire okAA,
        output reg READY   
    );
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 1000; //need to be at max 100kHz   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
                                      
    reg wrreg = 0; //flag signal to tell FSM that we want to write the address of the register we want to read or write from
    reg byte3; // flag signal to tell FSM the data we want to write the data stored in byte 3 or start the read routine
    //reg onacc, onmag; //flag signal to tell FSM to turn on accelerometer and magnetic sensor
    
    //didn't use error_bit
    reg error_bit, setack;
 
    reg [7:0] MSB, LSB;
    reg [7:0] bcounter = 0; // counter to count how many bytes have been read
    reg [3:0] rcounter = 4'd7; //used to count how many bits of the register we're reading from we've cycled through, through subtraction
    reg rmsb = 0; //flag signal to tell FSM reading MSB
    reg rlsb = 0; //flag signal to tell FSM reading LSB
    
    //parsed input data
    wire [7:0] devaddr = PCDATA[31:24]; //device address for writing
    wire [7:0] regaddr = PCDATA[23:16]; //register address we want to write to or read from
    wire [7:0] DATA = PCDATA[15:8]; //device we want to read from or data we want to write to device
    wire [6:0] BYTES = PCDATA[7:1]; //number of bytes you want to read
    wire RW = PCDATA[0]; 
    
    /*
    //fixed data - don't need if lines in python can control this part
    reg [6:0] adevaddr = 7'b0011001; //accelerometer device address
    reg [6:0] mdevaddr = 7'b0011110; //magnetometer device address
    reg [7:0] ctrl_reg_1_a_data = 8'b10010111; //accelerometer ctrl data
    reg [7:0] ctrl_reg_1_a = 8'b00100000; //accelerometer ctrl register to get device out of sleep mode
    reg [7:0] mr_reg_m_data = 8'b00000000; //magnetometer ctrl data
    reg [7:0] mr_reg_m = 8'b00000010; //magnetometer ctrl register to put device in continuous mode
    */
  
    localparam STATE_INIT = 8'd0;
    assign I2C_SCL_1 = SCL;
    assign I2C_SDA_1 = SDA;
    assign led[7] = ACK_bit;
    assign led[6] = error_bit; 
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;  
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
                 if (PC_control[0] == 1'b1) begin
                    State <= 8'd1;
                    wrreg <= 0;
                    byte3 <= 0;
                    READY <= 0;
                    rmsb <= 0;
                    rlsb <= 0;
                    setack <= 0;
                    rcounter <= 4'd7;
                    bcounter <= 8'b1;
                 end                 
                 else begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                      READY <= 1;
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
                  else if (byte3)
                    SDA <= DATA[7];
                  else 
                    SDA <= devaddr[7];
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
                  else if (byte3)
                    SDA <= DATA[6];                    
                  else                  
                    SDA <= devaddr[6];
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
                  else if (byte3)
                    SDA <= DATA[5];                    
                  else                  
                    SDA <= devaddr[5]; 
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
                  else if (byte3)
                    SDA <= DATA[4];                    
                  else                  
                    SDA <= devaddr[4]; 
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
                  else if (byte3)
                    SDA <= DATA[3];                   
                  else                  
                    SDA <= devaddr[3]; 
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
                  else if (byte3)
                    SDA <= DATA[2];                    
                  else                  
                    SDA <= devaddr[2]; 
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
                  else if (byte3)
                    SDA <= DATA[1];                    
                  else                  
                    SDA <= devaddr[1];  
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
                  else if (byte3)
                    SDA <= DATA[0];                    
                  else                  
                    SDA <= devaddr[0];
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
                  if (rlsb && setack) begin //set acknowledge bit to 0 after Lower Byte read
                    SDA <= 1'b0;
                  end
                  else if (rmsb && setack) begin //set no acknowledge after Higher Byte read
                    SDA <= 1'b1;
                  end
                  else
                    SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   
            

            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;
                  if (rlsb && ~setack) begin
                    LSB[rcounter] <= SDA;
                  end
                  else if (rmsb && ~setack) begin
                    MSB[rcounter] <= SDA;
                  end
                  else
                    ACK_bit <= SDA;   
                
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  wrreg <= 1'b1;
                  
                  //rotating through to read all 8 bits of data
                  
                  if (setack) begin
                        bcounter <= bcounter + 1'b1;
                        setack <= 0;
                        if (bcounter == BYTES)
                            State <= 8'd39; //done reading both bytes, can stop communication
                        //only have 2 outputs- can only read max 2 bytes
                        else begin
                            rlsb <= 0;
                            rmsb <= 1;
                            State <= 8'd35; //need to start reading next byte (higher byte)
                            rcounter <= 4'd7;
                        end
                  end      
                  else if (rmsb || rlsb) begin
                    if (rcounter == 0) begin
                        setack <= 1; 
                        State <= 8'd35; 
                    end
                    else begin
                        rcounter <= rcounter -1;
                        State <= 8'd35;                    
                    end
                  end
                  
                  else if (wrreg) begin //begin putting either writing in DATA or writing in read device address
                    State <= 8'd3;
                    byte3 <= 1;
                    wrreg <= 0;
                  end
                  
                  //jumping to correct state after
                  else if (byte3 && RW==1) begin //RW=1 when reading
                    State <= 8'd35; //loop into reading states
                    rlsb <= 1;
                    rmsb <= 0;
                  end
                  else if (byte3 && RW==0) begin
                    State <= 8'd39; //go to stop sequence
                    byte3 <= 0;
                  end                  
                 else 
                    State <= 8'd3;   
                    
            end 
            
            //stop sequence
            8'd39 : begin
                SCL <= 1'b0;
                SDA <= 1'b0;
                State <= State + 1'b1;
            end
            
            8'd40 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end
            
            8'd41 : begin //halt state
                  SCL <= 1'b1;
                  SDA <= 1'b1; 
                  State <= STATE_INIT; 
            end
            
            /*
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
            */
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end 
            
        endcase
    end    
    
    
    
    // OK Interface
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication 
        //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 2 output endpoints, hence endPt_count = 2.
    localparam  endPt_count = 2;
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
    
    
    //  PC_controll is a wire that contains data sent from the PC to FPGA.
    //  The data is communicated via memeory location 0x00

   okWireIn wire10 (   .okHE(okHE), 
                       .ep_addr(8'h00), 
                       .ep_dataout(PCDATA));  
                       
   okWireIn wire11 (   .okHE(okHE), 
                       .ep_addr(8'h01), 
                       .ep_dataout(PC_control));  

    
                      
   okWireOut wire21 (  .okHE(okHE), 
                   .okEH(okEHx[ 1*65 +: 65 ]), //unsure what this line is for but is giving errors
                   .ep_addr(8'h21), 
                   .ep_datain(MSB));
                  
   okWireOut wire20 (  .okHE(okHE), 
                   .okEH(okEHx[ 0*65 +: 65 ]),
                   .ep_addr(8'h20), 
                   .ep_datain(LSB));
                  
                   
 endmodule

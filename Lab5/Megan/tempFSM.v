`timescale 1ns / 1ps

module tempFSM(    
    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_0,
    inout  I2C_SDA_0,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,
    output reg [7:0] State,
    input wire [31:0] PC_control,
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,   
    inout wire okAA     
    );
    
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 100;   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
                                        
    reg [7:0] SingleByteData = 8'b1001_0001;        
    reg error_bit = 1'b1;  
    reg [3:0] cycle_count; 
     
    reg [7:0] wraddr = 8'h00; //sensor internal register to read from
    reg RW = 0; //read or write register that holds if want to read or write
    reg wrreg = 0; //flag signal to tell FSM that we want to write the address of the register we want to read from
    reg rregMSB = 0; //flag signal for reading register data for MSB
    reg rregLSB = 0; //flag signal for reading register data for LSB
    reg setack = 0; //flag signal that we want to master to set acknowledge bit
    reg [7:0] tempMSB, tempLSB;
    reg [1:0] counter = 0; //used to count up to 4 to see how many bytes of communication we've cycled through
    reg [3:0] rcounter = 4'd7; //used to count how many bits of the register we're reading from we've cycled through, through subtraction
      
       
    localparam STATE_INIT       = 8'd0;    
    assign led[7] = ACK_bit;
    assign led[6] = error_bit;
    assign ADT7420_A0 = 1'b0;
    assign ADT7420_A1 = 1'b0;
    assign I2C_SCL_0 = SCL;
    assign I2C_SDA_0 = SDA; 
    
    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;  
        State = 8'd0; 
    end
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;   
    end   
                               
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press signal from PC is sent in, start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (PC_control[0] == 1'b1) State <= 8'd1;                    
                 else begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                  end
            end            
            
            // Start temperature reading           
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
                    SDA <= wraddr[7];
                  else
                    SDA <= SingleByteData[7];
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
                    SDA <= wraddr[6];
                  else
                    SDA <= SingleByteData[6]; 
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
                    SDA <= wraddr[5];
                  else
                    SDA <= SingleByteData[5]; 

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
                    SDA <= wraddr[4];
                  else
                    SDA <= SingleByteData[4]; 
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
                    SDA <= wraddr[3];
                  else
                    SDA <= SingleByteData[3]; 
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
                    SDA <= wraddr[2];
                  else
                    SDA <= SingleByteData[2]; 
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
                    SDA <= wraddr[1];
                  else
                    SDA <= SingleByteData[1];  
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
            
            // transmit bit 0 - Read or Write value (RW = 1 reads, = 0 writes)
            8'd31 : begin
                  SCL <= 1'b0;
                  if (wrreg) //write register address we want to read from flag flagged
                    SDA <= wraddr[0];
                  else a
                    SDA <= RW;      
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
                  counter <= counter + 1; //counter counts which byte we are on to know which next state to go to
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd35 : begin
                  SCL <= 1'b0;
                  if (rregMSB && setack) begin //set acknowledge bit to 0 after MSB read
                    SDA <= 1'b0;
                  end
                  else if (rregLSB && setack) begin //set no acknowledge after LSB read
                    SDA <= 1'b1;
                  end
                  else begin
                    SDA <= 1'bz;
                  end 
                  State <= State + 1'b1;                 
            end   

            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;
                  if (rregMSB && ~setack) begin
                    tempMSB[rcounter] <= SDA;
                  end
                  else if (rregLSB && ~setack) begin
                    tempLSB[rcounter] <= SDA;
                  end
                  else begin
                    ACK_bit <= SDA;                 
                  end
                  State <= State + 1'b1;

            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  if (setack) begin
                        counter <= counter + 1;
                        State <= 8'b100;
                  end      
                  else if (rregMSB || rregLSB) begin
                    if (rcounter == 0) begin
                        setack <= 1;
                        State <= 8'd35;
                    end
                    else begin
                        rcounter <= rcounter -1;
                        State <= 8'd35;                    
                    end
                  end
                  
                  else
                    State <= 8'd100;   
            end  
            
            8'd100: begin //jump to state depending on number of byte communicated (after counter=1, start writing register address)
                  State <= State + counter;
 
            end
            
            8'd101 : begin //set flag and address signals to write to sensor register address we want to read from
                wrreg <= 1; //write register flag flagged
                wraddr <= 8'b00000000; //register address we want to read from (address we will write)
                State <= 8'd3; //go back to state 3 to load SDA with regiter address
            end
            
            8'd102 : begin //second start and device address setting with read bit
                wrreg <= 0;
                RW <= 1; //want to read this device addresss
                SDA <= 1;// set SDA to 1 to repeat start signal
                State <= 8'b1; // go back to state 1 to repeat start
            end
            
            8'd103 : begin //third byte of data, reading first byte MSB
                rregMSB <= 1;
                rregLSB <= 0;
                State <= 8'd35;
            end
            
            8'd104 : begin
                rregMSB <= 0;
                rregLSB <= 1;
                setack <= 0;
                rcounter <= 8'd7;
                State <= 8'd35;
            end
            
            8'd105 : begin //No Acknowledge by Master, implement STOP BY MASTER
                State <= 8'd39;
            end
            
            //stop bit sequence and go back to STATE_INIT           
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

            8'd41 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= STATE_INIT;                  
            end              
            
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
//    okWireIn wire10 (   .okHE(okHE), 
//                        .ep_addr(8'h00), 
//                        .ep_dataout(PC_control));
                        
   okWireOut wire21 (  .okHE(okHE), 
                   .okEH(okEHx[ 1*65 +: 65 ]), //unsure what this line is for but is giving errors
                   .ep_addr(8'h21), 
                   .ep_datain(tempLSB));
                    
    okWireOut wire20 (  .okHE(okHE), 
                    .okEH(okEHx[ 1*65 +: 65 ]),
                    .ep_addr(8'h20), 
                    .ep_datain(tempMSB));             
               
endmodule

`timescale 1ns / 1ps

module FSM(
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU, 
    inout wire okAA,
    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_1,
    output wire [31:0] PC_control,
    inout  I2C_SDA_1,
    output reg [7:0] State,
    output reg SDA,
    output reg SCL,
    output ACK_bitw,
    output wire FSM_Clk,
    output wire ILA_Clk
);

    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 100; //1000  
    //wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );

    // OK Interface
    wire okClk;
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication 
    localparam  endPt_count = 2; // Probably will have to change to 6
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


    // Initialize all variables
    // Clock vars
    reg FSM_Clk_reg;
    reg ILA_Clk_reg;
    reg ACK_bit;        // Acknowledge var
    //reg SCL;            
    //reg SDA;
    //reg [7:0] State;
    reg [7:0] Sens_Data;// MSB + LSB to PC
    reg error_bit;// error flag

    reg [3:0]   button_reg; 


    wire [1:0] RW;      // read/write
    wire [7:0] Data;    //SingleByteData
    wire [7:0] Data_2;
    wire [7:0] Array1;  // Data array 1 from sensor
    wire [7:0] Array2;  // Data array 2 from sensor
    reg [7:0] rec_RW;   // records RW previous value


    localparam STATE_INIT     = 8'd0;    
    assign led[7] = ACK_bit;    // display ACK on led board
    assign led[6] = error_bit;  // display error on led board
    assign I2C_SCL_1 = SCL;
    assign I2C_SDA_1 = SDA;
    assign ADT7420_A0 = 1'b0;   // ??
    assign ADT7420_A1 = 1'b0;   // ??
    assign AKC_bitw = ACK_bit;


    initial begin
        SCL = 1'b1;         // set SCL high
        SDA = 1'b1;         // set SDA low
        ACK_bit = 1'b1;     // set ACK to 1
        State = 8'd0;        // start at state 0
        Sens_Data = 8'd0;   // Sensor data is 0
        error_bit = 1'b1;   // set error high
        rec_RW = 2'd0;      // set RW record to nothing
    end

    // Clock
    always @(*) begin
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;
    end
                       
    /// FSM machine:
    always @(posedge FSM_Clk) begin

        case (State)
            STATE_INIT: begin
                if (PC_control[0] == 1'b1) begin
                    if (RW == 2'd1 && RW != rec_RW) begin
                        // if RW =2 (write) go to state 1
                        State <= 8'd1;
                        rec_RW <= RW;
                    end

                    else if(RW == 2'd2 && RW != rec_RW) begin
                        // if RW = 1 (read) go to state 1
                        State <= 8'd1;
                        rec_RW <= RW;
                    end
                    // else stay at state 0 (RW = 0: do nothing)
                    else if (RW == 2'd0) begin
                        rec_RW <= 2'd0;                 
                        SCL <= 1'b1;
                        SDA <= 1'b1;
                        State <= 8'd0;
                    end
                    else begin             
                        SCL <= 1'b1;
                        SDA <= 1'b1;  
                        State <= 8'd0;
                    end    
                end
            end


           // Start sequence            
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

            // SAD + Read
            // transit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  SDA <= Data[7];
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

            //  bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  SDA <= Data[6];  
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

            //  bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  SDA <= Data[5]; 
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

            //  bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  SDA <= Data[4]; 
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

            //  bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  SDA <= Data[3]; 
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
            
            //  bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  SDA <= Data[2]; 
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
 
            //  bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  SDA <= Data[1];  
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
            
            //  bit 0
            8'd31 : begin
                  SCL <= 1'b0;
                  SDA <= Data[0];      
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
                  State <= State + 1'b1;
            end  
                        
            // Get ACK bit
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz; //ACK
                  State <= State + 1'b1;                 
            end   

            // Set SCL high
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
                  State <= State + 1'b1;
            end  
            
            // Read Data
            // Data bit 7
            8'd39 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[7];             
                  State <= State + 1'b1; 
            end                 
                  
            8'd40 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd41 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd42 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Data bit 6
            8'd43 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[6];  
                  State <= State + 1'b1;               
            end   

            8'd44 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd45 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd46 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Data bit 5
            8'd47 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[5]; 
                  State <= State + 1'b1;                
            end   

            8'd48 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd49 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd50 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Data bit 4
            8'd51 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[4]; 
                  State <= State + 1'b1;                
            end   

            8'd52 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd53 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd54 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Data bit 3
            8'd55 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[3]; 
                  State <= State + 1'b1;                
            end   

            8'd56 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd57 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd58 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // Data bit 2
            8'd59 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[2]; 
                  State <= State + 1'b1;                
            end   

            8'd60 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd61 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd62 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // Data bit 1
            8'd63 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[1];  
                  State <= State + 1'b1;               
            end   

            8'd64 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd65 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd66 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // Data bit 0
            8'd67 : begin
                  SCL <= 1'b0;
                  SDA <= Array1[0];     
                  State <= State + 1'b1;           
            end   

            8'd68 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd69 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd70 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // Get ACK bit
            8'd71 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            // Set SCL high
            8'd72 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            8'd73 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   
            
            // Restart
            8'd74 : begin
                // set SCL low
                  SCL <= 1'b0;
                  if (RW == 2'd1) begin
                      // if read is on go to state 1
                       State <= State + 1'b1;
                  end
                  else if (RW == 2'd2) begin
                      // if write is on go to state 155
                      State <= 8'd155;
                  end
            end    
            
            //SAD + W
            8'd155 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[7];             
                  State <= State + 1'b1; 
            end                 
                  
            8'd156 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd157 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd158 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 6
            8'd159 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[6];  
                  State <= State + 1'b1;               
            end   

            8'd160 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd161 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd162 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 5
            8'd163 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[5]; 
                  State <= State + 1'b1;                
            end   

            8'd164 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd165 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd166 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 4
            8'd167 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[4]; 
                  State <= State + 1'b1;                
            end   

            8'd168 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd169 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd170 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 3
            8'd171 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[3]; 
                  State <= State + 1'b1;                
            end   

            8'd172 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd173 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd174 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            //  bit 2
            8'd175 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[2]; 
                  State <= State + 1'b1;                
            end   

            8'd176 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd177 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd178 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            //  bit 1
            8'd179 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[1];  
                  State <= State + 1'b1;               
            end   

            8'd180 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd181 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd182 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            //  bit 0
            8'd183 : begin
                  SCL <= 1'b0;
                  SDA <= Array2[0];     
                  State <= State + 1'b1;           
            end   

            8'd184 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd185 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd186 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end
            
            // Get ACK
            8'd187 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            // Set SCL high
            8'd188 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            8'd189 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   
            

            8'd190 : begin
                  SCL <= 1'b0;
                  State <= 8'd204;
            end 
            
            // Repeat
            8'd75 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd76 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= State + 1'b1;                                
            end
            
            8'd77 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd78 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= 8'd80;   // Set to state 80              
            end   
                                                                                        
            //Data_2
            //  bit 7
            8'd80 : begin
                  SDA <= Data_2[7];             
                  State <= State + 1'b1; 
            end                 
                  
            8'd81 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd82 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd83 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 6
            8'd84 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[6];  
                  State <= State + 1'b1;               
            end   

            8'd85 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd86 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd87 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 5
            8'd88 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[5]; 
                  State <= State + 1'b1;                
            end   

            8'd89 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd90 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd91 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 4
            8'd92 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[4]; 
                  State <= State + 1'b1;                
            end   

            8'd93 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd94 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd95 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            //  bit 3
            8'd96 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[3]; 
                  State <= State + 1'b1;                
            end   

            8'd97 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd98 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd99 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            //  bit 2
            8'd100 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[2]; 
                  State <= State + 1'b1;                
            end   

            8'd101 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd102 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd103 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            //  bit 1
            8'd104 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[1];  
                  State <= State + 1'b1;               
            end   

            8'd105 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd106 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd107 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            //  bit 0
            8'd108 : begin
                  SCL <= 1'b0;
                  SDA <= Data_2[0];      
                  State <= State + 1'b1;           
            end   

            8'd109 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd110 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd111 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // Get ACK
            8'd112 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            // Set SCL high
            8'd113 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            8'd114 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;                 
                  State <= State + 1'b1;
            end   
            

            8'd115 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end                       
            




            //MSB LSB
            8'd116 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd117 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 7th bit
            8'd118 : begin
                  SCL <= 1'b1;
                  Sens_Data[7] <= SDA;                 
                  State <= State + 1'b1;
            end   
            
            8'd119 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end       
            
            // ACK
            8'd120 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd121 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 6th bit
            8'd122 : begin
                  SCL <= 1'b1;
                  Sens_Data[6] <= SDA;                   
                  State <= State + 1'b1;
            end   
            
            8'd123 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // ACK
            8'd124 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd125 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 5th bit
            8'd126 : begin
                  SCL <= 1'b1;
                  Sens_Data[5] <= SDA;                   
                  State <= State + 1'b1;
            end   
            
            8'd127 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end    
            
            // ACK
            8'd128 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd129 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 4th bit
            8'd130 : begin
                  SCL <= 1'b1;
                  Sens_Data[4] <= SDA;                  
                  State <= State + 1'b1;
            end   
            
            8'd131 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end      
            
            // ACK
            8'd132 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd133 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 3rd bit
            8'd134 : begin
                  SCL <= 1'b1;
                  Sens_Data[3] <= SDA;                   
                  State <= State + 1'b1;
            end   
            
            8'd135 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end 
            
            // ACK
            8'd136 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd137 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 2nd bit
            8'd138 : begin
                  SCL <= 1'b1;
                  Sens_Data[2] <= SDA;                
                  State <= State + 1'b1;
            end   
            
            8'd139 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end 
            
            // ACK
            8'd140 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd141 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 1st bit
            8'd142 : begin
                  SCL <= 1'b1;
                  Sens_Data[1] <= SDA;                  
                  State <= State + 1'b1;
            end   
            
            8'd143 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // ACK
            8'd144 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd145 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end            
            
            // Set 0th bit
            8'd146 : begin
                  SCL <= 1'b1;
                  Sens_Data[0] <= SDA;                    
                  State <= State + 1'b1;
            end   
            
            8'd147 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end                                                                                       
            
            // 
            8'd148 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;      
                  State <= State + 1'b1;           
            end   

            8'd149 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd150 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd151 : begin
                  SCL <= 1'b0;                  
                  State <= 8'd204;
            end
            
            
            
            // Get ACK
            8'd200  : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;     
                  State <= State + 1'b1;           
            end   

            8'd201 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd202 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd203 : begin
                  SCL <= 1'b0;
                  if (error_bit == 5)    State <= State + 1'b1;
                  else  begin
                    State <= 116;
                    error_bit <= error_bit + 1'b1;
                  end                  
            end
               
            //Stop sequence and return to INIT           
            8'd204 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;             
                  State <= State + 1'b1;
            end   

            8'd205 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            8'd206 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  //flag <= 5'd0;
                  State <= STATE_INIT;                
            end              
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            default : begin
                  error_bit <= 0;
            end                              
        endcase                           
    end


    
    //  PC_controll is a wire that contains data sent from the PC to FPGA.
    //  The data is communicated via memeory location 0x00

//    okWireIn wire10 (   .okHE(okHE), 
//                        .ep_addr(8'h00), 
//                        .ep_dataout(PCDATA));  
                       
//    okWireIn wire11 (   .okHE(okHE), 
//                        .ep_addr(8'h01), 
//                        .ep_dataout(STARTW));  

    
                      
//    okWireOut wire21 (  .okHE(okHE), 
//                    .okEH(okEHx[ 1*65 +: 65 ]), //unsure what this line is for but is giving errors
//                    .ep_addr(8'h21), 
//                    .ep_datain(MSB));
                  
//    okWireOut wire20 (  .okHE(okHE), 
//                    .okEH(okEHx[ 0*65 +: 65 ]),
//                    .ep_addr(8'h20), 
//                    .ep_datain(LSB));    

    
    okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain(Sens_Data));
                        
    okWireIn wire10 (   .okHE(okHE),    // Read/Write: 2 = write, 1 = Read, 0 = do nothing with RW
                        .ep_addr(8'h00), 
                        .ep_dataout(RW));                                        
    
    okWireIn wire11 (   .okHE(okHE), 
                        .ep_addr(8'h01),  // address 0b00110010
                        .ep_dataout(Data));
    
    okWireIn wire12 (   .okHE(okHE), 
                        .ep_addr(8'h02), // address 0b00110011
                        .ep_dataout(Data_2));                                       
    
    okWireIn wire13 (   .okHE(okHE), 
                        .ep_addr(8'h03), // set to 0x20 first then 0x29
                        .ep_dataout(Array1));
    
    okWireIn wire14 (   .okHE(okHE), 
                        .ep_addr(8'h04), // address 0b10010111
                        .ep_dataout(Array2)); 

    okWireIn wire7 (   .okHE(okHE), 
                        .ep_addr(8'h07), // PC control
                        .ep_dataout(PC_control));
               
endmodule

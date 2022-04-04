//commented out okwires

`timescale 1ns / 1ps

module FSM(    
    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_1,
    inout  I2C_SDA_1,        
    output wire FSM_Clk_reg,    
    output wire ILA_Clk_reg,
    output wire ACK_bit,
    //output wire SCL,
    //output wire SDA,
    output reg [7:0] State,
    output wire [31:0] PCDATA,//changed to input
    //output wire [31:0] STARTR,
    output wire [31:0] STARTW, //changed to input
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,   
    inout wire okAA     
    );
    
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 1000; //1000   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
    
                                        
    wire [6:0] devaddrw = PCDATA[31:25];
    wire [7:0] regaddr = PCDATA[23:16];
    wire [7:0] DATA = PCDATA[15:8];
    wire RW = PCDATA[0]; 
    wire [7:0] currstateW;
    wire [7:0] currstateR;
    wire error_bit;
    wire [7:0] MSB;
    wire [7:0] LSB;   
    wire STARTR;
    wire WSTART;
    wire SDAW, SCLW, SDAR, SCLR;
    reg SDAreg, SCLreg, errorbit, ACKbit;
    wire ACK_bitW, ACK_bitR, error_bitR, error_bitW, DONE;
    
    Write write2read (  .devaddr(devaddrw),
                        .regaddr(regaddr),
                        .START(STARTW[0]),
                        .SDAW(SDAW),
                        .SCLW(SCLW),
                        .FSM_Clk(FSM_Clk),                                      
                        .ILA_Clk(ILA_Clk),
                        .FSM_Clk_reg(FSM_Clk_reg),
                        .ILA_Clk_reg(ILA_Clk_reg),
                        .State(currstateW),
                        .ACK_bit(ACK_bitW),
                        .error_bit(error_bitW),
                        .STARTR(STARTR),
                        .WSTART(WSTART),
                        .RW(RW),
                        .wdata(DATA),
                        .RDONE(DONE)
                      );
                      
    Read read_data (    .devaddr(DATA[7:1]),
                        .DATAL(LSB),
                        .DATAH(MSB),
                        .START(STARTR),
                        .SDAR(SDAR),
                        .SCLR(SCLR),
                        .FSM_Clk(FSM_Clk),                                      
                        .ILA_Clk(ILA_Clk),
                        .FSM_Clk_reg(FSM_Clk_reg),
                        .ILA_Clk_reg(ILA_Clk_reg),
                        .State(currstateR),
                        .ACK_bit(ACK_bitR),
                        .error_bit(error_bitR),
                        .DONE(DONE)
                      );     
       
    localparam STATE_INIT       = 8'd0;    
    assign led[7] = ACK_bit;
    assign led[6] = error_bit;     
    //assign I2C_SCL_1 = SCLreg; //high z's can't be passed through registers
    //assign I2C_SDA_1 = SDAreg;
    assign ACK_bit = ACKbit;
    assign error_bit = errorbit;
    assign I2C_SDA_1 = (WSTART)? SDAW : SDAR;
    assign I2C_SCL_1 = (WSTART)? SCLW : SCLR;

    
    always @(*) begin
        if (WSTART) begin
            SCLreg = SCLW;
            SDAreg = SDAW;
            State = currstateW;
            ACKbit = ACK_bitW;
            errorbit = error_bitW;
        end
        else if (STARTR) begin 
            SCLreg = SCLR;
            SDAreg = SDAR;  
            State = currstateR; 
            ACKbit = ACK_bitR;
            errorbit = error_bitR;   
        end
    
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
                       .ep_dataout(STARTW));  

    
                      
   okWireOut wire21 (  .okHE(okHE), 
                   .okEH(okEHx[ 1*65 +: 65 ]), //unsure what this line is for but is giving errors
                   .ep_addr(8'h21), 
                   .ep_datain(MSB));
                  
   okWireOut wire20 (  .okHE(okHE), 
                   .okEH(okEHx[ 0*65 +: 65 ]),
                   .ep_addr(8'h20), 
                   .ep_datain(LSB));             
           
               
endmodule

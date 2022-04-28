`timescale 1ns / 1ps

module BTPipeExample(
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA,
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,
    input [9:0] CVM300_D, //data_out (data to read)
    input CVM300_Data_valid, //DVAL
    input CVM300_Line_valid, //LVAL
    input CVM300_CLK_OUT, //CLK_OUT, FIFO_CLK
    output CVM300_CLK_IN, //10MHz
    output CVM300_SYS_RES_N, //IO
    output CVM300_FRAME_REQ,
    output CVM300_SPI_EN,
    output CVM300_SPI_IN,
    output CVM300_SPI_CLK,
    input CVM300_SPI_OUT,    
    output wire FSM_Clk,
    output wire ILA_Clk,        
    output [31:0] PC_control
    /*
    output [31:0] PC_data,
    output [31:0] return,
    //output [31:0] RST_FIFO,
    output [31:0] SYS_RST,
    output [31:0] grabimg,
    output wire [7:0] State_r,
    output reg [7:0] State
    */
    );
    

    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 1;   
    //*************uncomment if not use jteg************************//
    //wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
                                      
                                                                                  
    localparam STATE_INIT                = 8'd0;
    localparam STATE_RESET               = 8'd1;   
    localparam STATE_DELAY               = 8'd2;
    localparam STATE_RESET_FINISHED      = 8'd3;
    localparam FREM_REQ_START            = 8'd4;
    localparam FREM_REQ_END              = 8'd5;
    localparam STATE_FINISH              = 8'd6;
    localparam STATE_SYSRESN             = 8'd7;
    localparam STATE_GRABIMG             = 8'd8;
   
    reg [31:0] counter = 8'd0;
    reg [15:0] counter_delay = 16'd0;
    wire [7:0] State_r;
    reg [7:0] State;
    reg framereqreg;
    reg sysresnreg;

    reg [7:0] led_register = 0;
    reg [3:0] button_reg, write_enable_counter;  
    reg write_reset, read_reset, DVAL;
    //*************uncomment if not use jteg************************//
   //wire [31:0] PC_control;
    wire [31:0] PC_data;
    wire [31:0] return;    
    wire [31:0] RST_FIFO;
    wire [31:0] SYS_RST;
    wire [31:0] grabimg;
    wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
    wire [31:0] FIFO_data_out;
    
    //wr_en = DVAL, wr_clk = CLK_OUT, din[7:0] = Data_Out[9:2]
    //wr_rst and re_rst are the same
    
    assign led[0] = ~FIFO_empty; 
    assign led[1] = ~FIFO_full;
    assign led[2] = ~FIFO_BT_BlockSize_Full;
    assign led[3] = ~FIFO_read_enable;  
    assign led[7] = ~read_reset;
    assign led[6] = ~write_reset;
    
    assign CVM300_FRAME_REQ = framereqreg; 
    assign CVM300_SYS_RES_N = sysresnreg;
    
    initial begin
        write_reset <= 1'b0;
        read_reset <= 1'b0;
        State <= STATE_INIT;
        sysresnreg <= 1'b1;
    end
                                         
    always @(negedge FSM_Clk) begin     
        //button_reg <= ~button;   // Grab the values from the button, complement and store them in register                
        if (grabimg[0] == 1'b1) State <= STATE_RESET;
        
        case (State)
            STATE_INIT:   begin                              
                if (SYS_RST[0] == 1'b0) begin
                    sysresnreg <= 1'b0;
                    State <= STATE_SYSRESN;
                end  
            end
            
            STATE_SYSRESN: begin
                if (SYS_RST[0] == 1'b1) begin
                    sysresnreg <= 1'b1;
                    State <= STATE_GRABIMG;
                end
            end
            
            STATE_GRABIMG: begin
                //write_reset <= 1'b1;
                //read_reset <= 1'b1;
                if (grabimg[0] == 1'b1) State <= STATE_RESET;              
            end
            
            STATE_RESET:   begin
                counter <= 0;
                counter_delay <= 0;
                write_reset <= 1'b1;
                read_reset <= 1'b1;               
                if (grabimg[0] == 1'b0) State <= STATE_RESET_FINISHED;             
            end                                     
 
           STATE_RESET_FINISHED:   begin
                write_reset <= 1'b0;
                read_reset <= 1'b0;                 
                State <= STATE_DELAY;                                   
            end   
                          
            STATE_DELAY:   begin
                if (counter_delay == 16'b0000_1111_1111_1111)  State <= FREM_REQ_START;
                else counter_delay <= counter_delay + 1;
            end
            
             FREM_REQ_START:   begin
                //write_enable <= 1'b1;
                framereqreg <= 1'b1;
                State <= FREM_REQ_END;
             end
                                  
             FREM_REQ_END:   begin
                counter <= counter + 1;       //what is the point of the counter here?      
                framereqreg <= 1'b0;                
                if (counter == 1024)  State <= STATE_FINISH;         
             end
            
             STATE_FINISH:   begin                         
                State <= STATE_GRABIMG;                                                           
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
   
       
    fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
        .wr_clk(~CVM300_CLK_OUT),
        .wr_rst(write_reset),
        .rd_clk(okClk),
        .rd_rst(read_reset),
        .din(CVM300_D[9:2]),
        .wr_en(CVM300_Data_valid),
        .rd_en(FIFO_read_enable),
        .dout(FIFO_data_out),
        .full(FIFO_full),
        .empty(FIFO_empty),       
        .prog_full(FIFO_BT_BlockSize_Full)        
    );
      
    okBTPipeOut CounterToPC (
        .okHE(okHE), 
        .okEH(okEHx[ 0*65 +: 65 ]),
        .ep_addr(8'ha0), //multiple driver net issue
        .ep_datain(FIFO_data_out), 
        .ep_read(FIFO_read_enable),
        .ep_blockstrobe(BT_Strobe), 
        .ep_ready(FIFO_BT_BlockSize_Full)
    );                                      
     
     
        SPI_FSM SPI_reg (        
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),           
        .FSM_Clk(FSM_Clk),        
        .State(State_r),
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
                       .ep_dataout(PC_control)); //signal to tell start SPI settings (reading and writing SPI registers)
                       
    okWireIn wire11 (   .okHE(okHE), 
                       .ep_addr(8'h01), 
                       .ep_dataout(PC_data)); //data used to set SPI settings
    /*                   
    okWireIn wire12 (   .okHE(okHE), 
                   .ep_addr(8'h02), 
                   .ep_dataout(RST_FIFO));  
    */               
    okWireIn wire13 (   .okHE(okHE), 
                   .ep_addr(8'h03), 
                   .ep_dataout(SYS_RST));  
                   
    okWireIn wire14 (   .okHE(okHE), 
                   .ep_addr(8'h04), 
                   .ep_dataout(grabimg)); 
                       
    okWireOut wire21 (  .okHE(okHE), 
                   .okEH(okEHx[ 1*65 +: 65 ]),
                   .ep_addr(8'h21), 
                   .ep_datain(return));  //return returns data of registers we are reading from                    
                        
                                          
endmodule

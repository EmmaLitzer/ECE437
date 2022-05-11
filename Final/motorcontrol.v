`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2022 09:45:03 AM
// Design Name: 
// Module Name: MotorControl
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


module MotorControl(

        output [7:0] led,
        input  sys_clkn,
        input  sys_clkp,
        input slow_clk,        
        output PMOD_A1,
        output PMOD_A2,
        input wire [31:0] motor_control, //start to trigger FSM
        input wire [31:0] Pulses, //number of pulses motor should go on for
        input wire [31:0] dirinput, //direction of motor: 0 = forward, 1= reverse inputed from PC
        input wire [31:0] dutycycle, //duty cycle
        input  wire    [4:0] okUH,
        output wire    [2:0] okHU,
        inout  wire    [31:0] okUHU,   
        inout wire okAA 

    );
    
    
    //reg [23:0] clkdiv;
    //reg slow_clk;
    reg [7:0] pcounter; //counter to count how many pulses have been passed
    reg [7:0] counter, State; //counter to count how much DC 1's and 0's have been passed
    reg ENr; //regiter to hold enable value
    reg DIRr; //register to hold direction value
    /*
    // This section defines the main system clock from two
    //differential clock signals: sys_clkn and sys_clkp
    // Clk is a high speed clock signal running at ~200MHz
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    */
    initial begin
        //clkdiv = 0;
        pcounter = 0;
        counter = 0;
        State = 0;
        ENr = 0;
    end
    /*  
    // This code creates a slow clock from the high speed Clk signal
    // You will use the slow clock to run your finite state machine
    // The slow clock is derived from the fast 20 MHz clock by dividing it 10,000,000 time
    // Hence, the slow clock will run at 200 Hz
    always @(posedge clk) begin
        clkdiv <= clkdiv + 1'b1;
        if (clkdiv == 1000) begin //want slow clock used in FSM to be 100x's faster than desired 200Hz frequency of PWM 
            slow_clk <= ~slow_clk; 
            clkdiv <= 0;
        end
    end
    */
    localparam STATE_INIT       = 8'd0;  
    assign PMOD_A1 = ENr; //assign enable register to enable output wire signal
    assign PMOD_A2 = DIRr; //assing direction reigster to direction output wire signal
    //assign FSM_Clk_reg = slow_clk;        
    //assign ILA_Clk_reg = clk;

    always @(posedge slow_clk) begin                       
        case (State)
            // Press signal from PC is sent in, start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                if (motor_control[0]==1) begin
                    State <= 8'd1;
                end
                else begin
                    State <= 8'd0;
                end
            end         
            
            8'd1 : begin
                pcounter <= pcounter + 1'b1;
                counter <= 0;
                ENr <= 1;
                DIRr <= dirinput;
                State <= State + 1'b1;
            end
            
            8'd2 : begin
                if (counter >= dutycycle) begin
                    ENr <= 0;
                    if (counter >= 100) begin
                        if (pcounter == Pulses) begin
                            State <= 8'd0; 
                            pcounter <= 0;
                        end
                        else 
                            State <= 8'd1;  
                   end
                   else begin
                        counter <= counter + 1'b1;
                        State <= 8'd2;
                   end
                   
                end  
                else begin
                    counter <= counter + 1'b1;
                    State <= 8'd2;
                end
            end

        endcase
    end

/*

// OK Interface
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication 
        //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 2 output endpoints, hence endPt_count = 2.
    localparam  endPt_count = 0;
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
    
    //  motor_control is a wire that contains data sent from the PC to FPGA.
    //  The data is communicated via memeory location 0x00
   okWireIn wire10 (   .okHE(okHE), 
                       .ep_addr(8'h00), 
                       .ep_dataout(motor_control)); //signal to tell motor control to start
                       
   okWireIn wire11 (   .okHE(okHE), 
                       .ep_addr(8'h01), 
                       .ep_dataout(Pulses)); //signal to tell motor how many pulses to go for
                       
   okWireIn wire12 (   .okHE(okHE), 
                       .ep_addr(8'h02), 
                       .ep_dataout(dirinput)); //signal to tell motor what direction to go in
                       
   okWireIn wire13 (   .okHE(okHE), 
                       .ep_addr(8'h03), 
                       .ep_dataout(dutycycle)); //signal to tell motor what direction to go in                       

*/
endmodule











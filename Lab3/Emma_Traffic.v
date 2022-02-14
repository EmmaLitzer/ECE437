`timescale 1ns / 1ps


module Emma_v2(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp  
    );

    reg [2:0]   state = 0;
    reg [7:0]   led_register = 0;
    reg [3:0]   button_reg;    
    reg [28:0]  counter=0;  //used to count clock cycles for time delay in each state
    reg [1:0]   P=0;        //P-signal stores if pedestrian button is pressed, stored until traffic light stop states
    reg [1:0]   L=0;        //L-signal stores which was the last light direction so pedestrian state knows which light state to go to after 1s
                
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    assign led = ~led_register; //map led wire to led_register
    localparam STATE_NS_G      = 3'd0; 
    localparam STATE_NS_Y      = 3'd1;
    localparam STATE_EW_G      = 3'd2;
    localparam STATE_EW_Y      = 3'd3;              
    localparam STATE_PED_G     = 3'd4;
    localparam STATE_All_R     = 3'd5; //Not needed
    
    parameter G_timer            = 32'd1000;
    parameter Y_timer            = 32'd500;

    
    ////////// LIGHTS /////////
    // 0  0  0  0  0  0  0  0
    // R1 Y1 G1 R2 Y2 G2 R3 G3
    // |--NS--| |--EW--| |-PED-|
      
    always @(posedge clk)
    begin       
        button_reg = ~button;
        
        //if (button_reg == 4'b1000) begin
        //    led_register <= 8'b11111111;
        //end

        
        ////
        ////
        
//        else if (button_reg == 4'b0001) begin
        case (state)
                STATE_NS_G : begin
                    counter <= counter + 1;
                    if (counter == G_timer) begin
                        counter<=0;
                        state<= STATE_NS_Y;
                    end
                    led_register <= 8'b00110010; //8'b10000101
                    if (button_reg == 4'b0100)  P <= 1;                                                                     
                end

                STATE_NS_Y : begin
                    counter <= counter + 1;
                    if (counter == Y_timer/2) begin
                        counter <= 0;
                        if (P == 1 ) begin
                            state <= STATE_PED_G;
                            L=0;
                        end
                        else state<= STATE_EW_G;
                    end
                    led_register <= 8'b01010010; //8'b01000101;  
                    if (button_reg == 4'b0100)  P <= 1;                                                                        
                end

                STATE_EW_G : begin
                    counter <= counter + 1;
                    if (counter == G_timer) begin
                        counter <= 0;
                        state <= STATE_EW_Y;
                    end
                    led_register <= 8'b10000110; //8'b00110001 
                    if (button_reg == 4'b0100)  P <= 1;                                                                        
                end

                STATE_EW_Y : begin
                    counter <= counter+1;
                    if (counter == Y_timer/2) begin
                        counter<=0;
                        if (P == 1) begin
                            state <= STATE_PED_G;
                            L=1;
                        end
                        else state <= STATE_NS_G;
                    end
                    led_register <= 8'b10001010; //8'b00101001 
                    if (button_reg == 4'b0100)  P<=1;                                                                       
                end
                
                STATE_PED_G : begin
                    counter <= counter+1;
                    if (counter == G_timer) begin
                        counter<=0;
                        P=0;
                        if (L == 0)
                            state <= STATE_EW_G;
                        else
                            state <= STATE_NS_G;
                    end
                    led_register <= 8'b10010001; //8'b00100110                                                                          
                end
                
                default: state <= STATE_NS_G;
                
        endcase
    end                           
    //end    

endmodule

`timescale 1ns / 1ps
module Intersection_Ctrl(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp  
    );

    reg [2:0] state = 5;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg;  
    reg P = 0;  // P-signal stores if pedestrian button is pressed, stored until traffic light stop states
    reg L; // L-signal stores which was the last light direction so pedestrian state knows which light state to go to after 1s
    reg [31:0] counter = 0; //used to count clock cycles for time delay in each state
                
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    assign led = ~led_register; //map led wire to led_register
    localparam STATE_NSG    = 3'd0; //north south green light state
    localparam STATE_NSY    = 3'd1; //north south yellow light state
    localparam STATE_EWG    = 3'd2; //east west green light state
    localparam STATE_EWY    = 3'd3; //east west yellow light state
    localparam STATE_PEDG   = 3'd4; //pedestrian green light state
    localparam STATE_HOLD   = 3'd5; //no lights are on, haven't started yet
      
    always @(posedge clk) //use just clk for testbench
    begin  
        // Initial values     
        button_reg= ~button; 
        
        if (button_reg == 4'b0001) begin
            state <= STATE_HOLD;
        end
        
        if (button_reg==4'b1000) begin
            state <= STATE_NSG;
        end

        else
        begin
            case (state)
                STATE_NSG : begin
                    led_register <= 8'b00110010; //'d50

                    if (counter >= 20_000_000) begin //for board
                    //if (counter >= 10) begin //for testbench
                        state <= STATE_NSY;
                        counter <= 0;
                    end  
                    else begin
                        if (button_reg == 4'b0100) begin
                            P <= 1;
                            L <= 0;
                        end
                        counter <= counter + 1'b1;
                    end                                                                   
                end

                STATE_NSY : begin
                   led_register <= 8'b01010010; //'d82

                   if (counter >= 10_000_000) begin //for board
                   //if (counter >= 5) begin //for testbench
                        if (P) begin
                            state <= STATE_PEDG;
                            counter <= 0;
                        end
                        else begin
                            state <= STATE_EWG;
                            counter <= 0;
                        end
                   end
                   else begin
                        if (button_reg == 4'b0100) begin
                            P <= 1;
                            L <= 0;
                        end
                        counter <= counter+1'b1;
                   end
                end

                STATE_EWG : begin
                    led_register <= 8'b10000110; //'d134

                    if (counter >= 20_000_000) begin //for board
                    //if (counter >= 10) begin //for testbench
                        state <= STATE_EWY;
                        counter <= 0;
                    end  
                    else begin
                        if (button_reg == 4'b0100) begin
                            P <= 1;
                            L <= 1;
                        end
                        counter <= counter + 1'b1;
                    end                                                                        
                end

                STATE_EWY : begin
                   led_register <= 8'b10001010; //'d138
                  
                   if (counter >= 10_000_000) begin //for borad
                   //if (counter >= 5) begin //for testbench
                        if (P) begin
                            state <= STATE_PEDG;
                            counter <= 0;
                        end
                        else begin
                            state <= STATE_NSG;
                            counter <= 0;
                        end
                   end
                   else begin
                        if (button_reg == 4'b0100) begin
                            P <= 1;
                            L <= 1;
                        end
                        counter <= counter+1'b1;
                   end                                                                      
                end
                
                STATE_PEDG: begin
                
                    led_register <= 8'b10010001; //'d145
                    if (counter >= 20_000_000) begin //for board
                    //if (counter >= 10) begin //for testbench
                        if (L==0) begin
                            P <= 0;
                            state <= STATE_EWG;
                            counter <= 0;
                        end
                        else if (L==1) begin
                            P <= 0;
                            state <= STATE_NSG;
                            counter <= 0;
                        end
                    end  
                    else 
                        counter <= counter + 1'b1;
                end
                
                STATE_HOLD: begin
                    counter <= 0;
                    led_register <= 0;
                end
                
                default: state <= STATE_HOLD;
                
            endcase
        end                           
    end    
endmodule

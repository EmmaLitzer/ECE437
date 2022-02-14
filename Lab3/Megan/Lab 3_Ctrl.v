`timescale 1ns / 1ps
module Intersection_Ctrl(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp  
    );

    reg [2:0] state = 0;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg;  
    reg P;  // P-signal stores if pedestrian button is pressed, stored until traffic light stop states
    reg L; // L-signal stores which was the last light direction so pedestrian state knows which light state to go to after 1s
    reg [7:0] counter; //used to count clock cycles for time delay in each state
                
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    assign led = ~led_register; //map led wire to led_register
    localparam STATE_NSG    = 3'd0;
    localparam STATE_NSY    = 3'd1;
    localparam STATE_EWG    = 3'd2;
    localparam STATE_EWY    = 3'd3; 
    localparam STATE_PEDG   = 3'd4;
    localparam STATE_HOLD   = 3'd5;    
      
    always @(posedge clk)
    begin  
        // Initial values     
        button_reg= ~button; 
        counter = 0;
        
        if (button_reg==0) begin
            state <= STATE_HOLD;
        end
        else if (button_reg==4'd8) begin
            state <= STATE_NSG;
        end
        
        // pedestrian button is button[2] - if button=1 (on), if button=0 (off)
        // if button is pressed, register P will store signal
        if (~button[2]) begin //////not sure if this is the right location for it
            P <= 1;
        end     

        else
        begin
            case (state)
                STATE_NSG : begin
                    led_register <= 8'd50;
                    if (P) begin
                        L <= 0;
                    end
                    else
                    if (counter >= 200_000_000) begin
                        state <= STATE_NSY;
                        counter <= 0;
                    end  
                    else begin
                        counter <= counter + 1'b1;
                    end                                                                   
                end

                STATE_NSY : begin
                   led_register <= 8'd82;
                   if (counter >= 100_000_000) begin
                        if (P) begin
                            L <= 0;
                            state <= STATE_PEDG;
                        end
                        else begin
                            state <= STATE_EWG;
                            counter <= 0;
                        end
                   end
                   else begin
                        counter <= counter+1'b1;
                   end
                end

                STATE_EWG : begin
                    led_register <= 8'd134;
                    if (P) begin
                        L <= 1;
                    end
                    if (counter >= 200_000_000) begin
                        state <= STATE_EWY;
                        counter <= 0;
                    end  
                    else begin
                        counter <= counter + 1'b1;
                    end                                                                        
                end

                STATE_EWY : begin
                   led_register <= 8'd138;
                   if (counter >= 100_000_000) begin
                        if (P) begin
                            L <= 1;
                            state <= STATE_PEDG;
                        end
                        else begin
                            state <= STATE_NSG;
                            counter <= 0;
                        end
                   end
                   else begin
                        counter <= counter+1'b1;
                   end                                                                      
                end
                
                STATE_PEDG: begin
                
                    led_register <= 8'd145;
                    if (counter >= 200_000_000) begin
                        if (L==0) begin
                            state <= STATE_EWG;
                            counter <= 0;
                        end
                        else if (L==1) begin
                            state <= STATE_NSG;
                            counter <= 0;
                        end
                    end  
                    else 
                        counter <= counter + 1'b1;
                end
                
                STATE_HOLD: begin
                    led_register <= 0;
                end
                
                default: state <= STATE_HOLD;
                
            endcase
        end                           
    end    
endmodule


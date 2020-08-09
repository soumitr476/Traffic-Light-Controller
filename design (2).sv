module TrafficController(sensor,clk,rst,Light_Highway,Light_Crossing);
  input clk,rst,sensor;
  output reg[1:0]Light_Highway,Light_Crossing; // output of lights
  
  parameter HighwayGreen_CrossingRed = 2'b00,
  HighwayYellow_CrossingRed = 2'b01,
  HighwayRed_CrossingGreen = 2'b10,
  HighwayRed_CrossingYellow = 2'b11;
  
   reg[27:0] count = 0;
   reg[27:0] count_delay = 0;
  
  reg delay3sHighway = 0,delay3sCrossing = 0,Red_count =           0,Yellow_count1 = 0,Yellow_count2 = 0,delay10s = 0;
  
  wire clk_en; // clock enable signal for 1s
  reg[1:0] state;
  reg[1:0] nxt_state;
  
  always@(posedge clk or negedge rst)
    begin
      if(!rst)
        state <= 2'b00;
      else
        state <= nxt_state;
    end
  
  always@(*)
    begin
      case(state)
        HighwayGreen_CrossingRed: begin
          Red_count=0;
          Yellow_count1=0;
          Yellow_count2=0;
          Light_Highway = 2'b10;
          Light_Crossing = 2'b00;
          
          if(sensor)
            nxt_state = HighwayYellow_CrossingRed; 
          // if sensor detects vehicles on crossing road, 
         // turn highway to yellow -> green
           else 
             nxt_state = HighwayGreen_CrossingRed;
        end
        
        HighwayYellow_CrossingRed: begin
           Red_count=0;
           Yellow_count1=1;
           Yellow_count2=0;
           Light_Highway = 2'b01;
           Light_Crossing = 2'b00;
          
          if(delay3sHighway)
              nxt_state = HighwayRed_CrossingGreen;
          // yellow for 3s, then red
            else 
              nxt_state = HighwayYellow_CrossingRed;
        end
        
        HighwayRed_CrossingGreen: begin
           Red_count=1;
           Yellow_count1=0;
           Yellow_count2=0;
           Light_Highway = 2'b00;
           Light_Crossing = 2'b10;
          
          if(delay10s)
            nxt_state = HighwayRed_CrossingYellow;
          // red in 10s then turn to yellow -> green again for high way
          else
            nxt_state =  HighwayRed_CrossingGreen;
        end
        
        HighwayRed_CrossingYellow: begin
           Red_count=0;
           Yellow_count1=0;
           Yellow_count2=1;
           Light_Highway = 2'b00;
           Light_Crossing = 2'b01;
          
          if(delay3sCrossing)
            nxt_state = HighwayGreen_CrossingRed;
          // turn green for highway, red for crossing road
          else
            nxt_state =  HighwayRed_CrossingYellow;
        end
        default: nxt_state = HighwayGreen_CrossingRed;
        endcase
        end
  
  // create red and yellow delay counts
  always @(posedge clk)
begin
  if(clk_en) begin
  if(Red_count||Yellow_count1||Yellow_count2)
  count_delay <= count_delay + 1;
    
    if((count_delay == 9) && Red_count) 
  begin
   delay10s=1;
   delay3sHighway=0;
   delay3sCrossing=0;
   count_delay<=0;
  end
  else if((count_delay == 2)&&Yellow_count1) 
  begin
   delay10s=0;
   delay3sHighway=1;
   delay3sCrossing=0;
   count_delay<=0;
  end
  else if((count_delay == 2)&&Yellow_count2) 
  begin
   delay10s=0;
   delay3sHighway=0;
   delay3sCrossing=1;
   count_delay<=0;
  end
  else
  begin
   delay10s=0;
   delay3sHighway=0;
   delay3sCrossing=0;
  end 
 end
end
 
  // create 1s clock enable 
  always @(posedge clk)
begin
 count <= count + 1;
 //if(count == 50000000) // 50,000,000 for 50 MHz clock running on real FPGA
 if(count == 3) // for testbench
  count <= 0;
end
 assign clk_en = count==3 ? 1: 0; // 50,000,000 for 50MHz running on FPGA
endmodule 
          
        
        
          

          
        
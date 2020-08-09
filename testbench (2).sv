module test_traffic;
 reg clk;
reg  rst;
reg sensor;
  wire [1:0] Light_Crossing;
  wire [1:0] Light_Highway;
  
  
  TrafficController tb(sensor,clk,rst,Light_Highway,Light_Crossing);
  

  
initial
 begin
 $dumpfile("dump.vcd");
 $dumpvars(1,test_traffic);
 clk = 1'b0;
 rst = 1'b0;
 sensor = 1'b0;
 end 
  
initial
  #200 $finish;
  
initial
  begin
    repeat(60)
    #5 clk = ~clk;
  end
  
initial
  begin
    #1 rst = 1'b1;
    #10 sensor = 1;
  end
  
endmodule  
module ddio #(
  parameter NUM_DEVICE = 1)(
  
  
 input clk,
 input reset,
 
 input [NUM_DEVICE-1:0] clk_oe,
 
 output [NUM_DEVICE-1:0] clk_out
 );
 
 reg dataout;
 
 
 always @ (posedge clk or posedge reset) begin
   if(reset)
     dataout <= 1'b0;
   else
     dataout <= ~dataout;
  end
  
  genvar i;
  generate
  for (i = 0; i < NUM_DEVICE; i = i + 1) begin : _ddr_generic_inst_block_
    ddr_generic ddr_generic_inst (
	  .clk (clk),
	  .reset (reset),
	  .tristate (~clk_oe[i]),
	  .dataout({2{dataout}}),
	  .clkout (),
	  .sclk (),
	  .dout (clk_out[i])
	  );
	  end
	endgenerate
	
endmodule
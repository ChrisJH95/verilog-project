/*
 Simple counter with generic bitwidth .
 */

 `default_nettype none
 `ifndef __COUNTER__
 `define __COUNTER__

 module sigma_delta
 #(
 parameter BW = 8 // optional parameter
 ) (
 // define I /O ’ s of the module
 input clk_i , // clock
 input rst_i , // reset
 input signed [BW-1:0] dac_i, //input
 output wire dac_o
 ) ;

 // start the module implementation

 // register to store the counter value
 reg signed [BW-1:0] register_val;
 reg signed [BW-1:0] delta_val;
 reg dac_reg;

 // assign the counter value to the output
 //assign acc_o = register_val;
 assign dac_o = dac_reg;
 //assign delta_o = delta_val;

 always @ ( posedge clk_i ) begin
 // gets active always when a positive edge of the clock signal occours
 
 if ( rst_i == 1'b1 ) begin
 // if reset is enabled, all registers are rest
 register_val <= {BW {1'b0 }};
 delta_val <= {BW {1'b0 }};
 dac_reg <= 1'b0;
 end else begin
 if(dac_o == 1'b0) begin //DAC output is 0
  if(dac_i + $signed({1'b0,{(BW-1){1'b1}}}) < dac_i) begin
     delta_val <= {1'b0,{(BW-1){1'b1}}};
   end else begin
  delta_val <= dac_i + $signed({1'b0,{(BW-1){1'b1}}});
  end
 end
 
 if(dac_o == 1'b1) begin
   if(dac_i + $signed({1'b1,{(BW-1){1'b0}}}) > dac_i) begin
     delta_val <= {1'b1,{(BW-1){1'b0}}};
   end else begin
  delta_val <= dac_i + $signed({1'b1,{(BW-1){1'b0}}});
  end
 end
 
 //summing up the inputs, with overflow protection
 if(delta_val > {BW {1'b0}}) begin
   if(register_val + delta_val < register_val) begin
     register_val <= {1'b0,{(BW-1){1'b1}}};
   end else begin
  register_val <= register_val + delta_val;
  end
 end 
 
  if(delta_val <= $signed({BW {1'b0 }})) begin
   if(register_val + delta_val > register_val) begin
     register_val <= {1'b1,{(BW-1){1'b0}}};
   end else begin
  register_val <= register_val + delta_val;
  end
 end 
 
 //switching the output to 1 for positive accumulator values, and 0 for negative values
  if(register_val >= $signed({BW {1'b0}})) begin
   dac_reg <= 1'b1;
  end else begin
   dac_reg <= 1'b0;
  end
  
  end
 end

 endmodule // counter

`endif
`default_nettype wire

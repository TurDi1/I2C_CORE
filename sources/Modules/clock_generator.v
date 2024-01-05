module clock_generator (
   reset,
   clk,
   freq_mode,
   output_clk
);

input       reset;      // System reset input
input       clk;        // System clock input
input [1:0] freq_mode;  // I2C mode selector
output      output_clk;	// Output clock for internal core i2c logic and SCL port 

//==================
// Wire's, reg's etc
reg   [8:0] freq_divider;  // Counter for divide system clock
reg         out_clk_ff = 0;    // flip-flop of output clock value

//==================
// Assignments
assign   output_clk = out_clk_ff;

//==================
// Selector logic
always @ (freq_mode, freq_divider[8:0])
begin
   case (freq_mode)
      // In string below i wrote some shit
      2'b00    :  out_clk_ff = (!freq_divider[0] & !freq_divider[1] & freq_divider[2] & !freq_divider[3] & freq_divider[4] & freq_divider[5] & freq_divider[6] & freq_divider[7] & freq_divider[8]) ? (~out_clk_ff) : (out_clk_ff); // Standard-mode 
      2'b01    :  out_clk_ff = 0;   // Fast-mode
      2'b10    :  out_clk_ff = 0;   //
      2'b11    :  out_clk_ff = 0;   //
      default  :  out_clk_ff = 0;   
   endcase
end

//==================
// Divider logic
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      freq_divider   <= 0;
   else if (clk)
      freq_divider   <= freq_divider + 1;
   else
      freq_divider   <= freq_divider;
end
//
endmodule 
module clock_generator (
   reset,
   clk,
   freq_mode,
   output_clk
);

input       reset;      // System reset input
input       clk;        // System clock input (50 MHz)
input [1:0] freq_mode;  // I2C mode selector
output reg  output_clk;	// Output clock for internal core i2c logic and SCL port 

//==================
// Wire's, reg's etc
reg   [7:0] freq_divider;  // Counter for divide system clock
reg   [7:0] divider;       // Register for storage divide value
reg         out_clk_ff;    // flip-flop of output clock value

//==================
// Assignments
assign   output_clk = out_clk_ff;

//==================
// Selector logic
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      divider  <= 0;
   else
   begin
      case (freq_mode)
         2'b00    :  divider = 8'd124;   // Standard-mode
         2'b01    :  divider = 8'd31;    // "Fast-mode"
         2'b10    :  divider = 8'd12;    // "Fast-mode Plus"
         2'b11    :  divider = 8'd3;     // "High-speed mode"
         default  :  divider = 8'd124;   // Default - Standard-mode
      endcase
   end
end

//==================
// Counter logic
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      freq_divider   <= 0;
   else if (freq_divider[7:0] == divider[7:0])
      freq_divider   <= 0;
   else
      freq_divider   <= freq_divider + 1;
end

//==================
// Output ff logic
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      out_clk_ff  <= 0;
   else if (freq_divider[7:0] == divider[7:0])
      out_clk_ff  <= ~out_clk_ff;
   else
      out_clk_ff  <= out_clk_ff;
end
endmodule 
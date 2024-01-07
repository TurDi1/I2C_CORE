module clock_generator (
   reset,
   clk,
   freq_mode,
   output_clk,
   output_clk_6x
);

input       reset;         // System reset input
input       clk;           // System clock input (50 MHz)
input [1:0] freq_mode;     // I2C mode selector
output reg  output_clk;    // Output clock for SCL port 
output reg  output_clk_6x; // Output 6x clock for internal core i2c logic

//==================
// Wire's, reg's etc
reg   [7:0] freq_divider;  // Counter for divide system clock
reg   [4:0] freq_divider6x;// Append counter for divide system clock 
reg   [7:0] divider;       // Register for storage divide value
reg   [4:0] divider6x;     // Register for storage divide value 6x
reg         out_clk_ff;    // flip-flop of output clock value
reg         out_clk6x_ff;  // flip-flop of output 6x clock value 

//==================
// Assignments
assign   output_clk = out_clk_ff;
assign   output_clk_6x = out_clk6x_ff;

//=======================
// Selector logic for SCL
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      divider  <= 0;
   else
   begin
      case (freq_mode)
         2'b00    :  divider = 8'd124;   // 100 kHz (Standard-mode)
         2'b01    :  divider = 8'd31;    // 400 kHz ("Fast-mode")
         2'b10    :  divider = 8'd12;    // 1 MHz ("Fast-mode Plus")
         2'b11    :  divider = 8'd3;     // 3.4 MHz ("High-speed mode")
         default  :  divider = 8'd124;   // Default - Standard-mode
      endcase
   end
end

//=======================================================
// Selector logic for 6x clock of internal core i2c logic
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      divider6x<= 0;
   else
   begin
      case (freq_mode)
         2'b00    :  divider6x = 5'd20; 
         2'b01    :  divider6x = 5'd4;  
         2'b10    :  divider6x = 5'd1;  
         2'b11    :  divider6x = 5'd0;  
         default  :  divider6x = 5'd20; 
      endcase
   end
end

//=======================
// Counters logic section
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      freq_divider   <= 0;
   else if (freq_divider == divider)
      freq_divider   <= 0;
   else
      freq_divider   <= freq_divider + 1;
end
//=======================
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      freq_divider6x   <= 0;
   else if (freq_divider6x == divider6x)
      freq_divider6x   <= 0;
   else
      freq_divider6x   <= freq_divider6x + 1;
end

//========================
// Output ff logic section
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      out_clk_ff  <= 0;
   else if (freq_divider == divider)
      out_clk_ff  <= ~out_clk_ff;
   else
      out_clk_ff  <= out_clk_ff;
end
//========================
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      out_clk6x_ff   <= 0;
   else if (freq_divider6x == divider6x)
      out_clk6x_ff   <= ~out_clk6x_ff; 
   else
      out_clk6x_ff   <= out_clk6x_ff;
end
//
endmodule 
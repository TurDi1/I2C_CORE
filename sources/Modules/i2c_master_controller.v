module i2c_master_controller (
   reset,
   clk,
   bus_clock,
   bus_clock6x,
   
   address_rw,
   Sr,
   
   read,
   data_in,
   empty_tx,
   
   write,
   data_out,
   
   busy,
   
   scl,
   sda
);

input          reset;         // System reset input
input          clk;           // System clock input, 50 MHz
input          bus_clock;     // Clock input for bus serial clock inout
input          bus_clock6x;   // 6x clock input for controller
input    [7:0] address_rw;    // Input bus with address and R/W bit
input          Sr;            // Repeated START signal for controller
output         read;          // Read signal output to FIFO TX
input    [7:0] data_in;       // Data bus from FIFO TX
input          empty_tx;      // Empty signal input from FIFO TX
output         write;         // Write signal output to FIFO RX
output   [7:0] data_out;      // Data bus to FIFO RX
output         busy;          // Output busy signal from controller
inout          scl;           // Serial clock inout
inout          sda;           // Serial data inout

//==================
// Wire's, reg's etc
reg				Sr_reg;
reg				clear_;

//==================
// Parameters


//==================
// Assignments
assign scl = bus_clock;
assign busy = Sr_reg;

//==================
// Sr storage logic
always @ (posedge clk or negedge reset or negedge clear_)
begin
	if (!reset | !clear_)
		Sr_reg	<= 0;
	else if (Sr)
		Sr_reg	<= 1;
	else
		Sr_reg	<= Sr_reg;
end

//
endmodule 
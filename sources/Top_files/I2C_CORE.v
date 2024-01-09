module I2C_CORE (
   reset,
   clk,
   mode,
   address_rw,
   Sr,
   data_in,
   wr_data,
   data_out,
   rd_data,
   busy,
   empty_rx,
   scl,
   sda
);

input          reset;      // System reset input
input          clk;        // System clock input, 50 MHz
input    [1:0] mode;       // I2C bus speed selector (For example "standard-mode" etc)
input    [7:0] address_rw; // Input bus with address and R/W bit
input          Sr;         // Repeated START signal for i2c controller  
input    [7:0] data_in;    // Data bus to I2C core
input          wr_data;    // Write data signal to I2C core
output   [7:0] data_out;   // Data bus from I2C core
input          rd_data;    // Read data signal from I2C core
output         busy;       // Output busy signal of core
output         empty_rx;   // Output 
inout          scl;        // Serial clock inout
inout          sda;        // Serial data inout

//==================
// Wire's, reg's etc
wire        bus_clock;
wire        bus_clock6x;

wire  [7:0] data_in_wire;
wire  [7:0] data_out_wire;

wire        empty_tx_wire;

wire        write_rx_wire;
wire        read_tx_wire;

//==================
// Assignments


//==================
// Instatiations
clock_generator clock_generator (
   .reset         (reset),
   .clk           (clk),
   .freq_mode     (mode),
   .output_clk    (bus_clock),
   .output_clk_6x (bus_clock6x)
);

i2c_master_controller i2c_master (
   .reset         (reset),
   .clk           (clk),
   .bus_clock     (bus_clock),
   .bus_clock6x   (bus_clock6x),
   .address_rw    (address_rw),
   .Sr            (Sr),
   .read          (read_tx_wire),
   .data_in       (data_in_wire),
   .empty_tx      (empty_tx_wire),   
   .write         (write_rx_wire),
   .data_out      (data_out_wire),
   .busy          (busy),
   .scl           (scl),
   .sda           (sda)
);

FIFO_TX	FIFO_TX (
	.clock   (clk),
	.data    (data_in),
	.rdreq   (read_tx_wire),
	.sclr    (!reset),
	.wrreq   (wr_data),
	.empty   (empty_tx_wire),
	.q       (data_in_wire)
);

FIFO_RX	FIFO_RX (
	.clock   (clk),
	.data    (data_out_wire),
	.rdreq   (rd_data),
	.sclr    (!reset),
	.wrreq   (write_rx_wire),
	.empty   (empty_rx),
	.q       (data_out)
);
//
endmodule 
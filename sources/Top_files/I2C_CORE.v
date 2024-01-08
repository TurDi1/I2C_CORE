module I2C_CORE (
   reset,
   clk,
   mode,
   data_in,
   wr_data,
   data_out,
   rd_data,
   scl,
   sda
);

input          reset;      // System reset input
input          clk;        // System clock input, 50 MHz
input    [1:0] mode;       // I2C bus speed selector (For example "standard-mode" etc)
input    [7:0] data_in;    // Data bus to I2C core
input          wr_data;    // Write data signal to I2C core
output   [7:0] data_out;   // Data bus from I2C core
input          rd_data;    // Read data signal from I2C core
inout          scl;        // Serial clock inout
inout          sda;        // Serial data inout

//==================
// Wire's, reg's etc
wire     bus_clock;
wire     bus_clock6x;

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
   .read          (),
   .data_in       (),
   .empty_tx      (),   
   .write         (),
   .data_out      (),   
   .scl           (scl),
   .sda           (sda)
);
//
endmodule 
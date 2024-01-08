module i2c_master_controller (
   reset,
   clk,
   bus_clock,
   bus_clock6x,
   
   read,
   data_in,
   empty_tx,
   
   write,
   data_out,
   
   scl,
   sda
);

input          reset;
input          clk;
input          bus_clock;
input          bus_clock6x;
output         read;
input    [7:0] data_in;
input          empty_tx;
output         write;
output   [7:0] data_out;
inout          scl;
inout          sda;

//==================
// Wire's, reg's etc


//==================
// Assignments
assign scl = bus_clock;


//
endmodule 
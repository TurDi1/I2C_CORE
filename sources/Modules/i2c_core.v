module i2c_core (
    clk,
    rst_n,
    
    start,
    stop,
    read_op,
    enable,
    repeat_start,
    
    clk_div,
    tx_data,
    rx_data,
    
    busy,
    ack,
    error,
    complete,
    
    scl,
    sda
);
//==================================
//        PORTS DESCRIPTION
//==================================
input           clk;            // System clock input
input           rst_n;          // System reset_n input

input           start;          // Start flag
input           stop;           // Stop flag
input           read_op;        // Read operation flag
input           enable;         // Enable flag
input           repeat_start;   // Repeat flag start

input   [15:0]  clk_div;        // Frequency divider value
input   [7:0]   tx_data;        // Transmit data bus
output  [7:0]   rx_data;        // Receive data bus

output          busy;           // Busy flag
output          ack;            // Acknowledge flag
output          error;          // Error flag
output          complete;       // Complete error

inout           sda;
inout           scl;

//==================================
//      WIRE'S, REG'S and etc
//==================================

//==================================
//          INSTATIATIONS
//==================================

endmodule



// SCL generator module
/*
clk (system)
   ↓
Clock Divider / Tick Generator
   ↓
Timing Counter
   ↓
FSM (phase controller)
   ↓
SCL Output Control (open-drain)
   ↓
scl_out + scl_oe
*/
module scl_generator #(
    parameter LOW_T  = 250,
    parameter HIGH_T = 250
) (
    rst_n,
    clk,

    enable,

    scl_in,
    scl_out,

    tick_low_end,
    tick_high_end
);
//==================================
//        PORTS DESCRIPTION
//==================================
input           rst_n;          // System reset_n input
input           clk;            // System clock input

input           enable;         // Enable flag

input           scl_in;         // actual line (for stretching)
output          scl_out;        // open-drain control

output          tick_low_end;
output          tick_high_end;
//==================================
//       Parameters and etc
//==================================
typedef enum logic [2:0] {
    IDLE,
    SCL_LOW,
    SCL_HIGH,
    WAIT_STRETCH,
} scl_state_t;

scl_state_t fsm_state;

//==================================
//      WIRE'S, REG'S and etc
//==================================


endmodule

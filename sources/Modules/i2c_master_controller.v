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
inout tri      scl;           // Serial clock inout
inout tri      sda;           // Serial data inout

//==================
// Wire's, reg's etc
reg				Sr_reg;
reg				clear_Sr_;

reg      [2:0] state;            // State register that storage current state of FSM

reg      [7:0] address_rw_reg;
reg      [7:0] data_byte_reg;

reg      [3:0] bit_counter;      // Counter with value of current sended or received bits (with ACK bit too)
reg      [7:0] shift_reg;
reg            shifter_enable;

reg      [2:0] clock6x_counter;
reg				clock6x_reset_;

reg            read_reg;
reg            busy_reg;

reg				scl_reg;
reg				sda_reg;
reg            enable;

//==================
// Parameters
parameter   idle  = 0;
parameter   start = 1;
parameter   tx    = 2;
parameter   rx    = 3;


//==================
// Assignments
assign read = read_reg;
assign busy = busy_reg;

assign sda = enable ? sda_reg : 1'bZ;
assign scl = enable ? scl_reg : 1'bZ;

//==================
// Sr storage logic
always @ (posedge clk or negedge clear_Sr_)
begin
   if (!clear_Sr_)
	begin
		if (!Sr)
			Sr_reg	<= 0;
   end
	else if (clk)
   begin
      if (Sr)
         Sr_reg	<= 1;
   end      
   else
      Sr_reg	<= Sr_reg;
end

//===================
// FSM
always @ (posedge clk or negedge reset)
begin
   if (!reset)
      state <= idle;
   else
      case (state)
      //==== Idle state
      idle: begin
         clock6x_reset_	<= 0;
//			clear_Sr_		<= 1;	// In idle state we don't reset Sr flip-flop // this value is not correct because Sr flip-flop is not initialize
         read_reg       <= 0;
			sda_reg			<= 1;
			scl_reg			<= 1;
         busy_reg       <= 0;
         //
         enable         <= 0;
         //
         shifter_enable <= 0;
         //==================
			if (!empty_tx)
			begin
            read_reg       <= 1;
            address_rw_reg	<= address_rw;
				state				<= start;					
			end
			else
			begin
				address_rw_reg	<= 0;
				state				<= idle;
			end				
      end
      //==== Start state
      start: begin
//			clear_Sr_		<= 1;
         read_reg       <= 0;
         busy_reg       <= 1;
         //
         enable         <= 1;
         //
         shifter_enable <= 0;
         data_byte_reg  <= data_in;
         //==================
         if (clock6x_counter == 2)
         begin
            // sda change 1->0
            sda_reg  <= 0;
            scl_reg  <= scl_reg;
         end   
         else if (clock6x_counter == 5)
         begin
            // scl change 1->0
            sda_reg        <= sda_reg;
            scl_reg        <= 0;
            clock6x_reset_	<= 0;
            state          <= address_rw_reg[0] ? rx : tx;
         end
         else
         begin
            sda_reg        <= sda_reg;
            scl_reg        <= scl_reg;
            clock6x_reset_	<= 1;
         end
      end
      //==== TX state
      tx: begin
         sda_reg        <= 1;          // Redirect this reg to shifter
         scl_reg        <= bus_clock;  // Redirect this reg to bus_clock
         busy_reg       <= busy_reg;
         //
         enable         <= 1;
         //==================
         shifter_enable <= 1;
         state          <= tx;
      end
      //==== RX state
      rx: begin
         sda_reg        <= 1;
         scl_reg        <= 1;
         busy_reg       <= busy_reg;
         state          <= idle;
      end
      endcase
end

//===========================
// Counter logic for 6x clock
always @ (posedge bus_clock6x or negedge clock6x_reset_)
begin
   if (!clock6x_reset_)
      clock6x_counter   <= 0;
   else if (bus_clock6x)
      clock6x_counter   <= clock6x_counter + 1;
   else
      clock6x_counter   <= clock6x_counter;   
end

//==========================
// 
always @ (posedge bus_clock)
begin
   
end
//
endmodule 
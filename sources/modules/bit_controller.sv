module bit_controller (
    rst_,
    clk,
    start_cmd,
    stop_cmd,
    write_bit_cmd,
    read_bit_cmd,
    bit_in,
    bit_out,
    busy,
    done,
    tick_start,
    tick_done,
    scl_in,
    sda_drive_low,
    sda_in
);
//==================================
//        PORTS DESCRIPTION
//==================================
input           rst_;               // System reset input
input           clk;                // System clock input - 100 MHz

// Commands (from byte controller)
input           start_cmd;          // 
input           stop_cmd;           // 
input           write_bit_cmd;      // 
input           read_bit_cmd;       // 

input           bit_in;             // Data to write
output          bit_out;            // Data read

output          busy;               // 
output          done;               // 

// SCL interface
output          tick_start;          
input           tick_done;           
input           scl_in;              

// SDA interface
output          sda_drive_low;       
input           sda_in;              

//==================================
//      WIRE'S, REG'S and etc
//==================================
reg             bit_out_reg;
reg             busy_reg;
reg             done_reg;
reg             tick_start_reg;
reg             sda_drive_low_reg;

typedef enum logic [3:0] {
    IDLE,

    // START / REPEATED START FSM PHASES
    START_A,
    START_B,
    START_C,

    // STOP FSM PHASES
    STOP_A,
    STOP_B,
    STOP_C,

    // WRITE BIT PHASES
    WRITE_SETUP,
    WRITE_SCL,

    // READ BIT PHASES
    READ_SETUP,
    READ_SCL,
    READ_SAMPLE,

    DONE
} state_t;

state_t         fsm_state;

//==================================
//          ASSIGNMENTS
//==================================
assign bit_out          = bit_out_reg;
assign busy             = busy_reg;
assign done             = done_reg;
assign tick_start       = tick_start_reg;
assign sda_drive_low    = sda_drive_low_reg;

//==================================
//             LOGIC
//==================================
always @(posedge clk or negedge rst_)
begin
    if (!rst_)
    begin
        fsm_state           <= IDLE;
        bit_out_reg         <= 0;
        busy_reg            <= 0;
        done_reg            <= 0;
        tick_start_reg      <= 0;
        sda_drive_low_reg   <= 0;
    end
    else
    begin
        case(fsm_state)
        IDLE:
        begin
            done_reg        <= 0;
            busy_reg        <= 0;
            
            // Handling commands
            if (start_cmd)
            begin
                busy_reg    <= 1;
                fsm_state   <= START_A;
            end
            else if (stop_cmd)
            begin
                busy_reg    <= 1;
                fsm_state   <= STOP_A;
            end
            else if (write_bit_cmd)
            begin
                busy_reg    <= 1;
                fsm_state   <= WRITE_SETUP;
            end
            else if (read_bit_cmd)
            begin
                busy_reg    <= 1;
                fsm_state   <= READ_SETUP;
            end
        end
        START_A: // Release SDA
        begin
            sda_drive_low_reg   <= 0; // Release SDA
            if (scl_in == 1)
                fsm_state       <=  START_B;
        end
        START_B: // SDA 1 -> 0
        begin
            sda_drive_low_reg   <= 1; // Pulldown SDA
            fsm_state           <= START_C;
        end
        START_C: // Pulling low of scl via generator
        begin
            tick_start_reg      <= 1;
            fsm_state           <= DONE;
        end
        STOP_A:
        begin
            sda_drive_low_reg   <= 1; // Pulldown SDA
            if (scl_in == 1)
                fsm_state       <= STOP_B;
        end
        STOP_B: // SDA 0 -> 1 while SCL high
        begin
            sda_drive_low_reg   <= 0; // Release SDA
            fsm_state           <= STOP_C;
        end
        STOP_C:
        begin
            fsm_state           <= DONE;
        end
        WRITE_SETUP:
        begin
            sda_drive_low_reg   <= ~bit_in;
            tick_start_reg      <= 1;
            fsm_state           <= WRITE_SCL;
        end
        WRITE_SCL:
        begin
            tick_start_reg      <= 0; 
            if (tick_done)
                fsm_state       <= DONE;
        end
        READ_SETUP:
        begin
            sda_drive_low_reg   <= 0; // Release SDA
            tick_start_reg      <= 1;
            fsm_state           <= READ_SCL;
        end
        READ_SCL:
        begin
            if (tick_done)
                fsm_state       <= READ_SAMPLE;
        end
        READ_SAMPLE:
        begin
            bit_out_reg         <= sda_in;
            fsm_state           <= DONE;
        end
        DONE:
        begin
            tick_start_reg  <= 0;
            done_reg        <= 1;
            busy_reg        <= 0;
            fsm_state       <= IDLE;
        end   
        endcase
    end
end
endmodule
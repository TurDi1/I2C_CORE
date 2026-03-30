module scl_generator (
    rst_,
    clk,
    mode,
    tick_start,
    tick_done,
    scl_in,
    scl_out
);
//==================================
//        PORTS DESCRIPTION
//==================================
input           rst_;               // System reset input
input           clk;                // System clock input - 100 MHz
input   [1:0]   mode;               // I2C mode setting input bus
input           tick_start;         // 
output          tick_done;          // 
input           scl_in;             // SCL input for stretching
output          scl_out;            // SCL output

//==================================
//      WIRE'S, REG'S and etc
//==================================
reg     [8:0]   t_low_reg;
reg     [8:0]   t_high_reg;
reg     [8:0]   fsm_counter;
reg             tick_done_reg;

reg             drive_low;

typedef enum logic [1:0] {
    IDLE,
    LOW_PHASE,
    HIGH_PHASE,
    DONE
} state_t;

state_t         fsm_state;

//==================================
//          ASSIGNMENTS
//==================================
assign tick_done = tick_done_reg;
assign scl_out = (drive_low) ? 1'b0 : 1'bz;     // If drive - pull to 0, else - release;

//==================================
//             LOGIC
//==================================
// Logic for clock divider selected by mode bus
always @(*)
begin
    case(mode)
        2'd0:       // 100 kHz mode
        begin
            t_low_reg   = 9'd470;
            t_high_reg  = 9'd400;        
        end
        2'd1:       // 400 kHz mode
        begin
            t_low_reg   = 9'd130;
            t_high_reg  = 9'd60;        
        end
        2'd2:       // 1 MHz mode
        begin
            t_low_reg   = 9'd50;
            t_high_reg  = 9'd26;
        end    
        default:    // 100 kHz is default freq
        begin
            t_low_reg   = 9'd470;
            t_high_reg  = 9'd400;
        end
    endcase
end

// FSM logic for HIGH and LOW phases 
always @(posedge clk or negedge rst_)
begin
    if (!rst_)
    begin
        fsm_state       <= IDLE;
        fsm_counter     <= 0;
        drive_low       <= 0;
        tick_done_reg   <= 0;
    end
    else
    begin
        case(fsm_state)
            IDLE: begin
                fsm_counter     <= 0;
                drive_low       <= 0;
                tick_done_reg   <= 0;

                if (tick_start)
                    fsm_state   <= LOW_PHASE;
            end
            LOW_PHASE: begin
                drive_low   <= 1;

                if (fsm_counter == t_low_reg)
                begin
                    fsm_counter <= 0;
                    fsm_state   <= HIGH_PHASE;
                end
                else
                    fsm_counter <= fsm_counter + 1;
            end
            HIGH_PHASE: begin
                drive_low   <= 0;

                if (scl_in == 1'b1)
                begin
                    if (fsm_counter == t_high_reg)
                        fsm_state   <= DONE;
                    else
                        fsm_counter <= fsm_counter + 1;
                end
            end
            DONE: begin
               tick_done_reg <= 1; 
               fsm_state     <= IDLE;  
            end
        endcase        
    end
end
endmodule
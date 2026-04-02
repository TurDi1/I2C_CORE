`timescale 1 ns / 1 ns

module tb_scl_gen ();
//==================================
//           PARAMETERS
//==================================
parameter CLK_WIDTH       = 5ns;  // 100 MHz

int unsigned success;         // Success simulation variable

//==================================
//      WIRE'S, REG'S and etc
//==================================
// System required registers
reg                        sys_clk_reg;
reg                        sys_rst_reg;

reg     [1 : 0]            mode_reg;
reg                        tick_start_reg;

tri1                       scl_model;

//==================================
//          SYSTEM CLOCK
//==================================
initial
begin
    sys_clk_reg = 0;

    forever
    begin
        #CLK_WIDTH sys_clk_reg = ~sys_clk_reg;
    end
end

//==================================
//      Main block of testbench
//==================================
initial
begin
    $display("-----------------------------------");
    $display("[TB INFO]  STARTING SIMULATION");
    $display("-----------------------------------");
    $display("");
    
    mode_reg        <= 2'b00;
    tick_start_reg  <= 0;
    system_reset();

    #10ns;
    @(posedge sys_clk_reg);
    tick_start_reg  <= 1;

    @(posedge sys_clk_reg);
    tick_start_reg  <= 0;

    #10us;
    mode_reg        <= 2'b01;
    @(posedge sys_clk_reg);
    tick_start_reg  <= 1;

    @(posedge sys_clk_reg);
    tick_start_reg  <= 0;

    #5us;
    mode_reg        <= 2'b10;
    @(posedge sys_clk_reg);
    tick_start_reg  <= 1;

    @(posedge sys_clk_reg);
    tick_start_reg  <= 0;

    #5us;

    /*$display("-----------------------------------------------");
    $display("[TB INFO]  WAITING FOR PROGRAM EXECUTION... ");
    $display("TIME:  %t", $realtime);
    $display("-----------------------------------------------");

    fork : waiting_last_instruction
    begin
        wait (riscv_single_cycle.instr_addr_o == LAST_INSTR_ADDR);
        $display("-----------------------------------------------");
        $display("[TB INFO]  RISCV RECEIVED LAST INSTRUCTION... ");
        $display("TIME:  %t", $realtime);
        $display("-----------------------------------------------");
        $display("");        
        @(posedge sys_clk_reg);
        disable waiting_last_instruction;
    end
    
    begin
        #1000;
        $display("---------------------------------------------------");
        $display("[TB ERROR] TIMEOUT: LAST INSTRUCTION NOT REACHED!");
        $display("TIME:  %t", $realtime);
        $display("---------------------------------------------------");
        $finish;
    end
    join_any
    
    // Checking DPRAM register value with address 0x40
    if (dual_port_ram.ram[16] == 32'h00000031)
        success = 1;
    else
        success = 0;
    
    $display("");
    $display("==================== Results of simulation ====================");
    if (success == 1)
        $display("==       VALUE IN DPRAM AT ADDRESS 0x40 IS CORRECT, %h ==", dual_port_ram.ram[16]);
    else
        $display("==       VALUE IN DPRAM AT ADDRESS 0x40 IS INCORRECT, %h ==", dual_port_ram.ram[16]);
    $display("===============================================================");
    $display("");
    $display("");*/
    
    $finish;
end

//==================================
//          INSTATIATIONS
//==================================
scl_generator DUT (
    .rst_           ( sys_rst_reg ),
    .clk            ( sys_clk_reg ),
    .mode           ( mode_reg ),
    .tick_start     ( tick_start_reg ),
    .tick_done      (  ),
    .scl_in         ( scl_model ),
    .scl_out        ( scl_model )
);

//==================================
//         TESTBENCH TASKS
//==================================
task system_reset;
begin  
    int unsigned rst_time;        // Variable of time for reset

    // Active LOW reset
    sys_rst_reg = 0;    
    $display("----------------------------");
    $display("[TB INFO]  RESET SETTED!");
    $display("TIME:  %t", $realtime);
    $display("----------------------------");

    // Set random time in range
    rst_time = $urandom_range(30ns, 50ns);
    
    #rst_time sys_rst_reg = 1;
    $display("----------------------------");
    $display("[TB INFO]  RESET RELEASED!");
    $display("TIME:  %t", $realtime);
    $display("----------------------------");
    $display("");
end
endtask
endmodule 
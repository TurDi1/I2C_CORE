module i2c_master_axi #(
    parameter CLK_FREQ_HZ = 50000000
) (
    input  wire        s_axi_aclk,
    input  wire        s_axi_aresetn,
    input  wire [ 7:0] s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire [ 1:0] s_axi_bresp,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,
    input  wire [ 7:0] s_axi_araddr,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,
    output wire [31:0] s_axi_rdata,
    output wire [ 1:0] s_axi_rresp,
    output wire        s_axi_rvalid,
    input  wire        s_axi_rready,
    output wire        interrupt,
    inout  wire        scl,
    inout  wire        sda
);

    // Register addresses
    localparam REG_CTRL      = 8'h00;
    localparam REG_STATUS    = 8'h04;
    localparam REG_TX_DATA   = 8'h08;
    localparam REG_RX_DATA   = 8'h0C;
    localparam REG_CLK_DIV   = 8'h10;
    localparam REG_INT_EN    = 8'h14;

    // Register storage
    reg [7:0] ctrl_reg;
    reg [7:0] status_reg;
    reg [7:0] tx_data_reg;
    reg [7:0] rx_data_reg;
    reg [15:0] clk_div_reg;
    reg [7:0] int_en_reg;

    // Internal signals for core
    wire       i2c_start;
    wire       i2c_stop;
    wire       i2c_read;
    wire       i2c_repeat_start;
    wire       i2c_enable;
    wire       i2c_busy;
    wire       i2c_ack;
    wire       i2c_error;
    wire       i2c_complete;
    wire [7:0] i2c_tx_data;
    wire [7:0] i2c_rx_data;

    // AXI write address handshake
    reg        awready;
    assign s_axi_awready = awready;

    // AXI write data handshake
    reg        wready;
    assign s_axi_wready = wready;

    // AXI write response
    reg [1:0]  bresp;
    reg        bvalid;
    assign s_axi_bresp = bresp;
    assign s_axi_bvalid = bvalid;

    // AXI read address handshake
    reg        arready;
    assign s_axi_arready = arready;

    // AXI read data
    reg [31:0] rdata;
    reg [1:0]  rresp;
    reg        rvalid;
    assign s_axi_rdata = rdata;
    assign s_axi_rresp = rresp;
    assign s_axi_rvalid = rvalid;

    // AXI write transaction FSM
    localparam WR_IDLE = 0, WR_ADDR = 1, WR_DATA = 2, WR_RESP = 3;
    reg [1:0] wr_state;

    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            wr_state <= WR_IDLE;
            awready <= 1'b0;
            wready  <= 1'b0;
            bresp   <= 2'b00;
            bvalid  <= 1'b0;
            // Register initial values
            ctrl_reg     <= 8'b0;
            status_reg   <= 8'b0;
            tx_data_reg  <= 8'b0;
            clk_div_reg  <= 16'd249;  // Example for 100kHz at 50MHz (249+1)*2*20ns = 10us => 100kHz
            int_en_reg   <= 8'b0;
        end else begin
            case (wr_state)
                WR_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        // Simplified: if both address and data valid in same cycle
                        awready <= 1'b1;
                        wready  <= 1'b1;
                        wr_state <= WR_RESP;
                        // Decode write
                        case (s_axi_awaddr)
                            REG_CTRL:     ctrl_reg <= s_axi_wdata[7:0];
                            REG_TX_DATA:  tx_data_reg <= s_axi_wdata[7:0];
                            REG_CLK_DIV:  clk_div_reg <= s_axi_wdata[15:0];
                            REG_INT_EN:   int_en_reg <= s_axi_wdata[7:0];
                            // STATUS and RX_DATA are read-only
                            default: ;
                        endcase
                        bresp <= 2'b00; // OKAY
                        bvalid <= 1'b1;
end
                end
                WR_RESP: begin
                    awready <= 1'b0;
                    wready  <= 1'b0;
                    if (s_axi_bready) begin
                        bvalid <= 1'b0;
                        wr_state <= WR_IDLE;
                    end
                end
                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    // AXI read transaction FSM
    localparam RD_IDLE = 0, RD_DATA = 1;
    reg rd_state;

    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            rd_state <= RD_IDLE;
            arready  <= 1'b0;
            rdata    <= 32'b0;
            rresp    <= 2'b00;
            rvalid   <= 1'b0;
        end else begin
            case (rd_state)
                RD_IDLE: begin
                    if (s_axi_arvalid) begin
                        arready <= 1'b1;
                        rd_state <= RD_DATA;
                        // Decode read address
                        case (s_axi_araddr)
                            REG_CTRL:     rdata <= {24'b0, ctrl_reg};
                            REG_STATUS:   rdata <= {24'b0, status_reg};
                            REG_TX_DATA:  rdata <= {24'b0, tx_data_reg};
                            REG_RX_DATA:  rdata <= {24'b0, rx_data_reg};
                            REG_CLK_DIV:  rdata <= {16'b0, clk_div_reg};
                            REG_INT_EN:   rdata <= {24'b0, int_en_reg};
                            default:      rdata <= 32'b0;
                        endcase
                        rresp <= 2'b00; // OKAY
                        rvalid <= 1'b1;
                    end
                end
                RD_DATA: begin
                    arready <= 1'b0;
                    if (s_axi_rready) begin
                        rvalid <= 1'b0;
                        rd_state <= RD_IDLE;
                    end
                end
                default: rd_state <= RD_IDLE;
            endcase
        end
    end

    // Instantiate I2C master core
    // TODO: Connect signals from registers to core
    i2c_core u_core (
        .clk         (s_axi_aclk),
        .rst_n       (s_axi_aresetn),
        .start       (ctrl_reg[0]),       // START bit
        .stop        (ctrl_reg[1]),       // STOP bit
        .read_op     (ctrl_reg[2]),       // READ
        .enable      (ctrl_reg[3]),       // ENABLE
        .repeat_start(ctrl_reg[4]),       // REPEATED_START
        .clk_div     (clk_div_reg),
        .tx_data     (tx_data_reg),
        .rx_data     (rx_data_reg),
        .busy        (i2c_busy),
        .ack         (i2c_ack),
        .error       (i2c_error),
        .complete    (i2c_complete),
        .scl         (scl),
        .sda         (sda)
    );

    // Update status register
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            status_reg <= 8'b0;
        end else begin
            status_reg[0] <= i2c_busy;
            status_reg[1] <= i2c_ack;   // 0=ACK, 1=NACK
            status_reg[2] <= i2c_error;
            status_reg[3] <= i2c_complete;
            // Clear complete when a new start is issued? We'll handle in core logic.
        end
    end

    // Interrupt generation
    reg interrupt_int;
    assign interrupt = interrupt_int;

    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            interrupt_int <= 1'b0;
        end else begin
            // Assert interrupt when complete or error if corresponding enable bits set
            if ((i2c_complete && int_en_reg[2]) || (i2c_error && int_en_reg[1]))
                interrupt_int <= 1'b1;
            // Clear interrupt on write to status? Or on read? We'll add a clear mechanism later.
            // For now, we'll keep it simple and let the software clear by writing to a bit.
            // But we can add a status register clear when read by software.
        end
    end

endmodule

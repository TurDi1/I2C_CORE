# I2C Master AXI-Lite Register Map

## Register Overview

| Offset | Register    | Access | Description                                    |
|--------|-------------|--------|------------------------------------------------|
| 0x00   | CTRL        | R/W    | Control register for I2C transactions          |
| 0x04   | STATUS      | R      | Status register for I2C core state             |
| 0x08   | TX_DATA     | R/W    | Transmit data buffer                           |
| 0x0C   | RX_DATA     | R      | Receive data buffer                            |
| 0x10   | CLK_DIV     | R/W    | Clock divider for SCL generation (16-bit)      |
| 0x14   | INT_EN      | R/W    | Interrupt enable register                      |
| 0x18-0xFF| Reserved   | -      | Reserved for future expansion                  |

---

## Register Details

### 0x00 – CTRL (Control Register)

| Bit | Field           | Access | Reset | Description |
|-----|-----------------|--------|-------|-------------|
| 0   | START           | R/W1S  | 0     | **Start transaction**<br/>Write 1 to initiate I2C transaction. Self-clearing after start condition is generated. |
| 1   | STOP            | R/W1S  | 0     | **Stop condition**<br/>Write 1 to generate STOP condition. Self-clearing after stop is generated. |
| 2   | READ            | R/W    | 0     | **Read/Write select**<br/>0 = Write transaction<br/>1 = Read transaction |
| 3   | ENABLE          | R/W    | 0     | **I2C core enable**<br/>0 = Core disabled (pins tri-stated)<br/>1 = Core enabled |
| 4   | REPEATED_START  | R/W    | 0     | **Repeated start enable**<br/>0 = Normal transaction (STOP after write, then START for read)<br/>1 = Use repeated START instead of STOP |
| 7:5 | RESERVED        | R      | 0     | Reserved, read as 0 |

**Note**: START and STOP bits are self-clearing. Writing 1 triggers the action; the hardware clears the bit after execution.

---

### 0x04 – STATUS (Status Register)

| Bit | Field          | Access | Reset | Description |
|-----|----------------|--------|-------|-------------|
| 0   | BUSY           | R      | 0     | **Core busy**<br/>0 = Idle, ready for new transaction<br/>1 = Transaction in progress |
| 1   | ACK_RECEIVED   | R      | 0     | **Acknowledge status**<br/>0 = ACK received (0 from slave)<br/>1 = NACK received (1 from slave) |
| 2   | ERROR          | R/C    | 0     | **Error flag**<br/>0 = No error<br/>1 = Error occurred (arbitration lost, bus timeout, etc.)<br/>Clear by writing 1 to this bit |
| 3   | COMPLETE       | R/C    | 0     | **Transaction complete**<br/>0 = Transaction in progress or not started<br/>1 = Transaction completed successfully<br/>Clear by writing 1 to this bit |
| 7:4 | RESERVED       | R      | 0     | Reserved, read as 0 |

**Note**: ERROR and COMPLETE bits are cleared by writing 1 to the respective bit position.

---

### 0x08 – TX_DATA (Transmit Data Register)

| Bit | Field    | Access | Reset | Description |
|-----|----------|--------|-------|-------------|
| 7:0 | TX_DATA  | R/W    | 0x00  | **Transmit data buffer**<br/>For write transactions: data to be sent to slave.<br/>For read transactions: this register is ignored. |

**Behavior**: 
- Write to this register before setting START bit
- Data is transferred to the core's shift register when transaction begins
- Can be updated for multi-byte transfers (with proper control flow)

---

### 0x0C – RX_DATA (Receive Data Register)

| Bit | Field    | Access | Reset | Description |
|-----|----------|--------|-------|-------------|
| 7:0 | RX_DATA  | R      | 0x00  | **Receive data buffer**<br/>For read transactions: data received from slave.<br/>Valid when transaction completes and COMPLETE flag is set. |

**Behavior**:
- Updated after each byte received in read transactions
- For multi-byte reads, read this register after each byte completion
- Software must read before next byte is received to avoid data loss

---

### 0x10 – CLK_DIV (Clock Divider Register)

| Bit    | Field     | Access | Reset | Description |
|--------|-----------|--------|-------|-------------|
| 15:0   | CLK_DIV   | R/W    | 249   | **Clock divider value**<br/>Controls SCL frequency.<br/>Formula: `SCL frequency = CLK_FREQ_HZ / (2 × (CLK_DIV + 1))` |

**Example values for 50 MHz system clock**:

| CLK_DIV | SCL Frequency | Calculation |
|---------|---------------|-------------|
| 249     | 100 kHz       | 50e6 / (2 × 250) = 100,000 |
| 62      | 400 kHz       | 50e6 / (2 × 63) ≈ 396,825 |
| 9       | 2.5 MHz       | 50e6 / (2 × 10) = 2.5 MHz (fast-mode plus, use with pull-ups) |

**Note**: 
- Minimum value: 0 (SCL frequency = CLK_FREQ_HZ / 2)
- Maximum value: 65535 (SCL frequency = CLK_FREQ_HZ / 131072)
- Change this register only when core is idle (BUSY = 0)

---

### 0x14 – INT_EN (Interrupt Enable Register)

| Bit | Field              | Access | Reset | Description |
|-----|--------------------|--------|-------|-------------|
| 0   | GLOBAL_INT_EN      | R/W    | 0     | **Global interrupt enable**<br/>0 = Interrupts disabled<br/>1 = Interrupts enabled (individual enables still apply) |
| 1   | ERROR_INT_EN       | R/W    | 0     | **Error interrupt enable**<br/>0 = Disable interrupt on error<br/>1 = Enable interrupt when ERROR flag is set |
| 2   | COMPLETE_INT_EN    | R/W    | 0     | **Complete interrupt enable**<br/>0 = Disable interrupt on transaction complete<br/>1 = Enable interrupt when COMPLETE flag is set |
| 7:3 | RESERVED           | R      | 0     | Reserved, read as 0 |

**Interrupt behavior**:
- Interrupt line (interrupt output) is asserted when:
  - `GLOBAL_INT_EN = 1`
  - AND (`ERROR_INT_EN = 1` AND `ERROR = 1`) OR (`COMPLETE_INT_EN = 1` AND `COMPLETE = 1`)
- Interrupt is cleared by writing 1 to the corresponding STATUS bit (ERROR or COMPLETE)

---

## Programming Sequence Examples

### Single Byte Write

1. Write data to `TX_DATA`
2. Write `CTRL` with `ENABLE=1, READ=0, START=1`
3. Poll `STATUS.BUSY` until cleared, or wait for interrupt
4. Check `STATUS.ACK_RECEIVED` to verify slave acknowledged
5. Check `STATUS.ERROR` for any bus errors
6. Write 1 to `STATUS.COMPLETE` to clear (if using interrupts)

### Single Byte Read

1. Write `CTRL` with `ENABLE=1, READ=1, START=1`
2. Poll `STATUS.BUSY` until cleared, or wait for interrupt
3. Read data from `RX_DATA`
4. Check `STATUS.ACK_RECEIVED` (should be 0 for ACK)
5. Write 1 to `STATUS.COMPLETE` to clear

### Combined Write-Read with Repeated Start

1. Write data to `TX_DATA`
2. Write `CTRL` with `ENABLE=1, READ=0, REPEATED_START=1, START=1` (initiates write with repeated start enabled)
3. Poll `STATUS.BUSY` until cleared
4. Write `CTRL` with `ENABLE=1, READ=1, START=1` (read transaction uses repeated start)
5. Poll `STATUS.BUSY` until cleared
6. Read data from `RX_DATA`

---

## Register Access Timing

All registers are accessed via AXI4-Lite interface with 32-bit data width. Only the lower bytes are used for registers; upper bytes are ignored on writes and read as 0.

| Access Type | Address Alignment | Data Width | Response |
|-------------|------------------|------------|----------|
| Write       | 4-byte aligned   | 32-bit     | OKAY     |
| Read        | 4-byte aligned   | 32-bit     | OKAY     |
vlog -reportprogress 300 -work work /home/turdi/intelFPGA/18.1/quartus/eda/sim_lib/altera_mf.v

vlog -reportprogress 300 -work work /home/turdi/Quartus_projects/I2C/simulation/modelsim/I2C_CORE.vt

vsim work.I2C_CORE_vlg_tst

add wave -position insertpoint  \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/reset \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/clk \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/bus_clock \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/bus_clock6x \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/address_rw \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/Sr \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/read \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/data_in \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/empty_tx \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/write \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/data_out \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/busy \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/scl \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/sda \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/Sr_reg \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/clear_Sr_ \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/state \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/address_rw_reg \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/data_byte_reg \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/bit_counter \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/shift_reg \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/clock6x_counter \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/clock6x_reset_ \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/scl_reg \
sim:/I2C_CORE_vlg_tst/i1/i2c_master/sda_reg

run 10000 ns
vlog -reportprogress 300 -work work /home/turdi/Quartus_projects/I2C/simulation/modelsim/I2C_CORE.vt

vsim work.I2C_CORE_vlg_tst

add wave -position insertpoint  \
sim:/I2C_CORE_vlg_tst/i1/clock_generator/reset \
sim:/I2C_CORE_vlg_tst/i1/clock_generator/clk \
sim:/I2C_CORE_vlg_tst/i1/clock_generator/freq_mode \
sim:/I2C_CORE_vlg_tst/i1/clock_generator/output_clk \
sim:/I2C_CORE_vlg_tst/i1/clock_generator/freq_divider \
sim:/I2C_CORE_vlg_tst/i1/clock_generator/out_clk_ff

run 120000
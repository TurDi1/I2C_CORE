transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/TurDi/Desktop/I2C_CORE-main/I2C_CORE-main/sources/Top_files {C:/Users/TurDi/Desktop/I2C_CORE-main/I2C_CORE-main/sources/Top_files/I2C_CORE.v}
vlog -sv -work work +incdir+C:/Users/TurDi/Desktop/I2C_CORE-main/I2C_CORE-main/sources/Modules {C:/Users/TurDi/Desktop/I2C_CORE-main/I2C_CORE-main/sources/Modules/clock_generator.v}
vlog -sv -work work +incdir+C:/Users/TurDi/Desktop/I2C_CORE-main/I2C_CORE-main/sources/Modules {C:/Users/TurDi/Desktop/I2C_CORE-main/I2C_CORE-main/sources/Modules/i2c_master_controller.v}


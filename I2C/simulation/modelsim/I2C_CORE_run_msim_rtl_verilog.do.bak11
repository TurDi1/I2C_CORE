transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/Top_files {/home/turdi/Quartus_projects/sources/Top_files/I2C_CORE.v}
vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/Modules {/home/turdi/Quartus_projects/sources/Modules/clock_generator.v}
vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/Modules {/home/turdi/Quartus_projects/sources/Modules/i2c_master_controller.v}
vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/IP {/home/turdi/Quartus_projects/sources/IP/FIFO_TX.v}
vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/IP {/home/turdi/Quartus_projects/sources/IP/FIFO_RX.v}


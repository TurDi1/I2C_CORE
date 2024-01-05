transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/Top_files {/home/turdi/Quartus_projects/sources/Top_files/I2C_CORE.v}
vlog -sv -work work +incdir+/home/turdi/Quartus_projects/sources/Modules {/home/turdi/Quartus_projects/sources/Modules/clock_generator.v}


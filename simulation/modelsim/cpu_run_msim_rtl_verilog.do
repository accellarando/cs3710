transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/PSR_reg.v}
vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/register.v}
vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/cpu.v}
vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/mux2.v}
vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/alu.v}
vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/registerFile.v}

vlog -vlog01compat -work work +incdir+/home/ella/Documents/School/CS3710/cpu {/home/ella/Documents/School/CS3710/cpu/aluTb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  aluTb

add wave *
view structure
view signals
run -all

transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+c:/dsd/dsd_git/dsd {c:/dsd/dsd_git/dsd/mul.v}
vlog -vlog01compat -work work +incdir+c:/dsd/dsd_git/dsd {c:/dsd/dsd_git/dsd/mul_top.v}
vlog -vlog01compat -work work +incdir+C:/DSD/DSD_git/DSD/template/db {C:/DSD/DSD_git/DSD/template/db/altera_mult_add_20u2.v}
vlog -vlog01compat -work work +incdir+C:/DSD/DSD_git/DSD/template/db {C:/DSD/DSD_git/DSD/template/db/altera_mult_add_iau2.v}
vlog -vlog01compat -work work +incdir+C:/DSD/DSD_git/DSD/template/db {C:/DSD/DSD_git/DSD/template/db/altera_mult_add_hau2.v}
vlog -vlog01compat -work work +incdir+C:/DSD/DSD_git/DSD/template/db {C:/DSD/DSD_git/DSD/template/db/altera_mult_add_1lu2.v}
vlog -vlog01compat -work work +incdir+C:/DSD/DSD_git/DSD/template/db {C:/DSD/DSD_git/DSD/template/db/mult_b8n.v}
vlib first_nios2_system
vmap first_nios2_system first_nios2_system
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/first_nios2_system.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_customins_master_translator.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_reset_controller.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_cpu.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_cpu_debug_slave_sysclk.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_cpu_debug_slave_tck.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_cpu_debug_slave_wrapper.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_cpu_mult_cell.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_cpu_test_bench.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_jtag_uart.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_led_pio.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_avalon_st_adapter.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_onchip_mem.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_sys_clk_timer.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_sysid.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/mul_top.v}
vlog -vlog01compat -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_avalon_sc_fifo.v}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_customins_slave_translator.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_arbitrator.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_burst_uncompressor.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_master_agent.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_master_translator.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_slave_agent.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_slave_translator.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/altera_merlin_traffic_limiter.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_cpu_custom_instruction_master_comb_xconnect.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_irq_mapper.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_cmd_demux.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_cmd_demux_001.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_cmd_mux.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_cmd_mux_002.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_router.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_router_001.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_router_002.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_router_004.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_rsp_demux.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_rsp_demux_002.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_rsp_mux.sv}
vlog -sv -work first_nios2_system +incdir+c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules {c:/dsd/dsd_git/dsd/template/db/ip/first_nios2_system/submodules/first_nios2_system_mm_interconnect_0_rsp_mux_001.sv}


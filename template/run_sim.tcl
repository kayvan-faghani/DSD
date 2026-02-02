# --- run_sim.tcl ---
if [file exists work] { vdel -all }
vlib work

# 1. Get a list of all .v files in the current folder
set all_v_files [glob *.v]

# -all (returns all matches), -not (negates), -glob (pattern match)
set filtered_v_files [lsearch -all -not -inline -glob $all_v_files "*_bb*"]
echo "Compiling these files: $filtered_v_files"
vlog {*}$filtered_v_files

# 2. Load simulation WITH VERILOG-SPECIFIC LIBRARIES
vsim -voptargs=+acc -L 220model_ver -L altera_mf_ver work.tb

# 3. Setup waves and run
add wave -dec /tb/*
run 500ns
wave zoom full
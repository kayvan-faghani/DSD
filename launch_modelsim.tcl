set msim_path "C:/intelFPGA/20.1/modelsim_ase/win32aloem/modelsim.exe"

# 2. Tell Quartus to launch ModelSim and immediately run your simulation script
exec $msim_path -do run_sim.tcl &
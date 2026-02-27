set_global_assignment -entity "fp_addsub_final" -library "lib_fp_addsub_final" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "fp_addsub_final" -library "lib_fp_addsub_final" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "fp_addsub_final" -library "lib_fp_addsub_final" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fp_addsub_final" -name SPD_FILE [file join $::quartus(sip_path) "fp_addsub_final.spd"]

set_global_assignment -library "lib_fp_addsub_final" -name MISC_FILE [file join $::quartus(sip_path) "fp_addsub_final_sim/fp_addsub_final.vo"]

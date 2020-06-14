set_property SRC_FILE_INFO {cfile:/afs/tu-berlin.de/home/v/vincenthp2603/irb-ubuntu/HardwarePratikum/HardwarePRK-SoSe20/Blatt05/Vivado_WORK/Tutorial/vivado_project/HWP5/HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen.xdc rfile:../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1

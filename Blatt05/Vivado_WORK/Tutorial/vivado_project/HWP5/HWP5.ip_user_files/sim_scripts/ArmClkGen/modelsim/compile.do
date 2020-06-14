vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen_clk_wiz.v" \
"../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen.v" \

vlog -work xil_defaultlib \
"glbl.v"


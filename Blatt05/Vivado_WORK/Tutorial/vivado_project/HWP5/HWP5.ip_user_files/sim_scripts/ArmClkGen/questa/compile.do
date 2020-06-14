vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen_clk_wiz.v" \
"../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen.v" \

vlog -work xil_defaultlib \
"glbl.v"


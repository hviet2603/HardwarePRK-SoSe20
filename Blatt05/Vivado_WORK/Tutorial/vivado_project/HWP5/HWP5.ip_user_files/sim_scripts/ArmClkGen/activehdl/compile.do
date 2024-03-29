vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen_clk_wiz.v" \
"../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen.v" \

vlog -work xil_defaultlib \
"glbl.v"


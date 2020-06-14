-makelib ies_lib/xil_defaultlib -sv \
  "/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen_clk_wiz.v" \
  "../../../../HWP5.srcs/sources_1/ip/ArmClkGen/ArmClkGen.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib


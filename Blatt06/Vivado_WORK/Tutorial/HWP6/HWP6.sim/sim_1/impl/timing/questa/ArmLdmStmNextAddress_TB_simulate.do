######################################################################
#
# File name : ArmLdmStmNextAddress_TB_simulate.do
# Created on: Wed Jun 24 14:29:11 CEST 2020
#
# Auto generated by Vivado for 'post-implementation' simulation
#
######################################################################
vsim +transport_int_delays +pulse_e/0 +pulse_int_e/0 +pulse_r/0 +pulse_int_r/0 -lib xil_defaultlib ArmLdmStmNextAddress_TB_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {ArmLdmStmNextAddress_TB_wave.do}

view wave
view structure
view signals

do {ArmLdmStmNextAddress_TB.udo}

run 1000ns

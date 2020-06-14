#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/SDK/bin:/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/ids_lite/ISE/bin/lin64:/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/bin
else
  PATH=/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/SDK/bin:/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/ids_lite/ISE/bin/lin64:/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/afs/tu-berlin.de/units/Fak_IV/aes/tools/xilinx/Vivado/2017.3/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/afs/tu-berlin.de/home/v/vincenthp2603/irb-ubuntu/HardwarePratikum/HardwarePRK-SoSe20/Blatt05/Vivado_WORK/Tutorial/vivado_project/HWP5/HWP5.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log ArmUncoreTop.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source ArmUncoreTop.tcl

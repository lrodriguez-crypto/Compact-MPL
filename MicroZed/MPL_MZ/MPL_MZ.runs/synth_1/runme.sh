#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/Xilinx/SDK/2016.1/bin:/opt/Xilinx/Vivado/2016.1/ids_lite/ISE/bin/lin64:/opt/Xilinx/Vivado/2016.1/bin
else
  PATH=/opt/Xilinx/SDK/2016.1/bin:/opt/Xilinx/Vivado/2016.1/ids_lite/ISE/bin/lin64:/opt/Xilinx/Vivado/2016.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/opt/Xilinx/Vivado/2016.1/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/opt/Xilinx/Vivado/2016.1/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.runs/synth_1'
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

EAStep vivado -log design_1_wrapper.vds -m64 -mode batch -messageDb vivado.pb -notrace -source design_1_wrapper.tcl

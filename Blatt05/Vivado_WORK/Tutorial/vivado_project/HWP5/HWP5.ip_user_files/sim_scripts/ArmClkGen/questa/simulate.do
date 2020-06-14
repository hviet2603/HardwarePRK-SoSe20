onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ArmClkGen_opt

do {wave.do}

view wave
view structure
view signals

do {ArmClkGen.udo}

run -all

quit -force

#################################
# a very simple modelsim do file #
##################################
set size 1024

set xk 16
set yk 16
set digitos [expr $size/$xk]

#set xk 8
#set yk 8

#set xk 16
#set yk 16

#set xk 32
#set yk 32

#set xk 64
#set yk 64

vcom ../vhdl/*.vhd
radix hex

# 3) Load it for simulation
vsim  -gsize=$size -gxk=$xk -gyk=$yk work.montgomerycompact_tb

#  Para la lectura del archivo
#  Slurp up the data file
set fp [open "../do_files/data.dat" r]
set file_data [read $fp]
close $fp

#  Process data file
set data [split $file_data "\n"]
#Pone los datos leidos en las señales de entrada correspondientes.

set str_pPrima   [lindex $data 0]
set str_x_mont   [lindex $data 1]
set str_exponent [lindex $data 2]
set str_p        [lindex $data 3]
set str_uno_mont [lindex $data 4]

set hex_digits [expr $xk/4]

force pPrima $str_pPrima
for {set i 0} {$i < $digitos} {incr i} {
	set idx_str [expr ($digitos - 1 - $i) * $hex_digits ]
	force X     [string range $str_x_mont   [expr $idx_str] [expr $idx_str + $hex_digits - 1]] @[expr 20 + 10 * $i]ns -freeze
	force Exp   [string range $str_exponent [expr $idx_str] [expr $idx_str + $hex_digits - 1]] @[expr 20 + 10 * $i]ns -freeze
	force P     [string range $str_p        [expr $idx_str] [expr $idx_str + $hex_digits - 1]] @[expr 20 + 10 * $i]ns -freeze
	force Uno   [string range $str_uno_mont [expr $idx_str] [expr $idx_str + $hex_digits - 1]] @[expr 20 + 10 * $i]ns -freeze
} 

add wave -r /*

run 20ns
run [expr $digitos*10]ns

#add mem /montgomerycompact_tb/MM/R0/RAM -a hexadecimal -d hexadecimal
#add mem /montgomerycompact_tb/MM/R1/RAM -a hexadecimal -d hexadecimal

for {set i 0} {$i < $size} {incr i} {
	run [expr $digitos * ($digitos + 1) * 10 + 60]ns
	#pause
}

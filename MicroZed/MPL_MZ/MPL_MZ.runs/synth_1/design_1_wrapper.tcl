# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.cache/wt [current_project]
set_property parent.project_path /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:microzed_7010:part0:1.1 [current_project]
set_property ip_repo_paths /home/sr_x/Desktop/Basura/MicroZed/ip_repo/MPL_1.0 [current_project]
add_files /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/design_1.bd
set_property used_in_implementation false [get_files -all /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0/design_1_processing_system7_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/design_1_rst_processing_system7_0_100M_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/design_1_rst_processing_system7_0_100M_0.xdc]
set_property used_in_implementation false [get_files -all /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/design_1_rst_processing_system7_0_100M_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/ip/design_1_auto_pc_0/design_1_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/design_1_ooc.xdc]
set_property is_locked true [get_files /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/design_1.bd]

read_vhdl -library xil_defaultlib /home/sr_x/Desktop/Basura/MicroZed/MPL_MZ/MPL_MZ.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.vhd
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

synth_design -top design_1_wrapper -part xc7z010clg400-1


write_checkpoint -force -noxdef design_1_wrapper.dcp

catch { report_utilization -file design_1_wrapper_utilization_synth.rpt -pb design_1_wrapper_utilization_synth.pb }

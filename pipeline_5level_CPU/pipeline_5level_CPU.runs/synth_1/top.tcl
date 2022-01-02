# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a75tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.cache/wt [current_project]
set_property parent.project_path D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/coe/mipstest.coe
read_verilog -library xil_defaultlib {
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/adder.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/alu.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/controller.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/datapath.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/flopenrc.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/hazard.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/mips.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/mux2.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/mux3.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/pc.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/regfile.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/signext.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/sl2.v
  D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/rtl/top.v
}
read_ip -quiet D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.srcs/sources_1/ip/inst_ram/inst_ram.xci
set_property used_in_implementation false [get_files -all d:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.srcs/sources_1/ip/inst_ram/inst_ram_ooc.xdc]

read_ip -quiet D:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.srcs/sources_1/ip/data_ram/data_ram.xci
set_property used_in_implementation false [get_files -all d:/vivado_workspace/ComputerComposition/pipeline_5level_CPU/pipeline_5level_CPU.srcs/sources_1/ip/data_ram/data_ram_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top top -part xc7a75tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
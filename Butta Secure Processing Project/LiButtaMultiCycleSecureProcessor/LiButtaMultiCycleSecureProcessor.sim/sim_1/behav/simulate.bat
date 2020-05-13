@echo off
set xv_path=C:\\Apps\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xsim mccomp_tb_behav -key {Behavioral:sim_1:Functional:mccomp_tb} -tclbatch mccomp_tb.tcl -view C:/Users/j39950/Desktop/project_1/mccomp_tb_behav.wcfg -view C:/Users/j39950/Desktop/project_1/mccomp_tb_behav1.wcfg -view C:/Users/j39950/Desktop/project_1/mccomp_tb_behav2.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

@echo off
set xv_path=C:\\Apps\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 7740ca9f7d4d4a3e83660c5c84b536b7 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot mccomp_tb_behav xil_defaultlib.mccomp_tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

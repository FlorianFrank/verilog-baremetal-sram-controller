# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_static_text $IPINST -name "Description" -parent ${Page_0} -text {This module implements a SRAM protocol using GPIO pins on an FPGA. 
Author: Florian Frank}
  ipgui::add_param $IPINST -name "DATA_SETUP_TIME" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FREQ_CLK1" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FREQ_CLK2" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IDLE_DELAY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MEM_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "READ_START_DELAY" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_SETUP_TIME { PARAM_VALUE.DATA_SETUP_TIME } {
	# Procedure called to update DATA_SETUP_TIME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SETUP_TIME { PARAM_VALUE.DATA_SETUP_TIME } {
	# Procedure called to validate DATA_SETUP_TIME
	return true
}

proc update_PARAM_VALUE.FREQ_CLK1 { PARAM_VALUE.FREQ_CLK1 } {
	# Procedure called to update FREQ_CLK1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FREQ_CLK1 { PARAM_VALUE.FREQ_CLK1 } {
	# Procedure called to validate FREQ_CLK1
	return true
}

proc update_PARAM_VALUE.FREQ_CLK2 { PARAM_VALUE.FREQ_CLK2 } {
	# Procedure called to update FREQ_CLK2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FREQ_CLK2 { PARAM_VALUE.FREQ_CLK2 } {
	# Procedure called to validate FREQ_CLK2
	return true
}

proc update_PARAM_VALUE.IDLE_DELAY { PARAM_VALUE.IDLE_DELAY } {
	# Procedure called to update IDLE_DELAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IDLE_DELAY { PARAM_VALUE.IDLE_DELAY } {
	# Procedure called to validate IDLE_DELAY
	return true
}

proc update_PARAM_VALUE.MEM_SIZE { PARAM_VALUE.MEM_SIZE } {
	# Procedure called to update MEM_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_SIZE { PARAM_VALUE.MEM_SIZE } {
	# Procedure called to validate MEM_SIZE
	return true
}

proc update_PARAM_VALUE.READ_START_DELAY { PARAM_VALUE.READ_START_DELAY } {
	# Procedure called to update READ_START_DELAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_START_DELAY { PARAM_VALUE.READ_START_DELAY } {
	# Procedure called to validate READ_START_DELAY
	return true
}


proc update_MODELPARAM_VALUE.IDLE_DELAY { MODELPARAM_VALUE.IDLE_DELAY PARAM_VALUE.IDLE_DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IDLE_DELAY}] ${MODELPARAM_VALUE.IDLE_DELAY}
}

proc update_MODELPARAM_VALUE.READ_START_DELAY { MODELPARAM_VALUE.READ_START_DELAY PARAM_VALUE.READ_START_DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_START_DELAY}] ${MODELPARAM_VALUE.READ_START_DELAY}
}

proc update_MODELPARAM_VALUE.MEM_SIZE { MODELPARAM_VALUE.MEM_SIZE PARAM_VALUE.MEM_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_SIZE}] ${MODELPARAM_VALUE.MEM_SIZE}
}

proc update_MODELPARAM_VALUE.FREQ_CLK1 { MODELPARAM_VALUE.FREQ_CLK1 PARAM_VALUE.FREQ_CLK1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FREQ_CLK1}] ${MODELPARAM_VALUE.FREQ_CLK1}
}

proc update_MODELPARAM_VALUE.FREQ_CLK2 { MODELPARAM_VALUE.FREQ_CLK2 PARAM_VALUE.FREQ_CLK2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FREQ_CLK2}] ${MODELPARAM_VALUE.FREQ_CLK2}
}

proc update_MODELPARAM_VALUE.DATA_SETUP_TIME { MODELPARAM_VALUE.DATA_SETUP_TIME PARAM_VALUE.DATA_SETUP_TIME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SETUP_TIME}] ${MODELPARAM_VALUE.DATA_SETUP_TIME}
}


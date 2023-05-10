# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_static_text $IPINST -name "Description" -parent ${Page_0} -text {This module implements a bare metal SRAM controller to write data to external memory modules using GPIO pins. 
Author: Florian Frank}
  ipgui::add_param $IPINST -name "ADDRESS_BUS_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCK_CONFIG_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_BUS_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_FREQUENCY" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDRESS_BUS_SIZE { PARAM_VALUE.ADDRESS_BUS_SIZE } {
	# Procedure called to update ADDRESS_BUS_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDRESS_BUS_SIZE { PARAM_VALUE.ADDRESS_BUS_SIZE } {
	# Procedure called to validate ADDRESS_BUS_SIZE
	return true
}

proc update_PARAM_VALUE.CLOCK_CONFIG_WIDTH { PARAM_VALUE.CLOCK_CONFIG_WIDTH } {
	# Procedure called to update CLOCK_CONFIG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_CONFIG_WIDTH { PARAM_VALUE.CLOCK_CONFIG_WIDTH } {
	# Procedure called to validate CLOCK_CONFIG_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_BUS_SIZE { PARAM_VALUE.DATA_BUS_SIZE } {
	# Procedure called to update DATA_BUS_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_BUS_SIZE { PARAM_VALUE.DATA_BUS_SIZE } {
	# Procedure called to validate DATA_BUS_SIZE
	return true
}

proc update_PARAM_VALUE.INPUT_FREQUENCY { PARAM_VALUE.INPUT_FREQUENCY } {
	# Procedure called to update INPUT_FREQUENCY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_FREQUENCY { PARAM_VALUE.INPUT_FREQUENCY } {
	# Procedure called to validate INPUT_FREQUENCY
	return true
}


proc update_MODELPARAM_VALUE.INPUT_FREQUENCY { MODELPARAM_VALUE.INPUT_FREQUENCY PARAM_VALUE.INPUT_FREQUENCY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_FREQUENCY}] ${MODELPARAM_VALUE.INPUT_FREQUENCY}
}

proc update_MODELPARAM_VALUE.ADDRESS_BUS_SIZE { MODELPARAM_VALUE.ADDRESS_BUS_SIZE PARAM_VALUE.ADDRESS_BUS_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDRESS_BUS_SIZE}] ${MODELPARAM_VALUE.ADDRESS_BUS_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_BUS_SIZE { MODELPARAM_VALUE.DATA_BUS_SIZE PARAM_VALUE.DATA_BUS_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_BUS_SIZE}] ${MODELPARAM_VALUE.DATA_BUS_SIZE}
}

proc update_MODELPARAM_VALUE.CLOCK_CONFIG_WIDTH { MODELPARAM_VALUE.CLOCK_CONFIG_WIDTH PARAM_VALUE.CLOCK_CONFIG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_CONFIG_WIDTH}] ${MODELPARAM_VALUE.CLOCK_CONFIG_WIDTH}
}


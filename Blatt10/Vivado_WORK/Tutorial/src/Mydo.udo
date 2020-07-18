vcom   -93 "src/ArmArithInstructionCtrl.vhd"
vcom   -93 "src/ArmControlPath.vhd"
vcom   -93 "src/ArmCore_TB.vhd"
vsim -t 1ps   -lib work ArmCore_TB
view wave

# add wave -unsigned {sim:/armcore_tb/testcycle_nr}
add wave *

add wave \
{sim:/armcore_tb/uut/armcontrolpath/arm_state } \
{sim:/armcore_tb/uut/armcontrolpath/arm_next_state }\
{sim:/armcore_tb/uut/armcontrolpath/armcoarseinstructiondecoder_instance/cid_decoded_vector}\
{sim:/armcore_tb/uut/armcontrolpath/cdc_condition_met } \
{sim:/armcore_tb/uut/armcontrolpath/main_delay }
add wave \
{sim:/armcore_tb/uut/armcontrolpath/armldmstmnextaddress_instance/lna_load_reglist } \
{sim:/armcore_tb/uut/armcontrolpath/armldmstmnextaddress_instance/lna_hold_value } \
{sim:/armcore_tb/uut/armcontrolpath/armldmstmnextaddress_instance/lna_address } \
{sim:/armcore_tb/uut/armcontrolpath/armldmstmnextaddress_instance/lna_current_reglist_reg } 
add wave \
{sim:/armcore_tb/uut/armcontrolpath/cpa_mem_den } 
add wave \
{sim:/armcore_tb/inst_armmeminterface/dabort } 
 
add wave -hexadecimal \
{sim:/armcore_tb/uut/armdatapath/ex_opa_mux } \
{sim:/armcore_tb/uut/armdatapath/ex_opb_mux } \
{sim:/armcore_tb/uut/armdatapath/ex_opc_mux } \
{sim:/armcore_tb/uut/armdatapath/ex_shift_mux } \
{sim:/armcore_tb/uut/armdatapath/ex_cc_mux }
add wave -binary \
{sim:/armcore_tb/uut/armdatapath/dpa_ex_opa_mux_ctrl } \
{sim:/armcore_tb/uut/armdatapath/dpa_ex_opb_mux_ctrl } \
{sim:/armcore_tb/uut/armdatapath/dpa_ex_opc_mux_ctrl } \
{sim:/armcore_tb/uut/armdatapath/dpa_ex_shift_mux_ctrl } \
{sim:/armcore_tb/uut/armdatapath/dpa_ex_cc_mux_ctrl } 
add wave -decimal \
{sim:/armcore_tb/uut/armdatapath/ex_shift_res } \
{sim:/armcore_tb/uut/armdatapath/ex_mul_res } \
{sim:/armcore_tb/uut/armdatapath/ex_alu_res } 
add wave -binary \
{sim:/armcore_tb/uut/armdatapath/ex_shift_c_out } \
{sim:/armcore_tb/uut/armdatapath/ex_alu_cc_in } \
{sim:/armcore_tb/uut/armdatapath/ex_alu_cc_out }
add wave -hexadecimal\
{sim:/armcore_tb/uut/armdatapath/mem_data_reg } \
{sim:/armcore_tb/uut/armdatapath/mem_res_reg } \
{sim:/armcore_tb/uut/armdatapath/mem_cc_reg } \
{sim:/armcore_tb/uut/armdatapath/wb_cc_reg } \
{sim:/armcore_tb/uut/armdatapath/wb_load_reg } \
{sim:/armcore_tb/uut/armdatapath/wb_res_reg } 
add wave -binary\
{sim:/armcore_tb/uut/armcontrolpath/cpa_wb_ref_w_port_a_en } \
{sim:/armcore_tb/uut/armcontrolpath/cpa_wb_ref_w_port_b_en } 
add wave -hexadecimal\
{sim:/armcore_tb/uut/armcontrolpath/inst_armarithinstructionctrl/aic_id_r_port_a_addr } \
{sim:/armcore_tb/uut/armcontrolpath/inst_armarithinstructionctrl/aic_id_r_port_b_addr } \
{sim:/armcore_tb/uut/armcontrolpath/inst_armarithinstructionctrl/aic_id_r_port_c_addr } \
{sim:/armcore_tb/uut/armcontrolpath/inst_armarithinstructionctrl/aic_wb_w_port_a_addr } 

run -all


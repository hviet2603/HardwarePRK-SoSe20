-- ProjNav VHDL simulation template: ArmTop_TB.udo
-- You may edit this file after the line that starts with
-- '-- START' to customize your simulation
-- START user-defined simulation commands

add wave \
{sim:/armtop_tb/uut/sys_clk } \
{sim:/armtop_tb/uut/sys_inv_clk } \
{sim:/armtop_tb/uut/sys_rst } \
{sim:/armtop_tb/uut/ibus_ia } \
{sim:/armtop_tb/uut/ibus_id } \
{sim:/armtop_tb/uut/ibus_abort } \
{sim:/armtop_tb/uut/ibus_ibe } \
{sim:/armtop_tb/uut/ibus_ien } \
{sim:/armtop_tb/uut/dbus_da } \
{sim:/armtop_tb/uut/dbus_ddout } \
{sim:/armtop_tb/uut/dbus_ddin } \
{sim:/armtop_tb/uut/dbus_abort } \
{sim:/armtop_tb/uut/dbus_dnrw } \
{sim:/armtop_tb/uut/dbus_dmas } \
{sim:/armtop_tb/uut/core_dbe } \
{sim:/armtop_tb/uut/dbus_den } \
{sim:/armtop_tb/uut/dbus_cs_rs232 } \
{sim:/armtop_tb/uut/dbus_cs_mem } \
{sim:/armtop_tb/uut/inst_armcore/armcontrolpath/arm_state } \
{sim:/armtop_tb/uut/inst_armcore/armcontrolpath/arm_next_state } \
{sim:/armtop_tb/uut/inst_armcore/armcontrolpath/id_instruction_reg } \
{sim:/armtop_tb/uut/inst_armcore/armcontrolpath/cid_decoded_vector }

run -all

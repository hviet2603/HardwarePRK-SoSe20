// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Wed Jun 24 15:17:01 2020
// Host        : toro-ubu running 64-bit Ubuntu 18.04.4 LTS
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               /afs/tu-berlin.de/home/h/hungbui7698/irb-ubuntu/HWP/HardwarePRK-SoSe20/Blatt06/Vivado_WORK/Tutorial/project_1/project_1.sim/sim_1/impl/timing/questa/ArmRegisterBitAdder_TB_time_impl.v
// Design      : ArmRegisterBitAdder
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "c3e064ae" *) 
(* NotValidForBitStream *)
module ArmRegisterBitAdder
   (RBA_REGLIST,
    RBA_NR_OF_REGS);
  input [15:0]RBA_REGLIST;
  output [4:0]RBA_NR_OF_REGS;

  wire [4:0]RBA_NR_OF_REGS;
  wire [4:0]RBA_NR_OF_REGS_OBUF;
  wire \RBA_NR_OF_REGS_OBUF[0]_inst_i_2_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_2_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_3_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_4_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_5_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_6_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_7_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[1]_inst_i_8_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[2]_inst_i_2_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_10_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_11_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_2_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_3_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_4_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_5_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_6_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_7_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_8_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[3]_inst_i_9_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[4]_inst_i_2_n_0 ;
  wire \RBA_NR_OF_REGS_OBUF[4]_inst_i_3_n_0 ;
  wire [15:0]RBA_REGLIST;
  wire [15:0]RBA_REGLIST_IBUF;

initial begin
 $sdf_annotate("ArmRegisterBitAdder_TB_time_impl.sdf",,,,"tool_control");
end
  OBUF \RBA_NR_OF_REGS_OBUF[0]_inst 
       (.I(RBA_NR_OF_REGS_OBUF[0]),
        .O(RBA_NR_OF_REGS[0]));
  LUT6 #(
    .INIT(64'h6996966996696996)) 
    \RBA_NR_OF_REGS_OBUF[0]_inst_i_1 
       (.I0(\RBA_NR_OF_REGS_OBUF[1]_inst_i_2_n_0 ),
        .I1(RBA_REGLIST_IBUF[15]),
        .I2(RBA_REGLIST_IBUF[14]),
        .I3(RBA_REGLIST_IBUF[13]),
        .I4(RBA_REGLIST_IBUF[12]),
        .I5(\RBA_NR_OF_REGS_OBUF[0]_inst_i_2_n_0 ),
        .O(RBA_NR_OF_REGS_OBUF[0]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h96696996)) 
    \RBA_NR_OF_REGS_OBUF[0]_inst_i_2 
       (.I0(RBA_REGLIST_IBUF[4]),
        .I1(RBA_REGLIST_IBUF[5]),
        .I2(RBA_REGLIST_IBUF[6]),
        .I3(RBA_REGLIST_IBUF[7]),
        .I4(\RBA_NR_OF_REGS_OBUF[1]_inst_i_4_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[0]_inst_i_2_n_0 ));
  OBUF \RBA_NR_OF_REGS_OBUF[1]_inst 
       (.I(RBA_NR_OF_REGS_OBUF[1]),
        .O(RBA_NR_OF_REGS[1]));
  LUT6 #(
    .INIT(64'hF99F06600660F99F)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_1 
       (.I0(\RBA_NR_OF_REGS_OBUF[1]_inst_i_2_n_0 ),
        .I1(\RBA_NR_OF_REGS_OBUF[1]_inst_i_3_n_0 ),
        .I2(\RBA_NR_OF_REGS_OBUF[1]_inst_i_4_n_0 ),
        .I3(\RBA_NR_OF_REGS_OBUF[1]_inst_i_5_n_0 ),
        .I4(\RBA_NR_OF_REGS_OBUF[1]_inst_i_6_n_0 ),
        .I5(\RBA_NR_OF_REGS_OBUF[1]_inst_i_7_n_0 ),
        .O(RBA_NR_OF_REGS_OBUF[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_2 
       (.I0(RBA_REGLIST_IBUF[11]),
        .I1(RBA_REGLIST_IBUF[10]),
        .I2(RBA_REGLIST_IBUF[9]),
        .I3(RBA_REGLIST_IBUF[8]),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_3 
       (.I0(RBA_REGLIST_IBUF[15]),
        .I1(RBA_REGLIST_IBUF[14]),
        .I2(RBA_REGLIST_IBUF[13]),
        .I3(RBA_REGLIST_IBUF[12]),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_4 
       (.I0(RBA_REGLIST_IBUF[3]),
        .I1(RBA_REGLIST_IBUF[2]),
        .I2(RBA_REGLIST_IBUF[1]),
        .I3(RBA_REGLIST_IBUF[0]),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_4_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_5 
       (.I0(RBA_REGLIST_IBUF[7]),
        .I1(RBA_REGLIST_IBUF[6]),
        .I2(RBA_REGLIST_IBUF[5]),
        .I3(RBA_REGLIST_IBUF[4]),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h177E7EE8E8818117)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_6 
       (.I0(\RBA_NR_OF_REGS_OBUF[1]_inst_i_5_n_0 ),
        .I1(RBA_REGLIST_IBUF[0]),
        .I2(RBA_REGLIST_IBUF[1]),
        .I3(RBA_REGLIST_IBUF[2]),
        .I4(RBA_REGLIST_IBUF[3]),
        .I5(\RBA_NR_OF_REGS_OBUF[3]_inst_i_10_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hE8818117177E7EE8)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_7 
       (.I0(\RBA_NR_OF_REGS_OBUF[1]_inst_i_3_n_0 ),
        .I1(RBA_REGLIST_IBUF[8]),
        .I2(RBA_REGLIST_IBUF[9]),
        .I3(RBA_REGLIST_IBUF[10]),
        .I4(RBA_REGLIST_IBUF[11]),
        .I5(\RBA_NR_OF_REGS_OBUF[1]_inst_i_8_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h7EE8)) 
    \RBA_NR_OF_REGS_OBUF[1]_inst_i_8 
       (.I0(RBA_REGLIST_IBUF[12]),
        .I1(RBA_REGLIST_IBUF[13]),
        .I2(RBA_REGLIST_IBUF[14]),
        .I3(RBA_REGLIST_IBUF[15]),
        .O(\RBA_NR_OF_REGS_OBUF[1]_inst_i_8_n_0 ));
  OBUF \RBA_NR_OF_REGS_OBUF[2]_inst 
       (.I(RBA_NR_OF_REGS_OBUF[2]),
        .O(RBA_NR_OF_REGS[2]));
  LUT3 #(
    .INIT(8'h69)) 
    \RBA_NR_OF_REGS_OBUF[2]_inst_i_1 
       (.I0(\RBA_NR_OF_REGS_OBUF[3]_inst_i_2_n_0 ),
        .I1(\RBA_NR_OF_REGS_OBUF[3]_inst_i_3_n_0 ),
        .I2(\RBA_NR_OF_REGS_OBUF[2]_inst_i_2_n_0 ),
        .O(RBA_NR_OF_REGS_OBUF[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h80007FFF)) 
    \RBA_NR_OF_REGS_OBUF[2]_inst_i_2 
       (.I0(RBA_REGLIST_IBUF[8]),
        .I1(RBA_REGLIST_IBUF[9]),
        .I2(RBA_REGLIST_IBUF[10]),
        .I3(RBA_REGLIST_IBUF[11]),
        .I4(\RBA_NR_OF_REGS_OBUF[3]_inst_i_5_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[2]_inst_i_2_n_0 ));
  OBUF \RBA_NR_OF_REGS_OBUF[3]_inst 
       (.I(RBA_NR_OF_REGS_OBUF[3]),
        .O(RBA_NR_OF_REGS[3]));
  LUT5 #(
    .INIT(32'hFB2FF2FB)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_1 
       (.I0(\RBA_NR_OF_REGS_OBUF[3]_inst_i_2_n_0 ),
        .I1(\RBA_NR_OF_REGS_OBUF[3]_inst_i_3_n_0 ),
        .I2(\RBA_NR_OF_REGS_OBUF[3]_inst_i_4_n_0 ),
        .I3(\RBA_NR_OF_REGS_OBUF[3]_inst_i_5_n_0 ),
        .I4(\RBA_NR_OF_REGS_OBUF[3]_inst_i_6_n_0 ),
        .O(RBA_NR_OF_REGS_OBUF[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h7EE8)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_10 
       (.I0(RBA_REGLIST_IBUF[4]),
        .I1(RBA_REGLIST_IBUF[5]),
        .I2(RBA_REGLIST_IBUF[6]),
        .I3(RBA_REGLIST_IBUF[7]),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_10_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h8117)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_11 
       (.I0(RBA_REGLIST_IBUF[8]),
        .I1(RBA_REGLIST_IBUF[9]),
        .I2(RBA_REGLIST_IBUF[10]),
        .I3(RBA_REGLIST_IBUF[11]),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_11_n_0 ));
  LUT6 #(
    .INIT(64'h0660FFFF00000660)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_2 
       (.I0(\RBA_NR_OF_REGS_OBUF[1]_inst_i_2_n_0 ),
        .I1(\RBA_NR_OF_REGS_OBUF[1]_inst_i_3_n_0 ),
        .I2(\RBA_NR_OF_REGS_OBUF[1]_inst_i_4_n_0 ),
        .I3(\RBA_NR_OF_REGS_OBUF[1]_inst_i_5_n_0 ),
        .I4(\RBA_NR_OF_REGS_OBUF[1]_inst_i_6_n_0 ),
        .I5(\RBA_NR_OF_REGS_OBUF[1]_inst_i_7_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h60006660)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_3 
       (.I0(\RBA_NR_OF_REGS_OBUF[4]_inst_i_2_n_0 ),
        .I1(\RBA_NR_OF_REGS_OBUF[3]_inst_i_7_n_0 ),
        .I2(\RBA_NR_OF_REGS_OBUF[3]_inst_i_8_n_0 ),
        .I3(\RBA_NR_OF_REGS_OBUF[3]_inst_i_9_n_0 ),
        .I4(\RBA_NR_OF_REGS_OBUF[3]_inst_i_10_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00008000)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_4 
       (.I0(RBA_REGLIST_IBUF[0]),
        .I1(RBA_REGLIST_IBUF[1]),
        .I2(RBA_REGLIST_IBUF[2]),
        .I3(RBA_REGLIST_IBUF[3]),
        .I4(\RBA_NR_OF_REGS_OBUF[4]_inst_i_2_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h022A2AAB2AABABBF)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_5 
       (.I0(\RBA_NR_OF_REGS_OBUF[3]_inst_i_11_n_0 ),
        .I1(RBA_REGLIST_IBUF[12]),
        .I2(RBA_REGLIST_IBUF[13]),
        .I3(RBA_REGLIST_IBUF[14]),
        .I4(RBA_REGLIST_IBUF[15]),
        .I5(\RBA_NR_OF_REGS_OBUF[1]_inst_i_2_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_5_n_0 ));
  LUT4 #(
    .INIT(16'h8000)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_6 
       (.I0(RBA_REGLIST_IBUF[11]),
        .I1(RBA_REGLIST_IBUF[10]),
        .I2(RBA_REGLIST_IBUF[9]),
        .I3(RBA_REGLIST_IBUF[8]),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_7 
       (.I0(RBA_REGLIST_IBUF[3]),
        .I1(RBA_REGLIST_IBUF[2]),
        .I2(RBA_REGLIST_IBUF[1]),
        .I3(RBA_REGLIST_IBUF[0]),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h8117)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_8 
       (.I0(RBA_REGLIST_IBUF[0]),
        .I1(RBA_REGLIST_IBUF[1]),
        .I2(RBA_REGLIST_IBUF[2]),
        .I3(RBA_REGLIST_IBUF[3]),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_8_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h9669FFFF)) 
    \RBA_NR_OF_REGS_OBUF[3]_inst_i_9 
       (.I0(RBA_REGLIST_IBUF[4]),
        .I1(RBA_REGLIST_IBUF[5]),
        .I2(RBA_REGLIST_IBUF[6]),
        .I3(RBA_REGLIST_IBUF[7]),
        .I4(\RBA_NR_OF_REGS_OBUF[1]_inst_i_4_n_0 ),
        .O(\RBA_NR_OF_REGS_OBUF[3]_inst_i_9_n_0 ));
  OBUF \RBA_NR_OF_REGS_OBUF[4]_inst 
       (.I(RBA_NR_OF_REGS_OBUF[4]),
        .O(RBA_NR_OF_REGS[4]));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \RBA_NR_OF_REGS_OBUF[4]_inst_i_1 
       (.I0(\RBA_NR_OF_REGS_OBUF[4]_inst_i_2_n_0 ),
        .I1(RBA_REGLIST_IBUF[3]),
        .I2(RBA_REGLIST_IBUF[2]),
        .I3(RBA_REGLIST_IBUF[1]),
        .I4(RBA_REGLIST_IBUF[0]),
        .I5(\RBA_NR_OF_REGS_OBUF[4]_inst_i_3_n_0 ),
        .O(RBA_NR_OF_REGS_OBUF[4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \RBA_NR_OF_REGS_OBUF[4]_inst_i_2 
       (.I0(RBA_REGLIST_IBUF[7]),
        .I1(RBA_REGLIST_IBUF[6]),
        .I2(RBA_REGLIST_IBUF[5]),
        .I3(RBA_REGLIST_IBUF[4]),
        .O(\RBA_NR_OF_REGS_OBUF[4]_inst_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hBFFFFFFF)) 
    \RBA_NR_OF_REGS_OBUF[4]_inst_i_3 
       (.I0(\RBA_NR_OF_REGS_OBUF[3]_inst_i_5_n_0 ),
        .I1(RBA_REGLIST_IBUF[8]),
        .I2(RBA_REGLIST_IBUF[9]),
        .I3(RBA_REGLIST_IBUF[10]),
        .I4(RBA_REGLIST_IBUF[11]),
        .O(\RBA_NR_OF_REGS_OBUF[4]_inst_i_3_n_0 ));
  IBUF \RBA_REGLIST_IBUF[0]_inst 
       (.I(RBA_REGLIST[0]),
        .O(RBA_REGLIST_IBUF[0]));
  IBUF \RBA_REGLIST_IBUF[10]_inst 
       (.I(RBA_REGLIST[10]),
        .O(RBA_REGLIST_IBUF[10]));
  IBUF \RBA_REGLIST_IBUF[11]_inst 
       (.I(RBA_REGLIST[11]),
        .O(RBA_REGLIST_IBUF[11]));
  IBUF \RBA_REGLIST_IBUF[12]_inst 
       (.I(RBA_REGLIST[12]),
        .O(RBA_REGLIST_IBUF[12]));
  IBUF \RBA_REGLIST_IBUF[13]_inst 
       (.I(RBA_REGLIST[13]),
        .O(RBA_REGLIST_IBUF[13]));
  IBUF \RBA_REGLIST_IBUF[14]_inst 
       (.I(RBA_REGLIST[14]),
        .O(RBA_REGLIST_IBUF[14]));
  IBUF \RBA_REGLIST_IBUF[15]_inst 
       (.I(RBA_REGLIST[15]),
        .O(RBA_REGLIST_IBUF[15]));
  IBUF \RBA_REGLIST_IBUF[1]_inst 
       (.I(RBA_REGLIST[1]),
        .O(RBA_REGLIST_IBUF[1]));
  IBUF \RBA_REGLIST_IBUF[2]_inst 
       (.I(RBA_REGLIST[2]),
        .O(RBA_REGLIST_IBUF[2]));
  IBUF \RBA_REGLIST_IBUF[3]_inst 
       (.I(RBA_REGLIST[3]),
        .O(RBA_REGLIST_IBUF[3]));
  IBUF \RBA_REGLIST_IBUF[4]_inst 
       (.I(RBA_REGLIST[4]),
        .O(RBA_REGLIST_IBUF[4]));
  IBUF \RBA_REGLIST_IBUF[5]_inst 
       (.I(RBA_REGLIST[5]),
        .O(RBA_REGLIST_IBUF[5]));
  IBUF \RBA_REGLIST_IBUF[6]_inst 
       (.I(RBA_REGLIST[6]),
        .O(RBA_REGLIST_IBUF[6]));
  IBUF \RBA_REGLIST_IBUF[7]_inst 
       (.I(RBA_REGLIST[7]),
        .O(RBA_REGLIST_IBUF[7]));
  IBUF \RBA_REGLIST_IBUF[8]_inst 
       (.I(RBA_REGLIST[8]),
        .O(RBA_REGLIST_IBUF[8]));
  IBUF \RBA_REGLIST_IBUF[9]_inst 
       (.I(RBA_REGLIST[9]),
        .O(RBA_REGLIST_IBUF[9]));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif

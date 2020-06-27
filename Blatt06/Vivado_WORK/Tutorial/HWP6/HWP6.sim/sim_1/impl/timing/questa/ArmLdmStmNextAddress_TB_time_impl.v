// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Wed Jun 24 14:29:09 2020
// Host        : casa-ubu running 64-bit Ubuntu 18.04.4 LTS
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               /afs/tu-berlin.de/home/v/vincenthp2603/irb-ubuntu/HardwarePratikum/HardwarePRK-SoSe20/Blatt06/Vivado_WORK/Tutorial/HWP6/HWP6.sim/sim_1/impl/timing/questa/ArmLdmStmNextAddress_TB_time_impl.v
// Design      : ArmLdmStmNextAddress
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "960c380" *) 
(* NotValidForBitStream *)
module ArmLdmStmNextAddress
   (SYS_RST,
    SYS_CLK,
    LNA_LOAD_REGLIST,
    LNA_HOLD_VALUE,
    LNA_REGLIST,
    LNA_ADDRESS,
    LNA_CURRENT_REGLIST_REG);
  input SYS_RST;
  input SYS_CLK;
  input LNA_LOAD_REGLIST;
  input LNA_HOLD_VALUE;
  input [15:0]LNA_REGLIST;
  output [3:0]LNA_ADDRESS;
  output [15:0]LNA_CURRENT_REGLIST_REG;

  wire [3:0]LNA_ADDRESS;
  wire [3:0]LNA_ADDRESS_OBUF;
  wire \LNA_ADDRESS_OBUF[0]_inst_i_2_n_0 ;
  wire \LNA_ADDRESS_OBUF[0]_inst_i_3_n_0 ;
  wire \LNA_ADDRESS_OBUF[1]_inst_i_2_n_0 ;
  wire \LNA_ADDRESS_OBUF[1]_inst_i_3_n_0 ;
  wire \LNA_ADDRESS_OBUF[1]_inst_i_4_n_0 ;
  wire \LNA_ADDRESS_OBUF[2]_inst_i_2_n_0 ;
  wire \LNA_ADDRESS_OBUF[2]_inst_i_3_n_0 ;
  wire \LNA_ADDRESS_OBUF[2]_inst_i_4_n_0 ;
  wire \LNA_ADDRESS_OBUF[3]_inst_i_2_n_0 ;
  wire \LNA_ADDRESS_OBUF[3]_inst_i_3_n_0 ;
  wire [15:0]LNA_CURRENT_REGLIST_REG;
  wire [15:0]LNA_CURRENT_REGLIST_REG_OBUF;
  wire LNA_HOLD_VALUE;
  wire LNA_HOLD_VALUE_IBUF;
  wire LNA_LOAD_REGLIST;
  wire LNA_LOAD_REGLIST_IBUF;
  wire [15:0]LNA_REGLIST;
  wire [15:0]LNA_REGLIST_IBUF;
  wire \REGLIST[0]_i_1_n_0 ;
  wire \REGLIST[10]_i_1_n_0 ;
  wire \REGLIST[11]_i_1_n_0 ;
  wire \REGLIST[11]_i_2_n_0 ;
  wire \REGLIST[11]_i_3_n_0 ;
  wire \REGLIST[12]_i_1_n_0 ;
  wire \REGLIST[13]_i_1_n_0 ;
  wire \REGLIST[14]_i_1_n_0 ;
  wire \REGLIST[15]_i_1_n_0 ;
  wire \REGLIST[15]_i_2_n_0 ;
  wire \REGLIST[15]_i_3_n_0 ;
  wire \REGLIST[1]_i_1_n_0 ;
  wire \REGLIST[2]_i_1_n_0 ;
  wire \REGLIST[3]_i_1_n_0 ;
  wire \REGLIST[4]_i_1_n_0 ;
  wire \REGLIST[5]_i_1_n_0 ;
  wire \REGLIST[6]_i_1_n_0 ;
  wire \REGLIST[7]_i_1_n_0 ;
  wire \REGLIST[7]_i_2_n_0 ;
  wire \REGLIST[8]_i_1_n_0 ;
  wire \REGLIST[9]_i_1_n_0 ;
  wire SYS_CLK;
  wire SYS_CLK_IBUF;
  wire SYS_CLK_IBUF_BUFG;
  wire SYS_RST;
  wire SYS_RST_IBUF;

initial begin
 $sdf_annotate("ArmLdmStmNextAddress_TB_time_impl.sdf",,,,"tool_control");
end
  OBUF \LNA_ADDRESS_OBUF[0]_inst 
       (.I(LNA_ADDRESS_OBUF[0]),
        .O(LNA_ADDRESS[0]));
  LUT6 #(
    .INIT(64'h0000AAAA0000FFBA)) 
    \LNA_ADDRESS_OBUF[0]_inst_i_1 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I2(\LNA_ADDRESS_OBUF[0]_inst_i_2_n_0 ),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I5(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .O(LNA_ADDRESS_OBUF[0]));
  LUT6 #(
    .INIT(64'hFFFFFFFF55551110)) 
    \LNA_ADDRESS_OBUF[0]_inst_i_2 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .I2(\LNA_ADDRESS_OBUF[0]_inst_i_3_n_0 ),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .I5(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .O(\LNA_ADDRESS_OBUF[0]_inst_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000AAAAEEFE)) 
    \LNA_ADDRESS_OBUF[0]_inst_i_3 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[11]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I5(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .O(\LNA_ADDRESS_OBUF[0]_inst_i_3_n_0 ));
  OBUF \LNA_ADDRESS_OBUF[1]_inst 
       (.I(LNA_ADDRESS_OBUF[1]),
        .O(LNA_ADDRESS[1]));
  LUT6 #(
    .INIT(64'hEE00EE00EE00FE00)) 
    \LNA_ADDRESS_OBUF[1]_inst_i_1 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .I2(\LNA_ADDRESS_OBUF[1]_inst_i_2_n_0 ),
        .I3(\LNA_ADDRESS_OBUF[1]_inst_i_3_n_0 ),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .I5(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .O(LNA_ADDRESS_OBUF[1]));
  LUT5 #(
    .INIT(32'hFFFFFF10)) 
    \LNA_ADDRESS_OBUF[1]_inst_i_2 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .I2(\LNA_ADDRESS_OBUF[1]_inst_i_4_n_0 ),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .O(\LNA_ADDRESS_OBUF[1]_inst_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \LNA_ADDRESS_OBUF[1]_inst_i_3 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .O(\LNA_ADDRESS_OBUF[1]_inst_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF1110)) 
    \LNA_ADDRESS_OBUF[1]_inst_i_4 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[11]),
        .I5(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .O(\LNA_ADDRESS_OBUF[1]_inst_i_4_n_0 ));
  OBUF \LNA_ADDRESS_OBUF[2]_inst 
       (.I(LNA_ADDRESS_OBUF[2]),
        .O(LNA_ADDRESS[2]));
  LUT6 #(
    .INIT(64'hFE00FE00FF00FE00)) 
    \LNA_ADDRESS_OBUF[2]_inst_i_1 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I2(\LNA_ADDRESS_OBUF[2]_inst_i_2_n_0 ),
        .I3(\LNA_ADDRESS_OBUF[2]_inst_i_3_n_0 ),
        .I4(\LNA_ADDRESS_OBUF[2]_inst_i_4_n_0 ),
        .I5(\LNA_ADDRESS_OBUF[3]_inst_i_2_n_0 ),
        .O(LNA_ADDRESS_OBUF[2]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \LNA_ADDRESS_OBUF[2]_inst_i_2 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .O(\LNA_ADDRESS_OBUF[2]_inst_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \LNA_ADDRESS_OBUF[2]_inst_i_3 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .O(\LNA_ADDRESS_OBUF[2]_inst_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \LNA_ADDRESS_OBUF[2]_inst_i_4 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .O(\LNA_ADDRESS_OBUF[2]_inst_i_4_n_0 ));
  OBUF \LNA_ADDRESS_OBUF[3]_inst 
       (.I(LNA_ADDRESS_OBUF[3]),
        .O(LNA_ADDRESS[3]));
  LUT6 #(
    .INIT(64'hCCCCCCCCCCCCCCC8)) 
    \LNA_ADDRESS_OBUF[3]_inst_i_1 
       (.I0(\LNA_ADDRESS_OBUF[3]_inst_i_2_n_0 ),
        .I1(\LNA_ADDRESS_OBUF[3]_inst_i_3_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .I5(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .O(LNA_ADDRESS_OBUF[3]));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \LNA_ADDRESS_OBUF[3]_inst_i_2 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[11]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .O(\LNA_ADDRESS_OBUF[3]_inst_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00000002)) 
    \LNA_ADDRESS_OBUF[3]_inst_i_3 
       (.I0(\LNA_ADDRESS_OBUF[2]_inst_i_3_n_0 ),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .O(\LNA_ADDRESS_OBUF[3]_inst_i_3_n_0 ));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[0]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .O(LNA_CURRENT_REGLIST_REG[0]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[10]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .O(LNA_CURRENT_REGLIST_REG[10]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[11]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[11]),
        .O(LNA_CURRENT_REGLIST_REG[11]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[12]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .O(LNA_CURRENT_REGLIST_REG[12]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[13]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .O(LNA_CURRENT_REGLIST_REG[13]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[14]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .O(LNA_CURRENT_REGLIST_REG[14]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[15]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .O(LNA_CURRENT_REGLIST_REG[15]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[1]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .O(LNA_CURRENT_REGLIST_REG[1]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[2]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .O(LNA_CURRENT_REGLIST_REG[2]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[3]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .O(LNA_CURRENT_REGLIST_REG[3]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[4]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .O(LNA_CURRENT_REGLIST_REG[4]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[5]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .O(LNA_CURRENT_REGLIST_REG[5]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[6]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .O(LNA_CURRENT_REGLIST_REG[6]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[7]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .O(LNA_CURRENT_REGLIST_REG[7]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[8]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .O(LNA_CURRENT_REGLIST_REG[8]));
  OBUF \LNA_CURRENT_REGLIST_REG_OBUF[9]_inst 
       (.I(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .O(LNA_CURRENT_REGLIST_REG[9]));
  IBUF LNA_HOLD_VALUE_IBUF_inst
       (.I(LNA_HOLD_VALUE),
        .O(LNA_HOLD_VALUE_IBUF));
  IBUF LNA_LOAD_REGLIST_IBUF_inst
       (.I(LNA_LOAD_REGLIST),
        .O(LNA_LOAD_REGLIST_IBUF));
  IBUF \LNA_REGLIST_IBUF[0]_inst 
       (.I(LNA_REGLIST[0]),
        .O(LNA_REGLIST_IBUF[0]));
  IBUF \LNA_REGLIST_IBUF[10]_inst 
       (.I(LNA_REGLIST[10]),
        .O(LNA_REGLIST_IBUF[10]));
  IBUF \LNA_REGLIST_IBUF[11]_inst 
       (.I(LNA_REGLIST[11]),
        .O(LNA_REGLIST_IBUF[11]));
  IBUF \LNA_REGLIST_IBUF[12]_inst 
       (.I(LNA_REGLIST[12]),
        .O(LNA_REGLIST_IBUF[12]));
  IBUF \LNA_REGLIST_IBUF[13]_inst 
       (.I(LNA_REGLIST[13]),
        .O(LNA_REGLIST_IBUF[13]));
  IBUF \LNA_REGLIST_IBUF[14]_inst 
       (.I(LNA_REGLIST[14]),
        .O(LNA_REGLIST_IBUF[14]));
  IBUF \LNA_REGLIST_IBUF[15]_inst 
       (.I(LNA_REGLIST[15]),
        .O(LNA_REGLIST_IBUF[15]));
  IBUF \LNA_REGLIST_IBUF[1]_inst 
       (.I(LNA_REGLIST[1]),
        .O(LNA_REGLIST_IBUF[1]));
  IBUF \LNA_REGLIST_IBUF[2]_inst 
       (.I(LNA_REGLIST[2]),
        .O(LNA_REGLIST_IBUF[2]));
  IBUF \LNA_REGLIST_IBUF[3]_inst 
       (.I(LNA_REGLIST[3]),
        .O(LNA_REGLIST_IBUF[3]));
  IBUF \LNA_REGLIST_IBUF[4]_inst 
       (.I(LNA_REGLIST[4]),
        .O(LNA_REGLIST_IBUF[4]));
  IBUF \LNA_REGLIST_IBUF[5]_inst 
       (.I(LNA_REGLIST[5]),
        .O(LNA_REGLIST_IBUF[5]));
  IBUF \LNA_REGLIST_IBUF[6]_inst 
       (.I(LNA_REGLIST[6]),
        .O(LNA_REGLIST_IBUF[6]));
  IBUF \LNA_REGLIST_IBUF[7]_inst 
       (.I(LNA_REGLIST[7]),
        .O(LNA_REGLIST_IBUF[7]));
  IBUF \LNA_REGLIST_IBUF[8]_inst 
       (.I(LNA_REGLIST[8]),
        .O(LNA_REGLIST_IBUF[8]));
  IBUF \LNA_REGLIST_IBUF[9]_inst 
       (.I(LNA_REGLIST[9]),
        .O(LNA_REGLIST_IBUF[9]));
  LUT4 #(
    .INIT(16'hAAC0)) 
    \REGLIST[0]_i_1 
       (.I0(LNA_REGLIST_IBUF[0]),
        .I1(LNA_HOLD_VALUE_IBUF),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I3(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAF0F0F030)) 
    \REGLIST[10]_i_1 
       (.I0(LNA_REGLIST_IBUF[10]),
        .I1(\REGLIST[11]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAFF00F300)) 
    \REGLIST[11]_i_1 
       (.I0(LNA_REGLIST_IBUF[11]),
        .I1(\REGLIST[11]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[11]),
        .I4(\REGLIST[11]_i_3_n_0 ),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000010000)) 
    \REGLIST[11]_i_2 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I4(\LNA_ADDRESS_OBUF[2]_inst_i_3_n_0 ),
        .I5(LNA_HOLD_VALUE_IBUF),
        .O(\REGLIST[11]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \REGLIST[11]_i_3 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .O(\REGLIST[11]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hAA0C)) 
    \REGLIST[12]_i_1 
       (.I0(LNA_REGLIST_IBUF[12]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I2(\REGLIST[15]_i_2_n_0 ),
        .I3(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hAAAAF030)) 
    \REGLIST[13]_i_1 
       (.I0(LNA_REGLIST_IBUF[13]),
        .I1(\REGLIST[15]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I4(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAF0F0F030)) 
    \REGLIST[14]_i_1 
       (.I0(LNA_REGLIST_IBUF[14]),
        .I1(\REGLIST[15]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAFF00F300)) 
    \REGLIST[15]_i_1 
       (.I0(LNA_REGLIST_IBUF[15]),
        .I1(\REGLIST[15]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .I4(\REGLIST[15]_i_3_n_0 ),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000004)) 
    \REGLIST[15]_i_2 
       (.I0(LNA_HOLD_VALUE_IBUF),
        .I1(\LNA_ADDRESS_OBUF[2]_inst_i_3_n_0 ),
        .I2(\LNA_ADDRESS_OBUF[2]_inst_i_2_n_0 ),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .I5(\LNA_ADDRESS_OBUF[3]_inst_i_2_n_0 ),
        .O(\REGLIST[15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \REGLIST[15]_i_3 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .O(\REGLIST[15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'hAAAAF0C0)) 
    \REGLIST[1]_i_1 
       (.I0(LNA_REGLIST_IBUF[1]),
        .I1(LNA_HOLD_VALUE_IBUF),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I4(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAFF00FC00)) 
    \REGLIST[2]_i_1 
       (.I0(LNA_REGLIST_IBUF[2]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .I4(LNA_HOLD_VALUE_IBUF),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAFF00F300)) 
    \REGLIST[3]_i_1 
       (.I0(LNA_REGLIST_IBUF[3]),
        .I1(\LNA_ADDRESS_OBUF[1]_inst_i_3_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .I4(LNA_HOLD_VALUE_IBUF),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[3]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hAA0C)) 
    \REGLIST[4]_i_1 
       (.I0(LNA_REGLIST_IBUF[4]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I2(\REGLIST[7]_i_2_n_0 ),
        .I3(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAF030)) 
    \REGLIST[5]_i_1 
       (.I0(LNA_REGLIST_IBUF[5]),
        .I1(\REGLIST[7]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I4(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAF0F0F030)) 
    \REGLIST[6]_i_1 
       (.I0(LNA_REGLIST_IBUF[6]),
        .I1(\REGLIST[7]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .I4(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAFF00F300)) 
    \REGLIST[7]_i_1 
       (.I0(LNA_REGLIST_IBUF[7]),
        .I1(\REGLIST[7]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .I4(\LNA_ADDRESS_OBUF[2]_inst_i_2_n_0 ),
        .I5(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h00000001)) 
    \REGLIST[7]_i_2 
       (.I0(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .I4(LNA_HOLD_VALUE_IBUF),
        .O(\REGLIST[7]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'hAA0C)) 
    \REGLIST[8]_i_1 
       (.I0(LNA_REGLIST_IBUF[8]),
        .I1(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .I2(\REGLIST[11]_i_2_n_0 ),
        .I3(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hAAAAF030)) 
    \REGLIST[9]_i_1 
       (.I0(LNA_REGLIST_IBUF[9]),
        .I1(\REGLIST[11]_i_2_n_0 ),
        .I2(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .I3(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .I4(LNA_LOAD_REGLIST_IBUF),
        .O(\REGLIST[9]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[0] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[0]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[0]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[10] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[10]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[10]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[11] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[11]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[11]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[12] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[12]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[12]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[13] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[13]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[13]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[14] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[14]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[14]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[15] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[15]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[15]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[1] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[1]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[1]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[2] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[2]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[2]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[3] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[3]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[3]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[4] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[4]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[4]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[5] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[5]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[5]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[6] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[6]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[6]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[7] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[7]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[7]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[8] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[8]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[8]),
        .R(SYS_RST_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \REGLIST_reg[9] 
       (.C(SYS_CLK_IBUF_BUFG),
        .CE(1'b1),
        .D(\REGLIST[9]_i_1_n_0 ),
        .Q(LNA_CURRENT_REGLIST_REG_OBUF[9]),
        .R(SYS_RST_IBUF));
  BUFG SYS_CLK_IBUF_BUFG_inst
       (.I(SYS_CLK_IBUF),
        .O(SYS_CLK_IBUF_BUFG));
  IBUF SYS_CLK_IBUF_inst
       (.I(SYS_CLK),
        .O(SYS_CLK_IBUF));
  IBUF SYS_RST_IBUF_inst
       (.I(SYS_RST),
        .O(SYS_RST_IBUF));
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

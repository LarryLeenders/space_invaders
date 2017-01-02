// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1733598 Wed Dec 14 22:35:39 MST 2016
// Date        : Thu Dec 29 13:53:42 2016
// Host        : LAPTOP-E82C7PBC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/larsl/Documents/E-ICT/digitale2/spehz_invadorz/spehz_invadorz.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(MHz25, MHz6, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="MHz25,MHz6,reset,locked,clk_in1" */;
  output MHz25;
  output MHz6;
  input reset;
  output locked;
  input clk_in1;
endmodule

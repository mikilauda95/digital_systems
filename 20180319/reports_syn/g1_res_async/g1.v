/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP4
// Date      : Thu Mar 22 18:33:51 2018
/////////////////////////////////////////////////////////////


module g1 ( clk, a, res, s );
  input clk, a, res;
  output s;
  wire   N30, N31, N32, N33, N34, n4, n5, n7, n8, n9, n10, n11, n12, n13, n14,
         n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28,
         n29, n30, n31, n32, n33, n34, n35, n36, n37, n38;
  wire   [4:0] cnt;
  wire   [4:2] \r83/carry ;

  DFFARX1_RVT \cnt_reg[0]  ( .D(n35), .CLK(clk), .RSTB(res), .Q(cnt[0]), .QN(
        N30) );
  DFFARX1_RVT \cnt_reg[4]  ( .D(n34), .CLK(clk), .RSTB(res), .Q(cnt[4]) );
  DFFARX1_RVT \cnt_reg[1]  ( .D(n31), .CLK(clk), .RSTB(res), .Q(cnt[1]), .QN(
        n5) );
  DFFARX1_RVT \cnt_reg[2]  ( .D(n32), .CLK(clk), .RSTB(res), .Q(cnt[2]) );
  DFFARX1_RVT \cnt_reg[3]  ( .D(n33), .CLK(clk), .RSTB(res), .Q(cnt[3]), .QN(
        n4) );
  DFFARX1_RVT s_local_reg ( .D(n30), .CLK(clk), .RSTB(res), .Q(s) );
  AO22X1_RVT U16 ( .A1(n36), .A2(s), .A3(n7), .A4(n8), .Y(n30) );
  OAI22X1_RVT U17 ( .A1(n10), .A2(N30), .A3(n14), .A4(n15), .Y(n13) );
  AND2X1_RVT U18 ( .A1(N31), .A2(n16), .Y(n31) );
  AND2X1_RVT U19 ( .A1(N32), .A2(n16), .Y(n32) );
  AND2X1_RVT U20 ( .A1(N33), .A2(n16), .Y(n33) );
  AND2X1_RVT U21 ( .A1(N34), .A2(n16), .Y(n34) );
  AO21X1_RVT U22 ( .A1(n37), .A2(n17), .A3(n18), .Y(n16) );
  AO22X1_RVT U23 ( .A1(N30), .A2(n20), .A3(n21), .A4(n22), .Y(n35) );
  XNOR2X1_RVT U24 ( .A1(n37), .A2(n19), .Y(n22) );
  AND2X1_RVT U25 ( .A1(n23), .A2(a), .Y(n21) );
  OR2X1_RVT U26 ( .A1(n18), .A2(n37), .Y(n20) );
  OA21X1_RVT U27 ( .A1(n19), .A2(n38), .A3(n24), .Y(n18) );
  XNOR2X1_RVT U28 ( .A1(n25), .A2(n26), .Y(n23) );
  AO22X1_RVT U29 ( .A1(cnt[0]), .A2(cnt[1]), .A3(cnt[2]), .A4(n27), .Y(n26) );
  AO22X1_RVT U30 ( .A1(cnt[4]), .A2(cnt[3]), .A3(n28), .A4(n29), .Y(n25) );
  XOR2X1_RVT U31 ( .A1(n29), .A2(n28), .Y(n19) );
  XNOR2X1_RVT U32 ( .A1(n4), .A2(cnt[4]), .Y(n28) );
  XOR2X1_RVT U33 ( .A1(cnt[2]), .A2(n27), .Y(n29) );
  XNOR2X1_RVT U34 ( .A1(N30), .A2(cnt[1]), .Y(n27) );
  INVX1_RVT U35 ( .A(n23), .Y(n38) );
  INVX1_RVT U36 ( .A(n24), .Y(n37) );
  NAND2X0_RVT U37 ( .A1(n25), .A2(n26), .Y(n24) );
  NAND2X0_RVT U38 ( .A1(a), .A2(n19), .Y(n17) );
  NAND4X0_RVT U39 ( .A1(cnt[4]), .A2(cnt[3]), .A3(cnt[2]), .A4(cnt[1]), .Y(n10) );
  NAND2X0_RVT U40 ( .A1(s), .A2(n9), .Y(n7) );
  INVX1_RVT U41 ( .A(n8), .Y(n36) );
  NAND3X0_RVT U42 ( .A1(n10), .A2(n9), .A3(n11), .Y(n8) );
  HADDX1_RVT U43 ( .A0(cnt[1]), .B0(cnt[0]), .C1(\r83/carry [2]), .SO(N31) );
  HADDX1_RVT U44 ( .A0(cnt[2]), .B0(\r83/carry [2]), .C1(\r83/carry [3]), .SO(
        N32) );
  HADDX1_RVT U45 ( .A0(cnt[3]), .B0(\r83/carry [3]), .C1(\r83/carry [4]), .SO(
        N33) );
  NAND4X0_RVT U46 ( .A1(cnt[4]), .A2(n12), .A3(N30), .A4(n5), .Y(n11) );
  NAND2X0_RVT U47 ( .A1(cnt[2]), .A2(n4), .Y(n12) );
  NAND2X0_RVT U48 ( .A1(a), .A2(n13), .Y(n9) );
  NAND2X0_RVT U49 ( .A1(N30), .A2(n5), .Y(n15) );
  OR3X2_RVT U50 ( .A1(cnt[3]), .A2(cnt[4]), .A3(cnt[2]), .Y(n14) );
  XOR2X1_RVT U51 ( .A1(\r83/carry [4]), .A2(cnt[4]), .Y(N34) );
endmodule


/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP4
// Date      : Thu Mar 22 18:30:32 2018
/////////////////////////////////////////////////////////////


module g1 ( clk, a, res, s );
  input clk, a, res;
  output s;
  wire   N32, N33, N34, N35, N36, n9, n10, n12, n13, n14, n15, n16, n17, n18,
         n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32,
         n33, n34, n35, n36, n37, n38, n39;
  wire   [4:0] cnt;
  wire   [4:2] \r87/carry ;

  DFFSSRX1_RVT \cnt_reg[0]  ( .D(res), .SETB(1'b1), .RSTB(n25), .CLK(clk), .Q(
        cnt[0]), .QN(N32) );
  DFFSSRX1_RVT \cnt_reg[4]  ( .D(N36), .SETB(1'b1), .RSTB(n21), .CLK(clk), .Q(
        cnt[4]) );
  DFFSSRX1_RVT \cnt_reg[1]  ( .D(N33), .SETB(1'b1), .RSTB(n21), .CLK(clk), .Q(
        cnt[1]), .QN(n10) );
  DFFSSRX1_RVT \cnt_reg[2]  ( .D(N34), .SETB(1'b1), .RSTB(n21), .CLK(clk), .Q(
        cnt[2]) );
  DFFSSRX1_RVT \cnt_reg[3]  ( .D(N35), .SETB(1'b1), .RSTB(n21), .CLK(clk), .Q(
        cnt[3]), .QN(n9) );
  DFFX1_RVT s_local_reg ( .D(n37), .CLK(clk), .Q(s) );
  AO22X1_RVT U22 ( .A1(n12), .A2(s), .A3(n13), .A4(res), .Y(n37) );
  AOI21X1_RVT U23 ( .A1(n14), .A2(s), .A3(n12), .Y(n13) );
  OAI22X1_RVT U24 ( .A1(n16), .A2(N32), .A3(n18), .A4(n19), .Y(n17) );
  OA21X1_RVT U25 ( .A1(n22), .A2(n23), .A3(res), .Y(n21) );
  AND2X1_RVT U26 ( .A1(n38), .A2(n24), .Y(n23) );
  AO22X1_RVT U27 ( .A1(N32), .A2(n22), .A3(n26), .A4(n27), .Y(n25) );
  AO21X1_RVT U28 ( .A1(cnt[0]), .A2(n24), .A3(n30), .Y(n28) );
  AOI21X1_RVT U29 ( .A1(n31), .A2(n26), .A3(n38), .Y(n22) );
  XNOR2X1_RVT U30 ( .A1(n32), .A2(n33), .Y(n26) );
  AO22X1_RVT U31 ( .A1(cnt[0]), .A2(cnt[1]), .A3(cnt[2]), .A4(n34), .Y(n33) );
  AO22X1_RVT U32 ( .A1(cnt[4]), .A2(cnt[3]), .A3(n35), .A4(n36), .Y(n32) );
  XNOR2X1_RVT U33 ( .A1(n36), .A2(n35), .Y(n31) );
  XOR2X1_RVT U34 ( .A1(cnt[3]), .A2(cnt[4]), .Y(n35) );
  XOR2X1_RVT U35 ( .A1(cnt[2]), .A2(n34), .Y(n36) );
  XOR2X1_RVT U36 ( .A1(cnt[0]), .A2(cnt[1]), .Y(n34) );
  INVX1_RVT U37 ( .A(n30), .Y(n38) );
  NAND2X0_RVT U38 ( .A1(n32), .A2(n33), .Y(n30) );
  NAND2X0_RVT U39 ( .A1(n28), .A2(n29), .Y(n27) );
  NAND3X0_RVT U40 ( .A1(a), .A2(n30), .A3(n31), .Y(n29) );
  NAND2X0_RVT U41 ( .A1(a), .A2(n39), .Y(n24) );
  INVX1_RVT U42 ( .A(n31), .Y(n39) );
  NAND4X0_RVT U43 ( .A1(cnt[4]), .A2(cnt[3]), .A3(cnt[2]), .A4(cnt[1]), .Y(n16) );
  HADDX1_RVT U44 ( .A0(cnt[1]), .B0(cnt[0]), .C1(\r87/carry [2]), .SO(N33) );
  AND4X1_RVT U45 ( .A1(res), .A2(n15), .A3(n16), .A4(n14), .Y(n12) );
  NAND2X0_RVT U46 ( .A1(a), .A2(n17), .Y(n14) );
  HADDX1_RVT U47 ( .A0(cnt[2]), .B0(\r87/carry [2]), .C1(\r87/carry [3]), .SO(
        N34) );
  HADDX1_RVT U48 ( .A0(cnt[3]), .B0(\r87/carry [3]), .C1(\r87/carry [4]), .SO(
        N35) );
  NAND2X0_RVT U49 ( .A1(N32), .A2(n10), .Y(n19) );
  OR3X2_RVT U50 ( .A1(cnt[3]), .A2(cnt[4]), .A3(cnt[2]), .Y(n18) );
  NAND4X0_RVT U51 ( .A1(cnt[4]), .A2(n20), .A3(N32), .A4(n10), .Y(n15) );
  NAND2X0_RVT U52 ( .A1(cnt[2]), .A2(n9), .Y(n20) );
  XOR2X1_RVT U53 ( .A1(\r87/carry [4]), .A2(cnt[4]), .Y(N36) );
endmodule


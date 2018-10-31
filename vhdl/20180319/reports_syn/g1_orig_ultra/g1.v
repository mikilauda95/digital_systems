/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : N-2017.09-SP4
// Date      : Thu Mar 22 19:57:44 2018
/////////////////////////////////////////////////////////////


module g1 ( clk, a, s );
  input clk, a;
  output s;
  wire   n16, n17, n18, n19, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n34, n35, n36, n37, n38, n39, n40, n41;
  wire   [4:0] cnt;

  DFFX1_RVT \cnt_reg[0]  ( .D(n19), .CLK(clk), .Q(cnt[0]), .QN(n37) );
  DFFX1_RVT \cnt_reg[4]  ( .D(n18), .CLK(clk), .Q(cnt[4]), .QN(n34) );
  DFFX1_RVT \cnt_reg[3]  ( .D(n17), .CLK(clk), .Q(cnt[3]), .QN(n35) );
  DFFX1_RVT \cnt_reg[2]  ( .D(n16), .CLK(clk), .Q(cnt[2]), .QN(n36) );
  DFFSSRX1_RVT \cnt_reg[1]  ( .D(n41), .SETB(1'b1), .RSTB(n40), .CLK(clk), .Q(
        cnt[1]) );
  DFFSSRX1_RVT s_local_reg ( .D(n39), .SETB(1'b1), .RSTB(n38), .CLK(clk), .QN(
        s) );
  INVX1_RVT U23 ( .A(n26), .Y(n28) );
  INVX1_RVT U24 ( .A(n41), .Y(n21) );
  INVX0_RVT U25 ( .A(n31), .Y(n30) );
  INVX0_RVT U26 ( .A(a), .Y(n25) );
  OR2X1_RVT U29 ( .A1(cnt[0]), .A2(cnt[1]), .Y(n41) );
  NAND4X0_RVT U30 ( .A1(n21), .A2(n36), .A3(n35), .A4(n34), .Y(n27) );
  NAND2X0_RVT U31 ( .A1(cnt[4]), .A2(n21), .Y(n22) );
  NAND4X0_RVT U32 ( .A1(cnt[1]), .A2(cnt[2]), .A3(cnt[3]), .A4(cnt[4]), .Y(n26) );
  OA221X1_RVT U33 ( .A1(n22), .A2(cnt[2]), .A3(n22), .A4(n35), .A5(n26), .Y(
        n24) );
  NAND2X0_RVT U34 ( .A1(n24), .A2(s), .Y(n23) );
  OA221X1_RVT U35 ( .A1(n25), .A2(n27), .A3(n24), .A4(s), .A5(n23), .Y(n39) );
  NAND3X0_RVT U36 ( .A1(cnt[0]), .A2(a), .A3(n28), .Y(n38) );
  AO222X1_RVT U37 ( .A1(a), .A2(n37), .A3(a), .A4(n28), .A5(n37), .A6(n27), 
        .Y(n19) );
  NAND4X0_RVT U38 ( .A1(cnt[0]), .A2(cnt[1]), .A3(cnt[2]), .A4(cnt[3]), .Y(n29) );
  HADDX1_RVT U39 ( .A0(n34), .B0(n29), .SO(n18) );
  NAND3X0_RVT U40 ( .A1(cnt[0]), .A2(cnt[1]), .A3(cnt[2]), .Y(n31) );
  OA21X1_RVT U41 ( .A1(cnt[3]), .A2(n30), .A3(n29), .Y(n17) );
  OA221X1_RVT U42 ( .A1(cnt[2]), .A2(cnt[1]), .A3(cnt[2]), .A4(cnt[0]), .A5(
        n31), .Y(n16) );
  NAND2X0_RVT U43 ( .A1(cnt[0]), .A2(cnt[1]), .Y(n40) );
endmodule


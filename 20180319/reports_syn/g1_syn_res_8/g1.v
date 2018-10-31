/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP4
// Date      : Thu Mar 22 21:47:11 2018
/////////////////////////////////////////////////////////////


module g1 ( clk, a, res, s );
  input clk, a, res;
  output s;
  wire   N34, N35, N36, n9, n25, n37, n38, n39, n40, n41, n42, n43, n44, n45,
         n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59,
         n60, n61, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74,
         n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88,
         n89;
  wire   [4:0] cnt;

  DFFX1_RVT s_local_reg ( .D(n37), .CLK(clk), .Q(s), .QN(n55) );
  DFFSSRX1_RVT \cnt_reg[0]  ( .D(n49), .SETB(1'b1), .RSTB(n25), .CLK(clk), .Q(
        cnt[0]), .QN(n81) );
  DFFSSRX2_RVT \cnt_reg[2]  ( .D(N34), .SETB(1'b1), .RSTB(n51), .CLK(clk), .Q(
        cnt[2]), .QN(n70) );
  DFFX2_RVT \cnt_reg[1]  ( .D(n63), .CLK(clk), .Q(cnt[1]), .QN(n71) );
  DFFSSRX2_RVT \cnt_reg[4]  ( .D(N36), .SETB(1'b1), .RSTB(n51), .CLK(clk), .Q(
        cnt[4]), .QN(n64) );
  DFFSSRX1_RVT \cnt_reg[3]  ( .D(N35), .SETB(1'b1), .RSTB(n51), .CLK(clk), .Q(
        n42), .QN(n9) );
  XOR2X1_RVT U37 ( .A1(n38), .A2(n77), .Y(n80) );
  AND2X1_RVT U38 ( .A1(n72), .A2(n50), .Y(n38) );
  NOR2X0_RVT U39 ( .A1(n73), .A2(n53), .Y(n59) );
  AO21X1_RVT U40 ( .A1(n54), .A2(a), .A3(n44), .Y(n43) );
  INVX1_RVT U41 ( .A(n75), .Y(n49) );
  NOR2X2_RVT U42 ( .A1(n73), .A2(n53), .Y(n39) );
  OR2X2_RVT U43 ( .A1(n48), .A2(n81), .Y(n83) );
  AND2X1_RVT U44 ( .A1(n52), .A2(n81), .Y(n40) );
  AOI21X1_RVT U45 ( .A1(n9), .A2(cnt[2]), .A3(n64), .Y(n41) );
  AOI221X2_RVT U46 ( .A1(n76), .A2(a), .A3(n77), .A4(n39), .A5(n75), .Y(n51)
         );
  MUX21X2_RVT U47 ( .A1(s), .A2(n89), .S0(n43), .Y(n37) );
  NAND2X0_RVT U48 ( .A1(n56), .A2(res), .Y(n44) );
  INVX0_RVT U49 ( .A(n48), .Y(n45) );
  XOR2X2_RVT U50 ( .A1(cnt[0]), .A2(cnt[1]), .Y(n65) );
  XOR2X1_RVT U51 ( .A1(n64), .A2(n9), .Y(n46) );
  OR2X4_RVT U52 ( .A1(n57), .A2(n39), .Y(n47) );
  OR2X1_RVT U53 ( .A1(n59), .A2(n57), .Y(n78) );
  NBUFFX2_RVT U54 ( .A(n71), .Y(n48) );
  INVX1_RVT U55 ( .A(res), .Y(n75) );
  AO21X1_RVT U56 ( .A1(cnt[2]), .A2(n65), .A3(n82), .Y(n50) );
  AO21X1_RVT U57 ( .A1(a), .A2(n54), .A3(n55), .Y(n87) );
  INVX1_RVT U58 ( .A(n45), .Y(n52) );
  AO22X1_RVT U59 ( .A1(n42), .A2(cnt[4]), .A3(n69), .A4(n46), .Y(n53) );
  XOR3X2_RVT U60 ( .A1(n64), .A2(n42), .A3(n69), .Y(n77) );
  NAND3X0_RVT U61 ( .A1(n80), .A2(n47), .A3(a), .Y(n67) );
  INVX1_RVT U62 ( .A(n86), .Y(n54) );
  AND2X1_RVT U63 ( .A1(n88), .A2(n58), .Y(n56) );
  NAND2X0_RVT U64 ( .A1(n41), .A2(n40), .Y(n58) );
  NOR2X1_RVT U65 ( .A1(n84), .A2(n83), .Y(n60) );
  AND2X1_RVT U66 ( .A1(n72), .A2(n50), .Y(n57) );
  INVX0_RVT U67 ( .A(n77), .Y(n74) );
  NAND4X0_RVT U68 ( .A1(cnt[4]), .A2(n45), .A3(n42), .A4(cnt[2]), .Y(n88) );
  NAND4X0_RVT U69 ( .A1(n52), .A2(n9), .A3(n84), .A4(n64), .Y(n85) );
  XNOR2X1_RVT U70 ( .A1(cnt[4]), .A2(n61), .Y(N36) );
  NAND2X0_RVT U71 ( .A1(n60), .A2(n42), .Y(n61) );
  AND2X1_RVT U73 ( .A1(n65), .A2(n51), .Y(n63) );
  INVX1_RVT U74 ( .A(n83), .Y(n82) );
  NAND2X0_RVT U75 ( .A1(n81), .A2(n57), .Y(n66) );
  NAND2X0_RVT U76 ( .A1(n79), .A2(n81), .Y(n68) );
  NAND3X0_RVT U77 ( .A1(n68), .A2(n67), .A3(n66), .Y(n25) );
  NAND2X0_RVT U78 ( .A1(n78), .A2(n77), .Y(n79) );
  XOR3X2_RVT U79 ( .A1(n71), .A2(n70), .A3(cnt[0]), .Y(n69) );
  INVX0_RVT U80 ( .A(cnt[2]), .Y(n84) );
  AO21X1_RVT U81 ( .A1(cnt[2]), .A2(n65), .A3(n82), .Y(n73) );
  AO22X1_RVT U82 ( .A1(n42), .A2(cnt[4]), .A3(n69), .A4(n46), .Y(n72) );
  AND2X1_RVT U83 ( .A1(n57), .A2(n74), .Y(n76) );
  XOR2X1_RVT U84 ( .A1(cnt[2]), .A2(n82), .Y(N34) );
  XOR2X1_RVT U85 ( .A1(n42), .A2(n60), .Y(N35) );
  MUX21X1_RVT U86 ( .A1(n88), .A2(n85), .S0(n81), .Y(n86) );
  AND2X1_RVT U87 ( .A1(n87), .A2(n49), .Y(n89) );
endmodule


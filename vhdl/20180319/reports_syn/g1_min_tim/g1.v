/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP4
// Date      : Mon Mar 26 14:20:25 2018
/////////////////////////////////////////////////////////////


module g1 ( clk, a, res, s );
  input clk, a, res;
  output s;
  wire   N56, N57, n2, n3, n4, n5, n7, n8, n9, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n52, n54, n55, n56, n57, n58, n59, n60,
         n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74,
         n75, n76, n79, n80, n81;
  wire   [30:0] shift_reg_s;

  DFFSSRX1_RVT \shift_reg_s_reg[29]  ( .D(shift_reg_s[30]), .SETB(1'b1), 
        .RSTB(res), .CLK(clk), .Q(shift_reg_s[29]), .QN(n54) );
  DFFSSRX1_RVT \shift_reg_s_reg[28]  ( .D(shift_reg_s[29]), .SETB(1'b1), 
        .RSTB(res), .CLK(clk), .Q(shift_reg_s[28]), .QN(n55) );
  DFFSSRX1_RVT \shift_reg_s_reg[27]  ( .D(shift_reg_s[28]), .SETB(1'b1), 
        .RSTB(res), .CLK(clk), .Q(shift_reg_s[27]), .QN(n56) );
  DFFSSRX1_RVT \shift_reg_s_reg[26]  ( .D(shift_reg_s[27]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[26]) );
  DFFSSRX1_RVT \shift_reg_s_reg[25]  ( .D(shift_reg_s[26]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[25]) );
  DFFSSRX1_RVT \shift_reg_s_reg[24]  ( .D(shift_reg_s[25]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[24]) );
  DFFSSRX1_RVT \shift_reg_s_reg[23]  ( .D(shift_reg_s[24]), .SETB(1'b1), 
        .RSTB(res), .CLK(clk), .Q(shift_reg_s[23]), .QN(n57) );
  DFFSSRX1_RVT \shift_reg_s_reg[22]  ( .D(shift_reg_s[23]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[22]), .QN(n58) );
  DFFSSRX1_RVT \shift_reg_s_reg[21]  ( .D(shift_reg_s[22]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[21]), .QN(n59) );
  DFFSSRX1_RVT \shift_reg_s_reg[20]  ( .D(shift_reg_s[21]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[20]), .QN(n60) );
  DFFSSRX1_RVT \shift_reg_s_reg[19]  ( .D(shift_reg_s[20]), .SETB(1'b1), 
        .RSTB(n80), .CLK(clk), .Q(shift_reg_s[19]), .QN(n61) );
  DFFSSRX1_RVT \shift_reg_s_reg[18]  ( .D(shift_reg_s[19]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[18]), .QN(n62) );
  DFFSSRX1_RVT \shift_reg_s_reg[17]  ( .D(shift_reg_s[18]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[17]), .QN(n63) );
  DFFSSRX1_RVT \shift_reg_s_reg[16]  ( .D(shift_reg_s[17]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[16]), .QN(n64) );
  DFFSSRX1_RVT \shift_reg_s_reg[15]  ( .D(shift_reg_s[16]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[15]), .QN(n21) );
  DFFSSRX1_RVT \shift_reg_s_reg[14]  ( .D(shift_reg_s[15]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[14]), .QN(n75) );
  DFFSSRX1_RVT \shift_reg_s_reg[13]  ( .D(shift_reg_s[14]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[13]), .QN(n22) );
  DFFSSRX1_RVT \shift_reg_s_reg[12]  ( .D(shift_reg_s[13]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[12]), .QN(n65) );
  DFFSSRX1_RVT \shift_reg_s_reg[11]  ( .D(shift_reg_s[12]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[11]), .QN(n66) );
  DFFSSRX1_RVT \shift_reg_s_reg[10]  ( .D(shift_reg_s[11]), .SETB(1'b1), 
        .RSTB(n79), .CLK(clk), .Q(shift_reg_s[10]), .QN(n67) );
  DFFSSRX1_RVT \shift_reg_s_reg[9]  ( .D(shift_reg_s[10]), .SETB(1'b1), .RSTB(
        n79), .CLK(clk), .Q(shift_reg_s[9]), .QN(n68) );
  DFFSSRX1_RVT \shift_reg_s_reg[8]  ( .D(shift_reg_s[9]), .SETB(1'b1), .RSTB(
        n79), .CLK(clk), .Q(shift_reg_s[8]), .QN(n69) );
  DFFSSRX1_RVT \shift_reg_s_reg[7]  ( .D(shift_reg_s[8]), .SETB(1'b1), .RSTB(
        n79), .CLK(clk), .Q(shift_reg_s[7]), .QN(n70) );
  DFFSSRX1_RVT \shift_reg_s_reg[5]  ( .D(shift_reg_s[6]), .SETB(1'b1), .RSTB(
        n80), .CLK(clk), .Q(shift_reg_s[5]), .QN(n71) );
  DFFSSRX1_RVT \shift_reg_s_reg[4]  ( .D(shift_reg_s[5]), .SETB(1'b1), .RSTB(
        n80), .CLK(clk), .Q(shift_reg_s[4]), .QN(n72) );
  DFFSSRX1_RVT \shift_reg_s_reg[3]  ( .D(shift_reg_s[4]), .SETB(1'b1), .RSTB(
        n80), .CLK(clk), .Q(shift_reg_s[3]), .QN(n73) );
  DFFSSRX1_RVT \shift_reg_s_reg[2]  ( .D(shift_reg_s[3]), .SETB(1'b1), .RSTB(
        n80), .CLK(clk), .Q(shift_reg_s[2]), .QN(n76) );
  DFFSSRX1_RVT \shift_reg_s_reg[1]  ( .D(shift_reg_s[2]), .SETB(1'b1), .RSTB(
        n80), .CLK(clk), .Q(shift_reg_s[1]), .QN(n74) );
  LATCHX1_RVT s_local_reg ( .CLK(N56), .D(N57), .Q(s), .QN(n20) );
  AO22X1_RVT U3 ( .A1(shift_reg_s[30]), .A2(n81), .A3(n2), .A4(n80), .Y(n52)
         );
  OA21X1_RVT U4 ( .A1(n3), .A2(shift_reg_s[0]), .A3(a), .Y(n2) );
  OA21X1_RVT U6 ( .A1(shift_reg_s[30]), .A2(n20), .A3(n4), .Y(N57) );
  NAND4X0_RVT U7 ( .A1(n5), .A2(n75), .A3(n4), .A4(n7), .Y(N56) );
  AND3X1_RVT U8 ( .A1(n8), .A2(n9), .A3(n76), .Y(n7) );
  NAND2X0_RVT U9 ( .A1(n3), .A2(n5), .Y(n4) );
  AND4X1_RVT U10 ( .A1(n11), .A2(n12), .A3(n13), .A4(n14), .Y(n3) );
  NOR4X0_RVT U11 ( .A1(n15), .A2(n16), .A3(n17), .A4(n18), .Y(n14) );
  NAND3X0_RVT U12 ( .A1(n66), .A2(n65), .A3(n67), .Y(n18) );
  NAND4X0_RVT U13 ( .A1(n22), .A2(n75), .A3(n21), .A4(n64), .Y(n17) );
  NAND4X0_RVT U14 ( .A1(n63), .A2(n62), .A3(n61), .A4(n74), .Y(n16) );
  NAND4X0_RVT U15 ( .A1(n60), .A2(n59), .A3(n58), .A4(n57), .Y(n15) );
  NOR4X0_RVT U16 ( .A1(n19), .A2(shift_reg_s[24]), .A3(shift_reg_s[26]), .A4(
        shift_reg_s[25]), .Y(n13) );
  NAND4X0_RVT U17 ( .A1(n56), .A2(n55), .A3(n54), .A4(n76), .Y(n19) );
  AND4X1_RVT U19 ( .A1(n9), .A2(n70), .A3(n69), .A4(n68), .Y(n12) );
  AND4X1_RVT U21 ( .A1(n8), .A2(n73), .A3(n72), .A4(n71), .Y(n11) );
  DFFSSRX1_RVT \shift_reg_s_reg[6]  ( .D(shift_reg_s[7]), .SETB(1'b1), .RSTB(
        res), .CLK(clk), .Q(shift_reg_s[6]), .QN(n9) );
  DFFSSRX1_RVT \shift_reg_s_reg[0]  ( .D(shift_reg_s[1]), .SETB(1'b1), .RSTB(
        res), .CLK(clk), .Q(shift_reg_s[0]), .QN(n5) );
  DFFX1_RVT \shift_reg_s_reg[30]  ( .D(n52), .CLK(clk), .Q(shift_reg_s[30]), 
        .QN(n8) );
  INVX1_RVT U57 ( .A(n81), .Y(n79) );
  INVX1_RVT U58 ( .A(n81), .Y(n80) );
  INVX1_RVT U59 ( .A(res), .Y(n81) );
endmodule


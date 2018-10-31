/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP4
// Date      : Thu Mar 22 19:09:08 2018
/////////////////////////////////////////////////////////////


module g1 ( clk, a, res, s );
  input clk, a, res;
  output s;
  wire   N19, N20, N21, N22, N23, N30, N38, N39, N40, N41, N42, N96, N97, n4,
         n5, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20,
         n21, n22, n23, \mult_add_30_aco/PROD_not[4] , n24, n25, n26, n27, n28,
         n29;
  wire   [4:0] states;
  wire   [4:2] \add_26/carry ;
  wire   [4:2] \add_30_aco/carry ;

  DFFX1_RVT \states_reg[4]  ( .D(n22), .CLK(clk), .Q(states[4]) );
  DFFX1_RVT \states_reg[1]  ( .D(n21), .CLK(clk), .Q(states[1]), .QN(n5) );
  DFFX1_RVT \states_reg[2]  ( .D(n20), .CLK(clk), .Q(states[2]), .QN(n4) );
  DFFX1_RVT \states_reg[3]  ( .D(n19), .CLK(clk), .Q(states[3]) );
  LATCHX1_RVT s_local_reg ( .CLK(N96), .D(N97), .Q(s) );
  AO22X1_RVT U10 ( .A1(N22), .A2(n7), .A3(N41), .A4(n8), .Y(n19) );
  AO22X1_RVT U11 ( .A1(N21), .A2(n7), .A3(N40), .A4(n8), .Y(n20) );
  AO22X1_RVT U12 ( .A1(N20), .A2(n7), .A3(N39), .A4(n8), .Y(n21) );
  AO22X1_RVT U13 ( .A1(N23), .A2(n7), .A3(N42), .A4(n8), .Y(n22) );
  AO22X1_RVT U14 ( .A1(N19), .A2(n7), .A3(N38), .A4(n8), .Y(n23) );
  OA21X1_RVT U15 ( .A1(n9), .A2(n29), .A3(res), .Y(n8) );
  OR2X1_RVT U16 ( .A1(n11), .A2(n12), .Y(n9) );
  OAI22X1_RVT U17 ( .A1(N19), .A2(n13), .A3(s), .A4(n14), .Y(N97) );
  AO22X1_RVT U18 ( .A1(states[3]), .A2(states[2]), .A3(n5), .A4(n4), .Y(n15)
         );
  AO22X1_RVT U19 ( .A1(states[0]), .A2(states[1]), .A3(states[2]), .A4(n16), 
        .Y(n11) );
  AO22X1_RVT U20 ( .A1(states[3]), .A2(states[4]), .A3(n17), .A4(n18), .Y(n12)
         );
  XNOR2X1_RVT U21 ( .A1(n18), .A2(n17), .Y(n10) );
  XOR2X1_RVT U22 ( .A1(states[3]), .A2(states[4]), .Y(n17) );
  XNOR2X1_RVT U23 ( .A1(n4), .A2(n16), .Y(n18) );
  XOR2X1_RVT U24 ( .A1(states[0]), .A2(states[1]), .Y(n16) );
  DFFX1_RVT \states_reg[0]  ( .D(n23), .CLK(clk), .Q(states[0]), .QN(N19) );
  HADDX1_RVT U25 ( .A0(n25), .B0(\add_30_aco/carry [2]), .C1(
        \add_30_aco/carry [3]), .SO(N40) );
  HADDX1_RVT U26 ( .A0(n24), .B0(n27), .C1(\add_30_aco/carry [2]), .SO(N39) );
  HADDX1_RVT U27 ( .A0(n26), .B0(\add_30_aco/carry [3]), .C1(
        \add_30_aco/carry [4]), .SO(N41) );
  INVX1_RVT U28 ( .A(n10), .Y(n29) );
  NAND2X0_RVT U29 ( .A1(n13), .A2(n14), .Y(N96) );
  NAND4X0_RVT U30 ( .A1(a), .A2(n29), .A3(n12), .A4(n11), .Y(N30) );
  XNOR2X1_RVT U31 ( .A1(\add_30_aco/carry [4]), .A2(
        \mult_add_30_aco/PROD_not[4] ), .Y(N42) );
  INVX1_RVT U32 ( .A(n27), .Y(N38) );
  AND2X1_RVT U33 ( .A1(states[1]), .A2(N30), .Y(n24) );
  AND2X1_RVT U34 ( .A1(states[2]), .A2(N30), .Y(n25) );
  AND2X1_RVT U35 ( .A1(states[3]), .A2(N30), .Y(n26) );
  AND2X1_RVT U36 ( .A1(states[0]), .A2(N30), .Y(n27) );
  HADDX1_RVT U37 ( .A0(states[1]), .B0(states[0]), .C1(\add_26/carry [2]), 
        .SO(N20) );
  HADDX1_RVT U38 ( .A0(states[3]), .B0(\add_26/carry [3]), .C1(
        \add_26/carry [4]), .SO(N22) );
  HADDX1_RVT U39 ( .A0(states[2]), .B0(\add_26/carry [2]), .C1(
        \add_26/carry [3]), .SO(N21) );
  AND4X1_RVT U40 ( .A1(a), .A2(res), .A3(n10), .A4(n28), .Y(n7) );
  INVX1_RVT U41 ( .A(n9), .Y(n28) );
  NAND3X0_RVT U42 ( .A1(states[0]), .A2(n15), .A3(states[4]), .Y(n14) );
  OR4X1_RVT U43 ( .A1(states[1]), .A2(states[2]), .A3(states[3]), .A4(
        states[4]), .Y(n13) );
  NAND2X0_RVT U44 ( .A1(N30), .A2(states[4]), .Y(\mult_add_30_aco/PROD_not[4] ) );
  XOR2X1_RVT U45 ( .A1(\add_26/carry [4]), .A2(states[4]), .Y(N23) );
endmodule


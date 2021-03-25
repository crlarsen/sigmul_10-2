`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright: Chris Larsen, 2019-2021 
// Engineer: Chris Larsen
// 
// Create Date: 01/18/2021 08:33:16 AM
// Design Name: 
// Module Name: sigmul_10
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 11-bit Significand Multiply Circuit
//              This code assumes that the most significant bits of both input
//              values will be 1 (one) because of the way the parent module
//              extracts significands for normal and subnormal numbers. The
//              the output of this module will only ever be used if the two 
//              IEEE 754 binary16 floating point numbers being multiplied are
//              both normal, or subnormal numbers. Logic in the parent module
//              doesn't need the output of this module if either of the input
//              values are NaNs, Infinities, or Zeroes.
//
//              The module uses 3:2 compression to avoid carry bit propagation
//              delay, when possible. When the module uses a prefix adder to
//              perform addition, when addition can't be avoided.
// 
// Dependencies: Modules compress3_2, compress_scs, compress_csc, hadder, fadder,
//               and padder16.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module c32N(x, y, z, s, c);
  parameter N = 10;
  input [N-1:0] x, y, z;
  output [N-1:0] s, c;
  
   assign s = x ^ y ^ z;
   assign c = (x & y) | (x & z) | (y & z);
endmodule

module sigmul_10(a, b, p);
    parameter NSIG = 10;
    input [NSIG:0] a;
    input [NSIG:0] b;
    output [2*NSIG+1:0] p;
    
    wire [NSIG:0] pp[NSIG:0];
    
    genvar i;
    generate
      for (i = 0; i < NSIG; i = i + 1)
      begin
        assign pp[i] = a & {NSIG+1{b[i]}};
      end
      
      assign pp[NSIG] = a;
    endgenerate
    
    wire [NSIG+2:0] s0_1;
    wire [NSIG+2:2] c0_1;
    
    compress3_2 sc012(pp[0], pp[1], pp[2], s0_1, c0_1);

    wire [NSIG+5:3] s0_2;
    wire [NSIG+5:5] c0_2;
    
    compress3_2 sc345(pp[3], pp[4], pp[5], s0_2, c0_2);

    wire [NSIG+8:6] s0_3;
    wire [NSIG+8:8] c0_3;
    
    compress3_2 sc678(pp[6], pp[7], pp[8], s0_3, c0_3);
    
    wire [NSIG+5:0] s1_1;
    wire [NSIG+3:3] c1_1;
    
    compress_scs TS1_1(s0_1, c0_1, s0_2, s1_1, c1_1);
    
    // Strip off the next bits of our product.
    assign p[2:0] = s1_1[2:0];
    
    wire [NSIG+8:5] s1_2;
    wire [NSIG+9:7] c1_2;
    
    compress_csc TS1_2(c0_2, s0_3, c0_3, s1_2, c1_2);
    
    // From here to the end of the file we have to use hand crafted
    // 3:2 compression logic.
    wire [18:3] s2_1;
    wire [16:4] c2_1;
    
    wire [13:5] tmpS2_1, tmpC2_1;
    
    c32N #(9) TS2_1(s1_1[13:5], c1_1[13:5], s1_2[13:5], tmpS2_1, tmpC2_1);
    assign s2_1 = { s1_2[18:16], s1_1[15:14] ^ s1_2[15:14], tmpS2_1, s1_1[4:3] ^ c1_1[4:3] };
    assign c2_1 = { s1_1[15:14] & s1_2[15:14], tmpC2_1, s1_1[4:3] & c1_1[4:3] };
    
    // Strip off the next bit of our product.
    assign p[3] = s2_1[3];
    
    wire [20:7] s2_2;
    wire [20:10] c2_2;
    
    wire [19:10] tmpS2_2, tmpC2_2;
    
    c32N #(10) TS2_2(c1_2[19:10], pp[9][10:1], pp[10][9:0], tmpS2_2, tmpC2_2);
    assign s2_2 = { pp[10][10], tmpS2_2, c1_2[9] ^ pp[9][0], c1_2[8:7] }; 
    assign c2_2 = { tmpC2_2, c1_2[9] & pp[9][0] }; 
    
    wire [20:4] s3_1;
    wire [19:5] c3_1;
    
    wire [16:7] tmpS3_1, tmpC3_1;
    
    c32N #(10) TS3_1(s2_1[16:7], c2_1[16:7], s2_2[16:7], tmpS3_1, tmpC3_1);
    assign s3_1 = { s2_2[20:19], s2_1[18:17] ^ s2_2[18:17], tmpS3_1, s2_1[6:4] ^ c2_1[6:4] };
    assign c3_1 = { s2_1[18:17] & s2_2[18:17], tmpC3_1, s2_1[6:4] & c2_1[6:4] };
    
    // Strip off the next bit of our product.
    assign p[4] = s3_1[4];
    
    wire [20:5] s4_1;
    wire [21:6] c4_1;
    
    wire [19:10] tmpS4_1, tmpC4_1;
    
    c32N #(10) TS4_1(s3_1[19:10], c3_1[19:10], c2_2[19:10], tmpS4_1, tmpC4_1);
    assign s4_1 = { s3_1[20] ^ c2_2[20], tmpS4_1, s3_1[9:5] ^ c3_1[9:5] };
    assign c4_1 = { s3_1[20] & c2_2[20], tmpC4_1, s3_1[9:5] & c3_1[9:5] };
    
    // Strip off the next bit of our product.
    assign p[5] = s4_1[5];
    
    wire Cout;
    
    padder16 psum({ 1'b0, s4_1[20:6] }, c4_1, 1'b0, p[21:6], Cout);

endmodule

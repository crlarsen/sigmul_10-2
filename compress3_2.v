`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright: Chris Larsen, 2021
// Engineer: Chris Larsen
// 
// Create Date: 03/20/2021 09:47:04 PM
// Design Name: 
// Module Name: compress3_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Write generic modules for the 3:2 compression cases we
//              commonly expect to see while implementing significand
//              multiplication for the various IEEE 754 binary formats.
//              These common cases have been parameterized to increase
//              their generality.
// 
// Dependencies: hadder, fadder
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module compress3_2(x, y, z, s, c);
    parameter NSIG = 10;
    input [NSIG:0] x;
    input [NSIG+1:1] y;
    input [NSIG+2:2] z;
    output [NSIG+2:0] s;
    output [NSIG+2:2] c;
    
    assign s[0] = x[0];
    
    hadder U0(x[1], y[1], s[1], c[2]);
    
    genvar i;
    generate
      for (i = 2; i < NSIG+1; i = i + 1)
        begin
          fadder Ui(x[i], y[i], z[i], s[i], c[i+1]);
        end
    endgenerate
    
    hadder U1(y[NSIG+1], z[NSIG+1], s[NSIG+1], c[NSIG+2]);
    
    assign s[NSIG+2] = z[NSIG+2];
endmodule

// After compressing the partial products the next 3:2 compression is
// going to alternate between sum-carry-sum vectors and carry-sum-carry
// vectors. The next 2 modules deal with these two cases.
module compress_scs(x, y, z, s, c);
  parameter NSIG = 10;
  input [NSIG+2:0] x;
  input [NSIG+2:2] y;
  input [NSIG+5:3] z;
  output [NSIG+5:0] s;
  output [NSIG+3:3] c;
  
  assign s[1:0] = x[1:0];
  
  hadder U1(x[2], y[2], s[2], c[3]);
  
  genvar i;
  generate
    for (i = 3; i <= NSIG+2; i = i + 1)
      begin
        fadder Ui(x[i], y[i], z[i], s[i], c[i+1]);
      end
  endgenerate
  
  assign s[NSIG+5:NSIG+3] = z[NSIG+5:NSIG+3];
endmodule

module compress_csc(x, y, z, s, c);
  parameter NSIG = 10;
  input [NSIG+5:5] x;
  input [NSIG+8:6] y;
  input [NSIG+8:8] z;
  output [NSIG+8:5] s;
  output [NSIG+9:7] c;
  
  assign s[5] = x[5];
  
  genvar i;
  generate
    for (i = 6; i < 8; i = i + 1)
      begin
        hadder Ui(x[i], y[i], s[i], c[i+1]);
      end
  endgenerate
  
  generate
    for (i = 8; i <= NSIG+5; i = i + 1)
      begin
        fadder Vi(x[i], y[i], z[i], s[i], c[i+1]);
      end
  endgenerate
  
  generate
    for (i = NSIG+6; i <= NSIG+8; i = i + 1)
      begin
        hadder Wi(y[i], z[i], s[i], c[i+1]);
      end
  endgenerate
endmodule
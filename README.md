# Second Optimization of 11-Bit Integer Multiply Circuit

## Description

Accelerate circuit performance by:
- Performing 3:2 compression in parallel, when possible.
- Using 16-bit Prefix Adder module rather than Carry Look Ahead adder or Ripple Carry Adder modules.

The code is explained in the video series [Building an FPU in Verilog](https://www.youtube.com/watch?v=rYkVdJnVJFQ&list=PLlO9sSrh8HrwcDHAtwec1ycV-m50nfUVs).
See the video *Building an FPU in Verilog: Building a Faster Integer Multiply Circuit, Part 2*.

## Manifest

|   Filename   |                        Description                        |
|--------------|-----------------------------------------------------------|
| README.md | This file. |
| sigmul_10.v | Significand multiply module specific to the IEEE 754 binary16 data format. |
| compress3_2.v | Utility modules which can also be used with the 32-, 64-, and 128-bit IEEE 754 binary floating point formats. |
| fadder.v | Full adder module. |
| hadder.v | Half adder module. |
| padder16.v | 16-bit Prefix adder module. |

## Copyright

:copyright: Chris Larsen, 2019-2021

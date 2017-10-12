/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/


module nextpc_gen(
    input  wire        rst,
    input  wire        JSrc,
    input  wire [ 1:0] PCSrc,
    input  wire [31:0] PC,
    input  wire [31:0] JR_target,
    input  wire [31:0] J_target,
    input  wire [31:0] Br_addr,
    output wire [31:0] PC_next
  );
    wire [31:0] inst_addr, Jump_addr;

    assign PC_next   = rst  ? 32'hbfc00000 : inst_addr;
    assign Jump_addr = JSrc ? JR_target    : J_target;

    MUX_4_32 PCS_MUX(
        .Src1   (         PC),
        .Src2   (  Jump_addr),
        .Src3   (    Br_addr),
        .Src4   (      32'd0),
        .op     (      PCSrc),
        .Result (  inst_addr)
    );

endmodule //nextpc_gen

module MUX_4_32(
    input  [31:0] Src1,
    input  [31:0] Src2,
    input  [31:0] Src3,
    input  [31:0] Src4,
    input  [ 1:0] op,
    output [31:0] Result
);
    wire [31:0] and1, and2, and3, and4, op1, op1x, op0, op0x;

    assign op1  = {32{ op[1]}};
    assign op1x = {32{~op[1]}};
    assign op0  = {32{ op[0]}};
    assign op0x = {32{~op[0]}};
    assign and1 = Src1   & op1x & op0x;
    assign and2 = Src2   & op1x & op0;
    assign and3 = Src3   & op1  & op0x;
    assign and4 = Src4   & op1  & op0;

    assign Result = and1 | and2 | and3 | and4;

endmodule


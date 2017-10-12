/*
  ------------------------------------------------------------------------------
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
  --------------------------------------------------------------------------------
 */

`define SIMU_DEBUG

module mycpu_top(
    input  wire        clk,
    input  wire        resetn,            //low active

    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    
    output wire        data_sram_en,
    output wire [ 3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata 

  `ifdef SIMU_DEBUG
   ,output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_wen,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
  `endif
);

// we only need an inst ROM now
assign inst_sram_wen   = 4'b0;
assign inst_sram_wdata = 32'b0;

wire   rst;
assign rst = ~resetn;

wire JSrc;
wire [ 1:0] PCSrc;

wire [ 4:0] RegRaddr1;
wire [ 4:0] RegRaddr2;
wire [31:0] RegRdata1;
wire [31:0] RegRdata2;

wire [31:0] PC_next;
wire [31:0] PC_IF_ID;
wire [31:0] PC_add_4_IF_ID;
wire [31:0] Inst_IF_ID;

wire [31:0] J_target_ID;
wire [31:0] JR_target_ID;
wire [31:0] Br_target_ID;
wire [31:0] PC_add_4_ID;

wire [31:0] PC_ID_EXE        ;
wire [31:0] PC_add_4_ID_EXE  ;
wire [ 1:0] RegDst_ID_EXE    ;
wire [ 1:0] ALUSrcA_ID_EXE   ;
wire [ 1:0] ALUSrcB_ID_EXE   ;
wire [ 3:0] ALUop_ID_EXE     ;
wire [ 3:0] RegWrite_ID_EXE  ;
wire [ 3:0] MemWrite_ID_EXE  ;
wire        MemEn_ID_EXE     ;
wire        MemToReg_ID_EXE  ;
wire [ 4:0] Rt_ID_EXE        ;
wire [ 4:0] Rd_ID_EXE        ;
wire [31:0] PC_add_4_ID_EXE  ;
wire [31:0] PC_ID_EXE        ;
wire [31:0] RegRdata1_ID_EXE ;
wire [31:0] RegRdata2_ID_EXE ;
wire [31:0] Sa_ID_EXE        ;
wire [31:0] SgnExtend_ID_EXE ;

wire [31:0] PC_add_4_ID_EXE  ;
wire [31:0] PC_ID_EXE        ;
wire [31:0] RegRdata1_ID_EXE ;
wire [31:0] RegRdata2_ID_EXE ;
wire [31:0] Sa_ID_EXE        ;
wire [31:0] SgnExtend_ID_EXE ;
wire [31:0] Rt_ID_EXE        ;
wire [31:0] Rd_ID_EXE        ;

wire        MemEn_ID_EXE     ;
wire        MemToReg_ID_EXE  ;
wire [ 1:0] RegDst_ID_EXE    ;
wire [ 1:0] ALUSrcA_ID_EXE   ;
wire [ 1:0] ALUSrcB_ID_EXE   ;
wire [ 3:0] ALUop_ID_EXE     ;
wire [ 3:0] MemWrite_ID_EXE  ;
wire [ 3:0] RegWrite_ID_EXE  ;

wire        MemEn_EXE_MEM    ;
wire        MemToReg_EXE_MEM ;
wire [ 3:0] MemWrite_EXE_MEM ;
wire [ 3:0] RegWrite_EXE_MEM ;
wire [ 4:0] RegWaddr_EXE_MEM ;
wire [31:0] ALUResult_EXE_MEM;
wire [31:0] MemWdata_EXE_MEM ;
wire [31:0] PC_EXE_MEM       ;

wire        MemToReg_MEM_WB  ;
wire [ 3:0] RegWrite_MEM_WB  ;
wire [ 4:0] RegWaddr_MEM_WB  ;
wire [31:0] ALUResult_MEM_WB ;
wire [31:0] PC_MEM_WB        ;
wire [31:0] RegWdata_WB      ;
wire [ 4:0] RegWaddr_WB      ;
wire [ 3:0] RegWrite_WB      ;
wire [31:0] PC_WB            ;


nextpc_gen nextpc_gen(
    .rst               (              rst),
    .JSrc              (             JSrc),
    .PCSrc             (            PCSrc),
    .PC                (      PC_add_4_ID),
    .JR_target         (     JR_target_ID),
    .J_target          (      J_target_ID),
    .Br_addr           (     Br_target_ID),
    .PC_next           (          PC_next) 
  );


fetch_stage fe_stage(
    .clk               (              clk),
    .rst               (              rst),
    .PC_next           (          PC_next),
    .inst_sram_en      (     inst_sram_en),
    .inst_sram_addr    (   inst_sram_addr),
    .inst_sram_rdata   (  inst_sram_rdata),
    .PC_IF_ID          (         PC_IF_ID),
    .PC_add_4_IF_ID    (   PC_add_4_IF_ID),
    .Inst_IF_ID        (       Inst_IF_ID) 
  );


decode_stage de_stage(
    .clk               (              clk),
    .rst               (              rst),
    .Inst_IF_ID        (       Inst_IF_ID),
    .PC_IF_ID          (         PC_IF_ID),
    .PC_add_4_IF_ID    (   PC_add_4_IF_ID),
    .RegRaddr1_ID      (        RegRaddr1),
    .RegRaddr2_ID      (        RegRaddr2),
    .RegRdata1_ID      (        RegRdata1),
    .RegRdata2_ID      (        RegRdata2),
    .JSrc              (             JSrc),
    .PCSrc             (            PCSrc),
    .J_target_ID       (      J_target_ID),
    .JR_target_ID      (     JR_target_ID),
    .Br_target_ID      (     Br_target_ID),
    .PC_add_4_ID       (      PC_add_4_ID),
    .RegDst_ID_EXE     (    RegDst_ID_EXE),
    .ALUSrcA_ID_EXE    (   ALUSrcA_ID_EXE),
    .ALUSrcB_ID_EXE    (   ALUSrcB_ID_EXE),
    .ALUop_ID_EXE      (     ALUop_ID_EXE),
    .RegWrite_ID_EXE   (  RegWrite_ID_EXE),
    .MemWrite_ID_EXE   (  MemWrite_ID_EXE),
    .MemEn_ID_EXE      (     MemEn_ID_EXE),
    .MemToReg_ID_EXE   (  MemToReg_ID_EXE),
    .Rt_ID_EXE         (        Rt_ID_EXE),
    .Rd_ID_EXE         (        Rd_ID_EXE),
    .PC_add_4_ID_EXE   (  PC_add_4_ID_EXE),
    .PC_ID_EXE         (        PC_ID_EXE),
    .RegRdata1_ID_EXE  ( RegRdata1_ID_EXE),
    .RegRdata2_ID_EXE  ( RegRdata2_ID_EXE),
    .Sa_ID_EXE         (        Sa_ID_EXE),
    .SgnExtend_ID_EXE  ( SgnExtend_ID_EXE)
  );


execute_stage exe_stage(
    .clk               (              clk),
    .rst               (              rst),
    .PC_add_4_ID_EXE   (  PC_add_4_ID_EXE),
    .PC_ID_EXE         (        PC_ID_EXE),
    .RegRdata1_ID_EXE  ( RegRdata1_ID_EXE),
    .RegRdata2_ID_EXE  ( RegRdata2_ID_EXE),
    .Sa_ID_EXE         (        Sa_ID_EXE),
    .SgnExtend_ID_EXE  ( SgnExtend_ID_EXE),
    .Rt_ID_EXE         (        Rt_ID_EXE),
    .Rd_ID_EXE         (        Rd_ID_EXE),
    .MemEn_ID_EXE      (     MemEn_ID_EXE),
    .MemToReg_ID_EXE   (  MemToReg_ID_EXE),
    .RegDst_ID_EXE     (    RegDst_ID_EXE),
    .ALUSrcA_ID_EXE    (   ALUSrcA_ID_EXE),
    .ALUSrcB_ID_EXE    (   ALUSrcB_ID_EXE),
    .ALUop_ID_EXE      (     ALUop_ID_EXE),
    .MemWrite_ID_EXE   (  MemWrite_ID_EXE),
    .RegWrite_ID_EXE   (  RegWrite_ID_EXE),
    .MemEn_EXE_MEM     (    MemEn_EXE_MEM),
    .MemToReg_EXE_MEM  ( MemToReg_EXE_MEM),
    .MemWrite_EXE_MEM  ( MemToReg_EXE_MEM),
    .RegWrite_EXE_MEM  ( RegWrite_EXE_MEM),
    .RegWaddr_EXE_MEM  ( RegWaddr_EXE_MEM),
    .ALUResult_EXE_MEM (ALUResult_EXE_MEM),
    .MemWdata_EXE_MEM  ( MemWdata_EXE_MEM),
    .PC_EXE_MEM        (       PC_EXE_MEM) 
    );


memory_stage mem_stage(
    .clk               (              clk),
    .rst               (              rst),
    .MemEn_EXE_MEM     (    MemEn_EXE_MEM),
    .MemToReg_EXE_MEM  ( MemToReg_EXE_MEM),
    .MemWrite_EXE_MEM  ( MemWrite_EXE_MEM),
    .RegWrite_EXE_MEM  ( RegWrite_EXE_MEM),
    .RegWaddr_EXE_MEM  ( RegWaddr_EXE_MEM),
    .ALUResult_EXE_MEM (ALUResult_EXE_MEM),
    .MemWdata_EXE_MEM  ( MemWdata_EXE_MEM),
    .PC_EXE_MEM        (       PC_EXE_MEM),
    .MemEn_MEM         (     data_sram_en),
    .MemWrite_MEM      (    data_sram_wen),
    .data_sram_addr    (   data_sram_addr),
    .data_sram_rdata   (  data_sram_rdata),
    .MemWdata_MEM      (  data_sram_wdata),
    .MemToReg_MEM_WB   (  MemToReg_MEM_WB),
    .RegWrite_MEM_WB   (  RegWrite_MEM_WB),
    .RegWaddr_MEM_WB   (  RegWaddr_MEM_WB),
    .ALUResult_MEM_WB  ( ALUResult_MEM_WB),
    .PC_MEM_WB         (        PC_MEM_WB),
    .MemRdata_MEM_WB   (  MemRdata_MEM_WB)  
  );


writeback_stage wb_stage(
    .clk               (             clk),
    .rst               (             rst),
    .MemToReg_MEM_WB   ( MemToReg_MEM_WB),
    .RegWrite_MEM_WB   ( RegWrite_MEM_WB),
    .RegWaddr_MEM_WB   ( RegWaddr_MEM_WB),
    .ALUResult_MEM_WB  (ALUResult_MEM_WB),
    .PC_MEM_WB         (       PC_MEM_WB),
    .RegWdata_WB       (     RegWdata_WB),
    .RegWaddr_WB       (     RegWaddr_WB),
    .RegWrite_WB       (     RegWrite_WB),
    .PC_WB             (           PC_WB) 
);

reg_file RegFile( 
    .clk               (             clk),
    .rst               (             rst),
    .waddr             (     RegWaddr_WB),
    .raddr1            (       RegRaddr1),
    .raddr2            (       RegRaddr2),
    .wen               (     RegWrite_WB),
    .wdata             (     RegWdata_WB),
    .rdata1            (       RegRdata1),
    .rdata2            (       RegRdata2)
);

`ifdef SIMU_DEBUG
assign debug_wb_pc       = PC_WB;
assign debug_wb_rf_wen   = RegWrite_WB;
assign debug_wb_rf_wnum  = RegWaddr_WB;
assign debug_wb_rf_wdata = RegWdata_WB;
`endif

endmodule //mycpu_top

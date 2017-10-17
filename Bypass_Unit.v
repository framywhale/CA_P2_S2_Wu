module Bypass_Unit(
    input  wire        clk,
    input  wire        rst,
    // input IR recognize signals from Control Unit
    input  wire        is_rs_read,
    input  wire        is_rt_read,
    // Judge whether the instruction is LW
    input  wire        MemToReg_ID_EXE,
    input  wire        MemToReg_EXE_MEM,
    input  wire        MemToReg_MEM_WB,
    // Reg Write address in afterward stage
    input  wire [ 4:0] RegWaddr_EXE_MEM,
    input  wire [ 4:0] RegWaddr_MEM_WB,
    input  wire [ 4:0] RegWaddr_ID_EXE,
    // Reg read address in ID stage
    input  wire [ 4:0] rs_ID,
    input  wire [ 4:0] rt_ID,
    // Reg write data in afterward stage
    input  wire [31:0] ALUResult_EXE,
    input  wire [31:0] ALUResult_EXE_MEM,
    input  wire [31:0] RegWdata_WB,
    // output the stall signals
    output wire        PCWrite,
    output wire        IRWrite,
    output wire        ID_EXE_Stall,
    // output the real read data in ID stage
    output wire [ 1:0] RegRdata1_src,
    output wire [ 1:0] RegRdata2_src
  );

    wire [ 4:0] rs_read, rt_read;
    assign rs_read = (is_rs_read) ? rs_ID : 5'd0;
    assign rt_read = (is_rt_read) ? rt_ID : 5'd0;


    wire Haz_ID_EXE_rs, Haz_ID_EXE_rt,
         Haz_ID_MEM_rs, Haz_ID_MEM_rt,
         Haz_ID_WB_rs,  Haz_ID_WB_rt;

    assign Haz_ID_EXE_rs = (|RegWaddr_ID_EXE) & (|rs_read) & (&(rs_read^~RegWaddr_ID_EXE));
    assign Haz_ID_EXE_rt = (|RegWaddr_ID_EXE) & (|rt_read) & (&(rt_read^~RegWaddr_ID_EXE));

    assign Haz_ID_MEM_rs = (|RegWaddr_EXE_MEM) & (|rs_read) & (&(rs_read^~RegWaddr_EXE_MEM));
    assign Haz_ID_MEM_rt = (|RegWaddr_EXE_MEM) & (|rt_read) & (&(rt_read^~RegWaddr_EXE_MEM));

    assign Haz_ID_WB_rs  = (|RegWaddr_MEM_WB) & (|rs_read) & (&(rs_read^~RegWaddr_MEM_WB));
    assign Haz_ID_WB_rt  = (|RegWaddr_MEM_WB) & (|rt_read) & (&(rt_read^~RegWaddr_MEM_WB));

    assign RegRdata1_src = Haz_ID_EXE_rs ? 2'b01 :
                          (Haz_ID_MEM_rs ? 2'b10 :
                          (Haz_ID_WB_rs  ? 2'b11 : 2'b00));
    assign RegRdata2_src = Haz_ID_EXE_rt ? 2'b01 :
                          (Haz_ID_MEM_rt ? 2'b10 :
                          (Haz_ID_WB_rt  ? 2'b11 : 2'b00));

    assign ID_EXE_Stall = ((Haz_ID_EXE_rt |  Haz_ID_EXE_rs) & MemToReg_ID_EXE)
                        | ((Haz_ID_MEM_rt |  Haz_ID_MEM_rs) & MemToReg_EXE_MEM)
                        & (~Haz_ID_EXE_rt & ~Haz_ID_EXE_rs);

    assign PCWrite = ~ID_EXE_Stall;
    assign IRWrite = ~ID_EXE_Stall;

/*
    reg  Haz_EXE_MEM, Haz_EXE_WB, Haz_MEM_WB;
    always @(posedge clk) begin
        if(rst) begin
            {Haz_EXE_MEM,Haz_EXE_WB,Haz_MEM_WB} <= 3'd0;
        end
        else begin
            Haz_EXE_MEM <= Haz_ID_EXE;
            Haz_EXE_WB  <= Haz_ID_MEM;
            Haz_MEM_WB  <= Haz_EXE_MEM;
        end
    end
 */
endmodule

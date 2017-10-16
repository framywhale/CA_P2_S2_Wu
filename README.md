# Computer Architecture Project2 Stage2
### 有新的改动：
* **ALUop** 添加如下：
  * SUB 1000
  * NOR 1001
  * XOR 1010
  * SRA 1011    // {sa{rt[31]},rt[31:sa]}
  * SRL 1100    // {sa{0},rt[31:sa]}  ->  rt >> sa
* 数据通路中**增加**：
  * **ALUSrcB** 添加**11**信号
  * 含义为： 立即数 Zero-extend， 用到的信号是 ORI 、 XORI 和 ANDI
  * 已在下方的数据通路图中用**红线**标注出来
* ALU中SLL功能，由**B<<A[4:0]**，调整为**B<<A**

### 小组成员
勾凌睿: [CA_P2_S2_Go](https://github.com/Lingrui98/CA_P2_S2_Go)

吴嘉皓: [CA_P2_S2_Wu](https://github.com/framywhale/CA_P2_S2_Wu)

### 实验要求：
1. 在**实验一**（[勾凌睿](https://github.com/Lingrui98/CA_P2_S1)、[吴嘉皓](https://github.com/framywhale/CA-Project02_Stage01)）的基础上，增加16条指令：ADD、ADDI、SUB、SUBU、SLTU、AND、ANDI、NOR、ORI、XOR、XORI、SLLV、SRA、SRAV、SRL、SRLV
3. 考虑数据相关
4. 数据相关的解决：
   * 直接阻塞流水
   * 添加旁路技术

### （阶段二） 32位五级流水的MPIS处理器数据通路图：

![Datapath_version2.0](https://github.com/framywhale/CA_P2_S2_Wu/blob/master/Datapath_version2.0.PNG)

### 控制信号

| Inst  | Opcode |  Func  | RegWrite | RegDst | MemWrite| MemEn |MemToReg| ALUSrcA | ALUSrcB|PCSrc|JSrc | ALUOp |
|:-:    | :-:    |:-:     |:-:       |:-:     | :-:     |:-:    |:-:     |:-:      |:-:     |:-:  |:-:  |:-:    |
| LW    | 100011 |    X   |   1111   |   00   |   0000  |   1   |   1    |    00   |   01   |  00 |  0  |  0010 |
| SW    | 101011 |    X   |   0000   |   00   |   1111  |   1   |   0    |    00   |   01   |  00 |  0  |  0010 |
| BEQ   | 000100 |    X   |   0000   |   00   |   0000  |   0   |   0    |    00   |   00   |  ?? |  0  |   /   |
| BNE   | 000101 |    X   |   0000   |   00   |   0000  |   0   |   0    |    00   |   00   |  ?? |  0  |   /   |
| ADDIU | 001001 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0010 |
| SLTI  | 001010 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0111 |
| SLTIU | 001011 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0100 |
| J     | 000010 |    X   |   0000   |   00   |   0000  |   0   |   0    |    00   |   00   |  01 |  0  |   /   |
| JAL   | 000011 |    X   |   1111   |   10   |   0000  |   0   |   0    |    01   |   10   |  01 |  0  |   /   |
| LUI   | 001111 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0011 |
| ADDU  | R-Type | 100001 |   1111   |   01   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0010 |
| OR    | R-Type | 100101 |   1111   |   01   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0001 |
| SLT   | R-Type | 101010 |   1111   |   01   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0111 |
| SLL   | R-Type | 000000 |   1111   |   01   |   0000  |   0   |   0    |    10   |   01   |  00 |  0  |  0101 |
| JR    | R-Type | 001000 |   0000   |   00   |   0000  |   0   |   0    |    00   |   00   |  00 |  1  |   /   |
| **Stage2** |
| **Inst**  | **Opcode** |  **Func**  | **RegWrite** | **RegDst** | **MemWrite** |**MemEn**| **MemToReg** | **ALUSrcA** | **ALUSrcB**|**PCSrc**|**JSrc** | **ALUOp** |
| ADDI  | 001000 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0010 |
| ANDI  | 001100 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   01   |  00 |  0  |  0000 |
| ORI   | 001101 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   11   |  00 |  0  |  0001 |
| XORI  | 001110 |    X   |   1111   |   00   |   0000  |   0   |   0    |    00   |   11   |  00 |  0  |  1010 |
| ADD   | R-Type | 100000 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  0010 |
| SUB   | R-Type | 100010 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  0110 |
| SUBU  | R-Type | 100011 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  1000 |
| SLTU  | R-Type | 101011 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  0100 |
| AND   | R-Type | 100100 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  0000 |
| NOR   | R-Type | 100111 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  1001 |
| XOR   | R-Type | 100110 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  1010 |
| SLLV  | R-Type | 000100 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  0101 |
| SRA   | R-Type | 000011 |   1111   |   01   |   0000  |   0   |   0    |    10   |   00   |  00 |  0  |  1011 |
| SRAV  | R-Type | 000111 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  1011 |
| SRL   | R-Type | 000010 |   1111   |   01   |   0000  |   0   |   0    |    10   |   00   |  00 |  0  |  1100 |
| SRLV  | R-Type | 000110 |   1111   |   01   |   0000  |   0   |   0    |    00   |   00   |  00 |  0  |  1100 |

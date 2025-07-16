//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo da Unidade de Controle da ULA (ULA Control)
//
// Descrição: Este módulo é uma unidade de controle secundária que gera o código de operação específico de 4 bits para a ULA. Ele recebe um sinal de 3 bits (`ALUOp`) da Unidade de Controle Principal e, para instruções do tipo R, também decodifica o campo `funct` da instrução para determinar a operação exata a ser realizada pela ULA.
//********************************************************************************

module ula_ctrl (
    // PORTAS DE ENTRADA
    input wire [2:0] ALUOp, // Sinal de 3 bits da Unidade de Controle Principal
    input wire [5:0] funct, // Campo `funct` de 6 bits da instrução (para tipo R)

    // PORTA DE SAÍDA
    output reg [3:0] ALU_Operation // Código de operação final de 4 bits para a ULA
);
    // PARÂMETROS PARA CÓDIGOS DA ULA
    // Mantém a consistência com os códigos definidos no módulo da ULA.
    parameter ALU_ADD  = 4'b0000;
    parameter ALU_SUB  = 4'b0001;
    parameter ALU_AND  = 4'b0010;
    parameter ALU_OR   = 4'b0011;
    parameter ALU_XOR  = 4'b0100;
    parameter ALU_NOR  = 4'b0101;
    parameter ALU_SLT  = 4'b0110;
    parameter ALU_SLTU = 4'b0111;
    parameter ALU_SLL  = 4'b1000;
    parameter ALU_SRL  = 4'b1001;
    parameter ALU_SRA  = 4'b1010;
    parameter ALU_LUI  = 4'b1011;

    // PARÂMETROS PARA CÓDIGOS `funct` (TIPO R)
    parameter FUNC_ADD  = 6'b100000;
    parameter FUNC_SUB  = 6'b100010;
    parameter FUNC_AND  = 6'b100100;
    parameter FUNC_OR   = 6'b100101;
    parameter FUNC_XOR  = 6'b100110;
    parameter FUNC_NOR  = 6'b100111;
    parameter FUNC_SLT  = 6'b101010;
    parameter FUNC_SLTU = 6'b101011;
    parameter FUNC_SLL  = 6'b000000;
    parameter FUNC_SRL  = 6'b000010;
    parameter FUNC_SRA  = 6'b000011;
    parameter FUNC_SLLV = 6'b000100;
    parameter FUNC_SRLV = 6'b000110;
    parameter FUNC_SRAV = 6'b000111;
    parameter FUNC_JR   = 6'b001000; 

    // LÓGICA DE DECODIFICAÇÃO COMBINACIONAL
    // Bloco `always @(*)` que implementa a lógica de decisão.
    always @(*) begin
        case (ALUOp)
            3'b000: // LW ou SW
                ALU_Operation = ALU_ADD; // ULA deve somar (base + offset)
            3'b001: // BEQ ou BNE
                ALU_Operation = ALU_SUB; // ULA deve subtrair para comparar
            3'b010: // Instrução Tipo-R ou SLTI/SLTIU
                // A operação específica é determinada pelo campo 'funct'.
                case (funct)
                    FUNC_ADD:  ALU_Operation = ALU_ADD;
                    FUNC_SUB:  ALU_Operation = ALU_SUB;
                    FUNC_AND:  ALU_Operation = ALU_AND;
                    FUNC_OR:   ALU_Operation = ALU_OR;
                    FUNC_XOR:  ALU_Operation = ALU_XOR;
                    FUNC_NOR:  ALU_Operation = ALU_NOR;
                    FUNC_SLT:  ALU_Operation = ALU_SLT;
                    FUNC_SLTU: ALU_Operation = ALU_SLTU;
                    FUNC_SLL:  ALU_Operation = ALU_SLL;
                    FUNC_SRL:  ALU_Operation = ALU_SRL;
                    FUNC_SRA:  ALU_Operation = ALU_SRA;
                    FUNC_SLLV: ALU_Operation = ALU_SLL;
                    FUNC_SRLV: ALU_Operation = ALU_SRL;
                    FUNC_SRAV: ALU_Operation = ALU_SRA;
                    FUNC_JR:   ALU_Operation = 4'hX; // JR não usa a ULA, então a operação é "don't care".
                    default:   ALU_Operation = 4'hX; // "Don't care" para functs não reconhecidos.
                endcase
            3'b011: // ADDI
                ALU_Operation = ALU_ADD;
            3'b100: // ANDI
                ALU_Operation = ALU_AND;
            3'b101: // ORI
                ALU_Operation = ALU_OR;
            3'b110: // XORI
                ALU_Operation = ALU_XOR;
            3'b111: // LUI
                ALU_Operation = ALU_LUI;
            default: ALU_Operation = 4'hX; // "Don't care" para ALUOp não reconhecido.
        endcase
    end
endmodule
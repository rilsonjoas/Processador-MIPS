//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo da Unidade Lógica e Aritmética (ULA)
//
// Descrição: Este módulo implementa a Unidade Lógica e Aritmética (ULA). É um componente combinacional que realiza operações como soma, subtração, operações lógicas (AND, OR, etc.), comparações e deslocamentos, com base em um código de operação de 4 bits.
//********************************************************************************

module ula (
    // PORTAS DE ENTRADA
    input  wire [31:0] In1,  // Operando 1 de 32 bits
    input  wire [31:0] In2,  // Operando 2 de 32 bits
    input  wire [3:0]  OP,   // Código da operação de 4 bits fornecido pela ULA Control

    // PORTAS DE SAÍDA 
    output reg  [31:0] result,    // Resultado da operação de 32 bits
    output wire        Zero_flag  // Flag que indica se o resultado é zero, de apenas 1 bit
);
    // CÓDIGOS DE OPERAÇÃO
    // Estes parâmetros definem os códigos de operação que a ULA pode realizar. Eles são consistentes com os códigos usados na ULA Control.
    parameter ALU_ADD  = 4'b0000;
    parameter ALU_SUB  = 4'b0001;
    parameter ALU_AND  = 4'b0010;
    parameter ALU_OR   = 4'b0011;
    parameter ALU_XOR  = 4'b0100;
    parameter ALU_NOR  = 4'b0101;
    parameter ALU_SLT  = 4'b0110; // Set on less than (com sinal)
    parameter ALU_SLTU = 4'b0111; // Set on less than (sem sinal)
    parameter ALU_SLL  = 4'b1000; // Deslocamento lógico para a esquerda
    parameter ALU_SRL  = 4'b1001; // Deslocamento lógico para a direita
    parameter ALU_SRA  = 4'b1010; // Deslocamento aritmético para a direita
    parameter ALU_LUI  = 4'b1011; // Load upper immediate

    // LÓGICA COMBINACIONAL DA ULA
    // Bloco `always @(*)` descreve um circuito puramente combinacional. O `case` seleciona a operação a ser realizada com base no código `OP`. Esta lógica é responsável por calcular o resultado da operação e definir a flag `Zero_flag`. O resultado é atualizado imediatamente com base nos valores de entrada `In1` e `In2`. 
    always @(*) begin
        case (OP)
            ALU_ADD:  result = In1 + In2;
            ALU_SUB:  result = In1 - In2;
            ALU_AND:  result = In1 & In2;
            ALU_OR:   result = In1 | In2;
            ALU_XOR:  result = In1 ^ In2;
            ALU_NOR:  result = ~(In1 | In2);
            ALU_SLT:  result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;
            ALU_SLTU: result = (In1 < In2) ? 32'd1 : 32'd0;
            // Para shifts (SLLV/SRLV/SRAV), o valor do deslocamento vem de In1[4:0] e o dado de In2.
            ALU_SLL:  result = In2 << In1[4:0];
            ALU_SRL:  result = In2 >> In1[4:0];
            ALU_SRA:  result = $signed(In2) >>> In1[4:0]; // Deslocamento aritmético com sinal
            ALU_LUI:  result = {In2[15:0], 16'h0000}; // Carrega o imediato (em In2) na parte alta do resultado.
            default:  result = 32'hxxxxxxxx; // Valor indefinido para operações não especificadas.
        endcase
    end
    
    // FLAG ZERO
    // A flag `Zero_flag` é ativada (1) se o resultado da operação for exatamente zero. Usada em BEQ e outras instruções de comparação.
    assign Zero_flag = (result == 32'b0);

endmodule
//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo da Unidade de Controle Principal
//
// Descrição: Este módulo implementa a Unidade de Controle Principal. Unidade responsável por gerar todos os sinais de controle para a execução de todas as instruções especificadas.
//********************************************************************************

module control (
    // PORTA DE ENTRADA
    input wire [5:0] opcode,  // Opcode de 6 bits da instrução

    // PORTAS DE SAÍDA (SINAIS DE CONTROLE)
    output reg RegDst,        // Seleciona o registrador de destino (rd ou rt)
    output reg ALUSrc,        // Seleciona a segunda entrada da ULA (registrador ou imediato)
    output reg MemtoReg,      // Seleciona o dado a ser escrito no registrador (memória ou ULA)
    output reg RegWrite,      // Habilita a escrita no banco de registradores
    output reg MemRead,       // Habilita a leitura da memória de dados
    output reg MemWrite,      // Habilita a escrita na memória de dados
    output reg Branch,        // Indica uma instrução de desvio (BEQ)
    output reg BNE,           // Indica uma instrução de desvio (BNE)
    output reg [2:0] ALUOp,   // Código de operação para a ULA Control
    output reg Jump          // Indica uma instrução de salto (J ou JAL)
);

    // DEFINIÇÃO DOS OPCODES
    // Estes parâmetros definem os códigos de operação que a Unidade de Controle Principal reconhece.
    parameter OP_RTYPE = 6'b000000;
    parameter OP_J     = 6'b000010;
    parameter OP_JAL   = 6'b000011;
    parameter OP_BEQ   = 6'b000100;
    parameter OP_BNE   = 6'b000101;
    parameter OP_ADDI  = 6'b001000;
    parameter OP_SLTI  = 6'b001010;
    parameter OP_SLTIU = 6'b001011;
    parameter OP_ANDI  = 6'b001100;
    parameter OP_ORI   = 6'b001101;
    parameter OP_XORI  = 6'b001110;
    parameter OP_LUI   = 6'b001111;
    parameter OP_LW    = 6'b100011;
    parameter OP_SW    = 6'b101011;

    // DECODIFICAÇÃO COMBINACIONAL
    // Bloco `always @(*)` que implementa a tabela verdade da unidade de controle. Esta lógica é puramente combinacional e não depende de clock.
    always @(*) begin
        // Definimos os valores padrão para todos os sinais para evitar a inferência de latches. Por padrão, a maioria dos sinais de controle está desativada.
        RegDst = 1'b0; ALUSrc = 1'b0; MemtoReg = 1'b0; RegWrite = 1'b0;
        MemRead = 1'b0; MemWrite = 1'b0; Branch = 1'b0; BNE = 1'b0;
        Jump = 1'b0; ALUOp = 3'bxxx; // 'x' para don't care, ou seja, não importa.

        // Decodifica o opcode e ativa os sinais de controle correspondentes.
        case (opcode)
            OP_RTYPE: begin // Operações de tipo R: add, sub, and, or, slt, jr, etc.
                RegDst   = 1'b1; // Destino é o campo 'rd'.
                ALUSrc   = 1'b0; // Segunda entrada da ULA vem de um registrador.
                RegWrite = 1'b1; // Habilita escrita no registrador.
                ALUOp    = 3'b010; // Indica à ULA_Control que é uma operação R-Type.
            end
            OP_LW: begin // Load Word
                RegDst   = 1'b0; // Destino é o campo 'rt'.
                ALUSrc   = 1'b1; // Segunda entrada da ULA é o imediato (offset).
                MemtoReg = 1'b1; // Dado da memória vai para o registrador.
                RegWrite = 1'b1; // Habilita escrita no registrador.
                MemRead  = 1'b1; // Habilita leitura da memória de dados.
                ALUOp    = 3'b000; // ULA deve somar (endereço base + offset).
            end
            OP_SW: begin // Store Word
                ALUSrc   = 1'b1; // Segunda entrada da ULA é o imediato (offset).
                MemWrite = 1'b1; // Habilita escrita na memória de dados.
                ALUOp    = 3'b000; // ULA deve somar (endereço base + offset).
            end
            OP_BEQ: begin // Branch on Equal
                ALUSrc   = 1'b0; // ULA compara dois registradores.
                Branch   = 1'b1; // Ativa a lógica de desvio para BEQ.
                ALUOp    = 3'b001; // ULA deve subtrair para comparar.
            end
            OP_BNE: begin // Branch on Not Equal
                ALUSrc   = 1'b0; // ULA compara dois registradores.
                BNE      = 1'b1; // Ativa a lógica de desvio para BNE.
                ALUOp    = 3'b001; // ULA deve subtrair para comparar.
            end
            OP_ADDI: begin // Add Immediate
                ALUSrc   = 1'b1; // Segunda entrada da ULA é o imediato.
                RegWrite = 1'b1; // Habilita escrita no registrador.
                ALUOp    = 3'b011; // Indica à ULA_Control para somar.
            end
            OP_SLTI: begin // Set on Less Than Immediate
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b010; // Reutiliza a lógica R-Type na ULA_Ctrl, que vai gerar SLT.
            end
            OP_SLTIU: begin // Set on Less Than Immediate Unsigned
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b010; // Reutiliza a lógica R-Type na ULA_Ctrl, que vai gerar SLTU.
            end
            OP_ANDI: begin // AND Immediate
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b100; // Indica à ULA_Control para fazer AND.
            end
            OP_ORI: begin // OR Immediate
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b101; // Indica à ULA_Control para fazer OR.
            end
            OP_XORI: begin // XOR Immediate
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b110; // Indica à ULA_Control para fazer XOR.
            end
            OP_LUI: begin // Load Upper Immediate
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b111; // Indica à ULA_Control para fazer LUI.
            end
            OP_J: begin // Jump
                Jump = 1'b1; // Ativa a lógica de salto incondicional.
            end
            OP_JAL: begin // Jump and Link
                RegWrite = 1'b1; // Habilita a escrita do endereço de retorno em $ra.
                Jump     = 1'b1; // Ativa a lógica de salto incondicional.
            end
        endcase
    end
endmodule
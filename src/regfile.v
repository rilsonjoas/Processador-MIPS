//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo do Banco de Registradores
//
// Descrição: Este módulo implementa o banco de 32 registradores de 32 bits do MIPS. Ele suporta duas leituras assíncronas (combinacionais) e uma escrita síncrona (na borda de subida do clock). O registrador $zero ($0) é fixo em 0 e qualquer tentativa de escrita nele é ignorada.
//********************************************************************************

module regfile (
    // PORTAS DE ENTRADA
    input wire         clock,      // Sinal de clock para a escrita síncrona
    input wire         reset,      // Sinal de reset para zerar os registradores
    input wire         RegWrite,   // Sinal de controle que habilita a escrita
    input wire [4:0]   ReadAddr1,  // Endereço do primeiro registrador a ser lido
    input wire [4:0]   ReadAddr2,  // Endereço do segundo registrador a ser lido
    input wire [4:0]   WriteAddr,  // Endereço do registrador a ser escrito
    input wire [31:0]  WriteData,  // Dado a ser escrito no registrador

    // PORTAS DE SAÍDA
    output wire [31:0] ReadData1,  // Dado lido do primeiro endereço
    output wire [31:0] ReadData2   // Dado lido do segundo endereço
);

    // DECLARAÇÃO DO BANCO DE REGISTRADORES
    // Um array de 32 registradores, cada um com 32 bits.
    reg [31:0] registers [0:31];
    integer i; // Variável auxiliar para o loop de reset.

    // LÓGICA DE LEITURA ASSÍNCRONA
    // A leitura é combinacional e ocorre continuamente.
    // Se o endereço de leitura for 0, a saída é forçada para 0, implementando comportamento do registrador $zero. Caso contrário, retorna o valor do registrador no endereço especificado.
    assign ReadData1 = (ReadAddr1 == 5'b0) ? 32'b0 : registers[ReadAddr1];
    assign ReadData2 = (ReadAddr2 == 5'b0) ? 32'b0 : registers[ReadAddr2];

    // LÓGICA DE ESCRITA SÍNCRONA 
    // A escrita ocorre apenas na borda de subida do clock ou no reset.
    always @(posedge clock or posedge reset) begin
        // Se o sinal de reset estiver ativo, todos os registradores são zerados.
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        // Se o reset não estiver ativo, a escrita ocorre se o sinal `RegWrite` estiver habilitado e o endereço de escrita não for o registrador $zero.
        end else if (RegWrite && (WriteAddr != 5'b0)) begin
            registers[WriteAddr] <= WriteData;
        end
    end

endmodule
//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo da Memória de Dados
//
// Descrição: Este módulo implementa a memória de dados principal. Ele armazena os dados que o programa manipula. Suporta uma leitura (assíncrona) e uma escrita (síncrona na borda do clock). As operações são controladas pelos sinais MemRead e MemWrite.
//********************************************************************************

module d_mem (
    // PORTAS DE ENTRADA
    input wire         clock,      // Sinal de clock para a escrita síncrona
    input wire         MemWrite,   // Habilita a operação de escrita
    input wire         MemRead,    // Habilita a operação de leitura
    input wire [31:0]  Address,    // Endereço de memória para acesso. 
    input wire [31:0]  WriteData,  // Dado a ser escrito na memória na posição especificada pelo Address. 

    // PORTA DE SAÍDA
    output reg [31:0]  ReadData    // Dado lido da memória na posição especificada pelo Address.
);

    // MEMÓRIA ---
    // Definição de memória de 1KB, organizada como 256 palavras de 32 bits. Cada palavra ocupa 4 bytes, então o endereço é dividido por 4 para acessar a palavra correta.
    reg [31:0] memory [0:255];

    // ESCRITA SÍNCRONA
    // A escrita na memória ocorre na borda de subida do clock, se MemWrite estiver ativo. O endereço de byte (`Address`) é convertido para um índice de palavra ignorando os 2 bits menos significativos (ex: `Address[9:2]`).
    always @(posedge clock) begin
        if (MemWrite) begin
            memory[Address[9:2]] <= WriteData;
        end
    end

    // LÓGICA DE LEITURA ASSÍNCRONA
    // Depende do sinal MemRead. Se MemRead estiver ativo, o dado no endereço especificado é colocado na saída ReadData. Caso contrário, ReadData fica em valor indefinido 'x', simulando um barramento de dados que não está sendo usado.
    always @(*) begin
        if (MemRead) begin
            ReadData = memory[Address[9:2]];
        end else begin
            ReadData = 32'hxxxxxxxx;
        end
    end
endmodule
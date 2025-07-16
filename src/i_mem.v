//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo da Memória de Instruções
//
// Descrição: Este módulo implementa a memória de instruções. É uma memória somente de leitura (ROM) que armazena o programa a ser executado. As instruções são pré-carregadas de um arquivo externo (`instructions.list`) durante a inicialização da simulação. A leitura é assíncrona.
//********************************************************************************

module i_mem (
    // PORTA DE ENTRADA
    input wire [31:0] address, // Endereço da instrução a ser lida com 32 bits

    // PORTA DE SAÍDA
    output wire [31:0] i_out    // Instrução lida do endereço fornecido com 32 bits
);
    // DECLARAÇÃO DA MEMÓRIA
    // Declara uma memória (array de registradores) para armazenar 128 palavras de 32 bits. Segue o tamanho especificado também na memória de dados.
    reg [31:0] mem [0:127];

    // BLOCO DE INICIALIZAÇÃO
    // Este bloco é executado uma vez no início da simulação. Ele usa a tarefa de sistema `$readmemb` para carregar o conteúdo do arquivo "instructions.list" (em formato binário) para a memória `mem`.
    initial begin
        $readmemb("instructions.list", mem);
    end

    // LÓGICA DE LEITURA
    // A leitura da memória é combinacional (assíncrona).
    // address[7:2] é usado para converter um endereço de byte em um índice de palavra para a memória de instruções, aproveitando o alinhamento de 4 bytes das instruções MIPS e usando apenas os bits de endereço relevantes para o tamanho da memória de instruções utilizada pelo programa. 
    assign i_out = mem[address[7:2]];

endmodule
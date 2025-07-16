//*************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo do Contador de Programa (PC)
//
// Descrição: Este módulo implementa o Contador de Programa (PC) de um processador MIPS. O PC é um registrador que armazena o endereço da próxima instrução a ser executada. Ele é atualizado a cada ciclo de clock com o endereço fornecido pela entrada `nextPC`, e pode ser resetado para o endereço inicial 0.
//*******************************************************************

module PC (
    // PORTAS DE ENTRADA
    input wire clock,          // Sinal de clock para sincronização
    input wire reset,          // Sinal de reset para inicializar o PC
    input wire [31:0] nextPC,  // Endereço da próxima instrução

    // PORTAS DE SAÍDA
    output reg [31:0] PC_out   // Endereço da instrução atual
);

    // BLOCO DE INICIALIZAÇÃO
    // Define o valor inicial do PC durante a configuração da simulação. Este bloco garante que o valor seja conhecido no início da simulação.
    initial begin
        PC_out = 32'b0;
    end

    // LÓGICA DE ATUALIZAÇÃO DO PC ---
    // Este bloco `always` descreve o comportamento do PC. Ele é sensível à borda de subida do clock e ao sinal de reset.
    always @(posedge clock or posedge reset) begin
        // Se o sinal de reset estiver ativo, o PC é forçado para o endereço 0.
        if (reset) begin
            PC_out <= 32'h00000000;
        // Caso contrário, em cada borda de subida do clock, o PC recebe o valor de `nextPC`, que corresponde ao endereço da próxima instrução a ser buscada.
        end else begin
            PC_out <= nextPC;
        end
    end

endmodule
//*****************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo de Testbench para o processador MIPS
//
// Descrição: Este arquivo contém o módulo de testbench projetado para simular e verificar o funcionamento do processador MIPS (`mips_core`).
// Ele é responsável por:
// 1. Instanciar o processador (Unidade Sob Teste - UUT).
// 2. Gerar o sinal de clock para a simulação.
// 3. Aplicar um pulso de reset inicial para garantir um estado inicial conhecido.
// 4. Controlar a duração total da simulação.
// 5. Monitorar e exibir sinais internos importantes do processador no console.
// 6. Gerar um arquivo de forma de onda (`dump.vcd`) para a depuração visual do projeto.
//**************************************************************

// 1. INCLUSÃO DOS ARQUIVOS DO PROJETO
`include "pc.v"
`include "i_mem.v"
`include "control.v"
`include "regfile.v"
`include "ula_ctrl.v"
`include "ula.v"
`include "d_mem.v"
`include "mips_core.v"

// MÓDULO DE TESTBENCH
module tb_mips;

    // 2. SINAIS DO TESTBENCH
    // Os 'reg' são usados para os sinais que o testbench controla. 
    reg clock; // Sinal de clock.
    reg reset; // Sinal de reset.

  // Os 'wire' (fios) são usados para os sinais que o testbench observa. 
    wire [31:0] current_pc; // Fio para observar o PC atual do processador.
    wire [31:0] alu_result; // Fio para observar o resultado da ULA.
    wire [31:0] mem_data;   // Fio para observar os dados lidos da memória.

    // 3. INSTANCIAÇÃO DA UNIDADE SOB TESTE (UUT)
    // Cria uma instância do processador `mips_core` e conecta os sinais do testbench às suas portas de entrada e saída correspondentes.
    mips_core uut (
        .clock(clock),
        .reset(reset),
        
        .current_pc(current_pc),
        .alu_result_out(alu_result),
        .mem_data_out(mem_data)
    );

    // 4. GERAÇÃO DE CLOCK
    // Este bloco `initial` com um `forever` cria um sinal de clock periódico.
    // O período do clock é de 10 unidades de tempo (5 unidades em nível baixo, 5 em nível alto).
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // A cada 5 unidades de tempo, o clock é invertido.
    end

    // 5. ESTÍMULOS E CONTROLE DA SIMULAÇÃO
    // Este bloco define a sequência principal de eventos da simulação.
    initial begin
      // Configura a geração do arquivo de forma de onda (formato VCD). Isso permite visualizar os sinais em um visualizador. 
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mips); 

        // Aplicamos um pulso de reset no início da simulação. O processador precisa ser resetado para começar com o PC no endereço 0 e os registradores zerados.
        reset = 1; // Ativa o reset.
        #15;       // Mantém o reset ativo por 15 unidades de tempo.
        reset = 0; // Desativa o reset e permite que o processador comece a execução.

        // Definimos que simulação rodará por 1200 unidades de tempo após o reset. 
        #1200;
        
        // Finalizamos a simulação.
        $display("Simulação finalizada.");
        $finish; // Comando para terminar a simulação.
    end

    // 6. MONITORAMENTO DE SINAIS
    // O bloco `always` é sensível à borda de subida do clock e serve para exibir informações de depuração no console a cada ciclo.
    always @(posedge clock) begin
        // Exibe os valores apenas após o reset ter sido desativado.
        if(!reset) begin
            // $display é uma tarefa do sistema para imprimir texto formatado.
            // %0t: tempo atual da simulação
            // %h: valor em hexadecimal
            // %b: valor em binário
            $display("Time: %0t | PC: %h | Instr: %h | ALU_Result: %h | RegWrite: %b | MemWrite: %b",
                      $time, uut.pc_out, uut.instruction, uut.alu_result, uut.RegWrite, uut.MemWrite);
        end
    end

endmodule
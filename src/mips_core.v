//********************************************************************************
// Nome do Grupo: Rilson Joás, Jair Barbosa, Ryan Eskinazi
// Atividade: Atividade 2VA
// Disciplina: Arquitetura e Organização de Computadores
// Semestre: 2025.1
// Questão: Referente ao arquivo do núcleo MIPS (Top-Level)
//
// Descrição: Este arquivo descreve o caminho de dados completo de um processador MIPS  monociclo. Ele instancia e interconecta todos os componentes principais, como o PC, memórias de dados e instruções, banco  de registradores, ULA e unidades de controle, para executar instruções MIPS.
//********************************************************************************

module mips_core (
    // PORTAS DE ENTRADA
    input wire clock, // Sinal de clock principal
    input wire reset, // Sinal de reset para inicialização

    // PORTAS DE SAÍDA
    output wire [31:0] current_pc,     // Valor atual do PC
    output wire [31:0] alu_result_out, // Valor atual da saída da ULA
    output wire [31:0] mem_data_out    // Saída dos dados lidos da memória de dados
);

    // 1. SINAIS DE CONTROLE
    // Fios que conectam a Unidade de Controle Principal aos outros módulos.
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, BNE, Jump; 
    // Sinais de controle da Unidade de Controle Principal.
    wire [2:0] ALUOp;         // Sinal de 3 bits da Unidade de Controle Principal para a Controle da ULA.
    wire [3:0] ALU_Operation; // Sinal de 4 bits da Controle da ULA para a ULA.

    // 2. CAMINHO DE DADOS
    // Para o transporte de dados entre os módulos do processador.
    wire [31:0] pc_out, pc_next, pc_plus_4, pc_branch; // Endereço atual do PC, próximo PC, PC + 4 e endereço de branch.
    wire [31:0] instruction; // Instrução lida da memória de instruções.
    wire [31:0] read_data1, read_data2, write_data_reg; // Dados lidos do banco de registradores e dados a serem escritos de volta.
    wire [4:0]  write_reg_addr; // Endereço do registrador de destino para escrita.
    wire [31:0] sign_extended_imm, zero_extended_imm, final_imm; // Imediato estendido com sinal e sem sinal.
    wire [31:0] alu_in2; // Segunda entrada da ULA, que pode ser o dado do registrador ou o imediato estendido.
    wire [31:0] alu_result; // Resultado da ULA, que é a saída principal do caminho de dados.
    wire        alu_zero; // Sinal de zero da ULA, usado para decisões de branch e salto.
    wire [31:0] mem_read_data; // Dado lido da memória de dados, que pode ser usado para instruções de load.
    wire [31:0] jump_addr; // Endereço de salto calculado para instruções de salto (J ou JAL).

    // 3. EXTRAÇÃO DE CAMPOS DA INSTRUÇÃO
    // Decodificação dos campos da instrução de 32 bits.
    wire [5:0] opcode = instruction[31:26]; // Código da operação
    wire [5:0] funct  = instruction[5:0];   // Campo de função (para R-Type)
    wire [4:0] rs     = instruction[25:21]; // Registrador fonte 1
    wire [4:0] rt     = instruction[20:16]; // Registrador fonte 2
    wire [4:0] rd     = instruction[15:11]; // Registrador de destino
    wire [15:0] imm   = instruction[15:0];  // Imediato de 16 bits

    // 4. INSTANCIAÇÃO DOS MÓDULOS

    // MÓDULO DO CONTADOR DE PROGRAMA (PC)
    // O PC é responsável por manter o endereço da próxima instrução a ser executada.
    PC pc_unit (
        .clock(clock), .reset(reset),
        .nextPC(pc_next), .PC_out(pc_out)
    );
    assign current_pc = pc_out; // Conecta a saída do PC à porta de saída do módulo.

    // LÓGICA DE CÁLCULO DO PRÓXIMO PC
    assign pc_plus_4 = pc_out + 4; // Calcula o endereço da próxima instrução sequencial.
    assign pc_branch = pc_plus_4 + (sign_extended_imm << 2); // Calcula o endereço de desvio (branch).
    assign jump_addr = {pc_plus_4[31:28], instruction[25:0], 2'b00}; // Calcula o endereço de salto (jump).

    wire PCSrc = (Branch && alu_zero) || (BNE && !alu_zero); // Condição para tomar um desvio (BEQ ou BNE).
    wire is_jr = (opcode == 6'b000000) && (funct == 6'b001000); // Detecta a instrução 'jr' (Jump Register).

    // Lógica do MUX que seleciona o próximo PC. A prioridade é: jr > j/jal > beq/bne > pc+4.
    assign pc_next = is_jr   ? read_data1 : // Se 'jr', o PC recebe o valor de $rs.
                     Jump    ? jump_addr  : // Se 'j' ou 'jal', o PC recebe o endereço de salto.
                     PCSrc   ? pc_branch  : // Se for um desvio condicional válido.
                               pc_plus_4;   // Caso padrão: próxima instrução.

    // MEMÓRIA DE INSTRUÇÃO
    // A memória de instrução armazena o programa a ser executado. É uma memória somente leitura (ROM).
    i_mem instruction_memory (
        .address(pc_out),
        .i_out(instruction)
    );

    // UNIDADE DE CONTROLE PRINCIPAL
    // A Unidade de Controle Principal gera os sinais de controle necessários para a execução das instruções.
    control control_unit (
        .opcode(opcode), .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite),
        .Branch(Branch), .BNE(BNE), .ALUOp(ALUOp), .Jump(Jump)
    );

    // BANCO DE REGISTRADORES
    // O banco de registradores armazena os dados temporários usados pelo processador. Ele suporta leitura e escrita.
    wire is_jal = (opcode == 6'b000011); // Detecta a instrução 'jal'.
    assign write_reg_addr = is_jal ? 5'd31 : (RegDst ? rd : rt); // Seleciona o registrador de destino. Para 'jal' é sempre $ra (31).

    // Lógica para desabilitar a escrita no banco de registradores para 'jr', que é uma instrução R-Type mas não deve escrever nenhum resultado.
    wire final_RegWrite = RegWrite && !is_jr;

    regfile register_file (
        .clock(clock), .reset(reset), .RegWrite(final_RegWrite),
        .ReadAddr1(rs), .ReadAddr2(rt),
        .WriteAddr(write_reg_addr),
        .WriteData(write_data_reg),
        .ReadData1(read_data1), .ReadData2(read_data2)
    );

    // EXTENSOR DE SINAL
    assign sign_extended_imm = {{16{imm[15]}}, imm}; // Extensão de sinal para 32 bits.
    wire is_logical_imm = (opcode == 6'b001100 || opcode == 6'b001101 || opcode == 6'b001110); // Detecta ANDI, ORI, XORI
    assign zero_extended_imm = {16'b0, imm}; // Extensão com zeros para 32 bits.
    assign final_imm = is_logical_imm ? zero_extended_imm : sign_extended_imm; // Seleciona a extensão correta.

    // MUX DA SEGUNDA ENTRADA DA ULA
    assign alu_in2 = ALUSrc ? final_imm : read_data2; // Seleciona entre um registrador ou o imediato.

    // UNIDADE DE CONTROLE DA ULA
    // A Unidade de Controle da ULA recebe o sinal ALUOp e o campo funct (para instruções R-Type) e gera o código de operação de 4 bits para a ULA.  
    ula_ctrl alu_control_unit (
        .ALUOp(ALUOp), .funct(funct), .ALU_Operation(ALU_Operation)
    );
    
    // UNIDADE LÓGICA E ARITMÉTICA (ULA)
    // A ULA executa operações aritméticas e lógicas. Ela recebe duas entradas e um código de operação de 4 bits.
    wire [4:0] shamt = instruction[10:6]; // Campo de shift amount.
    wire is_shift_by_shamt = (opcode == 6'b000000) && (funct == 6'b000000 || funct == 6'b000010 || funct == 6'b000011); // Detecta SLL, SRL, SRA
    wire is_shift_by_reg = (opcode == 6'b000000) && (funct == 6'b000100 || funct == 6'b000110 || funct == 6'b000111); // Detecta SLLV, SRLV, SRAV
    
    // Para SLL/SRL/SRA, a entrada 1 da ULA é o 'shamt'. Para outras, é o valor de $rs.
    wire [31:0] alu_in1 = is_shift_by_shamt ? {27'b0, shamt} : read_data1;

    ula alu_unit (
        .In1(is_shift_by_reg ? read_data1 : alu_in1), // Para SLLV, a entrada 1 da ULA é o valor de $rs, não o shamt
        .In2(alu_in2),
        .OP(ALU_Operation),
        .result(alu_result),
        .Zero_flag(alu_zero)
    );
    assign alu_result_out = alu_result; // Conecta a saída da ULA à porta de saída do módulo.
    
    // MEMÓRIA DE DADOS
    // A memória de dados armazena os dados temporários usados pelo processador. Ela suporta leitura e escrita.
    d_mem data_memory (
        .clock(clock), .MemWrite(MemWrite), .MemRead(MemRead),
        .Address(alu_result), 
        .WriteData(read_data2),
        .ReadData(mem_read_data)
    );
    assign mem_data_out = mem_read_data; // Conecta o dado lido à porta de saída do módulo.

    // MUX FINAL DE ESCRITA NO REGISTRADOR
    // Seleciona o dado a ser escrito de volta no banco de registradores.
    wire is_lui = (opcode == 6'b001111); // Detecta a instrução 'lui'.
    assign write_data_reg = is_jal   ? pc_plus_4 :      // Para 'jal', escreve o endereço de retorno.
                           is_lui   ? {imm, 16'b0} :   // Para 'lui', carrega o imediato na parte alta.
                           MemtoReg ? mem_read_data :  // Para 'lw', escreve o dado da memória.
                                        alu_result;     // Caso padrão, escreve o resultado da ULA.

endmodule
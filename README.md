# 🖥️ Processador MIPS Monociclo em Verilog

Este repositório contém a implementação completa de um processador MIPS de 32 bits com arquitetura monociclo, desenvolvido em Verilog. O projeto foi criado como parte da disciplina de **Arquitetura e Organização de Computadores (2025.1)**.

**Autores:**
- Rilson Joás
- Jair Barbosa
- Ryan Eskinazi

## 📋 Visão Geral do Projeto

O objetivo deste projeto é projetar, implementar e verificar um processador MIPS funcional capaz de executar um subconjunto de instruções do tipo R, I e J. A arquitetura é baseada em um design monociclo, onde cada instrução é executada em um único ciclo de clock.

O projeto inclui todos os componentes essenciais de um processador, como:
- Unidade de Controle Principal e da ULA
- Unidade Lógica e Aritmética (ULA) de 32 bits
- Banco de Registradores com 32 registradores
- Contador de Programa (PC)
- Memórias de Instrução e de Dados
- Lógica para tratamento de desvios (branch) e saltos (jump)

## 🔧 Arquitetura do Processador

O design segue a arquitetura clássica de um processador MIPS monociclo.

### Componentes Principais (`.v`):
- `mips_core.v`: Módulo de topo que integra todos os componentes.
- `control.v`: Unidade de controle principal que decodifica o `opcode` da instrução.
- `ula_ctrl.v`: Unidade de controle secundária que gera o sinal de operação para a ULA.
- `ula.v`: Unidade Lógica e Aritmética que executa as operações.
- `regfile.v`: Banco de 32 registradores de 32 bits.
- `pc.v`: Contador de programa.
- `i_mem.v`: Memória de instruções (ROM).
- `d_mem.v`: Memória de dados (RAM).

## ⚙️ Conjunto de Instruções Suportado

O processador foi projetado para executar as seguintes instruções MIPS:

| Tipo | Instruções                                                                   |
| :--- | :--------------------------------------------------------------------------- |
| **Tipo-R** | `add`, `sub`, `and`, `or`, `xor`, `nor`, `slt`, `sltu`, `sll`, `srl`, `sra`, `sllv`, `srlv`, `srav`, `jr` |
| **Tipo-I** | `addi`, `slti`, `sltiu`, `andi`, `ori`, `xori`, `lui`, `lw`, `sw`, `beq`, `bne`              |
| **Tipo-J** | `j`, `jal`                                                                   |

## 🧪 Testes e Verificação

Para garantir o correto funcionamento do processador, foi criado um ambiente de teste robusto (`tb_mips.v`) que:
1.  Instancia o `mips_core`.
2.  Gera um sinal de clock e aplica um reset inicial.
3.  Carrega um programa de teste a partir do arquivo `instructions.list`.
4.  Monitora e exibe os principais sinais internos a cada ciclo de clock no console.
5.  Gera um arquivo de forma de onda (`dump.vcd`) para depuração visual.

### Programa de Teste (`mips_test.asm`)

O programa de teste incluído neste repositório (`mips_test.asm`) foi projetado para validar todas as instruções suportadas em diferentes cenários, incluindo:
- **Teste 1:** Operações aritméticas e lógicas básicas.
- **Teste 2:** Desvio condicional `beq` com `sll`.
- **Teste 3:** Desvio condicional `bne` com `sllv`.
- **Teste 4:** Comparação (`slt`) e deslocamento aritmético (`sra`).
- **Teste 5:** Operações de acesso à memória (`lw` e `sw`).
- **Teste 6:** Salto incondicional (`j`).
- **Teste 7:** Salto com link (`jal`) e retorno (`jr`).

O arquivo `instructions.list` contém o código de máquina (em binário) correspondente a este programa de teste.

## 🚀 Como Simular o Projeto

Para executar a simulação, você precisará de um simulador de Verilog, como o **Icarus Verilog**, e um visualizador de forma de onda, como o **GTKWave**.

**1. Pré-requisitos:**
   - [Icarus Verilog](http://iverilog.icarus.com/) instalado.
   - [GTKWave](https://gtkwave.sourceforge.net/) instalado.
   - Alternativa: [EDA Playground](https://www.edaplayground.com/) online.

**2. Clone o Repositório:**
   ```bash
   git clone https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
   cd SEU-REPOSITORIO
   ```

**3. Compilação e Simulação:**
   Execute os seguintes comandos no terminal, dentro do diretório do projeto:

   ```bash
   # Compila todos os arquivos Verilog, tendo o testbench como módulo de topo
   iverilog -o mips_tb tb_mips.v mips_core.v pc.v i_mem.v control.v regfile.v ula_ctrl.v ula.v d_mem.v

   # Executa a simulação, que gerará a saída no console e o arquivo dump.vcd
   vvp mips_tb
   ```

**4. Visualização da Forma de Onda:**
   Abra o arquivo de forma de onda gerado com o GTKWave para uma análise detalhada dos sinais:

   ```bash
   gtkwave dump.vcd
   ```

## 📜 Resultados e Conclusão

A simulação demonstra que o processador executa corretamente todas as instruções do programa de teste. Os resultados da ULA, os endereços do PC, os acessos à memória e as atualizações do banco de registradores correspondem aos valores esperados para cada ciclo. A saída no console e a análise da forma de onda em `dump.vcd` confirmam a funcionalidade completa da arquitetura monociclo implementada.

Este projeto serviu como uma excelente base para o aprendizado prático dos conceitos fundamentais de arquitetura de computadores.

---

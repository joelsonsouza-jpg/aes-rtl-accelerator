# Relatório de execução — Semana 01

**Projeto:** Acelerador AES com interface SPI e baixo consumo  
**Responsável:** Joelson Souza
**Data:** 09/10/2026
**Tag prevista:** `w01-ambiente-v1.0`

## 1. Objetivo

Preparar o ambiente de desenvolvimento RTL, organizar o repositório Git e validar um fluxo mínimo de análise de sintaxe, lint básico, compilação e simulação utilizando ferramentas Synopsys.

## 2. Atividades realizadas

- Estruturação do repositório conforme o cronograma do projeto.
- Criação do backlog inicial e do relatório introdutório sobre AES e SPI.
- Preparação do módulo `counter_demo.sv` e seu testbench `tb_counter_demo.sv`.
- Configuração do ambiente Synopsys no servidor da UFCG.
- Configuração do Makefile para automatizar o fluxo Vlogan → VCS → simulação.
- Inicialização do Git, criação do primeiro commit e configuração do repositório remoto no GitHub.
- Execução dos testes de compilação, lint básico e simulação.

## 3. Ambiente utilizado

| Item | Configuração |
|---|---|
| Servidor | srv-microeletronica3 |
| Sistema operacional | Linux x86_64, kernel 4.18.0-553.132.1.el8_10.x86_64 |
| Ferramentas | Synopsys Vlogan e VCS |
| Versão | X-2025.06-SP2_Full64 |
| Linguagem | SystemVerilog |
| Automação | GNU Make / Makefile |
| Controle de versão | Git 2.43.7 |

## 4. Resultados obtidos

| Etapa | Resultado |
|---|---|
| Análise de sintaxe com Vlogan | Aprovada |
| Lint básico (`+lint=all`) | 0 erros e 4 avisos |
| Compilação e elaboração com VCS | Aprovadas |
| Simulação funcional | PASS |
| Execução automatizada com `make` | Aprovada na sessão configurada |
| Execução a partir de clone limpo | Pendente |

### 4.1. Lint

Foram identificados quatro avisos `Lint-[NS] Null statement` no arquivo `tb/tb_counter_demo.sv`, nas linhas 14, 17, 20 e 23.

Os avisos estão associados a construções de espera por eventos e atrasos temporais utilizadas no testbench. Não foram reportados erros na análise realizada.

Não foram observados avisos no módulo RTL `counter_demo.sv` no relatório apresentado.

### 4.2. Simulação

O testbench verificou os comportamentos de reset, contagem e habilitação do contador.

Resultado registrado:

`PASS: reset, contagem e enable validados.`

Tempo final da simulação: 81 ns.

### 4.3. Evidências

- `build/syntax.log` — relatório de sintaxe e lint básico.
- `build/compile.log` — registro de compilação.
- `build/simulation.log` — resultado da simulação.

Os arquivos acima são gerados localmente e estão excluídos do versionamento pela regra `build/`. As evidências selecionadas para entrega ainda precisam ser copiadas para um diretório versionado.

## 5. Problemas encontrados e soluções

**Problema 1 — Execução do VCS em 32 bits:** o executável necessitava do interpretador `/lib/ld-linux.so.2`, indisponível no servidor.

**Solução:** utilização do parâmetro `-full64`, permitindo executar a versão de 64 bits.

**Problema 2 — Inconsistência de `timescale`:** o VCS identificou diferença na declaração temporal dos módulos.

**Solução:** inclusão da diretiva `` `timescale 1ns/1ps `` no RTL.

**Problema 3 — Arquivos do PDK no diretório do projeto:** foram identificados arquivos auxiliares do SAED32 e artefatos gerados pelas ferramentas.

**Tratamento:** atualização do `.gitignore` para impedir sua inclusão acidental no repositório.

**Problema 4 — Avisos de lint:** quatro avisos `Lint-[NS]` foram identificados no testbench e analisados. Não foi necessária alteração funcional.

## 6. Pendências da Semana 1

- Preservar as evidências necessárias no repositório.
- Validar o fluxo a partir de um clone limpo.
- Revisar o relatório de estudo sobre AES e SPI.
- Criar o commit final e a tag `w01-ambiente-v1.0`.

## 7. Próximos passos — Semana 2

- Analisar a especificação funcional oficial.
- Definir as interfaces externas e internas do sistema.
- Elaborar a arquitetura e a microarquitetura.
- Definir o mapa de registradores.
- Estabelecer as estratégias de clock, reset e CDC.
- Selecionar e justificar a microarquitetura do núcleo AES.
# Projeto Hands-on RTL — Acelerador AES/SPI

## 1. Descrição

Este repositório faz parte do desenvolvimento de um acelerador criptográfico AES com interface SPI e estratégias de baixo consumo, na trilha RTL Design.

Na Semana 1, o objetivo foi preparar o ambiente de desenvolvimento, organizar o repositório e validar o fluxo de análise de sintaxe, lint básico, compilação e simulação.

**Nesta etapa, ainda não foram implementados o núcleo AES e a interface SPI.** Foi utilizado um contador digital em SystemVerilog como exemplo para validar as ferramentas.

## 2. Ambiente de desenvolvimento

| Item | Configuração |
|---|---|
| Servidor | srv-microeletronica3 — UFCG |
| Linguagem | SystemVerilog |
| Ferramentas | Synopsys Vlogan e VCS |
| Versão validada | X-2025.06-SP2_Full64 |
| Automação | GNU Make |
| Versionamento | Git e GitHub |

## 3. Execução do projeto

Os comandos abaixo são destinados ao ambiente do laboratório da UFCG, com as ferramentas Synopsys disponíveis.

**Carregar o ambiente Synopsys:**

`source /Tools/synopsys-scripts/snps.sh`

**Executar o fluxo na raiz do projeto:**

`make`

O Makefile realiza a análise de sintaxe e lint básico com Vlogan, a compilação com VCS e a simulação funcional.

**Resultado esperado:**

`PASS: reset, contagem e enable validados.`

Para remover os arquivos gerados, utilize:

`make clean`

## 4. Resultados da Semana 1

| Verificação | Resultado |
|---|---|
| Análise de sintaxe | Aprovada |
| Lint básico | 0 erros e 4 avisos |
| Compilação com VCS | Aprovada |
| Simulação funcional | PASS |
| Teste em clone limpo | Aprovado com ressalva |

Os quatro avisos de lint foram identificados no testbench. No teste em clone limpo, houve uma falha na gravação do arquivo VCD, que não impediu a conclusão da simulação funcional.

## 5. Estrutura do projeto

- `rtl/`: módulos RTL em SystemVerilog.
- `tb/`: testbenches.
- `docs/spec/`: documentos de especificação.
- `docs/architecture/`: documentação da arquitetura.
- `docs/reports/`: estudos, relatórios e evidências.
- `models/`: modelos auxiliares.
- `syn/`: arquivos de síntese.
- `formal/`: verificação formal.
- `upf/`: intenção de baixo consumo.

## 6. Documentação

- `docs/reports/estudo_aes_spi.md`: estudo introdutório sobre AES e SPI.
- `docs/reports/semana_01.md`: relatório de execução da Semana 1.
- `docs/reports/evidencias/resultados_semana01.md`: resumo das evidências de validação.

Os logs completos são gerados na pasta `build/`, excluída do versionamento.

## 7. Próximos passos

Na Semana 2, serão desenvolvidas as definições de arquitetura e microarquitetura, interfaces, mapa de registradores e estratégias de clock, reset e travessia entre domínios de clock (CDC).
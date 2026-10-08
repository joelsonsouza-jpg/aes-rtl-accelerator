# Backlog inicial (versão 0.1)

| ID | Semana | Tarefa | Prioridade | Estado | Dependência / aceite |
|---|---:|---|---|---|---|
| B01 | 1 | Organizar repositório Git | Alta | Preparado; validar Git | Pastas, primeiro commit, tag |
| B02 | 1 | Instalar/verificar simulador e lint | Alta | Pendente de execução no ambiente-alvo | `iverilog`, `vvp`, `verilator` |
| B03 | 1 | Compilar, verificar lint e simular exemplo | Alta | Pendente de execução no ambiente-alvo | `bash scripts/run.sh` termina com PASS |
| B04 | 1 | Estudar AES/FIPS-197 e SPI/CPOL/CPHA | Alta | Documento-base preparado; revisar | `estudo_aes_spi.md` |
| B05 | 1 | Registrar evidências e relatório semanal | Alta | Pendente | Logs reais e revisão |
| B06 | 2 | Definir interfaces, arquitetura e mapa de registradores | Alta | Não iniciado | Especificação oficial e DV |
| B07 | 3 | Implementar transformações da rodada AES | Alta | Não iniciado | Arquitetura aprovada |
| B08 | 4 | Implementar expansão da chave e controle AES | Alta | Não iniciado | Datapath testado |
| B09 | 5 | Implementar SPI, CDC, RESET e modelo PLL | Alta | Não iniciado | Protocolo e interfaces definidos |
| B10 | 6 | Integrar memória, top e teste ponta a ponta | Alta | Não iniciado | B07–B09 |
| B11 | 7 | Sintetizar com SDC e obter baseline | Média | Não iniciado | RTL v1.0, PDK |
| B12 | 8 | Configurar Formality e verificar equivalência | Média | Não iniciado | Netlist/síntese |
| B13 | 9 | Corrigir discrepâncias e registrar RTL v1.1 | Média | Não iniciado | Resultado Formality |
| B14 | 10 | Definir arquitetura de energia | Média | Não iniciado | Baseline |
| B15 | 11 | Escrever UPF e testes power-aware | Média | Não iniciado | Arquitetura de energia |
| B16 | 12 | Aplicar controlador de power gating | Média | Não iniciado | UPF |
| B17 | 13 | Aplicar clock gating e entregar RTL v2.0 | Média | Não iniciado | Power gating |
| B18 | 14 | Sintetizar e comparar baseline × low power | Média | Não iniciado | RTL v2.0 |
| B19 | 15 | Fechar documentação, release e apresentação | Média | Não iniciado | Todas as evidências |

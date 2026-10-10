# Evidências de validação — Semana 1

## Ambiente de testes

- Servidor: srv-microeletronica3
- Linguagem: SystemVerilog
- Ferramentas: Synopsys Vlogan e VCS
- Versão: X-2025.06-SP2_Full64
- Automação: Makefile

## Resultados

| Verificação | Resultado |
|---|---|
| Análise de sintaxe | Aprovada |
| Lint básico (+lint=all) | 0 erros, 4 avisos |
| Compilação com VCS | Aprovada |
| Simulação funcional | PASS |
| Teste em clone limpo | Aprovado com ressalva |

## Evidência da simulação

Mensagem produzida pelo testbench:

    PASS: reset, contagem e enable validados.

Tempo final de simulação: 81 ns.

## Observações

Os quatro avisos de lint foram identificados no testbench,
sem impedir a compilação ou a simulação.

No teste em clone limpo, houve uma falha na gravação do arquivo
VCD. A simulação funcional, entretanto, foi concluída com PASS.

Os logs originais permanecem disponíveis localmente na pasta
build/, excluída do versionamento.

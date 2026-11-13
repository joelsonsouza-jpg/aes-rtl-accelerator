# Relatório Técnico — Semana 03

**Projeto:** MiniSoC AES — Implementação RTL\
**Período:** Semana 03 — 06/11/2026\
**Ferramentas:** SystemVerilog, Synopsys Vlogan e VCS

## 1. Objetivo

Implementar e verificar as transformações complementares
necessárias ao processamento AES-128, preparando os módulos
para integração ao datapath de cifragem e decifragem.

## 2. Módulos implementados

Os seguintes módulos foram desenvolvidos:

- `minisoc_aes_add_round_key.sv`
- `minisoc_aes_mix_columns.sv`
- `minisoc_aes_inv_shift_rows.sv`
- `minisoc_aes_inv_sub_bytes.sv`
- `minisoc_aes_inv_mix_columns.sv`

As transformações são implementadas por lógica combinacional
e operam sobre estados AES de 128 bits.

## 3. Verificação funcional

Foi utilizado o testbench:

`tb/tb_minisoc_aes_round.sv`

Os testes executados incluíram:

- MixColumns: vetor de referência da FIPS 197, Apêndice B.
- AddRoundKey: comparação com resultado esperado.
- InvShiftRows: comparação com vetor conhecido.
- InvSubBytes: comparação com vetor conhecido.
- InvMixColumns: recuperação da entrada de MixColumns.
- Teste adicional com estado nulo.
- Verificação de reversibilidade de SubBytes/InvSubBytes
  para os 256 possíveis valores de byte.
- Verificação de reversibilidade de MixColumns/InvMixColumns
  para 256 padrões de estado.

Todas as verificações executadas passaram.

## 4. Fluxo automatizado

O Makefile foi atualizado com o alvo:

`make test_w03`

O comando executa:

1. Análise de sintaxe e lint com Vlogan.
2. Elaboração do testbench com VCS.
3. Simulação funcional.
4. Verificação da mensagem de sucesso no log.

A execução em 12/11/2026 foi concluída sem erros
ou avisos de lint apresentados no terminal.

## 5. Microarquitetura

O documento de microarquitetura foi preparado em:

`docs/architecture/minisoc_aes_microarquitetura.md`

O projeto prevê uma arquitetura iterativa para AES-128,
com processamento de 10 rodadas, controle por FSM e
expansão de chave.

A integração do datapath e da expansão de chave
será realizada na Semana 04.

## 6. Limitações e próximos passos

Os testes atuais validam os casos dirigidos e os padrões
de reversibilidade executados. Não constituem uma
verificação exaustiva de todos os estados de 128 bits.

A validação completa de cifragem e decifragem AES-128,
incluindo vetores da FIPS 197, Apêndice C.1,
fica prevista para a integração da Semana 04.

## 7. Conclusão

As cinco transformações propostas para a Semana 03
foram implementadas e passaram nos testes funcionais
realizados com Synopsys VCS.

Os módulos estão preparados para a próxima etapa
de integração, sujeita à validação do sistema completo.

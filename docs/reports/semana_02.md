# Relatório de Atividades — Semana 02

**Projeto:** MiniSoC AES — Desenvolvimento RTL em SystemVerilog  
**Aluno:** Joelson Silva de Sousa  
**Instituição:** Universidade Federal de Campina Grande (UFCG)  
**Data da entrega:** 30/10/2026  
**Especificação de referência:** Block Guide MiniSoC AES v1.0.0 e NIST FIPS 197

## 1. Objetivo

Implementar e verificar as transformações combinacionais SubBytes e ShiftRows do algoritmo AES-128, conforme o desafio da Semana 2. Essas operações serão posteriormente integradas ao datapath `minisoc_aes_dp`.

## 2. Atividades desenvolvidas

Foram implementados três módulos em SystemVerilog:

- **`minisoc_aes_sbox.sv`:** substituição combinacional de um byte de 8 bits, utilizando a tabela de 256 entradas da FIPS 197.
- **`minisoc_aes_sub_bytes.sv`:** aplicação paralela da substituição aos 16 bytes do estado AES, utilizando 16 instâncias da S-box.
- **`minisoc_aes_shift_rows.sv`:** reorganização combinacional dos bytes do estado, mediante conexões entre as posições de entrada e saída.

Foi respeitada a convenção de organização do estado AES estabelecida no desafio: byte 0 em `[127:120]` e byte 15 em `[7:0]`, seguindo a representação por colunas da FIPS 197.

## 3. Metodologia de verificação

Foi desenvolvido o testbench autoverificável `tb_minisoc_aes_transform.sv`, utilizando o simulador Synopsys VCS e a ferramenta Vlogan para compilação e lint.

As verificações compreenderam:

1. Teste exaustivo das 256 entradas possíveis da S-box, com comparação contra uma função matemática de referência baseada em operações no campo finito GF(2⁸).
2. Verificação das transformações SubBytes e ShiftRows com os estados intermediários do exemplo de cifragem do Apêndice B da FIPS 197, nas rodadas 1 e 10.
3. Automatização da compilação, elaboração e simulação por meio do comando `make test_w02`.

## 4. Resultados obtidos

| Verificação | Resultado |
|---|---|
| Compilação dos módulos RTL | Aprovada |
| Teste das 256 entradas da S-box | PASS |
| SubBytes e ShiftRows — rodada 1 | PASS |
| SubBytes e ShiftRows — rodada 10 | PASS |
| Erros identificados no fluxo de compilação | 0 |
| Avisos de lint na execução final | 0 |
| Execução automatizada pelo Makefile | Concluída |

Os resultados demonstram que as transformações implementadas produziram as saídas esperadas nos casos verificados.

## 5. Problemas encontrados e soluções

Durante a compilação inicial, foi observado um aviso relacionado à configuração KDB da biblioteca de trabalho do Vlogan. A compilação em um diretório isolado permitiu eliminar a inconsistência.

Também ocorreu um erro de compatibilidade de escala de tempo (`ITSFM`), solucionado pela padronização da opção `-timescale=1ns/1ps` no fluxo de compilação.

Inicialmente, o lint identificou duas instruções vazias associadas ao uso de atrasos `#1;` no testbench. A sintaxe dos atrasos foi ajustada, preservando a espera necessária para estabilização dos sinais combinacionais. A execução final não apresentou avisos de lint.

## 6. Revisão do Block Guide

Foram analisadas as seções 1 a 3 e 8 do Block Guide MiniSoC AES v1.0.0, referentes à visão geral, arquitetura do sistema, interfaces de topo e AES Engine. A organização RTL da seção 10 também foi consultada.

A especificação estabelece um sistema com AES-128, interface SPI, PLL comportamental e memória compartilhada de 1024 palavras de 32 bits. As transformações desenvolvidas nesta semana constituem submódulos combinacionais destinados à integração futura no datapath AES.

## 7. Dúvidas para discussão com o instrutor

1. Existem nomes de portas obrigatórios para os submódulos internos `minisoc_aes_sbox`, `minisoc_aes_sub_bytes` e `minisoc_aes_shift_rows`, além dos nomes dos módulos?
2. A microarquitetura do datapath AES-128 pode ser definida livremente, desde que sejam respeitados os requisitos funcionais e a interface do sistema?
3. Existem metas específicas de latência e frequência para o núcleo AES que devem orientar a escolha entre uma arquitetura iterativa e outras alternativas?

## 8. Próximas atividades

Na Semana 3, serão desenvolvidos o documento de microarquitetura, as transformações MixColumns e AddRoundKey e as operações inversas necessárias à decriptação. Também serão preparados os testes unitários correspondentes aos vetores da FIPS 197.

## 9. Conclusão

Os três módulos combinacionais previstos para a Semana 2 foram implementados e verificados funcionalmente. A execução automatizada apresentou PASS nos 256 casos da S-box e nos vetores das rodadas 1 e 10, sem erros ou avisos de lint na execução final.

Os resultados constituem a base inicial para o desenvolvimento do datapath AES-128 nas etapas seguintes.
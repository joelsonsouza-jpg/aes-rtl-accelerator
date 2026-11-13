# Relatório Técnico — Semana 04

**Projeto:** MiniSoC AES — Implementação RTL

**Entrega:** 13/11/2026

**Ferramentas:** SystemVerilog, Synopsys Vlogan e VCS

## 1. Objetivo

Implementar a expansão de chave AES-128 e integrar as
transformações desenvolvidas anteriormente em um datapath
capaz de cifrar e decifrar blocos de 128 bits.

## 2. Módulos implementados

- `rtl/minisoc_aes/minisoc_aes_key_exp.sv`
- `rtl/minisoc_aes/minisoc_aes_dp.sv`

Testbenches:

- `tb/tb_minisoc_aes_key_exp.sv`
- `tb/tb_minisoc_aes_dp.sv`

## 3. Expansão de chave

O módulo de expansão recebe uma chave de 128 bits e gera
11 chaves de rodada, totalizando 1408 bits.

A geração utiliza as operações RotWord, SubWord, Rcon e XOR,
conforme o algoritmo AES-128.

### Escolha arquitetural

Foi adotada a expansão combinacional completa das 11 chaves.
No início de cada operação, o datapath registra as chaves
expandidas para utilização durante as rodadas.

Essa abordagem simplifica o controle e permite acessar
diretamente as chaves em ordem crescente na cifragem e
decrescente na decifragem.

Como contrapartida, requer armazenamento de 1408 bits no
datapath e lógica combinacional para expansão completa.

Uma arquitetura on-the-fly poderia reduzir o armazenamento
das chaves, mas exigiria controle adicional, principalmente
para disponibilizá-las em ordem inversa na decifragem.

Não foram realizadas medições de área ou temporização
pós-síntese. Os impactos apresentados são qualitativos.

## 4. Datapath AES-128

Foi implementada uma arquitetura iterativa com registrador
de estado, controle por FSM e reutilização das transformações
AES desenvolvidas nas Semanas 2 e 3.

A cifragem compreende:

- AddRoundKey inicial.
- Nove rodadas completas.
- Rodada final sem MixColumns.

A decifragem utiliza as operações inversas e as chaves
de rodada em ordem decrescente.

A interface inclui sinais de clock, reset, início,
seleção de operação, dados, chave, busy e done.

## 5. Verificação funcional

A expansão de chave foi validada com 11 chaves esperadas
do vetor AES-128 e verificações adicionais do Apêndice B.

O datapath foi testado com os seguintes vetores da FIPS 197:

### Apêndice C.1

Chave: `000102030405060708090a0b0c0d0e0f`

Texto original: `00112233445566778899aabbccddeeff`

Texto cifrado: `69c4e0d86a7b0430d8cdb78070b4c55a`

Resultado: PASS em cifragem e decifragem.

### Apêndice B

Chave: `2b7e151628aed2a6abf7158809cf4f3c`

Texto original: `3243f6a8885a308d313198a2e0370734`

Texto cifrado: `3925841d02dc09fbdc118597196a0b32`

Resultado: PASS em cifragem e decifragem.

## 6. Automação

O Makefile foi atualizado com o alvo:

`make test_w04`

Esse comando executa os testes da expansão de chave
e do datapath usando Vlogan e VCS.

A execução de 12/11/2026 foi concluída com sucesso,
incluindo os quatro testes de cifragem e decifragem.

## 7. Conclusão

A expansão de chave e o datapath AES-128 foram implementados
e validados funcionalmente com os vetores obrigatórios
da FIPS 197.

Os resultados atendem ao critério funcional da Semana 4.

A validação apresentada é baseada em simulação RTL.
Síntese, área, temporização e integração ao MiniSoC
completo permanecem fora do escopo desta entrega.

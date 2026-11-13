# MiniSoC AES — Documento de Microarquitetura

**Versão:** 1.0 (proposta de integração)\
**Referência de implementação:** AES-128, FIPS 197\
**Escopo:** transformações RTL da Semana 3 e arquitetura prevista para a Semana 4\
**Estado:** transformações combinacionais implementadas e testadas; expansão de chave e datapath iterativo ainda não implementados

## 1. Objetivo e delimitação

Definir a microarquitetura do núcleo AES-128 do MiniSoC, incluindo representação do estado, transformações, expansão de chave, controle e estratégia de verificação. Este documento registra decisões de projeto para orientar a integração, sem declarar como implementados os blocos ainda pendentes.

O núcleo deverá cifrar e decifrar blocos de **128 bits** com chaves de **128 bits**, executando **10 rodadas** conforme a FIPS 197. A integração com SPI, memória, PLL, modos de operação (ECB, CBC, PCBC, CFB, OFB e CTR) e o topo do MiniSoC são etapas posteriores. O datapath AES-128 descrito aqui não implementa, por si só, esses modos nem autenticação de dados.

## 2. Organização dos arquivos

| Arquivo RTL | Responsabilidade | Estado em 12/11/2026 |
|---|---|---|
| `rtl/minisoc_aes/minisoc_aes_sbox.sv` | Substituição direta de um byte | Implementado — Semana 2 |
| `rtl/minisoc_aes/minisoc_aes_sub_bytes.sv` | Aplicar S-box aos 16 bytes | Implementado — Semana 2 |
| `rtl/minisoc_aes/minisoc_aes_shift_rows.sv` | Deslocar linhas do estado | Implementado — Semana 2 |
| `rtl/minisoc_aes/minisoc_aes_add_round_key.sv` | XOR com chave de rodada | Implementado — Semana 3 |
| `rtl/minisoc_aes/minisoc_aes_mix_columns.sv` | Misturar colunas em GF(2^8) | Implementado — Semana 3 |
| `rtl/minisoc_aes/minisoc_aes_inv_shift_rows.sv` | Deslocamento inverso das linhas | Implementado — Semana 3 |
| `rtl/minisoc_aes/minisoc_aes_inv_sub_bytes.sv` | S-box inversa nos 16 bytes | Implementado — Semana 3 |
| `rtl/minisoc_aes/minisoc_aes_inv_mix_columns.sv` | Mistura inversa das colunas | Implementado — Semana 3 |
| `rtl/minisoc_aes/minisoc_aes_key_exp.sv` | Produzir K0 a K10 | **Pendente — Semana 4** |
| `rtl/minisoc_aes/minisoc_aes_dp.sv` | Estado, rodadas e controle | **Pendente — Semana 4** |
| `rtl/minisoc_aes/minisoc_aes_top.sv` | Interface e integração do núcleo | **Previsto para integração** |

## 3. Representação de dados

- Estado: vetor de 128 bits (`logic [127:0]`), composto de 16 bytes.
- Ordem: os bytes são representados na ordem convencional de entrada/saída da FIPS 197 e organizados no estado AES **por colunas**.
- Endereçamento do byte de índice `i` (0 a 15): `state[127 - 8*i -: 8]`.
- Relação com as coordenadas do estado: `i = r + 4*c`, em que `r` é a linha e `c` a coluna (0 a 3).
- Assim, a primeira coluna ocupa `state[127:96]` e a quarta, `state[31:0]`.
- O mesmo ordenamento deve ser preservado em todas as transformações, chaves de rodada, vetores de teste e interfaces de topo.

## 4. Arquitetura selecionada

Será adotado um **datapath iterativo**, reutilizando o mesmo conjunto de transformações em cada rodada. A operação de uma rodada é combinacional; um registrador de 128 bits armazena o estado entre ciclos. Uma máquina de estados finitos (FSM) seleciona cifragem/decifragem e controla a aplicação das chaves.

```text
                        +--------------------------+
key_i[127:0] ---------->| Expansao de chave        |
                        | K0, K1, ... , K10        |
                        +------------+-------------+
                                     |
                                     v
                           +------------------+
                           | Banco de chaves  |
                           | registradas      |
                           +--------+---------+
                                    |
                                    v
       +-----------------+   +--------------+   +-------------------+
       | Estado 128 bits |-->| Transformacao|-->| Proximo estado    |
       | (registrador)  |   | AES da rodada|   | (registrador)     |
       +--------+--------+   +--------------+   +---------+---------+
                ^                                          |
                +------------------------------------------+
                                   ^
                                   |
                        +---------------------+
start/decrypt/rst_n ---->| FSM + contador      |----> busy/done
                        | de rodadas          |
                        +---------------------+
```

O diagrama é **conceitual**: a realização em SystemVerilog pode empregar multiplexadores e sinais intermediários em vez de blocos separados para cada seta.

### 4.1 Justificativa

- Reutilizar lógica de rodada evita replicar dez datapaths completos.
- Um estado registrado por rodada facilita a depuração e os testes por etapas.
- A escolha favorece simplicidade de integração e validação, sem supor uma frequência máxima ou área já medidas.
- A expansão **combinacional e pré-calculada** das 11 chaves, armazenadas quando `start_i` for aceito, é a proposta inicial da Semana 4. É simples para cifrar e decifrar, porém aumenta o caminho combinacional da expansão e o número de registradores. Se a síntese indicar problemas de área ou temporização, essa decisão deverá ser revisada em favor de uma expansão sequencial.

## 5. Transformações de rodada

### 5.1 Cifragem

1. **Rodada inicial (0):** `state = plaintext XOR K0`.
2. **Rodadas 1 a 9:** `SubBytes -> ShiftRows -> MixColumns -> AddRoundKey(Kr)`.
3. **Rodada 10:** `SubBytes -> ShiftRows -> AddRoundKey(K10)`; **não aplica MixColumns**.

### 5.2 Decifragem

1. **Rodada inicial:** `state = ciphertext XOR K10`.
2. **Rodadas 9 a 1:** `InvShiftRows -> InvSubBytes -> AddRoundKey(Kr) -> InvMixColumns`.
3. **Rodada final:** `InvShiftRows -> InvSubBytes -> AddRoundKey(K0)`; **não aplica InvMixColumns**.

A ordem apresentada para decifragem corresponde ao algoritmo de **Inverse Cipher** da FIPS 197. A chave utilizada em cada etapa não deve ser confundida com o índice do contador do datapath.

## 6. Expansão de chave AES-128

O módulo `minisoc_aes_key_exp.sv` deverá produzir **11 chaves de 128 bits**, `K0` a `K10`, a partir da chave inicial de 128 bits:

- `Nk = 4` palavras de 32 bits; `Nb = 4`; `Nr = 10`.
- A expansão produz `44` palavras (`w[0]` até `w[43]`).
- As primeiras quatro palavras são a chave original.
- Para `i >= 4` e `i` múltiplo de 4: `w[i] = w[i-4] XOR SubWord(RotWord(w[i-1])) XOR Rcon[i/4]`.
- Para os demais índices: `w[i] = w[i-4] XOR w[i-1]`.
- Cada chave `Kr` é formada por `w[4*r]` a `w[4*r+3]`.
- Constantes Rcon (bytes não nulos): `01, 02, 04, 08, 10, 20, 40, 80, 1B, 36`.

**Contrato de interface proposto:** entrada `key_i[127:0]`; saída de 11 chaves de 128 bits, com mapeamento explícito a ser definido no RTL e no respectivo testbench. Caso seja usado um barramento achatado `[1407:0]`, a associação entre faixas de bits e `Kr` deverá ser documentada no código para evitar inversão de ordem.

## 7. Datapath e controle

### 7.1 Interface proposta de `minisoc_aes_dp.sv`

| Sinal | Direção | Largura | Significado |
|---|---|---:|---|
| `clk` | Entrada | 1 | Clock do núcleo |
| `rst_n` | Entrada | 1 | Reset ativo em nível baixo |
| `start_i` | Entrada | 1 | Solicitação de operação |
| `decrypt_i` | Entrada | 1 | `0`: cifrar; `1`: decifrar |
| `data_i` | Entrada | 128 | Bloco de entrada |
| `key_i` | Entrada | 128 | Chave AES-128 |
| `data_o` | Saída | 128 | Resultado registrado |
| `busy_o` | Saída | 1 | Operação em andamento |
| `done_o` | Saída | 1 | Pulso de conclusão de um ciclo |

Os nomes acima constituem uma **proposta para implementação**, não um registro de interfaces já existentes. A integração com `minisoc_aes_top.sv` deverá preservar o contrato efetivamente adotado no RTL.

### 7.2 Registros internos previstos

- `state_r[127:0]`: estado intermediário.
- `round_keys_r`: banco das 11 chaves expandidas (caso adotada a pré-computação).
- `decrypt_r`: modo capturado no início.
- `round_r`: índice da rodada corrente.
- `fsm_r`: estado da máquina de controle.
- `data_o`: resultado retido até a próxima operação ou reset, conforme contrato final.

### 7.3 Estados da FSM

| Estado | Ação prevista |
|---|---|
| `IDLE` | Aguarda `start_i`; captura bloco, chave expandida e modo |
| `INIT` | Aplica `K0` (cifragem) ou `K10` (decifragem) |
| `ROUND` | Executa uma rodada por ciclo, com tratamento especial para a rodada final |
| `DONE` | Sinaliza conclusão por um ciclo e retorna ao repouso |

**Protocolo proposto:** `start_i` é aceito somente em `IDLE`. Entradas são amostradas na aceitação, e alterações posteriores em `data_i`, `key_i` ou `decrypt_i` não devem interferir na operação em curso. Durante o processamento, `busy_o=1`. O resultado deve estar válido ao sinalizar `done_o=1`. Definir explicitamente no RTL se o reset é assíncrono (`posedge clk or negedge rst_n`) e aplicar a mesma convenção aos módulos sequenciais.

**Latência:** com uma rodada por ciclo, existem uma etapa inicial e dez atualizações de rodada; a duração observável entre `start_i` e `done_o` também depende da FSM. A contagem exata será registrada somente após a implementação e a simulação do datapath. Não há, neste estágio, medição de frequência, área, potência ou latência validada.

## 8. Plano de verificação

### 8.1 Semana 3 — evidências já obtidas

O alvo `make test_w03`, executado com Synopsys Vlogan/VCS, concluiu sem erros nos registros apresentados em **12/11/2026**, cobrindo:

- Vetor de rodada da FIPS 197, Apêndice B: MixColumns, AddRoundKey, InvShiftRows e InvSubBytes.
- Reversibilidade `InvMixColumns(MixColumns(X)) = X` para o vetor de referência e 256 padrões adicionais.
- Reversibilidade `InvSubBytes(SubBytes(X)) = X` para cada um dos 256 valores possíveis de byte, replicados nas 16 posições.
- Estado nulo para MixColumns, InvMixColumns e AddRoundKey.
- Transformações diretas S-box, SubBytes e ShiftRows verificadas anteriormente na Semana 2.

Os 256 padrões de MixColumns **não equivalem** a uma prova exaustiva sobre todos os estados de 128 bits. A verificação da composição com a S-box depende também da verificação independente da S-box direta feita na Semana 2.

### 8.2 Semana 4 — critérios de aceitação previstos

Para considerar a integração AES-128 concluída, os testes automatizados deverão incluir, no mínimo:

| Referência | Chave | Texto plano | Texto cifrado esperado |
|---|---|---|---|
| FIPS 197, Apêndice C.1 | `000102030405060708090a0b0c0d0e0f` | `00112233445566778899aabbccddeeff` | `69c4e0d86a7b0430d8cdb78070b4c55a` |
| FIPS 197, Apêndice B | `2b7e151628aed2a6abf7158809cf4f3c` | `3243f6a8885a308d313198a2e0370734` | `3925841d02dc09fbdc118597196a0b32` |

Os dois vetores devem ser verificados **tanto na cifragem quanto na decifragem**, além de testes específicos de expansão de chave, reset, sinalização `busy/done`, retenção da saída e operações consecutivas. O alvo `make test_w04` será criado na Semana 4. Nenhum desses resultados é declarado como obtido neste documento.

## 9. Riscos técnicos e decisões de integração

1. **Mapeamento de bytes:** manter consistentemente a ordem por colunas; uma transposição pode passar por testes de reversibilidade e ainda falhar nos vetores oficiais.
2. **Rodada final:** omitir MixColumns ou InvMixColumns onde a FIPS 197 exige.
3. **Índice das chaves:** cifragem utiliza K0 a K10; decifragem utiliza K10 a K0.
4. **Expansão combinacional:** a profundidade lógica pode limitar o clock. Medir na síntese antes de qualquer promessa de desempenho.
5. **Interface temporal:** definir amostragem de `start_i`, validade de `data_o` e duração de `done_o` de modo observável pelo testbench.
6. **Escopo de segurança:** não há, nesta fase, avaliação de vazamento por canal lateral, proteção contra falhas, resistência a ataques físicos nem autenticação de mensagens.

## 10. Próximas entregas

1. Implementar e verificar `minisoc_aes_key_exp.sv` com valores oficiais de chaves de rodada.
2. Implementar `minisoc_aes_dp.sv` e a FSM iterativa.
3. Integrar cifragem e decifragem com seleção de chaves e regra da última rodada.
4. Criar testbench de integração e o alvo `make test_w04`.
5. Validar os vetores FIPS 197 B e C.1 em ambas as direções, registrar resultados e atualizar este documento caso alguma decisão arquitetural mude.

---

**Nota de rastreabilidade:** as descrições de Semana 4 representam o projeto arquitetural proposto. Resultados de simulação são declarados somente para os módulos e testes já executados na Semana 3.

# Estudo técnico — Semana 01: AES e SPI

## 1. Objetivo
Compreender os fundamentos do AES e do protocolo SPI e sua função no acelerador digital, preparando o desenvolvimento RTL das próximas semanas.

## 2. AES (Advanced Encryption Standard)
O AES é uma cifra simétrica de bloco padronizada pelo NIST no FIPS 197. Atua em blocos de **128 bits** usando chaves de **128, 192 ou 256 bits**, com respectivamente **10, 12 e 14 rodadas**. AES-128 é uma **hipótese de trabalho**, ainda dependente da especificação do instrutor.

### Transformações do cifrador
- **SubBytes:** substituição não linear de cada byte pela S-box.
- **ShiftRows:** deslocamento cíclico das linhas do estado.
- **MixColumns:** combinação linear dos bytes de cada coluna em GF(2^8); **não aplicada na última rodada**.
- **AddRoundKey:** XOR do estado com a subchave da rodada.
- **KeyExpansion:** geração das subchaves a partir da chave original.

### Sequência do AES-128 (cifragem)
1. AddRoundKey inicial.
2. Rodadas 1 a 9: SubBytes → ShiftRows → MixColumns → AddRoundKey.
3. Rodada 10: SubBytes → ShiftRows → AddRoundKey.

**Nota de implementação:** a representação do estado AES é uma matriz 4×4 de bytes em ordem de coluna. A correspondência exata entre índices de bytes e vetores RTL deve ser documentada para evitar erros.

### Implicações para RTL
Uma implementação iterativa pode reutilizar uma unidade de rodada para economizar área, com custo de latência maior. Essa opção deve ser avaliada na Semana 2; ainda não é uma decisão de arquitetura. Também será necessário definir handshake de início/fim e a interface de entrada/saída de dados.

## 3. SPI (Serial Peripheral Interface)
SPI é um protocolo serial síncrono frequentemente implementado com **SCLK** (clock serial), **CS_n** (seleção ativa em nível baixo), **MOSI** (dados do controlador para o periférico) e **MISO** (dados do periférico para o controlador). O projeto usará SPI para configuração e controle, conforme especificação ainda pendente.

### Modos
| Modo | CPOL | CPHA | Clock em repouso | Amostragem |
|---|---:|---:|---|---|
| 0 | 0 | 0 | Baixo | Borda de subida |
| 1 | 0 | 1 | Baixo | Borda de descida |
| 2 | 1 | 0 | Alto | Borda de descida |
| 3 | 1 | 1 | Alto | Borda de subida |

CPOL define polaridade em repouso; CPHA define se o dado é capturado na borda inicial ou final de cada pulso. Modo suportado, ordem dos bits, tamanho de palavra e protocolo de registradores **não devem ser presumidos** sem a especificação.

## 4. Arquitetura de topo
- **SPI:** receber comandos de configuração e fornecer status.
- **RESET:** garantir inicialização definida.
- **PLL/mock:** produzir clock do sistema e sinal de travamento (*locked*).
- **AES:** processar blocos conforme comando e chave.
- **MEMORY/DATA:** disponibilizar blocos de entrada e saída e integrar modelo de memória.

### Risco técnico relevante
O SPI opera no domínio SCLK e o banco de registradores opera no domínio do sistema. Assim, comandos e dados precisam de uma solução explícita de **clock-domain crossing (CDC)**, a detalhar na Semana 2. Não basta passar um barramento multibit por sincronizadores independentes.

## 5. Questões a resolver com o instrutor
1. AES-128 apenas ou também AES-192/AES-256? Apenas cifragem ou também decifragem?
2. Interface SPI: modos permitidos, frequência, ordem de bits, formato de transação e mapa de registradores?
3. Quais são os nomes, larguras e timings obrigatórios das quatro interfaces de topo?
4. Interface esperada dos modelos comportamentais do PLL e da memória?
5. Quais simulador/linter e versões oficiais serão utilizados no laboratório?
6. Onde ficam PDK, bibliotecas e licenças das ferramentas de síntese/Formality?

## Referências
- NIST. *FIPS 197 — Advanced Encryption Standard (AES)*, atualização 2023. https://doi.org/10.6028/NIST.FIPS.197-upd1
- Texas Instruments. *SPI Communication Basics*. https://www.ti.com/video/6163521589001
- Texas Instruments. *SPI data transfer modes*. https://www.ti.com/document-viewer/lit/html/SBOA621/GUID-5BA8492C-2941-4AFA-A6D8-AD7958C19C83

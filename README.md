# Projeto Hands-on RTL — Acelerador AES/SPI

## Semana 1 — ambiente de desenvolvimento
Este repositório contém um **exemplo didático de contador**, apenas para validar o fluxo de lint, compilação e simulação. **Não contém implementação AES/SPI**, prevista para semanas posteriores.

### Pré-requisitos (Ubuntu ou WSL2 Ubuntu)
```bash
sudo apt update
sudo apt install -y git iverilog verilator
```

### Executar em um comando
Na raiz do projeto:
```bash
bash scripts/run.sh
```
Saída esperada: `PASS: reset, contagem e enable validados.` e `FLUXO MINIMO APROVADO.`

### Resultados
- `build/lint.log`: lint Verilator
- `build/compile.log`: compilação Icarus Verilog
- `build/simulation.log`: resultado dos testes
- `build/counter_demo.vcd`: forma de onda (visualizável via GTKWave)

> `build/` é ignorado pelo Git. Copie evidências relevantes para `docs/reports/evidencias/`, quando executar o fluxo na sua máquina. Não declare testes realizados sem execução.

### Estrutura
- `docs/spec/` especificação oficial **pendente** do instrutor
- `docs/architecture/` arquitetura (Semana 2)
- `docs/reports/` estudo, backlog, relatório semanal
- `rtl/` RTL sintetizável (apenas exemplo mínimo nesta semana)
- `tb/` testbenches
- `models/` mocks PLL e memória (Semana 5/6)
- `syn/`, `formal/`, `upf/` etapas posteriores
- `scripts/` automação

### Primeiro commit e tag
```bash
git init
git add .
git commit -m "w01: estrutura, estudo e fluxo minimo"
git tag w01-ambiente-v1.0
```
Necessário configurar `git config user.name` e `git config user.email` caso ainda não estejam definidos.

### Próximos passos
1. Receber especificação funcional das interfaces.
2. Alinhar nomes e larguras de sinais com a trilha de Design Verification.
3. Definir arquitetura e mapa de registradores na Semana 2.

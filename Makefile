.PHONY: all test clean help

# Configuracoes
SHELL := /bin/bash
BUILD_DIR := build

# Fluxo completo: lint, compilacao e simulacao
all: test

test:
	@bash scripts/run.sh

# Remove os arquivos gerados
clean:
	@echo "Limpando arquivos de compilacao..."
	@rm -rf $(BUILD_DIR)

# Mostra os comandos disponiveis
help:
	@echo "Comandos disponiveis:"
	@echo "  make       - Executa o fluxo completo"
	@echo "  make test  - Executa lint, compilacao e simulacao"
	@echo "  make clean - Remove arquivos gerados"
	@echo "  make help  - Mostra esta ajuda"

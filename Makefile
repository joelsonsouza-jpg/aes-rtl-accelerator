
# ==========================================
# Projeto AES RTL - Semana 01
# ==========================================

# ==========================================
# Diretorios
# ==========================================
RTL_DIR   = rtl
TB_DIR    = tb
BUILD_DIR = build
SYNTH_DIR = syn

# ==========================================
# Arquivos RTL
# ==========================================
RTL_FILES = \
	$(RTL_DIR)/counter_demo.sv

TB_FILES = \
	$(TB_DIR)/tb_counter_demo.sv

# ==========================================
# Top do testbench
# ==========================================
TOP = tb_counter_demo

# ==========================================
# Flags
# ==========================================
TIMESCALE = 1ns/1ps

VLOGAN_FLAGS = -full64 \
               -sverilog \
               -kdb \
               +lint=all

VCS_FLAGS = -full64 \
            -timescale=$(TIMESCALE) \
            -kdb

# ==========================================
# Fluxo principal
# ==========================================
all: run

# ==========================================
# Verificacao de sintaxe e lint
# ==========================================
syntax:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && vlogan $(VLOGAN_FLAGS) \
		../$(RTL_FILES) \
		../$(TB_FILES) \
		-l syntax.log

# ==========================================
# Compilacao / Elaboracao
# ==========================================
compile: syntax
	cd $(BUILD_DIR) && vcs $(VCS_FLAGS) \
		-top $(TOP) \
		-o simv \
		-l compile.log

# ==========================================
# Simulacao
# ==========================================
run: compile
	cd $(BUILD_DIR) && ./simv -no_save -l simulation.log
	grep -q "PASS: reset, contagem e enable validados." $(BUILD_DIR)/simulation.log

# ==========================================
# Limpeza da simulacao
# ==========================================
clean_sim:
	rm -rf $(BUILD_DIR)

# ==========================================
# Limpeza total
# ==========================================
clean: clean_sim

# ==========================================
# Ajuda
# ==========================================
help:
	@echo "make syntax    - Sintaxe e lint basico"
	@echo "make compile   - Compilacao com VCS"
	@echo "make run       - Executar simulacao"
	@echo "make clean     - Limpar build"
	@echo "make          - Executar fluxo completo"

.PHONY: all syntax compile run clean_sim clean help

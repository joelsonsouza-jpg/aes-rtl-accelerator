
# ==========================================
# Projeto AES RTL
# ==========================================

# ==========================================
# Diretorios
# ==========================================
RTL_DIR   = rtl
TB_DIR    = tb
BUILD_DIR = build
SYNTH_DIR = syn

# ==========================================
# Arquivos RTL - Semana 01
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
# Fluxo principal - Semana 01
# ==========================================
all: run

syntax:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && vlogan $(VLOGAN_FLAGS) \
		../$(RTL_FILES) \
		../$(TB_FILES) \
		-l syntax.log

compile: syntax
	cd $(BUILD_DIR) && vcs $(VCS_FLAGS) \
		-top $(TOP) \
		-o simv \
		-l compile.log

run: compile
	cd $(BUILD_DIR) && ./simv -no_save -l simulation.log
	grep -q "PASS: reset, contagem e enable validados." $(BUILD_DIR)/simulation.log

# ==========================================
# Limpeza
# ==========================================
clean_sim:
	rm -rf $(BUILD_DIR)

clean: clean_sim

# ==========================================
# Ajuda
# ==========================================
help:
	@echo "make           - Executar Semana 01"
	@echo "make test_w02  - Executar Semana 02"
	@echo "make test_w03  - Executar Semana 03"
	@echo "make syntax    - Sintaxe e lint basico"
	@echo "make compile   - Compilacao com VCS"
	@echo "make run       - Executar simulacao"
	@echo "make clean     - Limpar build"

# ==========================================
# Semana 02 - S-box, SubBytes e ShiftRows
# ==========================================

test_w02:
	mkdir -p build/aes_w02
	cd build/aes_w02 && vlogan -full64 -sverilog -kdb +lint=all \
		-timescale=1ns/1ps \
		../../rtl/minisoc_aes/minisoc_aes_sbox.sv \
		../../rtl/minisoc_aes/minisoc_aes_sub_bytes.sv \
		../../rtl/minisoc_aes/minisoc_aes_shift_rows.sv \
		../../tb/tb_minisoc_aes_transform.sv \
		-l syntax.log
	cd build/aes_w02 && vcs -full64 -timescale=1ns/1ps -kdb \
		-top tb_minisoc_aes_transform \
		-o simv -l compile.log
	cd build/aes_w02 && ./simv -no_save -l simulation.log
	grep -Fq "PASS: Todos os testes AES da Semana 2" build/aes_w02/simulation.log

# ==========================================
# Semana 03 - Transformacoes AES
# ==========================================

test_w03:
	mkdir -p build/aes_w03/round
	cd build/aes_w03/round && vlogan -full64 -sverilog -kdb +lint=all \
		-timescale=1ns/1ps \
		../../../rtl/minisoc_aes/minisoc_aes_sbox.sv \
		../../../rtl/minisoc_aes/minisoc_aes_sub_bytes.sv \
		../../../rtl/minisoc_aes/minisoc_aes_add_round_key.sv \
		../../../rtl/minisoc_aes/minisoc_aes_mix_columns.sv \
		../../../rtl/minisoc_aes/minisoc_aes_inv_shift_rows.sv \
		../../../rtl/minisoc_aes/minisoc_aes_inv_sub_bytes.sv \
		../../../rtl/minisoc_aes/minisoc_aes_inv_mix_columns.sv \
		../../../tb/tb_minisoc_aes_round.sv \
		-l syntax.log
	cd build/aes_w03/round && vcs -full64 -timescale=1ns/1ps -kdb \
		-top tb_minisoc_aes_round \
		-o simv -l compile.log
	cd build/aes_w03/round && ./simv -no_save -l simulation.log
	grep -Fq "PASS: Testes iniciais da Semana 3" build/aes_w03/round/simulation.log

.PHONY: all syntax compile run clean_sim clean help test_w02 test_w03

# ==========================================
# Semana 04 - AES-128 completo
# ==========================================

test_w04: test_w04_key_exp test_w04_dp

# Expansao de chave
test_w04_key_exp:
	mkdir -p build/aes_w04/key_exp
	cd build/aes_w04/key_exp && vlogan $(VLOGAN_FLAGS) \
		-timescale=$(TIMESCALE) \
		../../../rtl/minisoc_aes/minisoc_aes_sbox.sv \
		../../../rtl/minisoc_aes/minisoc_aes_key_exp.sv \
		../../../tb/tb_minisoc_aes_key_exp.sv \
		-l syntax.log
	cd build/aes_w04/key_exp && vcs $(VCS_FLAGS) \
		-top tb_minisoc_aes_key_exp \
		-o simv -l compile.log
	cd build/aes_w04/key_exp && ./simv -no_save -l simulation.log
	grep -Fq "PASS: Testes da expansao de chave" build/aes_w04/key_exp/simulation.log

# Cifragem e decifragem AES-128
test_w04_dp:
	mkdir -p build/aes_w04/datapath
	cd build/aes_w04/datapath && vlogan $(VLOGAN_FLAGS) \
		-timescale=$(TIMESCALE) \
		../../../rtl/minisoc_aes/minisoc_aes_sbox.sv \
		../../../rtl/minisoc_aes/minisoc_aes_sub_bytes.sv \
		../../../rtl/minisoc_aes/minisoc_aes_shift_rows.sv \
		../../../rtl/minisoc_aes/minisoc_aes_mix_columns.sv \
		../../../rtl/minisoc_aes/minisoc_aes_add_round_key.sv \
		../../../rtl/minisoc_aes/minisoc_aes_inv_shift_rows.sv \
		../../../rtl/minisoc_aes/minisoc_aes_inv_sub_bytes.sv \
		../../../rtl/minisoc_aes/minisoc_aes_inv_mix_columns.sv \
		../../../rtl/minisoc_aes/minisoc_aes_key_exp.sv \
		../../../rtl/minisoc_aes/minisoc_aes_dp.sv \
		../../../tb/tb_minisoc_aes_dp.sv \
		-l syntax.log
	cd build/aes_w04/datapath && vcs $(VCS_FLAGS) \
		-top tb_minisoc_aes_dp \
		-o simv -l compile.log
	cd build/aes_w04/datapath && ./simv -no_save -l simulation.log
	grep -Fq "PASS: Todos os testes da Semana 4" build/aes_w04/datapath/simulation.log

.PHONY: test_w04 test_w04_key_exp test_w04_dp

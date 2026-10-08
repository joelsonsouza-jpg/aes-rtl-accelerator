#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
command -v iverilog >/dev/null || { echo 'ERRO: instale Icarus Verilog (iverilog).'; exit 127; }
command -v vvp >/dev/null || { echo 'ERRO: instale vvp.'; exit 127; }
command -v verilator >/dev/null || { echo 'ERRO: instale Verilator para lint.'; exit 127; }
echo '[1/3] Lint (Verilator)'
verilator --lint-only --sv --top-module counter_demo -Wall rtl/counter_demo.sv 2>&1 | tee build/lint.log
echo '[2/3] Compilacao (Icarus Verilog)'
iverilog -g2012 -Wall -s tb_counter_demo -o build/sim.vvp rtl/counter_demo.sv tb/tb_counter_demo.sv 2>&1 | tee build/compile.log
echo '[3/3] Simulacao (Icarus Verilog)'
vvp build/sim.vvp | tee build/simulation.log
grep -q 'PASS: reset, contagem e enable validados.' build/simulation.log
echo 'FLUXO MINIMO APROVADO.'

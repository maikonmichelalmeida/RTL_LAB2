SHELL := /bin/bash

ROOT_DIR  := $(abspath .)
TB_DIR    := $(ROOT_DIR)/tb
BUILD_DIR := $(ROOT_DIR)/build

TEST ?= top
GUI  ?= 0

TESTS := alu memory mux regbank top top_smoke

RTL_SOURCES := \
	$(ROOT_DIR)/alu.sv \
	$(ROOT_DIR)/control.sv \
	$(ROOT_DIR)/memory.sv \
	$(ROOT_DIR)/mux.sv \
	$(ROOT_DIR)/regbank.sv \
	$(ROOT_DIR)/top.sv

TB_FILE_alu       := $(TB_DIR)/tb_alu.sv
TB_FILE_memory    := $(TB_DIR)/tb_memory.sv
TB_FILE_mux       := $(TB_DIR)/tb_mux.sv
TB_FILE_regbank   := $(TB_DIR)/tb_regbank.sv
TB_FILE_top       := $(TB_DIR)/tb_top.sv
TB_FILE_top_smoke := $(TB_DIR)/tb_top_smoke.sv

TB_TOP_alu       := tb_alu
TB_TOP_memory    := tb_memory
TB_TOP_mux       := tb_mux
TB_TOP_regbank   := tb_regbank
TB_TOP_top       := tb_top
TB_TOP_top_smoke := tb_top_smoke

TB_FILE := $(TB_FILE_$(TEST))
TB_TOP  := $(TB_TOP_$(TEST))
RUN_DIR := $(BUILD_DIR)/$(TEST)

VCS_FLAGS := \
	-full64 \
	-sverilog \
	-timescale=1ns/1ps \
	-debug_access+all \
	-kdb \
	+memcbk

ifeq ($(GUI),1)
RUN_FLAGS += -gui=verdi
endif

.PHONY: help list doctor check-test check-tools setup comp run sim test \
	sim-alu sim-memory sim-mux sim-regbank sim-top sim-top-smoke \
	verdi waves show-config clean clean-all

help:
	@echo "2RTL - Simulacao SystemVerilog com VCS/Verdi"
	@echo
	@echo "Preparacao no servidor:"
	@echo "  module load vcs verdi"
	@echo
	@echo "Comandos principais:"
	@echo "  make sim                 Roda o teste principal (TEST=top)"
	@echo "  make sim TEST=memory     Roda um teste especifico"
	@echo "  make test                Roda todos os testbenches"
	@echo "  make doctor              Verifica ferramentas e estrutura"
	@echo "  make comp TEST=top       Apenas compila"
	@echo "  make run TEST=top        Executa um binario ja compilado"
	@echo "  make verdi TEST=top      Abre a waveform test.fsdb"
	@echo "  make clean TEST=top      Limpa somente um teste"
	@echo "  make clean-all           Remove todos os resultados"
	@echo "  make list                Lista os testes disponiveis"
	@echo "  make show-config TEST=x  Mostra arquivos e configuracao"
	@echo
	@echo "Atalhos:"
	@echo "  make sim-alu"
	@echo "  make sim-memory"
	@echo "  make sim-mux"
	@echo "  make sim-regbank"
	@echo "  make sim-top"
	@echo "  make sim-top-smoke"
	@echo
	@echo "Opcional:"
	@echo "  make sim TEST=top GUI=1  Executa abrindo a GUI do Verdi"

list:
	@echo "Testes disponiveis: $(TESTS)"

doctor: check-test
	@echo "Estrutura do teste '$(TEST)' encontrada."
	@command -v vcs >/dev/null 2>&1 && \
		echo "VCS:   encontrado" || \
		echo "VCS:   nao encontrado (execute: module load vcs)"
	@command -v verdi >/dev/null 2>&1 && \
		echo "Verdi: encontrado" || \
		echo "Verdi: nao encontrado (execute: module load verdi)"
	@echo "Use 'make show-config TEST=$(TEST)' para ver os caminhos."

check-test:
	@if [[ " $(TESTS) " != *" $(TEST) "* ]]; then \
		echo "ERRO: TEST='$(TEST)' nao existe."; \
		echo "Use: make list"; \
		exit 1; \
	fi
	@if [[ ! -f "$(TB_FILE)" ]]; then \
		echo "ERRO: testbench nao encontrado: $(TB_FILE)"; \
		exit 1; \
	fi

check-tools:
	@command -v vcs >/dev/null 2>&1 || { \
		echo "ERRO: VCS nao encontrado."; \
		echo "Execute antes: module load vcs verdi"; \
		exit 1; \
	}

setup: check-test
	@mkdir -p "$(RUN_DIR)"

comp: check-tools setup
	@echo "--- [COMP] TEST=$(TEST), TOP=$(TB_TOP) ---"
	@cd "$(RUN_DIR)" && vcs $(VCS_FLAGS) \
		$(RTL_SOURCES) "$(TB_FILE)" \
		-top "$(TB_TOP)" \
		-o simv \
		-l compile.log

run: check-test
	@if [[ ! -x "$(RUN_DIR)/simv" ]]; then \
		echo "ERRO: $(RUN_DIR)/simv nao existe."; \
		echo "Execute: make comp TEST=$(TEST)"; \
		exit 1; \
	fi
	@echo "--- [RUN] TEST=$(TEST) ---"
	@cd "$(RUN_DIR)" && ./simv $(RUN_FLAGS) -l sim.log

sim: comp run

test:
	@set -e; \
	for test_name in $(TESTS); do \
		echo; \
		echo "============================================================"; \
		echo "Executando $$test_name"; \
		echo "============================================================"; \
		$(MAKE) --no-print-directory sim TEST=$$test_name; \
	done
	@echo
	@echo "Todos os testbenches foram executados."

sim-alu:
	@$(MAKE) --no-print-directory sim TEST=alu

sim-memory:
	@$(MAKE) --no-print-directory sim TEST=memory

sim-mux:
	@$(MAKE) --no-print-directory sim TEST=mux

sim-regbank:
	@$(MAKE) --no-print-directory sim TEST=regbank

sim-top:
	@$(MAKE) --no-print-directory sim TEST=top

sim-top-smoke:
	@$(MAKE) --no-print-directory sim TEST=top_smoke

verdi: waves

waves: check-test
	@if [[ ! -f "$(RUN_DIR)/test.fsdb" ]]; then \
		echo "ERRO: waveform nao encontrada: $(RUN_DIR)/test.fsdb"; \
		echo "Execute antes: make sim TEST=$(TEST)"; \
		exit 1; \
	fi
	@command -v verdi >/dev/null 2>&1 || { \
		echo "ERRO: Verdi nao encontrado."; \
		echo "Execute antes: module load verdi"; \
		exit 1; \
	}
	@cd "$(RUN_DIR)" && verdi -dbdir simv.daidir -ssf test.fsdb &

show-config: check-test
	@echo "TEST:       $(TEST)"
	@echo "TB_TOP:     $(TB_TOP)"
	@echo "TB_FILE:    $(TB_FILE)"
	@echo "RUN_DIR:    $(RUN_DIR)"
	@echo "GUI:        $(GUI)"
	@echo "RTL:"
	@printf "  %s\n" $(RTL_SOURCES)

clean: check-test
	@echo "Limpando $(RUN_DIR)"
	@rm -rf "$(RUN_DIR)"

clean-all:
	@echo "Limpando $(BUILD_DIR)"
	@rm -rf "$(BUILD_DIR)"

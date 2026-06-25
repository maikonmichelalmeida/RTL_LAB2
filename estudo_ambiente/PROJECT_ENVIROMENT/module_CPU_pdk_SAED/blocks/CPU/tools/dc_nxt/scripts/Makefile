# ==============================================================================
# Makefile Interno - Síntese Lógica (Design Compiler DC_NXT)
# Localização: tools/dc_nxt/scripts/Makefile
# ==============================================================================

ROOT_DIR        := ../../..
RTL_DIR         := $(ROOT_DIR)/rtl
VERIF_DIR       := $(ROOT_DIR)/verif
CONSTRAINTS_DIR := $(ROOT_DIR)/constraints
RUN_DIR         := ../run

FILELIST_RTL    := $(VERIF_DIR)/filelist.f
SYNTH_SCRIPT    := synth.tcl

FILELIST_NETLIST    := $(VERIF_DIR)/filelist_gl.f
SYNTH_SCRIPT_lowp    := dc.tcl
TOP_MODULE      := top_cpu

GUI ?= 0
LOG_FILE := dc_synth.log

.PHONY: synth setup run_synth clean

synth: setup run_synth

setup:
	@echo "--- [DC_NXT SETUP] Preparando diretório de execução em /run ---"
	@mkdir -p $(RUN_DIR)
	@if [ ! -f "$(FILELIST_RTL)" ]; then echo "ERRO: Arquivo $(FILELIST_RTL) não encontrado!"; exit 1; fi
	@echo "--- [DC_NXT SETUP] Tudo pronto. Modo Gráfico (GUI): $(GUI) ---"

# Alterado para dcnxt_shell, que gerencia o fluxo topográfico nativamente
run_synth:
	@echo "--- [DC_NXT RUN] Iniciando a Síntese com dcnxt_shell (GUI=$(GUI)) ---"
	@if [ "$(GUI)" = "1" ]; then \
		cd $(RUN_DIR) && dcnxt_shell -64bit -topo -gui; \
	else \
		cd $(RUN_DIR) && dcnxt_shell -64bit -topo -f ../scripts/$(SYNTH_SCRIPT) -output_log_file $(LOG_FILE); \
	fi

synth_lowp: setup_lowp run_synth_lowp

setup_lowp:
	@echo "--- [DC_NXT SETUP] Preparando diretório de execução em /run ---"
	@mkdir -p $(RUN_DIR) 
	@if [ ! -f "$(FILELIST_NETLIST)" ]; then \
		echo "ERRO: Arquivo $(FILELIST_NETLIST) não encontrado!"; \
		exit 1; \
	fi
	@echo "--- [DC_NXT SETUP] Entrando em /run e processando SAIF ---"
	@cd $(RUN_DIR) && \
	if [ -f "../../vcs/run/top_rtl.fsdb" ]; then \
		echo "Copiando FSDB..."; \
		cp ../../vcs/run/top_rtl.fsdb ./top_rtl.fsdb; \
		echo "Convertendo top_rtl.fsdb para top_cpu_activity.saif..."; \
		if fsdb2saif top_rtl.fsdb -o ../outputs/top_cpu_activity.saif; then \
			echo "SUCESSO: SAIF gerado e salvo em ../outputs/ !"; \
		else \
			echo "ERRO: Falha ao executar fsdb2saif (Verifique o tb). Abortando!"; \
			exit 1; \
		fi; \
	else \
		echo "ERRO CRÍTICO: FSDB não encontrado em ../../vcs/run/top_rtl.fsdb!"; \
		echo "Você precisa rodar a simulação RTL antes da síntese Low Power. Abortando!"; \
		exit 1; \
	fi

# Alterado para dcnxt_shell, que gerencia o fluxo topográfico nativamente
run_synth_lowp:
	@echo "--- [DC_NXT RUN] Iniciando a Síntese com dcnxt_shell (GUI=$(GUI)) ---"
	@if [ "$(GUI)" = "1" ]; then \
		cd $(RUN_DIR) && dcnxt_shell -64bit -topo -gui; \
	else \
		cd $(RUN_DIR) && dcnxt_shell -64bit -topo -f ../scripts/lp_scripts/$(SYNTH_SCRIPT_lowp) -output_log_file $(LOG_FILE); \
	fi

clean:
	@echo "--- [DC_NXT CLEAN] Limpando a pasta /run ---"
	rm -rf $(RUN_DIR)/*

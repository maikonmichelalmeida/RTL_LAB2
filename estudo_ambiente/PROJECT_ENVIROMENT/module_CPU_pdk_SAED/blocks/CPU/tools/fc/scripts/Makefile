# ==============================================================================
# Makefile Interno - Síntese Lógica (Design Compiler DC_NXT)
# Localização: tools/dc_nxt/scripts/Makefile
# ==============================================================================

# ==============================================================================
# 1. Definição de Caminhos Relativos e Variáveis do Bloco
# ==============================================================================
ROOT_DIR        := ../../..
RTL_DIR         := $(ROOT_DIR)/rtl
VERIF_DIR       := $(ROOT_DIR)/verif
CONSTRAINTS_DIR := $(ROOT_DIR)/constraints
RUN_DIR         := ../run

# Arquivos necessários para a síntese
FILELIST_RTL    := $(VERIF_DIR)/filelist_rtl.f
SYNTH_SCRIPT    := synth.tcl
TOP_MODULE      := top_cpu

# ==============================================================================
# 2. Controle de Interface Gráfica (DC GUI)
# Exemplo de uso: make synth GUI=1
# ==============================================================================
GUI ?= 0

# Flags base: 64 bits e modo topográfico (melhor estimativa de fios e área)
DC_ARGS := -64bit -topographical

ifeq ($(GUI),1)
    DC_ARGS += -gui
endif

# Nome do arquivo de log que nascerá dentro de /run
LOG_FILE := dc_synth.log

.PHONY: synth setup run_synth clean

# ==============================================================================
# Regras Principais (TUDO executado isolado dentro de /run)
# ==============================================================================
synth: setup run_synth

# Passo 1: Setup - Valida a estrutura antes de gastar licença do DC
setup:
	@echo "--- [DC_NXT SETUP] Preparando diretório de execução em /run ---"
	@mkdir -p $(RUN_DIR)
	@if [ ! -d "$(RTL_DIR)" ]; then echo "ERRO: RTL_DIR não encontrado em $(RTL_DIR)"; exit 1; fi
	@if [ ! -f "$(FILELIST_RTL)" ]; then echo "ERRO: Arquivo $(FILELIST_RTL) não encontrado!"; exit 1; fi
	@if [ ! -f "$(SYNTH_SCRIPT)" ]; then echo "ERRO: Script TCL $(SYNTH_SCRIPT) não encontrado em /scripts"; exit 1; fi
	@if [ ! -d "$(CONSTRAINTS_DIR)" ]; then echo "AVISO: Pasta de constraints não encontrada em $(CONSTRAINTS_DIR)"; fi
	@echo "--- [DC_NXT SETUP] Tudo pronto. Modo Gráfico (GUI): $(GUI) ---"

# Passo 2: Execução da Síntese
run_synth:
	@echo "--- [DC_NXT RUN] Iniciando a Síntese Lógica ---"
	# Entra na pasta /run e executa o dc_shell apontando para o script que está em /scripts
	cd $(RUN_DIR) && dc_shell $(DC_ARGS) -f ../scripts/$(SYNTH_SCRIPT) -log_file $(LOG_FILE)

# ==============================================================================
# 3. Limpeza Local
# ==============================================================================
clean:
	@echo "--- [DC_NXT CLEAN] Limpando a pasta /run ---"
	rm -rf $(RUN_DIR)/*

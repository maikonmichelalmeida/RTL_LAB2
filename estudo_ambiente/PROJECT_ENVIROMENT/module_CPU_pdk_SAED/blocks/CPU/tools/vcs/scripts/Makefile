# Makefile Interno - Simulação VCS
# Localização: tools/vcs/scripts/Makefile
# ==============================================================================
# 0. Definição de Caminhos Relativos
# ==============================================================================
ROOT_DIR  := ../../..
RTL_DIR   := $(ROOT_DIR)/rtl
VERIF_DIR := $(ROOT_DIR)/verif
RUN_DIR   := ../run
# ==============================================================================
# 1. Configuração de Modo (RTL vs Gate-Level)
# ==============================================================================
GL ?= 0

ifeq ($(GL),1)
    $(info --- [MODO] Configurando para Gate-Level Simulation (Netlist) ---)
    FILELIST  = $(VERIF_DIR)/filelist_gl.f
    TOP_TB    = top_tb_gl
    
    SDF_FILE := $(wildcard $(ROOT_DIR)/tools/dc_nxt/outputs/*.sdf)
    
    ifneq ($(words $(SDF_FILE)),1)
        $(error ERRO: Encontrado $(words $(SDF_FILE)) arquivos .sdf. Precisa ser exatamente 1)
    endif

    DUT_INST  = uut
    COMP_ARGS += +define+GATE_LEVEL_SIM
    COMP_ARGS += -sdf max:$(TOP_TB).$(DUT_INST):$(SDF_FILE)
else
    $(info --- [MODO] Configurando para RTL Simulation ---)
    FILELIST  = $(VERIF_DIR)/filelist.f
    TOP_TB    = top_tb
endif
# ==============================================================================
# 1. Controle de Features (Tags de Linha de Comando)
# ==============================================================================
GUI ?= 0
UVM ?= 0
COV ?= 0

COMP_ARGS :=
RUN_ARGS  :=

# -- Tag: GUI (Verdi) --
ifeq ($(GUI),1)
    RUN_ARGS += -gui=verdi
endif

# -- Tag: UVM --
ifeq ($(UVM),1)
    COMP_ARGS += -ntb_opts uvm-1.2
endif

# -- Tag: Coverage --
ifeq ($(COV),1)
    COV_METRICS := line+cond+fsm+tgl+branch
    # Agora não precisamos mais forçar o diretório para ../run, pois já estaremos lá
    COMP_ARGS   += -cm $(COV_METRICS)
    RUN_ARGS    += -cm $(COV_METRICS) -cm_name $(TOP_TB)
endif

# 3. Flags Base Profissionais do VCS (Adicionado o timescale para evitar erros de LRM)
VCS_FLAGS := -full64 -sverilog -timescale=10ns/1ps -debug_access+all -kdb -l vcs_comp.log

.PHONY: sim setup comp run view_cov clean

# ==============================================================================
# Regras Principais (TUDO executado dentro de /run)
# ==============================================================================
sim: setup comp run

setup:
	@echo "--- [VCS SETUP] Preparando diretório de execução em /run ---"
	@mkdir -p $(RUN_DIR)
	@if [ ! -f "$(FILELIST)" ]; then echo "ERRO: $(FILELIST) não encontrado!"; exit 1; fi

comp:
	@echo "--- [VCS COMP] Compilando RTL e Testbench dentro de /run ---"
	# Entra na pasta /run ANTES de chamar o VCS. Tudo será gerado lá dentro.
	cd $(RUN_DIR) && vcs $(VCS_FLAGS) $(COMP_ARGS) -f $(FILELIST) -top $(TOP_TB)

run:
	@echo "--- [VCS RUN] Executando Simulação em /run ---"
	# Como o simv foi gerado em /run, chamamos apenas ./simv
	cd $(RUN_DIR) && ./simv $(RUN_ARGS) -l vcs_run.log

# ==============================================================================
# 4. Análise de Cobertura no VERDI
# ==============================================================================
view_cov:
	@echo "--- [VERDI COV] Abrindo Análise de Cobertura no Verdi ---"
	@if [ ! -d "$(RUN_DIR)/simv.vdb" ]; then \
		echo "ERRO: Banco de dados de cobertura não encontrado!"; \
		exit 1; \
	fi
	cd $(RUN_DIR) && verdi -cov -covdir simv.vdb &

# ==============================================================================
# 5. Limpeza
# ==============================================================================
clean:
	@echo "--- [VCS CLEAN] Limpando a pasta /run ---"
	# Como NADA é gerado em /scripts, a limpeza apaga apenas o conteúdo de /run
	rm -rf $(RUN_DIR)/*

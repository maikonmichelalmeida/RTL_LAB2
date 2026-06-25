# Makefile Orquestrador do Bloco CPU (Standalone)

# 1. Força o uso do bash
SHELL := /bin/bash

# 2. Define os módulos

MODULES := \
    syn/W-2024.09-SP5-2 \
    fusioncompiler/W-2024.09-SP3 \
    designcompiler/W-2024.09-SP5-4 \
    vcs/W-2024.09-SP2-3 \
    verdi/W-2024.09-SP2-6 \
    fm/W-2024.09-SP5   

.PHONY: all help sim synth formal clean

all: help

help:
	@echo "Comandos disponíveis:"
	@echo "  make sim    - Carrega módulos e roda VCS"
	@echo "  make synth  - Carrega módulos e roda DC_NXT"
	@echo "  make formal - Carrega módulos e roda Formality"
	@echo "  make clean  - Limpa os diretórios"

# 3. Regras de Execução (Carrega direto e delega para o sub-Makefile)
sim:
	@echo "--- Preparando ambiente e executando Simulação (VCS) ---"
	@module load $(MODULES) && cd tools/vcs/scripts && make sim	
view_cov:
	@echo "--- Preparando ambiente e abrindo Cobertura (Verdi) ---"
	@module load $(MODULES) && cd tools/vcs/scripts && make view_cov
synth:
	@echo "--- Preparando ambiente e executando Síntese (DC_NXT) ---"
	@module load $(MODULES) && cd tools/dc_nxt/scripts && make synth
synth_lowp:
	@echo "--- Preparando ambiente e executando Síntese de Baixa Potência (DC_NXT) ---"
	@module load $(MODULES) && cd tools/dc_nxt/scripts && make synth_lowp
formal:
	@echo "--- Preparando ambiente e executando Equivalência (FM) ---"
	@module load $(MODULES) && cd tools/fm/scripts && make formal
fc:
	@echo "--- Preparando ambiente e executando Equivalência (FM) ---"
	@module load $(MODULES) && cd tools/fc/scripts && make fc

	
	
	
# ==============================================================================
# 4. Limpeza de Arquivos Temporários e Pastas de Execução
# ==============================================================================
clean:
	@echo "--- Iniciando limpeza do projeto /run de todas tools ---"
	@# 1. Tenta rodar o clean do sub-makefile do VCS (ignora erro se a pasta/arquivo não existir)
	@-cd tools/vcs/scripts && make clean 2>/dev/null || true
	@# 2. Esvazia o conteúdo de qualquer pasta run ou .run em todas as ferramentas de forma genérica
	@rm -rf tools/*/run/* tools/*/.run/*
	@# 3. Garante a remoção de arquivos ocultos dentro dessas pastas (ex: .vdb ou .lock)
	@rm -rf tools/*/run/.[a-zA-Z0-9]* tools/*/.run/.[a-zA-Z0-9]* 2>/dev/null || true
	@# 4. Remove lixo residual e logs que possam ter sido gerados na raiz do bloco
	@rm -rf *.log *.rpt work/ simv* csrc/ *.daidir/ verdiLog/ NOCOMP_INFO
	@echo "--- Limpeza concluída com sucesso ---"
	
clean_hard_dc:
	@echo "--- Iniciando limpeza profunda do projeto /outputs and /rpt das rodadas antigas ---"
	@rm -rf tools/dc_nxt/rpt/* tools/dc_nxt/outputs/*


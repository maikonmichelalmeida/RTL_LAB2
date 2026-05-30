#!/usr/bin/env bash

set -euo pipefail

RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$RUN_DIR"

MODE="${1:-reset}"

echo "Diretorio de execucao:"
pwd
echo

echo "Atualizando codigo pelo Git..."
git pull --ff-only origin main

echo
echo "Carregando VCS e Verdi..."
module load vcs verdi

echo
if [ "$MODE" = "keep" ]; then
    echo "Modo keep: mantendo arquivos antigos de simulacao."
else
    echo "Modo reset: removendo resultados antigos..."
    rm -rf simv simv.daidir csrc AN.DB verdiLog ucli.key comp.log sim.log test.fsdb novas.conf novas.rc novas_dump.log
fi

echo
echo "Compilando projeto..."
vcs -full64 -f filelist.f -debug_access+all +memcbk -kdb -l comp.log

echo
echo "Executando testbench..."
./simv | tee sim.log

echo
if [ ! -f test.fsdb ]; then
    echo "ERRO: o arquivo test.fsdb nao foi gerado."
    echo "Confira o testbench e os comandos fsdbDumpfile/fsdbDumpvars."
    exit 1
fi

echo "Arquivo de ondas gerado: test.fsdb"

echo
if [ -n "${DISPLAY:-}" ]; then
    echo "Abrindo Verdi..."
    verdi -dbdir simv.daidir -ssf test.fsdb &
else
    echo "Simulacao concluida, mas DISPLAY esta vazio."
    echo "Entre no servidor usando ssh -X para abrir o Verdi."
fi
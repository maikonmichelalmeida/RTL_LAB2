#!/usr/bin/env bash

set -euo pipefail

RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$RUN_DIR"

echo "Diretorio de simulacao:"
pwd
echo

echo "Carregando VCS e Verdi..."
module load vcs verdi

echo
echo "Removendo resultados antigos..."
rm -rf simv simv.daidir csrc AN.DB verdiLog ucli.key comp.log sim.log test.fsdb novas.conf

echo
echo "Compilando mux e testbench..."
vcs -full64 -f filelist.f -debug_access+all -kdb -l comp.log

echo
echo "Executando simulacao..."
./simv | tee sim.log

echo
if [ ! -f test.fsdb ]; then
    echo "ERRO: test.fsdb nao foi gerado."
    exit 1
fi

echo "Arquivo de ondas gerado: test.fsdb"

if [ -n "${DISPLAY:-}" ]; then
    echo "Abrindo Verdi..."
    verdi -dbdir simv.daidir -ssf test.fsdb &
else
    echo "Simulacao concluida, mas DISPLAY esta vazio."
    echo "Abra a sessao do servidor usando ssh -X para visualizar no Verdi."
fi
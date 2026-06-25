#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/maikonmichelalmeida/RTL_LAB2.git"
REPO_DIR="${HOME}/RTL_LAB2"
REMOTE="origin"
BRANCH="main"

echo
echo "Sincronizacao do RTL_LAB2"
echo "Destino: ${REPO_DIR}"
echo

if ! command -v git >/dev/null 2>&1; then
    echo "ERRO: Git nao foi encontrado no servidor."
    exit 1
fi

if [[ ! -d "${REPO_DIR}/.git" ]]; then
    if [[ -e "${REPO_DIR}" ]]; then
        echo "ERRO: ${REPO_DIR} existe, mas nao e um repositorio Git."
        echo "Mova ou remova essa pasta antes do primeiro clone."
        exit 1
    fi

    echo "Repositorio ainda nao existe. Fazendo o clone inicial..."
    git clone --branch "${BRANCH}" --single-branch "${REPO_URL}" "${REPO_DIR}"
    echo
    echo "Clone concluído."
    exit 0
fi

cd "${REPO_DIR}"

ROOT="$(git rev-parse --show-toplevel)"
if [[ "${ROOT}" != "${REPO_DIR}" ]]; then
    echo "ERRO: a raiz Git detectada nao corresponde a ${REPO_DIR}."
    echo "Raiz detectada: ${ROOT}"
    exit 1
fi

CURRENT_REMOTE="$(git remote get-url "${REMOTE}")"
if [[ "${CURRENT_REMOTE}" != "${REPO_URL}" ]]; then
    echo "ERRO: o remoto ${REMOTE} nao aponta para o repositorio esperado."
    echo "Esperado: ${REPO_URL}"
    echo "Atual:    ${CURRENT_REMOTE}"
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "ERRO: existem alteracoes locais no servidor."
    git status --short
    echo
    echo "Resolva, descarte ou salve essas alteracoes antes de sincronizar."
    exit 1
fi

echo "Buscando atualizacoes..."
git fetch "${REMOTE}" "${BRANCH}"

echo "Aplicando atualizacao fast-forward..."
git checkout "${BRANCH}"
git merge --ff-only "${REMOTE}/${BRANCH}"

echo
echo "Servidor sincronizado com sucesso."
git log -1 --oneline

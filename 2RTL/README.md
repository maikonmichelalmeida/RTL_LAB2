# 2RTL

Versao SystemVerilog do projeto original em `RTL`, com simulacao organizada por Makefile.

## Preparacao no servidor

```bash
module load vcs verdi
cd ~/RTL_LAB2/2RTL
make help
```

## Uso rapido

```bash
make sim
make test
make doctor
make sim TEST=alu
make verdi TEST=top
```

Cada teste usa um diretorio proprio em `build/<teste>`, evitando que logs, binarios e waveforms de testes diferentes se misturem.

## Testes disponiveis

- `alu`
- `memory`
- `mux`
- `regbank`
- `top`
- `top_smoke`

O teste `top` e o teste integrado completo. O teste `top_smoke` e uma versao menor para operacoes aritmeticas e divisao por zero.

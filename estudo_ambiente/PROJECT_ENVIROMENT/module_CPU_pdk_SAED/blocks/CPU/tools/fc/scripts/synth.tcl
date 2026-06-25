# ==============================================================================
# Script Principal de Síntese - Synopsys Design Compiler (DC_NXT)
# Executado a partir de: tools/dc_nxt/run/
# ==============================================================================

################################################################################
## 1. Setup do Ambiente e Definição de Variáveis
################################################################################
puts "--- \[DC_NXT\] 1. Inicializando Ambiente ---"

set DESIGN_NAME     "top_cpu"

# Caminhos Relativos ao diretório /run
set _REPORTS_PATH   "../reports"
set _OUTPUTS_PATH   "../outputs"
set _DFT_PATH       "../dft"
set CONSTRAINTS_DIR "../../../constraints"
set RTL_FILELIST    "../../../verif/filelist_rtl.f"

# Cria a estrutura de diretórios para os artefatos de saída
foreach dir [list $_REPORTS_PATH $_OUTPUTS_PATH $_DFT_PATH] {
    if {![file exists $dir]} { file mkdir $dir }
}

################################################################################
## 2. Configuração do PDK e Bibliotecas Lógicas/Físicas (PLACEHOLDERS)
################################################################################
puts "--- \[DC_NXT\] 2. Configurando Bibliotecas ---"

# ---> PREENCHA AQUI: Caminho base do seu PDK
set PDK_BASE        "/caminho/para/seu/pdk"
set DB_NLDM_DIR     "${PDK_BASE}/lib/stdcell_pasta/db_nldm"
set NDM_DIR         "${PDK_BASE}/lib/stdcell_pasta/ndm"

# 2.1 Configuração Lógica (Síntese)
set search_path [concat $search_path $DB_NLDM_DIR]

# ---> PREENCHA AQUI: Nomes exatos dos arquivos .db na pasta db_nldm
set target_library "nome_da_sua_lib_logica.db"
set link_library   "* $target_library"

# 2.2 Configuração Física (DC_NXT Topographical Mode)
# ---> PREENCHA AQUI: Nome exato do arquivo .ndm na pasta ndm
set_app_var ndm_reference_library "${NDM_DIR}/nome_da_sua_lib_fisica.ndm"

# Setup para o Formality (Gera arquivo .svf que rastreia as otimizações)
set_svf ${_OUTPUTS_PATH}/${DESIGN_NAME}.svf

################################################################################
## 3. Leitura e Elaboração do RTL
################################################################################
puts "--- \[DC_NXT\] 3. Lendo e Elaborando RTL ---"

if {![analyze -format sverilog -vcs "-f ${RTL_FILELIST}"]} {
    puts "ERRO: Falha na análise do RTL."
    exit 1
}

elaborate $DESIGN_NAME
current_design $DESIGN_NAME

# Vincula as instâncias às células do PDK
link

# Verifica se há referências não resolvidas ou múltiplos drivers
check_design -unresolved

################################################################################
## 4. Aplicação de Constraints (Temporais e Físicas)
################################################################################
puts "--- \[DC_NXT\] 4. Aplicando Constraints ---"

set SDC_FILE "${CONSTRAINTS_DIR}/constraints.sdc"

if {[file exists $SDC_FILE]} {
    source -echo -verbose $SDC_FILE
    puts "INFO: Constraints aplicadas a partir de $SDC_FILE"
} else {
    puts "AVISO: Arquivo $SDC_FILE não encontrado. Síntese ocorrerá sem constraints de timing."
}

################################################################################
## 5. Configuração de Testabilidade (DFT / Scan Chain)
################################################################################
puts "--- \[DC_NXT\] 5. Configurando DFT ---"

set_scan_configuration -style multiplexed_flip_flop

# Define as portas de controle de scan (DC criará as portas no topo se não existirem)
set_dft_signal -view spec -type ScanEnable  -port scan_en -active_state 1
set_dft_signal -view spec -type ScanDataIn  -port scan_in
set_dft_signal -view spec -type ScanDataOut -port scan_out

create_test_protocol
dft_drc -verbose

################################################################################
## 6. Síntese Lógica e Otimização
################################################################################
puts "--- \[DC_NXT\] 6. Iniciando Compile Ultra ---"

# Síntese agressiva considerando os fios virtuais (topographical) e inserção de scan
compile_ultra -scan

# Efetiva a inserção das cadeias de Scan no design mapeado
insert_dft

# Gera estimativa de cobertura do ATPG
dft_drc -coverage_estimate > ${_DFT_PATH}/${DESIGN_NAME}_dft_coverage.log

################################################################################
## 7. Extração de Relatórios
################################################################################
puts "--- \[DC_NXT\] 7. Gerando Relatórios ---"

report_area -hierarchy   > ${_REPORTS_PATH}/${DESIGN_NAME}_area.rpt
report_timing            > ${_REPORTS_PATH}/${DESIGN_NAME}_timing.rpt
report_power             > ${_REPORTS_PATH}/${DESIGN_NAME}_power.rpt
report_qor               > ${_REPORTS_PATH}/${DESIGN_NAME}_qor.rpt
report_dft_scan_path     > ${_DFT_PATH}/${DESIGN_NAME}_scan_chains.rpt

################################################################################
## 8. Exportação de Artefatos Finais (Para PnR / Innovus / ICC2)
################################################################################
puts "--- \[DC_NXT\] 8. Exportando Arquivos Finais ---"

# Limpa a nomenclatura das instâncias e redes para o fluxo de Backend
change_names -rules verilog -hierarchy

# Netlist final mapeada (Gate-level)
write -format verilog -hierarchy -output ${_OUTPUTS_PATH}/${DESIGN_NAME}_mapped.v

# Constraints atualizadas pós-síntese
write_sdc -nosplit ${_OUTPUTS_PATH}/${DESIGN_NAME}_final.sdc

# Atrasos anotados (Standard Delay Format)
write_sdf ${_OUTPUTS_PATH}/${DESIGN_NAME}_delays.sdf

# Definição física das Scan Chains
write_scan_def -output ${_OUTPUTS_PATH}/${DESIGN_NAME}_scan_chain.def

# Fecha a gravação do arquivo Formality
set_svf -off

puts "--- \[DC_NXT\] SÍNTESE CONCLUÍDA COM SUCESSO ---"
exit

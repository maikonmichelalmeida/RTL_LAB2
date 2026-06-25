# ==============================================================================
# Script Principal de Síntese - Synopsys Design Compiler (DC_NXT)
# Executado a partir de: tools/dc_nxt/run/
# (Versão Standard - Sem inserção de DFT)
# ==============================================================================

################################################################################
## 1. Setup do Ambiente e Definição de Variáveis
################################################################################
puts "--- \[DC_NXT\] 1. Inicializando Ambiente ---"

set DESIGN_NAME     "top_cpu"

# Caminhos Relativos ao diretório /run
set _REPORTS_PATH   "../rpt"
set _OUTPUTS_PATH   "../outputs"
set CONSTRAINTS_DIR "../../../constraints"
set RTL_FILELIST    "../../../verif/filelist.f"

# Cria a estrutura de diretórios para os artefatos de saída (caso alguma não exista)
foreach dir [list $_REPORTS_PATH $_OUTPUTS_PATH] {
    if {![file exists $dir]} { file mkdir $dir }
}

source ../scripts/setup.tcl

set_svf ${_OUTPUTS_PATH}/${DESIGN_NAME}.svf

puts "Pressione ENTER para prosseguir com o source ou CTRL+C para cancelar..."
# Pausa a execução aguardando sua interação
gets stdin

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

puts "Pressione ENTER para prosseguir com o source ou CTRL+C para cancelar..."
# Pausa a execução aguardando sua interação
gets stdin

################################################################################
## 5. Síntese Lógica e Otimização
################################################################################
puts "--- \[DC_NXT\] 5. Iniciando Compile Ultra ---"
check_timing
# Síntese agressiva considerando os fios virtuais (topographical)
compile_ultra

################################################################################
## 6. Extração de Relatórios
################################################################################
puts "--- \[DC_NXT\] 6. Gerando Relatórios ---"

report_area -hierarchy   > ${_REPORTS_PATH}/${DESIGN_NAME}_area.rpt
report_timing            > ${_REPORTS_PATH}/${DESIGN_NAME}_timing.rpt
report_power             > ${_REPORTS_PATH}/${DESIGN_NAME}_power.rpt
report_qor               > ${_REPORTS_PATH}/${DESIGN_NAME}_qor.rpt

################################################################################
## 7. Exportação de Artefatos Finais (Para PnR / Innovus / ICC2)
################################################################################
puts "--- \[DC_NXT\] 7. Exportando Arquivos Finais ---"

# Limpa a nomenclatura das instâncias e redes para o fluxo de Backend
change_names -rules verilog -hierarchy

# Netlist final mapeada (Gate-level)
write -format verilog -hierarchy -output ${_OUTPUTS_PATH}/${DESIGN_NAME}_mapped.v

# Constraints atualizadas pós-síntese
write_sdc -nosplit ${_OUTPUTS_PATH}/${DESIGN_NAME}_final.sdc

# Atrasos anotados (Standard Delay Format)
write_sdf ${_OUTPUTS_PATH}/${DESIGN_NAME}_delays.sdf

# Fecha a gravação do arquivo Formality
set_svf -off

puts "--- \[DC_NXT\] SÍNTESE CONCLUÍDA COM SUCESSO ---"
exit

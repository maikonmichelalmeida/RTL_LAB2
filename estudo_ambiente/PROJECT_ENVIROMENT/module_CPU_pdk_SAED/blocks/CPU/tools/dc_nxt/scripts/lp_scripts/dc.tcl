# ==============================================================================
# Script Principal de Síntese - Synopsys Design Compiler (DC_NXT)
# Executado a partir de: tools/dc_nxt/run/
# (Fluxo Low Power - Com Clock Gating e Análise SAIF)
# ==============================================================================

################################################################################
## 1. Setup do Ambiente e Definição de Variáveis
################################################################################
puts "--- \[DC_NXT\] 1. Inicializando Ambiente ---"

set DESIGN_NAME     "top_cpu"

# Caminhos Relativos ao diretório /run
set _REPORTS_PATH   "../rpt"
set _OUTPUTS_PATH   "../outputs"
set CONSTRAINTS_DIR "../outputs"

# [CORREÇÃO]: Apontando para o filelist do RTL original, não o GL!
set RTL_FILELIST    "../../../verif/filelist_gl_dc.f"

# Cria a estrutura de diretórios para os artefatos de saída
foreach dir [list $_REPORTS_PATH $_OUTPUTS_PATH] {
    if {![file exists $dir]} { file mkdir $dir }
}

source ../scripts/setup.tcl

set_svf ${_OUTPUTS_PATH}/${DESIGN_NAME}.svf

puts "Pressione ENTER para prosseguir com o source ou CTRL+C para cancelar..."
gets stdin

################################################################################
## 2. Leitura e Elaboração do RTL
################################################################################
puts "--- \[DC_NXT\] 2. Lendo e Elaborando RTL ---"

if {![analyze -format sverilog -vcs "-f ${RTL_FILELIST}"]} {
    puts "ERRO: Falha na análise do RTL."
    exit 1
}

elaborate $DESIGN_NAME
current_design $DESIGN_NAME

# Vincula as instâncias às células do PDK
link


################################################################################
## 4. Aplicação de Constraints (Temporais e Físicas)
################################################################################
puts "--- \[DC_NXT\] 4. Aplicando Constraints ---"

set SDC_FILE "${CONSTRAINTS_DIR}/top_cpu_final.sdc"

if {[file exists $SDC_FILE]} {
    source -echo -verbose $SDC_FILE
    puts "INFO: Constraints aplicadas a partir de $SDC_FILE"
} else {
    puts "AVISO: Arquivo $SDC_FILE não encontrado. Síntese ocorrerá sem constraints de timing."
}
################################################################################
## 3. Fluxo de Otimização (Clock Gating Iterativo)
################################################################################
puts "--- \[DC_NXT\] 3. Otimização Inicial e Clock Gating ---"

compile_ultra -spg -no_autoungroup -gate_clock
report_clock_gating -ungated 

identify_clock_gating 

source -echo ../scripts/lp_scripts/clock_gating.tcl
compile_ultra -spg -no_autoungroup -gate_clock
report_clock_gating -ungated

set compile_clock_gating_through_hierarchy true
compile_ultra -spg -no_autoungroup -gate_clock
report_clock_gating -ungated
 
source -echo ../scripts/lp_scripts/power_analysis.tcl
compile_ultra -spg -no_autoungroup -gate_clock
report_clock_gating -ungated
report_activity -driver 

################################################################################
## 4. Otimização Focada em Potência (Low Power)
################################################################################
puts "--- \[DC_NXT\] 4. Otimização Final de Área/Potência ---"

set_qor_strategy -metric total_power
compile_ultra -spg -no_autoungroup -gate_clock
report_clock_gating -ungated

# Inserção de Scan/DFT (Se houver)
source -echo ../scripts/lp_scripts/insert_dft.tcl

compile_ultra -spg -no_autoungroup -incr 
report_clock_gating -ungated


# Configuração estática para pinos de Scan (evita consumo irreal de potência)
set_switching_activity [get_ports -quiet SE] -static_probability 0 -toggle_rate 0
set_switching_activity [get_ports -quiet SI*] -static_probability 0 -toggle_rate 0

compile_ultra -spg -no_autoungroup -incr 
report_clock_gating -ungated
set_ideal_network [all_fanout -clock_tree -flat]

################################################################################
## 6. Exportação de Arquivos de Integração (Mapas e Parasíticos)
################################################################################
puts "--- \[DC_NXT\] 6. Exportando Integrações ---"

change_names -rule verilog -hier

# Exporta mapa do SAIF corrigido (primepower) e no diretório correto
saif_map -write_map ${_OUTPUTS_PATH}/primepower_lowp.saif.map -type primepower

extract_rc -estimate  
update_timing 

################################################################################
## 7. Geração de Artefatos Finais (Netlist, Constraints e SDF)
################################################################################
puts "--- \[DC_NXT\] 7. Gerando Artefatos Finais para P&R e Simulação ---"

# Constraints otimizadas
write_sdc ${_OUTPUTS_PATH}/constraints_lowp.sdc

# Netlist para a simulação Gate-Level
write_file -format verilog -output ${_OUTPUTS_PATH}/netlist_lowp.v -hierarchy

# Parasíticos para PrimePower
write_parasitics -output ${_OUTPUTS_PATH}/parasitics_lowp.spef 

# Atrasos temporais (SDF) para simulação no VCS
write_sdf -version 2.1 -context verilog ${_OUTPUTS_PATH}/netlist_lowp.sdf

################################################################################
## 8. Relatórios Finais (Power, Timing, Area)
################################################################################
puts "--- \[DC_NXT\] 8. Gerando Relatórios Finais em ${_REPORTS_PATH} ---"

redirect -file ${_REPORTS_PATH}/report_power.final.rpt -tee {report_power -nosplit}
report_timing > ${_REPORTS_PATH}/report_timing.final.rpt
report_qor    > ${_REPORTS_PATH}/report_qor.final.rpt
report_area   > ${_REPORTS_PATH}/report_area.final.rpt

# (Opcional) Script dedicado do PrimePower
#source -echo ../scripts/lp_scripts/pwr.tcl 

puts "--- \[DC_NXT\] Síntese Concluída com Sucesso! ---"
exit
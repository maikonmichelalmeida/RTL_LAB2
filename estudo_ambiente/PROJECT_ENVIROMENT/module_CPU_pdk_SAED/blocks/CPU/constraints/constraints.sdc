# ==============================================================================
# Synopsys Design Constraints (SDC) - Versão de Teste Básica
# Design Top: top_cpu
# ==============================================================================

# 1. Limpa restrições anteriores (boa prática)
reset_design

# 2. Definição do Clock Principal
# Cria um clock chamado 'master_clk' no pino físico 'clk' com período de 2.0ns (500 MHz)
create_clock -name master_clk -period 20.0 [get_ports clk]

# 3. Modelagem de Não-Idealidades do Clock
# Define o jitter/skew estimado (Ex: 10% do período)
set_clock_uncertainty 0.2 [get_clocks master_clk]
# Define o tempo de transição (slew rate) do clock
set_clock_transition 0.1  [get_clocks master_clk]

# 4. Restrições de Entrada (Input Delays)
# Define que os sinais externos chegam ao chip 0.8ns após a borda do clock (40% do período)
# O 'remove_from_collection' garante que não aplicamos essa regra no próprio pino de clock
set_input_delay -clock master_clk 0.8 [remove_from_collection [all_inputs] [get_ports clk]]

# 5. Restrições de Saída (Output Delays)
# Define que o circuito externo exige que os dados fiquem estáveis 0.8ns antes da próxima borda
set_output_delay -clock master_clk 0.8 [all_outputs]

# 6. Modelagem de Ambiente Físico (Opcional, mas evita warnings de síntese)
# Aplica uma carga capacitiva básica (em pF) em todas as saídas para o cálculo de delay de rampa
set_load 0.050 [all_outputs]

# Define que o sinal de Reset é assíncrono/falso caminho para análise de tempo (evita violações bobas)
set_false_path -from [get_ports rst]

# ==============================================================================
# Fim do Script de Constraints
# ==============================================================================
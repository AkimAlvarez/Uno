# compile.do - Compila todos os arquivos do projeto UNO para simulacao
#
# Como executar (a partir de src/ModelSim/UNO/):
#   vsim -c -do compile.do

if {[file exists work]} { vdel -lib work -all }
vlib work

echo "=== [1/2] Compilando RTL ==="
vlog -work work \
    rtl/embaralhar.v \
    rtl/card_ram.v \
    rtl/clock_div.v \
    rtl/reset_synchronizer.v \
    rtl/timer_2s.v \
    rtl/dealer.v \
    rtl/player.v \
    rtl/cpu.v \
    rtl/controlador.v \
    rtl/decoder_valor.v \
    rtl/decorder_cor.v \
    "rtl/conversor_bin-dec.v" \
    rtl/led_animator.v \
    rtl/display_animator.v \
    rtl/view_controller.v \
    rtl/top.v

echo "=== [2/2] Compilando Testbenches ==="
vlog -work work +incdir+tbs \
    tbs/dealer_controlavel.v \
    tbs/tb_dealer.v \
    tbs/tb_distribuicao.v \
    tbs/tb_carta_inicial.v \
    tbs/tb_jogada_player.v \
    tbs/tb_compra_player.v \
    tbs/tb_cpu.v \
    tbs/tb_cpu_compra.v \
    tbs/tb_skip.v \
    tbs/tb_empilhamento.v \
    tbs/tb_coringa.v \
    tbs/tb_coringa_cpu.v \
    tbs/tb_win.v \
    tbs/tb_lose.v \
    tbs/tb_penalidade.v \
    tbs/tb_view_controller.v \
    tb_uno.v

echo "=== Compilacao concluida. Execute run_all.bat para simular. ==="
quit

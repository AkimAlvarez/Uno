onerror {resume}
quietly WaveActivateNextPane {} 0

# ============================================================
# ENTRADAS / ESTIMULOS
# ============================================================
add wave -noupdate -divider {ENTRADAS}
add wave -noupdate /tb_view_controller/clk
add wave -noupdate /tb_view_controller/reset
add wave -noupdate /tb_view_controller/start_game
add wave -noupdate /tb_view_controller/player_turn
add wave -noupdate /tb_view_controller/cpu_turn
add wave -noupdate /tb_view_controller/invalid_move
add wave -noupdate /tb_view_controller/win_game
add wave -noupdate /tb_view_controller/lose_game
add wave -noupdate /tb_view_controller/choosing_color
add wave -noupdate -radix binary /tb_view_controller/color_selector
add wave -noupdate -radix binary /tb_view_controller/player_card
add wave -noupdate -radix binary /tb_view_controller/top_card
add wave -noupdate -radix unsigned /tb_view_controller/n_player
add wave -noupdate -radix unsigned /tb_view_controller/n_cpu

# ============================================================
# CLOCK / RESET INTERNOS
# ============================================================
add wave -noupdate -divider {CLOCK & RESET}
add wave -noupdate /tb_view_controller/dut/w_reset_sync
add wave -noupdate /tb_view_controller/dut/w_tick_animacao
add wave -noupdate -radix unsigned /tb_view_controller/dut/redutor_freq/contador

# ============================================================
# DISPLAY DO JOGADOR (FSM de animacao + saidas)
# ============================================================
add wave -noupdate -divider {DISPLAY JOGADOR}
add wave -noupdate -radix binary /tb_view_controller/dut/animador_displays/estado_atual
add wave -noupdate /tb_view_controller/dut/animador_displays/pisca_status
add wave -noupdate -radix binary /tb_view_controller/out_cor_player
add wave -noupdate -radix binary /tb_view_controller/out_val_player

# ============================================================
# DISPLAY DA MESA (top card)
# ============================================================
add wave -noupdate -divider {DISPLAY MESA}
add wave -noupdate -radix binary /tb_view_controller/out_cor_top
add wave -noupdate -radix binary /tb_view_controller/out_val_top

# ============================================================
# CONTADORES DE CARTAS (BCD -> 7 segmentos)
# ============================================================
add wave -noupdate -divider {CONTADORES}
add wave -noupdate -radix binary /tb_view_controller/out_player_dez
add wave -noupdate -radix binary /tb_view_controller/out_player_unid
add wave -noupdate -radix binary /tb_view_controller/out_cpu_dez
add wave -noupdate -radix binary /tb_view_controller/out_cpu_unid

# ============================================================
# LEDS (FSM de animacao + saidas)
# ============================================================
add wave -noupdate -divider {LEDS}
add wave -noupdate -radix binary /tb_view_controller/dut/animador_leds/estado_atual
add wave -noupdate -radix unsigned /tb_view_controller/dut/animador_leds/contador_piscadas
add wave -noupdate -radix unsigned /tb_view_controller/dut/animador_leds/contador_tempo
add wave -noupdate -radix binary /tb_view_controller/ledg
add wave -noupdate -radix binary /tb_view_controller/ledr

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
configure wave -valuecolwidth 110
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {24000 ns}
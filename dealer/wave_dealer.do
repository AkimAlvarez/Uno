onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TOP
add wave -noupdate /tb_dealer/clk
add wave -noupdate /tb_dealer/rst
add wave -noupdate /tb_dealer/draw
add wave -noupdate -radix binary /tb_dealer/draw_action
add wave -noupdate -radix decimal /tb_dealer/carta_sorteada_id
add wave -noupdate /tb_dealer/carta_sorteada
add wave -noupdate -divider Dealer
add wave -noupdate -radix binary /tb_dealer/uut/dealer/clk
add wave -noupdate -radix binary /tb_dealer/uut/dealer/draw
add wave -noupdate -radix binary /tb_dealer/uut/dealer/rst
add wave -noupdate /tb_dealer/uut/dealer/draw_action
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/carta_sorteada_id
add wave -noupdate /tb_dealer/uut/dealer/cartas_usadas
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/contador
add wave -noupdate /tb_dealer/uut/dealer/current_state
add wave -noupdate /tb_dealer/uut/dealer/next_state
add wave -noupdate /tb_dealer/uut/dealer/carta_valida
add wave -noupdate -divider Baralho
add wave -noupdate -radix binary /tb_dealer/uut/baralho_lut/clock
add wave -noupdate /tb_dealer/uut/baralho_lut/address
add wave -noupdate /tb_dealer/uut/baralho_lut/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {149937 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 95
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {240791 ps}

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Dealer
add wave -noupdate -radix hexadecimal /tb_top/uut/dealer/clk
add wave -noupdate -radix hexadecimal /tb_top/uut/dealer/draw
add wave -noupdate -radix hexadecimal /tb_top/uut/dealer/rst
add wave -noupdate /tb_top/uut/dealer/draw_action
add wave -noupdate -radix decimal /tb_top/uut/dealer/carta_sorteada_id
add wave -noupdate /tb_top/uut/dealer/cartas_usadas
add wave -noupdate -radix decimal /tb_top/uut/dealer/contador
add wave -noupdate /tb_top/uut/dealer/current_state
add wave -noupdate /tb_top/uut/dealer/next_state
add wave -noupdate /tb_top/uut/dealer/carta_valida
add wave -noupdate -divider {LUT - Baralho}
add wave -noupdate -radix hexadecimal /tb_top/uut/baralho_lut/clock
add wave -noupdate -radix decimal /tb_top/uut/baralho_lut/address
add wave -noupdate /tb_top/uut/baralho_lut/q
add wave -noupdate -divider Top
add wave -noupdate /tb_top/clk
add wave -noupdate /tb_top/rst
add wave -noupdate /tb_top/draw
add wave -noupdate /tb_top/draw_action
add wave -noupdate -radix decimal /tb_top/carta_sorteada_id
add wave -noupdate /tb_top/carta_sorteada
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {481100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 222
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
WaveRestoreZoom {739167 ps} {918992 ps}

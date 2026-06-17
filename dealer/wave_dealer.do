onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TOP
add wave -noupdate /tb_dealer/clk
add wave -noupdate /tb_dealer/rst
add wave -noupdate /tb_dealer/draw
add wave -noupdate /tb_dealer/ready
add wave -noupdate -radix binary /tb_dealer/draw_action
add wave -noupdate -radix decimal /tb_dealer/carta_ponteiro
add wave -noupdate -radix binary /tb_dealer/carta_sorteada
add wave -noupdate -divider {Dealer FSM}
add wave -noupdate /tb_dealer/uut/dealer/state
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/idx
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/jrand
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/ptr
add wave -noupdate -radix binary /tb_dealer/uut/dealer/aval
add wave -noupdate -radix binary /tb_dealer/uut/dealer/bval
add wave -noupdate -divider Semente/LFSR
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/entropy_counter
add wave -noupdate -radix binary /tb_dealer/uut/dealer/reset_release
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/seed_value
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/lfsr_out
add wave -noupdate -divider RAM
add wave -noupdate -radix decimal /tb_dealer/uut/dealer/ram_addr
add wave -noupdate -radix binary /tb_dealer/uut/dealer/ram_we
add wave -noupdate -radix binary /tb_dealer/uut/dealer/ram_data
add wave -noupdate -radix binary /tb_dealer/uut/dealer/ram_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {30000 ns}

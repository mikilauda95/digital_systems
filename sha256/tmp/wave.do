onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /sha256sim/s_clk
add wave -noupdate -radix hexadecimal /sha256sim/s_aresetn
add wave -noupdate -radix hexadecimal /sha256sim/s_valid_out
add wave -noupdate -radix hexadecimal /sha256sim/s_busy_out
add wave -noupdate -radix hexadecimal /sha256sim/CORRECT
add wave -noupdate -radix hexadecimal /sha256sim/s_new_mess
add wave -noupdate -radix hexadecimal /sha256sim/s_new_data
add wave -noupdate -radix hexadecimal /sha256sim/s_HASH
add wave -noupdate -radix hexadecimal /sha256sim/s_M_in
add wave -noupdate -radix hexadecimal /sha256sim/s_s_sigma0
add wave -noupdate -radix hexadecimal /sha256sim/s_s_sigma1
add wave -noupdate -radix hexadecimal /sha256sim/s_b_sigma0
add wave -noupdate -radix hexadecimal /sha256sim/s_b_sigma1
add wave -noupdate -radix hexadecimal /sha256sim/s_num_block
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/clk
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/aresetn
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/new_data
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/new_mess
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/M_in
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/HASH
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/busy
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/valid_out
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/count
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/M_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/HASH_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/H_next
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/H_next_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/H_prev
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/H_partial
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/W_in
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/enable
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/fill
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/CW
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/clk
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/aresetn
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/enable
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/new_block
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/count
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/W_in
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/H_prev
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/H_partial
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/a
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/b
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/c
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/d
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/e
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/f
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/g
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/h
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/a_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/b_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/c_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/d_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/e_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/f_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/g_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/h_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/CH_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/MAJ_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/K_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/T1
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/compression_0/T2
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/clk
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/aresetn
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/new_data
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/new_mess
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/H_prev
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/CW
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/count
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/H_start
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/count_it
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/endblock
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/enable
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/enable_i
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/busy
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/fill
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/CURR_STATE
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/NEXT_STATE
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/count_it_s
add wave -noupdate -radix hexadecimal /sha256sim/sha256_block_0/cu_0/count_block_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {54568 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {34927 ps} {195074 ps}

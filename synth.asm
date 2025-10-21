    .data 0x10010000
    # (no data needed)

    .text 0x00400000
    .globl main

main:
    # --- stack boiler?plate ---
    lui   $sp,0x1001
    ori   $sp,$sp,0x1000
    addi  $fp,$sp,-4

    # 1. Pass hardware sound reg addresses into Registers 
    #lui   $t0,0x1003
    #ori   $t0,$t0,0x0010        # t0 = 0x1003_0010 (period1) C
    #addi  $t7,$t0,4             # t7 = 0x1003_0014 (period2) C#
    #addi  $t8,$t7,4             # (D)  0018
    #addi  $t9,$t8,4             # (D#) 001C
    #addi  $s0,$t9,4             # (E) 0020
    #addi  $s1,$s0,4             # (F) 0024
    #addi  $s2,$s1,4             # (F#) 0028
    #addi  $s3,$s2,4             # (G) 002C
    #addi  $s4,$s3,4             # (G#) 0030
    #addi  $s5,$s4,4             # A) 0034
    #addi  $s6,$s5,4             # (A#) 0038
    #addi  $s7,$s6,4             #(B) 003C
    #addi  $a0,$s7,4            # (C2)  0040

    # 2. Silence all sound (pass 0 into sound registers)
    #sw    $zero,0($t0)          # C off
    #sw    $zero,0($t7)          # C# off
    #sw    $zero,0($t8) # D off 
    #sw    $zero,0($t9) #D#
    #sw    $zero,0($s0) #E
    #sw    $zero,0($s1) #F
    #sw    $zero,0($s2) #F#
    #sw    $zero,0($s3) #G
    #sw    $zero,0($s4) #G# 
    #sw    $zero,0($s5) #A
    #sw    $zero,0($s6) #A#
    #sw    $zero,0($s7) #B
    #sw    $zero,0($a0) #C2


main_loop:
    # 3. Read keyboard character (loop if none)
    lw    $t1,0x10030000        # read PS/2, $t1 stores 
    beqz  $t1,main_loop         # nothing ? poll again

    # 4. Check if key character is a Release (FXXX)
    andi  $t2,$t1,0xF000 # Pass in F or 0 (Release or Press)
    li    $t3,0xF000
    beq   $t2,$t3,key_up        # Branch if it's an F (key release)



# KEY PRESSES
# 5. Check lower 2 bits of key character, Branch to appropriate proc
key_down:
    andi  $t4,$t1,0x00FF        # low byte
    
    li    $t5,0x1C              # 'A' ? C
    beq   $t4,$t5,start_C
    
    li    $t5,0x1D              # 'W' ? C#
    beq   $t4,$t5,start_Cs
    
    li    $t5,0x1B              #  D  
    beq   $t4,$t5,start_D  #
    
    li    $t5,0x24              # D# 
    beq   $t4,$t5,start_Ds  #

    li    $t5,0x23              # E 
    beq   $t4,$t5,start_E  #
    
    li    $t5,0x2B              # F
    beq   $t4,$t5,start_F  #
    
    li    $t5,0x2C             # F# 
    beq   $t4,$t5,start_Fs  #
    
    li    $t5,0x34              #  G 
    beq   $t4,$t5,start_G  #
    
    li    $t5,0x35              # G#
    beq   $t4,$t5,start_Gs  #
    
    li    $t5,0x33              #  A 
    beq   $t4,$t5,start_A  #
    
    li    $t5,0x3C              #  A#
    beq   $t4,$t5,start_As  #
    
    li    $t5,0x3B              #  B 
    beq   $t4,$t5,start_B  #
    
    li    $t5,0x42              # C2
    beq   $t4,$t5,start_Ctwo  #
    
    j     main_loop             # any other key ignored


# 6. procs for key Presses. Stores the appropriate Period into the appropriate sound Address from Step #1. Then returns to main loop. 
start_C:                        # middle C
    lui   $t0,0x1003
    ori   $t0,$t0,0x0010       
    li    $t6,393419
    sw    $t6,0($t0)
# DRAWING 
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawC_rowtop:
    li    $a1,0              # col start = ???
drawC_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,2              # stop when col == ???
    ble   $a1,$t7,drawC_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawC_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawC_rowbottom:
    li    $a1,0       # start col = ???
drawC_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,3            # end col = ???
    ble   $a1,$t7,drawC_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawC_rowbottom
    j     main_loop#
    



start_Cs:                       # C?
    lui   $t0,0x1003
    ori   $t0,$t0,0x0014
    li    $t6,371338
    sw    $t6,0($t0)
#DRAWING
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawCs_row:
    li    $a1,3              # col = ???
drawCs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,6             # stop when col == ???
    blt   $a1,$t7,drawCs_col
    addi  $a2,$a2,1
    li    $t7,14              # stop when row == 14
    blt   $a2,$t7,drawCs_row
    j     main_loop#
    
    
    
start_D:                       # D 
    lui   $t0,0x1003
    ori   $t0,$t0,0x0018
    li    $t6,350497 # 
    sw    $t6,0($t0)# 
# DRAWING 
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawD_rowtop:
    li    $a1,6              # col = 6
drawD_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,7              # stop when col == 2
    ble   $a1,$t7,drawD_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawD_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawD_rowbottom:
    li    $a1,5             # start col = 5
drawD_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,8             # end col = 8
    ble   $a1,$t7,drawD_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawD_rowbottom
    j     main_loop#
    
    
    

start_Ds:                       # D#
    lui   $t0,0x1003
    ori   $t0,$t0,0x001C
    li    $t6,330825 # 
    sw    $t6,0($t0)# 
#DRAWING
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawDs_row:
    li    $a1,8              # col = ???
drawDs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,11              # stop when col == ???
    blt   $a1,$t7,drawDs_col
    addi  $a2,$a2,1
    li    $t7,14              # stop when row == 14
    blt   $a2,$t7,drawDs_row
    j     main_loop#


start_E:                       # E
    lui   $t0,0x1003
    ori   $t0,$t0,0x0020
    li    $t6,312257 # 
    sw    $t6,0($t0)# 
# DRAWING 
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawE_rowtop:
    li    $a1,11             # col start = ???
drawE_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,13              # stop when col == ???
    ble   $a1,$t7,drawE_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawE_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawE_rowbottom:
    li    $a1,10       # start col = ???
drawE_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,13            # end col = ???
    ble   $a1,$t7,drawE_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawE_rowbottom
    j     main_loop#


start_F:                       # F
    lui   $t0,0x1003
    ori   $t0,$t0,0x0024
    li    $t6,294731 # 
    sw    $t6,0($t0)# 
# DRAWING 
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawF_rowtop:
    li    $a1,15              # col start = ???
drawF_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,17             # stop when col == ???
    ble   $a1,$t7,drawF_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawF_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawF_rowbottom:
    li    $a1,15       # start col = ???
drawF_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,18            # end col = ???
    ble   $a1,$t7,drawF_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawF_rowbottom
    j     main_loop#


start_Fs:                       # F#
    lui   $t0,0x1003
    ori   $t0,$t0,0x0028
    li    $t6,278189 # 
    sw    $t6,0($t0)# 
#DRAWING
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawFs_row:
    li    $a1,18              # col = ???
drawFs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,21              # stop when col == ???
    blt   $a1,$t7,drawFs_col
    addi  $a2,$a2,1
    li    $t7,14              # stop when row == 14
    blt   $a2,$t7,drawFs_row
    j     main_loop#


start_G:                       # G
    lui   $t0,0x1003
    ori   $t0,$t0,0x002C
    li    $t6,262576 # 
    sw    $t6,0($t0)# 
# DRAWING 
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawG_rowtop:
    li    $a1,21              # col = ???
drawG_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,22              # stop when col == ???
    ble   $a1,$t7,drawG_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawG_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawG_rowbottom:
    li    $a1,20             # start col = ???
drawG_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,23             # end col = ???
    ble   $a1,$t7,drawG_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawG_rowbottom
    j     main_loop#


start_Gs:                       # G#
    lui   $t0,0x1003
    ori   $t0,$t0,0x0030
    li    $t6,247838 # 
    sw    $t6,0($t0)# 
#DRAWING
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawGs_row:
    li    $a1,23              # col = ???
drawGs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,26              # stop when col == ???
    blt   $a1,$t7,drawGs_col
    addi  $a2,$a2,1
    li    $t7,14              # stop when row == 14
    blt   $a2,$t7,drawGs_row
    j     main_loop#


start_A:                       # A
    lui   $t0,0x1003
    ori   $t0,$t0,0x0034
    li    $t6,233928 # 
    sw    $t6,0($t0)# 
# draw 
    li    $a0,2               # charcode = 0
    li    $a2,3               # row = 3
drawA_rowtop:
    li    $a1,26              # col start =  ???
drawA_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,27              # stop when col == ???
    ble   $a1,$t7,drawA_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawA_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawA_rowbottom:
    li    $a1,25             # start col = ???
drawA_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,28             # end col = ???
    ble   $a1,$t7,drawA_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawA_rowbottom
    j     main_loop#


start_As:                       # A#
    lui   $t0,0x1003
    ori   $t0,$t0,0x0038
    li    $t6,220799 # 
    sw    $t6,0($t0)# 
#DRAWING
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawAs_row:
    li    $a1,28              # col = ???
drawAs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,31              # stop when col == ???
    blt   $a1,$t7,drawAs_col
    addi  $a2,$a2,1
    li    $t7,14              # stop when row == 14
    blt   $a2,$t7,drawAs_row
    j     main_loop#
   


start_B:                       # B
    lui   $t0,0x1003
    ori   $t0,$t0,0x003C
    li    $t6,208406 # 
    sw    $t6,0($t0)# 
# DRAWING 
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawB_rowtop:
    li    $a1,31              # col start = ???
drawB_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,33             # stop when col == ???
    ble   $a1,$t7,drawB_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,drawB_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
drawB_rowbottom:
    li    $a1,30       # start col = ???
drawB_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,33            # end col = ???
    ble   $a1,$t7,drawB_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,drawB_rowbottom
    j     main_loop#


start_Ctwo:                       # C
    lui   $t0,0x1003
    ori   $t0,$t0,0x0040
    li    $t6,196710 # 
    sw    $t6,0($t0)# 
    
        # — draw red bar (sprite 1) cols 35–39, rows 3–26 —
    li    $a0,2               # charcode = 2 (solid?red sprite)
    li    $a2,3               # row = 3
drawCtwo_row:
    li    $a1,35              # col = 35
drawCtwo_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,40              # stop when col == 40
    blt   $a1,$t7,drawCtwo_col
    addi  $a2,$a2,1
    li    $t7,27              # stop when row == 27
    blt   $a2,$t7,drawCtwo_row
    j     main_loop#



# KEY RELEASES 

# 7. Check lower 2 bits of key character, Branch to appropriate proc
key_up:
    andi  $t4,$t1,0x00FF
    
    li    $t5,0x1C # C
    beq   $t4,$t5,stop_C
    
    li    $t5,0x1D # C#
    beq   $t4,$t5,stop_Cs
    
    li    $t5,0x1B # D 
    beq   $t4,$t5,stop_D #
    
    li    $t5,0x24 # D# 
    beq   $t4,$t5,stop_Ds #
    
    li    $t5,0x23 # E 
    beq   $t4,$t5,stop_E #
    
    li    $t5,0x2B # F 
    beq   $t4,$t5,stop_F #
    
    li    $t5,0x2C # F# 
    beq   $t4,$t5,stop_Fs #
    
    li    $t5,0x34 # G
    beq   $t4,$t5,stop_G #
    
    li    $t5,0x35 # G# 
    beq   $t4,$t5,stop_Gs #
    
    li    $t5,0x33 # A
    beq   $t4,$t5,stop_A #
    
    li    $t5,0x3C # A# 
    beq   $t4,$t5,stop_As #
    
    li    $t5,0x3B # B
    beq   $t4,$t5,stop_B #
    
    li    $t5,0x42 # C2 
    beq   $t4,$t5,stop_Ctwo #
    
    j     main_loop


# 8. procs for key Releases. Stores 0 (sound off) into the appropriate sound Address from Step #1. Then returns to main loop. 
stop_C:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0010   
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode = 0
    li    $a2,3               # row = 3
eraseC_rowtop:
    li    $a1,0              # col start =  ???
eraseC_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,2              # stop when col == ???
    ble   $a1,$t7,eraseC_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseC_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseC_rowbottom:
    li    $a1,0             # start col = ???
eraseC_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,3             # end col = ???
    ble   $a1,$t7,eraseC_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseC_rowbottom
    j     main_loop#
    
    
    
    
stop_Cs:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0014
    sw    $zero,0($t0)
# ERASE
    li    $a0,1               # charcode = 0 (blank)
    li    $a2,3 # row start
eraseCs_row:
    li    $a1,3 # COL START = ?
eraseCs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,6 # COL END = ?
    blt   $a1,$t7,eraseCs_col
    addi  $a2,$a2,1
    li    $t7,14 # row end
    blt   $a2,$t7,eraseCs_row
    j     main_loop



stop_D:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0018
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode =0
    li    $a2,3               # row = 3
eraseD_rowtop:
    li    $a1,6              # col = 6
eraseD_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,7              # stop when col == 2
    ble   $a1,$t7,eraseD_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseD_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseD_rowbottom:
    li    $a1,5             # start col = 5
eraseD_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,8             # end col = 8
    ble   $a1,$t7,eraseD_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseD_rowbottom
    j     main_loop#

    
    
    
stop_Ds:
    lui   $t0,0x1003
    ori   $t0,$t0,0x001C
    sw    $zero,0($t0)
# ERASE
    li    $a0,1               # charcode = 0 (blank)
    li    $a2,3 # row start
eraseDs_row:
    li    $a1,8 # COL START = ?
eraseDs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,11 # COL END = ?
    blt   $a1,$t7,eraseDs_col
    addi  $a2,$a2,1
    li    $t7,14 # row end
    blt   $a2,$t7,eraseDs_row
    j     main_loop
    
stop_E:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0020
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode = 0
    li    $a2,3               # row = 3
eraseE_rowtop:
    li    $a1,11             # col start =  ???
eraseE_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,13              # stop when col == ???
    ble   $a1,$t7,eraseE_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseE_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseE_rowbottom:
    li    $a1,10             # start col = ???
eraseE_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,13             # end col = ???
    ble   $a1,$t7,eraseE_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseE_rowbottom
    j     main_loop#
    
stop_F:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0024
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode = 0
    li    $a2,3               # row = 3
eraseF_rowtop:
    li    $a1,15              # col start =  ???
eraseF_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,17              # stop when col == ???
    ble   $a1,$t7,eraseF_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseF_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseF_rowbottom:
    li    $a1,15             # start col = ???
eraseF_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,18             # end col = ???
    ble   $a1,$t7,eraseF_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseF_rowbottom
    j     main_loop#
    
stop_Fs:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0028
    sw    $zero,0($t0)
# ERASE
    li    $a0,1               # charcode = 0 (blank)
    li    $a2,3 # row start
eraseFs_row:
    li    $a1,18 # COL START = ?
eraseFs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,21 # COL END = ?
    blt   $a1,$t7,eraseFs_col
    addi  $a2,$a2,1
    li    $t7,14 # row end
    blt   $a2,$t7,eraseFs_row
    j     main_loop
    
stop_G:
    lui   $t0,0x1003
    ori   $t0,$t0,0x002C
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode = 0
    li    $a2,3               # row = 3
eraseG_rowtop:
    li    $a1,21              # col start =  ???
eraseG_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,22              # stop when col == ???
    ble   $a1,$t7,eraseG_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseG_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseG_rowbottom:
    li    $a1,20             # start col = ???
eraseG_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,23             # end col = ???
    ble   $a1,$t7,eraseG_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseG_rowbottom
    j     main_loop#
    
stop_Gs:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0030
    sw    $zero,0($t0)
# ERASE
    li    $a0,1               # charcode = 0 (blank)
    li    $a2,3 # row start
eraseGs_row:
    li    $a1,23 # COL START = ?
eraseGs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,26 # COL END = ?
    blt   $a1,$t7,eraseGs_col
    addi  $a2,$a2,1
    li    $t7,14 # row end
    blt   $a2,$t7,eraseGs_row
    j     main_loop
    
stop_A:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0034
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode = 0
    li    $a2,3               # row = 3
eraseA_rowtop:
    li    $a1,26              # col start =  ???
eraseA_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,27              # stop when col == ???
    ble   $a1,$t7,eraseA_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseA_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseA_rowbottom:
    li    $a1,25             # start col = ???
eraseA_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,28             # end col = ???
    ble   $a1,$t7,eraseA_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseA_rowbottom
    j     main_loop#

    
stop_As:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0038
    sw    $zero,0($t0)
# ERASE
    li    $a0,1               # charcode = 0 (blank)
    li    $a2,3 # row start
eraseAs_row:
    li    $a1,28 # COL START = ?
eraseAs_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,31 # COL END = ?
    blt   $a1,$t7,eraseAs_col
    addi  $a2,$a2,1
    li    $t7,14 # row end
    blt   $a2,$t7,eraseAs_row
    j     main_loop
    
stop_B:
    lui   $t0,0x1003
    ori   $t0,$t0,0x003C
    sw    $zero,0($t0)
# ERASING 
    li    $a0,0               # charcode = 0
    li    $a2,3               # row = 3
eraseB_rowtop:
    li    $a1,31              # col start =  ???
eraseB_coltop:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,33              # stop when col == ???
    ble   $a1,$t7,eraseB_coltop
    addi  $a2,$a2,1
    li    $t8,14              # stop when row == 14
    blt   $a2,$t8,eraseB_rowtop
    # bottom half: rows 14…26, cols 5…8
    li    $a2,14            # row = 14
eraseB_rowbottom:
    li    $a1,30             # start col = ???
eraseB_colbottom:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,33             # end col = ???
    ble   $a1,$t7,eraseB_colbottom
    addi  $a2,$a2,1
    li    $t8,27            # stop before row 27
    blt   $a2,$t8,eraseB_rowbottom
    j     main_loop#
    
stop_Ctwo:
    lui   $t0,0x1003
    ori   $t0,$t0,0x0040
    sw    $zero,0($t0)
    
        # — erase red bar (sprite 0) —
    li    $a0,0               # charcode = 0 (blank)
    li    $a2,3
eraseCtwo_row:
    li    $a1,35
eraseCtwo_col:
    jal   putChar_atXY
    addi  $a1,$a1,1
    li    $t7,40
    blt   $a1,$t7,eraseCtwo_col
    addi  $a2,$a2,1
    li    $t7,27
    blt   $a2,$t7,eraseCtwo_row

    j     main_loop


# (never reached)
end:
    j end

.include "procs_board.asm"

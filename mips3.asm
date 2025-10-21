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
    lui   $t0,0x1003
    ori   $t0,$t0,0x0010        # t0 = 0x1003_0010 (period1) C
    addi  $t7,$t0,4             # t7 = 0x1003_0014 (period2) C#
    addi  $t8,$t7,4             # (D)  0018
    addi  $t9,$t8,4             # (D#) 001C
    addi  $s0,$t9,4             # (E) 0020
    addi  $s1,$s0,4             # (F) 0024
    addi  $s2,$s1,4             # (F#) 0028
    addi  $s3,$s2,4             # (G) 002C
    addi  $s4,$s3,4             # (G#) 0030
    addi  $s5,$s4,4             # A) 0034
    addi  $s6,$s5,4             # (A#) 0038
    addi  $s7,$s6,4             #(B) 003C
    addi  $a0,$s7,4            # (C2)  0040

    # 2. Silence all sound (pass 0 into sound registers)
    sw    $zero,0($t0)          # C off
    sw    $zero,0($t7)          # C# off
    sw    $zero,0($t8) # D off 
    sw    $zero,0($t9) #D#
    sw    $zero,0($s0) #E
    sw    $zero,0($s1) #F
    sw    $zero,0($s2) #F#
    sw    $zero,0($s3) #G
    sw    $zero,0($s4) #G# 
    sw    $zero,0($s5) #A
    sw    $zero,0($s6) #A#
    sw    $zero,0($s7) #B
    sw    $zero,0($a0) #C2


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
    li    $t6,393419
    sw    $t6,0($t0)
    j     main_loop

start_Cs:                       # C?
    li    $t6,371338
    sw    $t6,0($t7)
    j     main_loop
    
start_D:                       # D 
    li    $t6,350497 # 
    sw    $t6,0($t8)# 
    j     main_loop#

start_Ds:                       # D#
    li    $t6,330825 # 
    sw    $t6,0($t9)# 
    j     main_loop#


start_E:                       # E
    li    $t6,312257 # 
    sw    $t6,0($s0)# 
    j     main_loop#


start_F:                       # F
    li    $t6,294731 # 
    sw    $t6,0($s1)# 
    j     main_loop#


start_Fs:                       # F#
    li    $t6,278189 # 
    sw    $t6,0($s2)# 
    j     main_loop#


start_G:                       # G
    li    $t6,262576 # 
    sw    $t6,0($s3)# 
    j     main_loop#


start_Gs:                       # G#
    li    $t6,247838 # 
    sw    $t6,0($s4)# 
    j     main_loop#


start_A:                       # A
    li    $t6,233928 # 
    sw    $t6,0($s5)# 
    j     main_loop#


start_As:                       # A#
    li    $t6,220799 # 
    sw    $t6,0($s6)# 
    j     main_loop#


start_B:                       # B
    li    $t6,208406 # 
    sw    $t6,0($s7)# 
    j     main_loop#


start_Ctwo:                       # C
    li    $t6,196710 # 
    sw    $t6,0($a0)# 
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
    sw    $zero,0($t0)
    j     main_loop

stop_Cs:
    sw    $zero,0($t7)
    j     main_loop

stop_D:
    sw    $zero,0($t8)
    j     main_loop
    
stop_Ds:
    sw    $zero,0($t9)
    j     main_loop
    
stop_E:
    sw    $zero,0($s0)
    j     main_loop
    
stop_F:
    sw    $zero,0($s1)
    j     main_loop
    
stop_Fs:
    sw    $zero,0($s2)
    j     main_loop
    
stop_G:
    sw    $zero,0($s3)
    j     main_loop
    
stop_Gs:
    sw    $zero,0($s4)
    j     main_loop
    
stop_A:
    sw    $zero,0($s5)
    j     main_loop
    
stop_As:
    sw    $zero,0($s6)
    j     main_loop
    
stop_B:
    sw    $zero,0($s7)
    j     main_loop
    
stop_Ctwo:
    sw    $zero,0($a0)
    j     main_loop

# (never reached)
end:
    j end

.include "procs_board.asm"

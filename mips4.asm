#####################################################################
# 5?note test – C C? D D? E
# Uses period1..period5 already in hardware
#####################################################################

    .data 0x10010000
    # (no data needed)

    .text 0x00400000
    .globl main

main:
    # --- stack boiler?plate ---
    lui   $sp,0x1001
    ori   $sp,$sp,0x1000
    addi  $fp,$sp,-4

    # --- generator addresses ---
    lui   $t0,0x1003
    ori   $t0,$t0,0x0010        # t0 = period1  (C)
    addi  $t7,$t0,4             # t7 = period2  (C#)
    addi  $t8,$t7,4             # t8 = period3  (D)
    # addi  $t9,$t8,4             # t9 = period4  (D#)
    # addi  $s0,$t9,4             # s0 = period5  (E)

    # --- silence on startup ---
    sw    $zero,0($t0)
    sw    $zero,0($t7)
    sw    $zero,0($t8)
    # sw    $zero,0($t9)
    # sw    $zero,0($s0)

#####################################################################
# main polling loop
#####################################################################
main_loop:
    lw    $t1,0x10030000        # read PS/2 FIFO
    beqz  $t1,main_loop         # nothing ? poll again
    andi  $t1,$t1,0x00FF        # keep it 8?bit

    # -------- handle optional F0 prefix --------
    li    $t2,0xF0
    bne   $t1,$t2,have_code
        # first byte is 0xF0 -> read second byte, flag=BREAK
        lw   $t1,0x10030000
        andi $t1,$t1,0x00FF
        li   $t6,1              # break flag
        b    decide
have_code:
    li   $t6,0                  # make flag
decide:
    bnez $t6,key_up             # 1 = break, 0 = make

# ------------- make -------------
key_down:
    li    $t5,0x1C              # 'A' ? C
    beq   $t1,$t5,start_C
    li    $t5,0x1D              # 'W' ? C#
    beq   $t1,$t5,start_Cs
    li    $t5,0x1B              # 'S' ? D
    beq   $t1,$t5,start_D
    li    $t5,0x24              # 'E' ? D#
    beq   $t1,$t5,start_Ds
    li    $t5,0x23              # 'D' ? E
    beq   $t1,$t5,start_E
    j     main_loop

start_C:    
    li $t3,393419
    sw $t3,0($t0)
    j main_loop
start_Cs:   li $t3,371338; sw $t3,0($t7); j main_loop
start_D:    li $t3,350497; sw $t3,0($t8); j main_loop
start_Ds:   li $t3,330825; sw $t3,0($t9); j main_loop
start_E:    li $t3,312257; sw $t3,0($s0); j main_loop

# ------------- break -------------
key_up:
    li    $t5,0x1C
    beq   $t1,$t5,stop_C
    li    $t5,0x1D
    beq   $t1,$t5,stop_Cs
    li    $t5,0x1B
    beq   $t1,$t5,stop_D
    li    $t5,0x24
    beq   $t1,$t5,stop_Ds
    li    $t5,0x23
    beq   $t1,$t5,stop_E
    j     main_loop

stop_C:   sw $zero,0($t0); j main_loop
stop_Cs:  sw $zero,0($t7); j main_loop
stop_D:   sw $zero,0($t8); j main_loop
stop_Ds:  sw $zero,0($t9); j main_loop
stop_E:   sw $zero,0($s0); j main_loop

# never reached
end: j end

.include "procs_board.asm"

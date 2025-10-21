    .data 0x10010000
    # (no data needed)

    .text 0x00400000
    .globl main

main:
    # — Stack setup (template boilerplate) —
    lui   $sp, 0x1001
    ori   $sp, $sp, 0x1000
    addi  $fp, $sp, -4
    
    

    # — Silence on startup —
    lui   $t0, 0x1003
    ori   $t0, $t0, 0x0010   # address = 0x1003_0010 (period1)
    sw    $zero, 0($t0)

main_loop:
    # 1) Read raw PS/2 code
    lw    $t1, 0x10030000
    beqz  $t1, main_loop     # if no event, keep polling

    # 2) Mask high nibble to detect "break" (0xF000) vs "make"
    andi  $t2, $t1, 0xF000
    li    $t3, 0xF000
    beq   $t2, $t3, key_up   # if high nibble == F ? release
    # else it’s a make (press)

key_down:
    # isolate low byte
    andi  $t4, $t1, 0x00FF
    li    $t5, 0x1C          # scancode for A (middle C)
    bne   $t4, $t5, main_loop# if not A, ignore
    # it is A-down: start tone
    li    $t6, 393419        # period for middle C
    sw    $t6, 0($t0)
    j     main_loop

key_up:
    # isolate low byte
    andi  $t4, $t1, 0x00FF
    li    $t5, 0x1C          # scancode for A up also has low byte 0x1C
    bne   $t4, $t5, main_loop# if not A, ignore
    # it is A-up: stop tone
    sw    $zero, 0($t0)
    j     main_loop

# (never reach here)
end:
    j     end

    .include "procs_board.asm"

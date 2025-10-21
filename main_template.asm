# =============================================================
# main PROCEDURE TEMPLATE # 4b
#
# Use with "proc_template.asm" as the template for other procedures
#
# Based on "Ex4b" of Lecture 9 (Procedures and Stacks) of COMP411 Spring 2020
#   (main is simpler than other procedures because it does not have to
#     clean up anything before exiting)
#
# Assumptions:
#
#   - main calls other procedures with no more than 4 arguments ($a0-$a3)
#   - any local variables needed are put into registers (not memory)
#   - no values are put in temporaries that must be preserved across a call from main
#       to another procedure
#
# =============================================================

.data 0x10010000                # Start of data memory
#
# declare global variables here


.text 0x00400000                # Start of instruction memory
.globl main

main:
    lui     $sp, 0x1001         # Initialize stack pointer to the 1024th location above start of data
    ori     $sp, $sp, 0x1000    # top of the stack will be one word below
                                #   because $sp is decremented first.
                                # $sp = 0x1001_1000 (top of stack)
    addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame



    # =============================================================
    # No need to create room for temporaries to be protected.
    # =============================================================




    # =============================================================
    # BODY OF main
    # ...
    # ...
    # ...
    # ... CODE FOR main HERE
        
            # =====================================================
            # main CALLS proc1
            #
            # Suppose main needs to call proc1, but there are no
            #   temporaries that need to be protected for this call.
            #
            # Suppose there are four arguments to send to proc1:
            #   (0, 10, 20, 30).  Here's how to do it.

            ori     $a0, $0,  0     # Put  0 in $a0
            ori     $a1, $0, 10     # Put 10 in $a1
            ori     $a2, $0, 20     # Put 20 in $a2
            ori     $a3, $0, 30     # Put 30 in $a3

            jal     proc1           # call proc1
                                    # valued returned by proc1 will be in $v0-$v1

            # =====================================================
            

    # ... MORE CODE FOR main HERE
    # ...
    # ...
    # END OF BODY OF main
    # =============================================================



exit_from_main:

    ###############################
    # END using infinite loop     #
    ###############################

                        # program may not reach here, but have it for safety
end:
    j   end             # infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################



.include "procs_board.asm"          # include file with helpful procedures


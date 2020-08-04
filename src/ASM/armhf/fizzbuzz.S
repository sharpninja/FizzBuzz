# FizzBuzz Implementation in ARMF ASM For Linux
# matthew - October 26, 2019
# 
# "Write a program that prints the numbers from 1 to 100. But for multiples of three print 
# "Fizz" instead of the number and for the multiples of five print "Buzz". For numbers which 
# are multiples of both three and five print "FizzBuzz"."

.global _start
        .func _start

_start:
        push {LR}
        mov R7, #1

loop:
        mov R6, #0
        mov R0, R7
        mov R1, #3
        bl __aeabi_uidivmod
        cmp R1, #0
        bne checkBuzz

printFizz:
        mov R6, #1
        ldr R0, =fizz
        bl printf

checkBuzz:
        mov R0, R7
        mov R1, #5
        bl __aeabi_uidivmod
        cmp R1, #0
        bne printNumber

printBuzz:
        mov R6, #1
        ldr R0, =buzz
        bl printf

printNumber:
        cmp R6, #0
        bne endLoop

	mov R1, R7
        ldr R0, =integer
        bl printf

endLoop:
        ldr R0, =newLine
        bl printf

        add R7, R7, #1
        cmp R7, #101
        blne loop
exitProgram:
        pop {LR}
        mov R0, #0
        bl exit

.data
fizz:
        .asciz "Fizz"
buzz:
        .asciz "Buzz"
integer:
        .asciz "%u"
newLine:
        .byte 10, 0

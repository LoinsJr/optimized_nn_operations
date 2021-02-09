push_callee_saved_regs macro
    push  r15
    push  r14
    push  r13
    push  r12
    push  r11
    push  r10
    push  rbx
    push  rsi
    push  rdi
endm

pop_callee_saved_regs macro
    pop   rdi
    pop   rsi
    pop   rbx
    pop   r10
    pop   r11
    pop   r12
    pop   r13
    pop   r14
    pop   r15
endm
.code

include macros.inc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void reorder_6_rows(float *src_rows = R10, const uint32_t width = EDX,        ;;
;;                     const uint64_t width_real = R11, float *dst_matrix = R12) ;;
;; Uses RAX, RCX, RSI, R13                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reorder_6_rows proc
    mov    ecx,    edx
    mov    r13,    r10
loop_head:
    mov    r10,    r13
    mov    eax,    [r10]
    mov    [r12],  eax
    mov    esi,    [r10 + r11]
    mov    [r12 + 4],      esi
    lea    r10,    [r10 + 2 * r11]
    mov    eax,    [r10]
    mov    [r12 + 8],      eax
    mov    esi,    [r10 + r11]
    mov    [r12 + 12],     esi
    lea    r10,    [r10 + 2 * r11]
    mov    eax,    [r10]
    mov    [r12 + 16],     eax
    mov    esi,    [r10 + r11]
    mov    [r12 + 20],     esi
    lea    r12,    [r12 + 24]
    add    r13,    4
    sub    ecx,    1
    jnz    loop_head
    ret
reorder_6_rows endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void reorder_4_rows(float *src_rows = R10, const uint32_t width = EDX,        ;;
;;                     const uint64_t width_real = R11, float *dst_matrix = R12) ;;
;; Uses RAX, RCX, RSI, R13                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reorder_4_rows proc
    mov    ecx,    edx
    mov    r13,    r10
loop_head:
    mov    r10,    r13
    mov    eax,    [r10]
    mov    [r12],  eax
    mov    esi,    [r10 + r11]
    mov    [r12 + 4],      esi
    lea    r10,    [r10 + 2 * r11]
    mov    eax,    [r10]
    mov    [r12 + 8],      eax
    mov    esi,    [r10 + r11]
    mov    [r12 + 12],     esi
    lea    r12,    [r12 + 16]
    add    r13,    4
    sub    ecx,    1
    jnz    loop_head
    ret
reorder_4_rows endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void reorder_2_rows(float *src_rows = R10, const uint32_t width = EDX,        ;;
;;                     const uint64_t width_real = R11, float *dst_matrix = R12) ;;
;; Uses RAX, RCX, RSI, R13                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reorder_2_rows proc
    mov    ecx,    edx
loop_head:
    mov    eax,    [r10]
    mov    [r12],  eax
    mov    esi,    [r10 + r11]
    mov    [r12 + 4],      esi
    lea    r10,    [r10 + 4]
    add    r12,    8
    sub    ecx,    1
    jnz    loop_head
    ret
reorder_2_rows endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void reorder_1_row(float *src_rows = R10, const uint32_t width = EDX,         ;;
;;                     const uint64_t width_real = R11, float *dst_matrix = R12) ;;
;; Uses RAX, RCX, RSI, R13                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reorder_1_row proc
    mov    ecx,    edx
loop_head:
    mov    eax,    [r10]
    mov    [r12],  eax
    lea    r10,    [r10 + 4]
    lea    r12,    [r12 + 4]
    sub    ecx,    1
    jnz    loop_head
    ret
reorder_1_row endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void reorder_src_matrix1_debug(float *src_matrix, uint32_t height,           ;;
;;                      uint32_t width, uint64_t width_real, float *dst_matrix) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reorder_src_matrix1_debug proc
    push   rbp
    mov    rbp,    rsp
    push_callee_saved_regs
    mov    ebx,    edx
    mov    edx,    r8d
    mov    r11,    r9
    mov    r14,    rdx
    shl    r14,    2
    mov    r10,     rcx
    mov    r12,     [rbp + 48]
    sub    ebx,     6
    jb     reorder_4
loop_head_h:
    call   reorder_6_rows
    lea    r10,    [r10 + r11 + 35]
    and    r10,    -32
    mov    rax,    r10
    sub    ebx,    6
    jae    loop_head_h
reorder_4:
    cmp    ebx,    -2
    jl     reorder_2
    call   reorder_4_rows
    lea    r10,    [r10 + r11 + 35]
    and    r10,    -32
    sub    ebx,    4
reorder_2:
    test   ebx,    2
    jnz    reorder_1
    call   reorder_2_rows
    lea    r10,    [r10 + r11 + 35]
    and    r10,    -32
    sub    ebx,    2
reorder_1:
    test   ebx,    1
    jz     exit
    call   reorder_1_row
exit:
    pop_callee_saved_regs
    leave
    ret
reorder_src_matrix1_debug endp

end
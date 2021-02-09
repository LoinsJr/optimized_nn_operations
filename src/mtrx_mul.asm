data segment align(32)
order dd 0, 7, 6, 5, 4, 3, 2, 1
data ends

include macros.inc

extern buffer : qword

.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void fill_buffer_16(float *src_matrix2 = R10, uint32_t src_matrix1_w = ESI,  ;;
;;                     uint32_t src_matrix2_w_real = EBX, float *buffer = RAX)  ;;
;;                                                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_buffer_16 proc
fill_buffer_16_loop_head:
    vmovaps        ymm0,   [r10]           ; 5 B
    vmovaps        [rax],  ymm0            ; 4 B
    vmovaps        ymm1,   [r10 + 32]      ; 6 B
    vmovaps        [rax + 32],     ymm1    ; 5 B
    lea    r10,    [r10 + rbx]             ; 4 B ?
    lea    rax,    [rax + 64]              ; 4 B
    sub    esi,    1                       ; 4 B
    jne    fill_buffer_16_loop_head
    ret
fill_buffer_16 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void fill_buffer_8(float *src_matrix2 = R10, uint32_t src_matrix2_h = ESI,  ;;
;;                     uint32_t src_matrix2_w_real = EBX, float *buffer = RAX) ;;
;;                                                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_buffer_8 proc
    sub    esi,    2
    jb     fill_last_row
fill_buffer_8_loop_head:
    vmovaps        ymm0,   [r10]           ; 5 B
    lea    r10,    [r10 + rbx]
    vmovaps        [rax],  ymm0            ; 4 B
    vmovaps        ymm1,   [r10]           ; 6 B
    vmovaps        [rax + 32],     ymm1    ; 5 B
    lea    rax,    [rax + 64]              ; 4 B
    lea    r10,    [r10 + rbx]
    sub    esi,    2                       ; 4 B
    jne    fill_buffer_8_loop_head
fill_last_row:
    vmovaps        ymm2,   [r10]
    vmovaps        [rax],  ymm2
    ret
fill_buffer_8 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_6x16(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D, ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_6x16 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    vxorps ymm4,   ymm4,   ymm4
    vxorps ymm5,   ymm5,   ymm5
    vxorps ymm6,   ymm6,   ymm6
    vxorps ymm7,   ymm7,   ymm7
    vxorps ymm8,   ymm8,   ymm8
    vxorps ymm9,   ymm9,   ymm9
    vxorps ymm10,  ymm10,  ymm10
    vxorps ymm11,  ymm11,  ymm11
    mov    rax,    r10
count_kernel_6x16_loop_head:
    vmovaps        ymm13,  [r12]
    vmovaps        ymm14,  [r12 + 32]
    lea    rax,    [rax + 4]
    vbroadcastss   ymm12,   dword ptr [r10]
    add    r10,    r11
    vfmadd231ps    ymm0,  ymm12, ymm13
    vfmadd231ps    ymm1,  ymm12, ymm14
    vbroadcastss   ymm15, dword ptr [r10]
    lea    r10,    [r10 + r11]
    vfmadd231ps    ymm2,  ymm15, ymm13
    vfmadd231ps    ymm3,  ymm15, ymm14
    vbroadcastss   ymm12, dword ptr [r10]
    lea    r10,    [r10 + r11]
    vfmadd231ps    ymm4,  ymm12, ymm13
    vfmadd231ps    ymm5,  ymm12, ymm14
    vbroadcastss   ymm15,  dword ptr [r10]
    lea    r10,    [r10 + r11]
    vfmadd231ps    ymm6,  ymm15, ymm13
    vfmadd231ps    ymm7,  ymm15, ymm14
    vbroadcastss   ymm12,  dword ptr [r10]
    lea    r10,    [r10 + r11]
    vfmadd231ps    ymm8,  ymm12, ymm13
    vfmadd231ps    ymm9,  ymm12, ymm14
    vbroadcastss   ymm15,  dword ptr [r10]
    mov    r10,    rax
    vfmadd231ps    ymm10, ymm15, ymm13
    vfmadd231ps    ymm11, ymm15, ymm14
    lea    r12,    [r12 + 64]
    sub    esi,    1
    jne    count_kernel_6x16_loop_head
    vmovaps        [r13], ymm0
    vmovaps        [r13 + 32],   ymm1
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm2
    vmovaps        [r13 + 32],   ymm3
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm4
    vmovaps        [r13 + 32],   ymm5
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm6
    vmovaps        [r13 + 32],   ymm7
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm8
    vmovaps        [r13 + 32],   ymm9
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm10
    vmovaps        [r13 + 32],   ymm11
    lea    r13,    [r13 + rbx]
    ret
count_kernel_6x16 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_4x16(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D, ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_4x16 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    vxorps ymm4,   ymm4,   ymm4
    vxorps ymm5,   ymm5,   ymm5
    vxorps ymm6,   ymm6,   ymm6
    vxorps ymm7,   ymm7,   ymm7
    mov    rax,    r10
count_kernel_4x16_loop_head:
    vmovaps        ymm9,   [r12]
    vmovaps        ymm10,  [r12 + 32]
    lea    rax,    [rax + 4]
    vbroadcastss   ymm8,   dword ptr [r10]
    add    r10,    r11
    vfmadd231ps    ymm0,  ymm8,  ymm9
    vfmadd231ps    ymm1,  ymm8,  ymm10
    vbroadcastss   ymm11,  dword ptr [r10]
    lea    r10,    [r10 + r11]
    vfmadd231ps    ymm2,  ymm11, ymm9
    vfmadd231ps    ymm3,  ymm11, ymm10
    vbroadcastss   ymm8,  dword ptr [r10]
    lea    r10,    [r10 + r11]
    vfmadd231ps    ymm4,  ymm8,  ymm9
    vfmadd231ps    ymm5,  ymm8,  ymm10
    vbroadcastss   ymm11,  dword ptr [r10]
    mov    r10,    rax
    vfmadd231ps    ymm6,  ymm11, ymm9
    vfmadd231ps    ymm7,  ymm11, ymm10
    lea    r12,    [r12 + 64]
    sub    esi,    1
    jne    count_kernel_4x16_loop_head
    vmovaps        [r13], ymm0
    vmovaps        [r13 + 32],   ymm1
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm2
    vmovaps        [r13 + 32],   ymm3
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm4
    vmovaps        [r13 + 32],   ymm5
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm6
    vmovaps        [r13 + 32],   ymm7
    lea    r13,    [r13 + rbx]
    ret
count_kernel_4x16 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_2x16(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D, ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_2x16 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    mov    rax,    r10
count_kernel_2x16_loop_head:
    vmovaps        ymm9,   [r12]
    vmovaps        ymm10,  [r12 + 32]
    lea    rax,    [rax + 4]
    vbroadcastss   ymm8,   dword ptr [r10]
    add    r10,    r11
    vfmadd231ps    ymm0,  ymm8,  ymm9
    vfmadd231ps    ymm1,  ymm8,  ymm10
    vbroadcastss   ymm11,  dword ptr [r10]
    mov    r10,    rax
    vfmadd231ps    ymm2,  ymm11, ymm9
    vfmadd231ps    ymm3,  ymm11, ymm10
    lea    r12,    [r12 + 64]
    sub    esi,    1
    jne    count_kernel_2x16_loop_head
    vmovaps        [r13], ymm0
    vmovaps        [r13 + 32],   ymm1
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm2
    vmovaps        [r13 + 32],   ymm3
    lea    r13,    [r13 + rbx]
    ret
count_kernel_2x16 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_1x16(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D, ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;                                                                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_1x16 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
count_kernel_1x16_loop_head:
    vmovaps        ymm9,   [r12]
    vmovaps        ymm10,  [r12 + 32]
    vbroadcastss   ymm8,   dword ptr [r10]
    add    r10,    4
    vfmadd231ps    ymm0,  ymm8,  ymm9
    vfmadd231ps    ymm1,  ymm8,  ymm10
    lea    r12,    [r12 + 64]
    sub    esi,    1
    jne    count_kernel_1x16_loop_head
    vmovaps        [r13], ymm0
    vmovaps        [r13 + 32],   ymm1
    lea    r13,    [r13 + rbx]
    ret
count_kernel_1x16 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void mtrx_mul(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w, ;;
;;                 float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix)    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mtrx_mul proc
    push   rbp                     ; 1 B
    mov    rbp,    rsp             ; 3 B
    push   r15                     ; 2 B
    push   r14                     ; 2 B
    push   r13                     ; 2 B
    push   r12                     ; 2 B
    push   r11                     ; 2 B
    push   r10                     ; 2 B
    push   rbx                     ; 1 B
    push   rsi                     ; 1 B
    push   rdi                     ; 1 B
    mov    [rbp + 24],     edx     ; 3 B
    mov    ebx,    [rbp + 48]      ; 3 B
    mov    edx,    r8d             ; 3 B
    mov    esi,    r8d             ; 3 B
    add    r8d,    7               ; 4 B
    add    ebx,    7               ; 3 B
    mov    r15,    [rbp + 56]      ; 4 B
    and    r8d,    -8              ; 4 B
    and    ebx,    -8              ; 3 B
    shl    r8d,    2               ; 4 B
    shl    ebx,    2               ; 3 B
    mov    r11d,   r8d             ; 3 B
    mov    r8,     rcx             ; 3 B
    mov    ecx,    ebx             ; 3 B
    ; R8 - src_matrix1
    ; R9 - src_matrix2
    ; [RBP + 24] - src_matrix1_h
    ; EDX - src_matrix1_w
    ; EBX - next multiply of 32 after 4 * src_matrix2_w (invariant)
    ; R11D - next multiply of 32 after 4 * src_matrix1_w (invariant)
    ; R15 - dst_matrix
    sub    ecx,    64
    jb     kernels_Yx8
loop_head_w2:
    mov    rax,    buffer          ; 7 B
    mov    r10,    r9              ; 3 B
    mov    esi,    edx             ; 2 B
    call   fill_buffer_16
    mov    edi,    [rbp + 24]      ;
    mov    r14,    r8              ; 
    mov    r13,    r15             ; 
    add    r15,    64              ; 
    sub    edi,    6
    jb     kernel_4x16
loop_head_h1_6x16:
    mov    r12,    buffer          ; 
    mov    r10,    r14             ; 3 B
    mov    esi,    edx             ;
    lea    r14,    [r14 + 4 * r11] ;
    lea    r14,    [r14 + 2 * r11] ;
    call   count_kernel_6x16
    sub    edi,    6               ;
    jae    loop_head_h1_6x16       ;
kernel_4x16:
    cmp    edi,    -2
    jl     kernel_2x16
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    lea    r14,    [r14 + 4 * r11]
    call   count_kernel_4x16
kernel_2x16:
    test   edi,    2
    jnz    kernel_1x16
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    lea    r14,    [r14 + 2 * r11] ;
    call   count_kernel_2x16
kernel_1x16:
    test   edi,    1
    jz     next_16
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    call   count_kernel_1x16
next_16:
    lea    r9,     [r9 + 64]       ;
    sub    ecx,    64              ; 3 B
    jae    loop_head_w2            ;
kernels_Yx8:
    ;mov    rax,    buffer          ; 7 B
    ;mov    r10,    r9              ; 3 B
    ;mov    esi,    edx             ; 2 B
    ;call   fill_buffer_8
    ;mov    edi,    [rbp + 24]
exit:
    pop_callee_saved_regs
    leave
    ret
mtrx_mul endp

end
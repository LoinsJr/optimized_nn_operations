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
    vmovaps        ymm0,   [r10]
    vmovaps        [rax],  ymm0
    vmovaps        ymm1,   [r10 + 32]
    vmovaps        [rax + 32],     ymm1
    lea    r10,    [r10 + rbx]
    lea    rax,    [rax + 64]
    sub    esi,    1
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
    vmovaps        ymm0,   [r10]
    lea    r10,    [r10 + rbx]
    vmovaps        [rax],  ymm0
    vmovaps        ymm1,   [r10]
    vmovaps        [rax + 32],     ymm1
    lea    rax,    [rax + 64]
    lea    r10,    [r10 + rbx]
    sub    esi,    2
    jae    fill_buffer_8_loop_head
fill_last_row:
    cmp    esi,    -2
    je     exit
    vmovaps        ymm2,   [r10]
    vmovaps        [rax],  ymm2
exit:
    ret
fill_buffer_8 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_6x16(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D, ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_6x16 proc
    mov    rax,    r10
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
count_kernel_6x16_loop_head:
    vbroadcastss   ymm12,  dword ptr [r10]
    vmovaps        ymm13,  [r12]
    vfmadd231ps    ymm0,   ymm12,  ymm13
    add    rax,    4
    vmovaps        ymm14,  [r12 + 32]
    vbroadcastss   ymm15,  dword ptr [r10 + r11]
    vfmadd231ps    ymm1,   ymm12,  ymm14
    vfmadd231ps    ymm2,   ymm15,  ymm13
    vfmadd231ps    ymm3,   ymm15,  ymm14
    lea    r10,    [r10 + 2 * r11]
    vbroadcastss   ymm12,  dword ptr [r10]
    vbroadcastss   ymm15,  dword ptr [r10 + r11]
    vfmadd231ps    ymm4,   ymm12,  ymm13
    vfmadd231ps    ymm5,   ymm12,  ymm14
    vfmadd231ps    ymm6,   ymm15,  ymm13
    vfmadd231ps    ymm7,   ymm15,  ymm14
    lea    r10,    [r10 + 2 * r11]
    vbroadcastss   ymm12,  dword ptr [r10]
    vbroadcastss   ymm15,  dword ptr [rax + r11]
    vfmadd231ps    ymm8,   ymm12,  ymm13
    vfmadd231ps    ymm9,   ymm12,  ymm14
    vfmadd231ps    ymm10,  ymm15,  ymm13
    vfmadd231ps    ymm11,  ymm15,  ymm14
    mov    r10,    rax
    add    r12,    64
    sub    esi,    1
    jne    count_kernel_6x16_loop_head
    vmovaps        [r13],  ymm0
    vmovaps        [r13 + 32],   ymm1
    lea    r13,    [r13 + rbx]
    vmovaps        [r13],  ymm2
    vmovaps        [r13 + 32],   ymm3
    lea    r13,    [r13 + rbx]
    vmovaps        [r13],  ymm4
    vmovaps        [r13 + 32],   ymm5
    lea    r13,    [r13 + rbx]
    vmovaps        [r13],  ymm6
    vmovaps        [r13 + 32],   ymm7
    lea    r13,    [r13 + rbx]
    vmovaps        [r13],  ymm8
    vmovaps        [r13 + 32],   ymm9
    lea    r13,    [r13 + rbx]
    vmovaps        [r13],  ymm10
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
count_kernel_4x16_loop_head:
    vbroadcastss   ymm8,   dword ptr [r10]
    vmovaps        ymm9,   [r12]
    vfmadd231ps    ymm0,  ymm8,  ymm9
    lea    rax,    [r10 + 2 * r11]
    vmovaps        ymm10,  [r12 + 32]
    vbroadcastss   ymm11,  dword ptr [r10 + r11]
    vfmadd231ps    ymm1,  ymm8,  ymm10
    vfmadd231ps    ymm2,  ymm11, ymm9
    vfmadd231ps    ymm3,  ymm11, ymm10
    vbroadcastss   ymm8,  dword ptr [rax]
    vbroadcastss   ymm11, dword ptr [rax + r11]
    vfmadd231ps    ymm4,  ymm8,  ymm9
    vfmadd231ps    ymm5,  ymm8,  ymm10
    vfmadd231ps    ymm6,  ymm11, ymm9
    vfmadd231ps    ymm7,  ymm11, ymm10
    lea    r10,    [r10 + 4]
    add    r12,    64
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
count_kernel_2x16_loop_head:
    vbroadcastss   ymm8,   dword ptr [r10]
    vmovaps        ymm9,   [r12]
    vfmadd231ps    ymm0,  ymm8,  ymm9
    vmovaps        ymm10,  [r12 + 32]
    vbroadcastss   ymm11,  dword ptr [r10 + r11]
    vfmadd231ps    ymm1,  ymm8,  ymm10
    vfmadd231ps    ymm2,  ymm11, ymm9
    vfmadd231ps    ymm3,  ymm11, ymm10
    lea    r10,    [r10 + 4]
    add    r12,    64
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
    vbroadcastss   ymm8,   dword ptr [r10]
    vmovaps        ymm9,   [r12]
    vfmadd231ps    ymm0,  ymm8,  ymm9
    lea    r10,    [r10 + 4]
    vmovaps        ymm10,  [r12 + 32]
    vfmadd231ps    ymm1,  ymm8,  ymm10
    lea    r12,    [r12 + 64]
    sub    esi,    1
    jne    count_kernel_1x16_loop_head
    vmovaps        [r13], ymm0
    vmovaps        [r13 + 32],   ymm1
    lea    r13,    [r13 + rbx]
    ret
count_kernel_1x16 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_6x8(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D,  ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_6x8 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    vxorps ymm4,   ymm4,   ymm4
    vxorps ymm5,   ymm5,   ymm5
count_kernel_6x8_loop_head:
    vmovaps        ymm9,   [r12]
    vbroadcastss   ymm8,   dword ptr [r10]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    lea    rax,    [r10 + r11]
    add    r12,    32
    vbroadcastss   ymm10,  dword ptr [rax]
    vbroadcastss   ymm11,  dword ptr [rax + r11]
    vfmadd231ps    ymm1,   ymm10, ymm9
    vfmadd231ps    ymm2,   ymm11, ymm9
    vbroadcastss   ymm12,  dword ptr [rax + 2 * r11]
    vbroadcastss   ymm13,  dword ptr [r10 + 4 * r11]
    vfmadd231ps    ymm3,   ymm12, ymm9
    vfmadd231ps    ymm4,   ymm13, ymm9
    vbroadcastss   ymm10,  dword ptr [rax + 4 * r11]
    vfmadd231ps    ymm5,   ymm10, ymm9
    lea    r10,    [r10 + 4]
    sub    esi,    1
    jne    count_kernel_6x8_loop_head
    vmovaps        [r13], ymm0
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm1
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm2
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm3
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm4
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm5
    lea    r13,    [r13 + rbx]
    ret
count_kernel_6x8 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_4x8(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D,  ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_4x8 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
count_kernel_4x8_loop_head:
    vmovaps        ymm9,   [r12]
    vbroadcastss   ymm8,   dword ptr [r10]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    lea    rax,    [r10 + 2 * r11]
    add    r12,    32
    vbroadcastss   ymm10,  dword ptr [r10 + r11]
    vbroadcastss   ymm11,  dword ptr [rax]
    vfmadd231ps    ymm1,   ymm10, ymm9
    vfmadd231ps    ymm2,   ymm11, ymm9
    vbroadcastss   ymm12,  dword ptr [rax + r11]
    vfmadd231ps    ymm3,   ymm12, ymm9
    lea    r10,    [r10 + 4]
    sub    esi,    1
    jne    count_kernel_4x8_loop_head
    vmovaps        [r13], ymm0
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm1
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm2
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm3
    lea    r13,    [r13 + rbx]
    ret
count_kernel_4x8 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_2x8(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D,  ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_2x8 proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    mov    rax,    r10
count_kernel_2x8_loop_head:
    vmovaps        ymm9,   [r12]
    vbroadcastss   ymm8,   dword ptr [r10]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    add    r12,    32
    vbroadcastss   ymm10,  dword ptr [r10 + r11]
    vfmadd231ps    ymm1,   ymm10, ymm9
    lea    r10,    [r10 + 4]
    sub    esi,    1
    jne    count_kernel_2x8_loop_head
    vmovaps        [r13], ymm0
    lea    r13,    [r13 + rbx]
    vmovaps        [r13], ymm1
    lea    r13,    [r13 + rbx]
    ret
count_kernel_2x8 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void count_kernel_1x8(float *src_matrix1 = R10, uint32_t src_matrix1_w = ESI, uint32_t src_matrix1_w_real = R11D,  ;;
;;                         float *src_buffer = R12, uint32_t src_matrix2_w_real = EBX, float *dst_matrix = R13)       ;;
;; Uses RAX                                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count_kernel_1x8 proc
    vxorps ymm0,   ymm0,   ymm0
    mov    rax,    r10
count_kernel_1x8_loop_head:
    vmovaps        ymm9,   [r12]
    vbroadcastss   ymm8,   dword ptr [r10]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    lea    r10,    [r10 + 4]
    add    r12,    32
    sub    esi,    1
    jne    count_kernel_1x8_loop_head
    vmovaps        [r13], ymm0
    lea    r13,    [r13 + rbx]
    ret
count_kernel_1x8 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; void mtrx_mul(float *src_matrix1, uint32_t src_matrix1_h, uint32_t src_matrix1_w, ;;
;;                 float *src_matrix2, uint32_t src_matrix2_w, float *dst_matrix)    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mtrx_mul_debug proc
    push   rbp
    mov    rbp,    rsp
    push   r15
    push   r14
    push   r13
    push   r12
    push   r11
    push   r10
    push   rbx
    push   rsi
    push   rdi
    mov    [rbp + 24],     edx
    mov    ebx,    [rbp + 48]
    mov    edx,    r8d
    add    r8d,    7
    add    ebx,    7
    mov    r15,    [rbp + 56]
    and    r8d,    -8
    and    ebx,    -8
    shl    r8d,    2
    shl    ebx,    2
    mov    r11d,   r8d
    mov    r8,     rcx
    mov    ecx,    ebx
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
    mov    rax,    buffer
    mov    r10,    r9
    mov    esi,    edx
    call   fill_buffer_16
    mov    edi,    [rbp + 24]
    mov    r14,    r8
    mov    r13,    r15
    add    r15,    64
    sub    edi,    6
    jb     kernel_4x16
loop_head_h1_6x16:
    mov    r12,    buffer
    mov    r10,    r14
    lea    r14,    [r14 + 4 * r11]
    mov    esi,    edx
    call   count_kernel_6x16
    lea    r14,    [r14 + 2 * r11]
    sub    edi,    6
    jae    loop_head_h1_6x16
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
    lea    r14,    [r14 + 2 * r11]
    call   count_kernel_2x16
kernel_1x16:
    test   edi,    1
    jz     next_16
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    call   count_kernel_1x16
next_16:
    lea    r9,     [r9 + 64]
    sub    ecx,    64
    jae    loop_head_w2
kernels_Yx8:
    cmp    ecx,    -64
    je     exit
    mov    rax,    buffer
    mov    r10,    r9
    mov    esi,    edx
    call   fill_buffer_8
    mov    edi,    [rbp + 24]
    mov    r14,    r8
    mov    r13,    r15
    sub    edi,    6
    jb     kernel_4x8
loop_head_h1_6x8:
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    lea    r14,    [r14 + 4 * r11]
    call   count_kernel_6x8
    lea    r14,    [r14 + 2 * r11]
    sub    edi,    6
    jae    loop_head_h1_6x8
kernel_4x8:
    cmp    edi,    -2
    jl     kernel_2x8
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    lea    r14,    [r14 + 4 * r11]
    call   count_kernel_4x8
kernel_2x8:
    test   edi,    2
    jnz    kernel_1x8
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    lea    r14,    [r14 + 2 * r11]
    call   count_kernel_2x8
kernel_1x8:
    test   edi,    1
    jz     exit
    mov    r12,    buffer
    mov    r10,    r14
    mov    esi,    edx
    call   count_kernel_1x8
exit:
    pop_callee_saved_regs
    leave
    ret
mtrx_mul_debug endp

end
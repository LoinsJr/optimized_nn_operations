include macros.inc

extern buffer : qword

; TODO : write mtrx_mul
.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mtrx_mul_async_(params) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mtrx_mul_async_ proc
    push   rbp
    mov    rbp,    rsp
    push   buffer
    push   [rcx + 40]
    push   [rcx + 32]
    sub    rsp,    32
    mov    r9,     [rcx + 24]
    mov    r8d,    [rcx + 16]
    mov    edx,    [rcx + 8]
    mov    rcx,    [rcx]
    call   mtrx_mul_
    add    rsp,    32
    leave
    ret
mtrx_mul_async_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mtrx_mul_(src_matrix1, src_matrix1_h, src_matrix1_w, src_matrix2, ;;
;;             src_matrix2_w, dst_matrix, buffer)                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mtrx_mul_ proc
    push   rbp
    mov    rbp,    rsp
    push_callee_saved_regs
    mov    [rbp + 24],     edx
    mov    edx,    r8d
    mov    r8,     rcx
    mov    ecx,    [rbp + 48]
    ; set next multiply of 32 after 4 * src_matrix1_w
    mov    r10d,   edx
    add    r10,    7
    and    r10,    -8
    shl    r10,    2
    ; set next multiply of 32 after 4 * src_matrix2_w
    mov    r11d,   ecx
    add    r11,    7
    and    r11,    -8
    shl    r11,    2
    mov    r12,    [rbp + 56]
    ; R8 - src_matrix1
    ; [RBP + 24] - src_matrix1_h
    ; EDX - src_matrix1_w
    ; R10 - next multiply of 32 after 4 * src_matrix1_w (invariant)
    ; R9 - src_matrix2
    ; ECX - src_matrix2_width
    ; R11 - next multiply of 32 after 4 * src_matrix2_w (invariant)
    ; R12 - dst_matrix
    cmp    ecx,    16
    jb     kernels_Yx8
loop_head_kernels_Yx16:
    ; call fill_buffer_16
    mov    r15,    [rbp + 64]
    mov    r13,    r9
    mov    ebx,    edx
    call   fill_buffer_16_
    mov    edi,    [rbp + 24]
    mov    r15,    r12
    mov    rax,    r8
    cmp    edi,    6
    jb     kernel_4x16
loop_head_kernels_6x16:
    ; call compute_kernel_6x16
    mov    r14,    [rbp + 64]
    mov    r13,    rax
    mov    ebx,    edx
    lea    rax,    [rax + 4 * r10]
    call   compute_kernel_6x16_
    lea    rax,    [rax + 2 * r10]
    sub    edi,    6
    cmp    edi,    6
    jae    loop_head_kernels_6x16
kernel_4x16:
    test   edi,    4
    jz     kernel_2x16
    ; call compute_kernel_4x16
    mov    r14,    [rbp + 64]
    mov    r13,    rax
    mov    ebx,    edx
    lea    rax,    [rax + 4 * r10]
    call   compute_kernel_4x16_
kernel_2x16:
    test   edi,    2
    jz     kernel_1x16
    ; call compute_kernel_2x16
    mov    r14,    [rbp + 64]
    mov    r13,    rax
    mov    ebx,    edx
    lea    rax,    [rax + 2 * r10]
    call   compute_kernel_2x16_
kernel_1x16:
    test   edi,    1
    jz     next_iteration
    ; call compute_kernel_1x16
    mov    r14,    [rbp + 64]
    mov    r13,    rax
    mov    ebx,    edx
    call   compute_kernel_1x16_
next_iteration:
    lea    r9,     [r9 + 64]
    add    r12,    64
    sub    ecx,    16
    cmp    ecx,    16
    jae    loop_head_kernels_Yx16
kernels_Yx8:
    test   ecx,    ecx
    jz     exit
    mov    r15,    [rbp + 64]
    mov    r13,    r9
    mov    ebx,    edx
    call   fill_buffer_8_
    mov    edi,    [rbp + 24]
    cmp    edi,    6
    jb     kernel_4x8
loop_head_kernels_6x8:
    mov    r14,    [rbp + 64]
    mov    r13,    r8
    mov    ebx,    edx
    lea    r8,     [r8 + 4 * r10]
    call   compute_kernel_6x8_
    lea    r8,     [r8 + 2 * r10]
    sub    edi,    6
    cmp    edi,    6
    jae    loop_head_kernels_6x8
kernel_4x8:
    test   edi,    4
    jz     kernel_2x8
    mov    r14,    [rbp + 64]
    mov    r13,    r8
    mov    ebx,    edx
    lea    r8,     [r8 + 4 * r10]
    call   compute_kernel_4x8_
kernel_2x8:
    test   edi,    2
    jz     kernel_1x8
    mov    r14,    [rbp + 64]
    mov    r13,    r8
    mov    ebx,    edx
    lea    r8,     [r8 + 2 * r10]
    call   compute_kernel_2x8_
kernel_1x8:
    test   edi,    1
    jz     exit
    mov    r14,    [rbp + 64]
    mov    r13,    r8
    mov    ebx,    edx
    call   compute_kernel_1x8_
exit:
    pop_callee_saved_regs
    leave
    ret
mtrx_mul_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fill_buffer_16_(src_matrix2 = R13, src_matrix1_w = EBX, src_matrix2_w_real = R11, buffer = R15) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_buffer_16_ proc
fill_buffer_16_loop_head:
    vmovaps        ymm0,   [r13]
    vmovaps        [r15],  ymm0
    vmovaps        ymm1,   [r13 + 32]
    vmovaps        [r15 + 32],     ymm1
    lea    r13,    [r13 + r11]
    lea    r15,    [r15 + 64]
    sub    ebx,    1
    jnz    fill_buffer_16_loop_head
    ret
fill_buffer_16_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fill_buffer_8_(src_matrix2 = R13, src_matrix1_w = EBX, src_matrix2_w_real = R11, buffer = R15) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_buffer_8_ proc
    cmp    ebx,    2
    jb     fill_last_row
fill_buffer_8_loop_head:
    vmovaps        ymm0,   [r13]
    vmovaps        [r15],  ymm0
    vmovaps        ymm1,   [r13 + r11]
    vmovaps        [r15 + 32],     ymm1
    lea    r13,    [r13 + 2 * r11]
    add    r15,    64
    sub    ebx,    2
    cmp    ebx,    2
    jae    fill_buffer_8_loop_head
fill_last_row:
    test   ebx,    ebx
    jz     exit
    vmovaps        ymm0,   [r13]
    vmovaps        [r15],  ymm0
exit:
    ret
fill_buffer_8_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_6x16_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R15)     ;;
;; Uses RSI. Returns R15 = ptr to next kernel in dst_matrix                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_6x16_ proc
    mov    rsi,    r13
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
loop_head:
    vbroadcastss   ymm12,  dword ptr [r13]
    vmovaps        ymm13,  [r14]
    add    rsi,    4
    vfmadd231ps    ymm0,   ymm12,  ymm13
    vmovaps        ymm14,  [r14 + 32]
    vbroadcastss   ymm15,  dword ptr [r13 + r10]
    vfmadd231ps    ymm1,   ymm12,  ymm14
    vfmadd231ps    ymm2,   ymm15,  ymm13
    lea    r13,    [r13 + 2 * r10]
    vfmadd231ps    ymm3,   ymm15,  ymm14
    vbroadcastss   ymm12,  dword ptr [r13]
    vbroadcastss   ymm15,  dword ptr [r13 + r10]
    vfmadd231ps    ymm4,   ymm12,  ymm13
    vfmadd231ps    ymm5,   ymm12,  ymm14
    lea    r13,    [r13 + 2 * r10]
    vfmadd231ps    ymm6,   ymm15,  ymm13
    vfmadd231ps    ymm7,   ymm15,  ymm14
    vbroadcastss   ymm12,  dword ptr [r13]
    vbroadcastss   ymm15,  dword ptr [r13 + r10]
    vfmadd231ps    ymm8,   ymm12,  ymm13
    vfmadd231ps    ymm9,   ymm12,  ymm14
    lea    r14,    [r14 + 64]
    mov    r13,    rsi
    vfmadd231ps    ymm10,  ymm15,  ymm13
    vfmadd231ps    ymm11,  ymm15,  ymm14
    sub    ebx,    1
    jnz    loop_head
    vmovaps        [r15],  ymm0
    vmovaps        [r15 + 32],     ymm1
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm2
    vmovaps        [r15 + 32],     ymm3
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm4
    vmovaps        [r15 + 32],     ymm5
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm6
    vmovaps        [r15 + 32],     ymm7
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm8
    vmovaps        [r15 + 32],     ymm9
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm10
    vmovaps        [r15 + 32],     ymm11
    add    r15,    r11
    ret
compute_kernel_6x16_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_4x16_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R15)     ;;
;; Uses RSI. Returns R15 = ptr to next kernel in dst_matrix                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_4x16_ proc
    mov    rsi,    r13
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    vxorps ymm4,   ymm4,   ymm4
    vxorps ymm5,   ymm5,   ymm5
    vxorps ymm6,   ymm6,   ymm6
    vxorps ymm7,   ymm7,   ymm7
loop_head:
    vbroadcastss   ymm8,   dword ptr [r13]
    vmovaps        ymm9,   [r14]
    vfmadd231ps    ymm0,   ymm8,   ymm9
    add    rsi,    4
    vmovaps        ymm10,  [r14 + 32]
    vbroadcastss   ymm11,  dword ptr [r13 + r10]
    vfmadd231ps    ymm1,   ymm8,   ymm10
    lea    r13,    [r13 + 2 * r10]
    vfmadd231ps    ymm2,   ymm11,  ymm9
    vfmadd231ps    ymm3,   ymm11,  ymm10
    vbroadcastss   ymm8,   dword ptr [r13]
    vbroadcastss   ymm12,  dword ptr [r13 + r10]
    vfmadd231ps    ymm4,   ymm8,   ymm9
    vfmadd231ps    ymm5,   ymm8,   ymm10
    lea    r14,    [r14 + 64]
    mov    r13,    rsi
    vfmadd231ps    ymm6,   ymm12,  ymm9
    vfmadd231ps    ymm7,   ymm12,  ymm10
    sub    ebx,    1
    jnz    loop_head
    vmovaps        [r15],  ymm0
    vmovaps        [r15 + 32],     ymm1
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm2
    vmovaps        [r15 + 32],     ymm3
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm4
    vmovaps        [r15 + 32],     ymm5
    lea    r15,    [r15 + r11]
    vmovaps        [r15],  ymm6
    vmovaps        [r15 + 32],     ymm7
    lea    r15,    [r15 + r11]
    ret
compute_kernel_4x16_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_2x16_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R15)     ;;
;; Returns R15 = ptr to next kernel in dst_matrix                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_2x16_ proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
loop_head:
    vbroadcastss   ymm4,   dword ptr [r13]
    vmovaps        ymm5,   [r14]
    vfmadd231ps    ymm0,   ymm4,  ymm5
    vmovaps        ymm6,   [r14 + 32]
    vbroadcastss   ymm7,   dword ptr [r13 + r10]
    vfmadd231ps    ymm1,   ymm4,  ymm6
    lea    r13,    [r13 + 4]
    lea    r14,    [r14 + 64]
    vfmadd231ps    ymm2,   ymm7,  ymm5
    vfmadd231ps    ymm3,   ymm7,  ymm6
    sub    ebx,    1
    jne    loop_head
    vmovaps        [r15],  ymm0
    vmovaps        [r15 + 32],    ymm1
    lea    r15,    [r15 + r11]
    vmovaps        [r15], ymm2
    vmovaps        [r15 + 32],    ymm3
    lea    r15,    [r15 + r11]
    ret
compute_kernel_2x16_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_1x16_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R15)     ;;
;; Returns R15 = ptr to next kernel in dst_matrix                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_1x16_ proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    cmp    ebx,    2
    jb     compute_last
loop_head:
    vbroadcastss   ymm8,   dword ptr [r13]
    vmovaps        ymm9,   [r14]
    vfmadd231ps    ymm0,   ymm8,   ymm9
    lea    r13,    [r13 + 4]
    vmovaps        ymm10,  [r14 + 32]
    vfmadd231ps    ymm1,   ymm8,   ymm10
    lea    r14,    [r14 + 64]
    sub    ebx,    1
    jnz    loop_head
compute_last:
    vmovaps        [r15],  ymm0
    vmovaps        [r15 + 32],     ymm1
    ret
compute_kernel_1x16_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_6x8_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R12)    ;;
;; Uses RSI. Returns R15 = ptr to next kernel in dst_matrix                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_6x8_ proc
    mov    rsi,    r13
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
    vxorps ymm4,   ymm4,   ymm4
    vxorps ymm5,   ymm5,   ymm5
loop_head:
    vmovaps        ymm9,   [r14]
    vbroadcastss   ymm8,   dword ptr [r13]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    lea    r13,    [r13 + r10]
    add    rsi,    4
    vbroadcastss   ymm10,  dword ptr [r13]
    vbroadcastss   ymm11,  dword ptr [r13 + r10]
    vfmadd231ps    ymm1,   ymm10, ymm9
    vfmadd231ps    ymm2,   ymm11, ymm9
    lea    r13,    [r13 + 2 * r10]
    vbroadcastss   ymm12,  dword ptr [r13]
    vbroadcastss   ymm13,  dword ptr [r13 + r10]
    vfmadd231ps    ymm3,   ymm12, ymm9
    vfmadd231ps    ymm4,   ymm13, ymm9
    add    r14,    32
    vbroadcastss   ymm10,  dword ptr [r13 + 2 * r10]
    vfmadd231ps    ymm5,   ymm10, ymm9
    mov    r13,    rsi
    sub    ebx,    1
    jne    loop_head
    vmovaps        [r12], ymm0
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm1
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm2
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm3
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm4
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm5
    add    r12,    r11
    ret
compute_kernel_6x8_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_4x8_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R12)    ;;
;; Uses RSI. Returns R15 = ptr to next kernel in dst_matrix                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_4x8_ proc
    mov    rsi,    r13
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
    vxorps ymm2,   ymm2,   ymm2
    vxorps ymm3,   ymm3,   ymm3
loop_head:
    vmovaps        ymm9,   [r14]
    vbroadcastss   ymm8,   dword ptr [r13]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    lea    r13,    [r13 + r10]
    vbroadcastss   ymm10,  dword ptr [r13]
    vbroadcastss   ymm11,  dword ptr [r13 + r10]
    vfmadd231ps    ymm1,   ymm10, ymm9
    vfmadd231ps    ymm2,   ymm11, ymm9
    lea    r14,    [r14 + 32]
    add    rsi,    4
    vbroadcastss   ymm12,  dword ptr [r13 + 2 * r10]
    vfmadd231ps    ymm3,   ymm12, ymm9
    mov    r13,    rsi
    sub    ebx,    1
    jne    loop_head
    vmovaps        [r12], ymm0
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm1
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm2
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm3
    lea    r12,    [r12 + r11]
    ret
compute_kernel_4x8_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_2x8_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R12)    ;;
;; Returns R15 = ptr to next kernel in dst_matrix                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_2x8_ proc
    vxorps ymm0,   ymm0,   ymm0
    vxorps ymm1,   ymm1,   ymm1
loop_head:
    vmovaps        ymm9,   [r14]
    vbroadcastss   ymm8,   dword ptr [r13]
    vfmadd231ps    ymm0,   ymm8,   ymm9
    add    r14,    32
    vbroadcastss   ymm10,  dword ptr [r13 + r10]
    vfmadd231ps    ymm1,   ymm10,  ymm9
    lea    r13,    [r13 + 4]
    sub    ebx,    1
    jne    loop_head
    vmovaps        [r12], ymm0
    lea    r12,    [r12 + r11]
    vmovaps        [r12], ymm1
    lea    r12,    [r12 + r11]
    ret
compute_kernel_2x8_ endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compute_kernel_1x8_(src_matrix1 = R13, src_matrix1_w = EBX, src_matrix1_w_real = R10, ;;
;;                     src_matrix2 = R14, src_matrix2_w_real = R11, dst_matrix = R12)    ;;
;; Returns R15 = ptr to next kernel in dst_matrix                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compute_kernel_1x8_ proc
    vxorps ymm0,   ymm0,   ymm0
loop_head:
    vmovaps        ymm9,   [r14]
    vbroadcastss   ymm8,   dword ptr [r13]
    vfmadd231ps    ymm0,   ymm8,  ymm9
    lea    r14,    [r14 + 32]
    add    r13,    4
    sub    ebx,    1
    jne    loop_head
    vmovaps        [r12], ymm0
    ret
compute_kernel_1x8_ endp

end
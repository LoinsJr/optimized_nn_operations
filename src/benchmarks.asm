.code

start_measuring proc
    push  rbp
    mov   rbp,   rsp

    push  rbx

    cpuid
    rdtsc

    pop   rbx

    shl   rdx,   32
    or    rax,   rdx

    mov   rsp,   rbp
    pop   rbp
    ret
start_measuring endp

end_measuring proc
    push  rbp
    mov   rbp,   rsp

    push  rbx

    rdtscp
    push  rax
    push  rdx
    cpuid
    pop   rdx
    pop   rax

    shl   rdx,   32
    or    rax,   rdx

    pop   rbx

    mov   rsp,   rbp
    pop   rbp
    ret
end_measuring endp

end
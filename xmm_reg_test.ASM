format PE console
include 'win32ax.inc'
entry start
section '.data' data readable writable   ; xmm0=128bits -> 16bytes
        C rb 16
        Z rb 16
        I rb 16
        shifter dq 1 shl 63
        quatre db 4

section '.text' code readable executable
start:
     mov [I],1
     mov eax,100
     mov ebx,dword [quatre]
     CVTSI2SD  xmm0,ebx

     mov ebx,dword [I]
     CVTSI2SD xmm7,ebx
     divsd xmm0,xmm7
     movsd qword [C],xmm0
     jmp calculate_pi
second:
     int3
     invoke ExitProcess,0


calculate_pi:
     cmp eax,0
     je second

     add [I],2

     mov ebx,dword [quatre]
     CVTSI2SD  xmm0,ebx

     mov ebx,dword [I]
     CVTSI2SD xmm7,ebx
     divsd xmm0,xmm7
     movsd qword [Z],xmm0 ; qword cause the other 64 bits (other half) of xmm0 are empty

     mov esi,eax
     call modulo
     mov eax,esi

     cmp edx,0
     je calculate_pi.negate
     jmp  calculate_pi.sec_half

     .sec_half:

        LEA ebx,[Z]
        movsd xmm1,ptr ebx
        LEA ebx,[C]
        movsd xmm0,ptr ebx
        ADDSD xmm0,xmm1
        movsd qword [C],xmm0

        dec eax
        jmp calculate_pi

     .negate:
        LEA ebx,[shifter]
        movsd xmm1,ptr ebx
        pxor xmm0,xmm1
        movsd qword [Z],xmm0


        jmp  calculate_pi.sec_half

modulo: ;eax
        cdq
        mov edi,2
        idiv edi
        ret
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

    import kernel,\
            ExitProcess, 'ExitProcess'
    import msvcrt,\
      printf, 'printf',\
      getchar,'getchar'
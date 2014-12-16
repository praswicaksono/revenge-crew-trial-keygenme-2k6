literal MACRO quoted_text:VARARG
LOCAL local_text
.data
	local_text db quoted_text,0
align 4
.code
	EXITM <local_text>
ENDM
SADD MACRO quoted_text:VARARG
	EXITM <ADDR literal(quoted_text)>
ENDM
szText MACRO Name, Text:VARARG
LOCAL lbl
jmp lbl
	Name db Text,0
lbl:
ENDM
m2m MACRO M1, M2
	push M2
	pop  M1
ENDM
FUNC MACRO parameters:VARARG
	invoke parameters
	EXITM <eax>
ENDM

return MACRO arg
	mov eax, arg
	ret
ENDM

RGB MACRO red, green, blue
        xor eax, eax
        mov ah, blue    ; blue
        mov al, green   ; green
        rol eax, 8
        mov al, red     ; red
ENDM

chr$ MACRO any_text:VARARG
	LOCAL txtname
	.data
		txtname db any_text,0
	.code
	EXITM <OFFSET txtname>
ENDM

dsText MACRO Name, Text:VARARG
      .data
        Name db Text,0
        align 4
      .code
ENDM

FF	MACRO	dta,dtb,dtc,dtd,x,s,t	; a = b + ((a + F(b,c,d) + x + t) << s )
	mov	eax,dtb
	mov	ebx,dtc
	mov	ecx,dtd

	; F(x,y,z) = (x and y) or ((not x) and z)
	and	ebx,eax
	not	eax
	and	eax,ecx
	or	eax,ebx

	add	eax,dta
	add	eax,x
	add	eax,t

	mov	cl,s
	rol	eax,cl

	add	eax,dtb

	mov	dta,eax
ENDM

GG	MACRO	dta,dtb,dtc,dtd,x,s,t	; a = b + ((a + G(b,c,d) + x + t) << s)
	mov	eax,dtb
	mov	ebx,dtc
	mov	ecx,dtd

	; G(x,y,z) = (x and z) or (y and (not z))
	and	eax,ecx
	not	ecx
	and	ecx,ebx
	or	eax,ecx

	add	eax,dta
	add	eax,x
	add	eax,t

	mov	cl,s
	rol	eax,cl

	add	eax,dtb

	mov	dta,eax
ENDM

HH	MACRO	dta,dtb,dtc,dtd,x,s,t	; a = b + ((a + H(b,c,d) + x + t) << s)
	mov	eax,dtb
	mov	ebx,dtc
	mov	ecx,dtd

	; H(x,y,z) = x xor y xor z
	xor	eax,ebx
	xor	eax,ecx

	add	eax,dta
	add	eax,x
	add	eax,t

	mov	cl,s
	rol	eax,cl

	add	eax,dtb

	mov	dta,eax
ENDM

II	MACRO	dta,dtb,dtc,dtd,x,s,t	; a = b + ((a + I(b,c,d) + x + t) << s)
	mov	eax,dtb
	mov	ebx,dtc
	mov	ecx,dtd

	; I(x,y,z) = y xor (x or (not z))
	not	ecx
	or	eax,ecx
	xor	eax,ebx

	add	eax,dta
	add	eax,x
	add	eax,t

	mov	cl,s
	rol	eax,cl

	add	eax,dtb

	mov	dta,eax
ENDM

AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
      ENDM

;+--------------------+ The comments are to point you to things you would like to change.
;|  Keygen Template   | The rest of the code is self-explanatory.
;|      MASM32        | Plus, you're the ASM gurus .. rofl
;| For CiM Team only  | 
;|   Do not share!    | If you can/want to modify this code, imporve it, feel free :)
;+--------------------+ 

; Hehe I've moddified this with some new function :P

; now you can use BMP, PNG, JPG format for the background
; and support BMP, JPG, PNG button image
; you can set in include.inc on the top line
; dont forget set in Resource.rc too

; and you can set scroll text type (use thread or use timer)
; if you choose use timer the blend effect will be appear
; the blend effect doesnt appear on scroll text use thread (i dunno why ? :P)

; added custom cursor and updating bitmap button code
; added XML file for GUI standard windows
; added some junk code :)
; updated ufmod library
; changed icon :P
; scroller text code changed (diablo2oo2 scroller text)
; any suggest or bug ?
; please dont tell me... lol

; next in future
; any suggestion ?
;---------------------------------------------------------------------------------------------!

.586
.model flat,stdcall
option casemap:none

Music	equ	1                ;<------| Music 1/0 (ON/OFF)

include Includes.inc

; My custom bmp button + custom cursor
include GFX\bmpbutn.asm

.code
code:

    IFDEF USEANTIDBG
    ASSUME FS:NOTHING
	pushad
	mov dword ptr [SavedESP],esp
	push offset SehContinue
	push dword ptr fs:[0]
	mov dword ptr fs:[0],esp
	
	db 0f3h,64h
	db 0f1h
	
	pop dword ptr fs:[0]
	add esp,4
	popad
	invoke MessageBox,NULL,SADD("Debugger found"),SADD("Damn!!!"),MB_ICONEXCLAMATION
	invoke ExitProcess,0
	
	SehContinue:
	pop dword ptr fs:[0]
	mov esp,dword ptr [SavedESP]
	popad
	
	invoke VirtualProtect,00400000h,00001000h,40h,addr OldProtect

	mov ebx,0040003ch
	mov ecx,dword ptr[ebx]
	add ecx,00400006h

	xor ebx,ebx   
	mov bx,word ptr[ecx]
	push ecx
	add ecx,0f2h

 @clear_section:
	mov edx,28h	
 @clear_section_s:
	mov byte ptr[ecx],0h
	inc ecx
	dec edx
	jne @clear_section_s
	dec ebx
	jne @clear_section
	pop ecx
	mov word ptr[ecx],bx
	ENDIF
	
	AllowSingleInstance addr szApp ;<---|prevents the app to start multiple times, the CreateMutex function's buggy on my vista, so I opted for this approach XD
	mov hInstance, FUNC(GetModuleHandle,NULL)
	mov hInstance,eax
	invoke InitCommonControls
	invoke DialogBoxParam, hInstance, IDD_DLGBOX, NULL, DlgProc, NULL
	pop eax
	invoke ExitProcess, eax
	
DlgProc	proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL ThreadID2	:DWORD
    
	push hWnd
	pop handle
	   	
	.if uMsg==WM_INITDIALOG
        
		invoke InitializeKeygen,hWnd
		invoke SetDlgItemText,hWnd,IDC_STATUS,SADD("All set!! Enter your name, generate and n-joy !!")
		
		invoke GetDlgItem,hWnd,IDC_NAME
		mov hName,eax
		invoke GetDlgItem,hWnd,IDC_SERIAL
		mov hSerial,eax
		invoke GetDlgItem,hWnd,IDC_STATUS
		mov hStatus,eax
		invoke GetDlgItem,hWnd,IDC_GENERATE
		mov hGen,eax
		invoke GetDlgItem,hWnd,IDC_EXIT
		mov hExit,eax
		
		IFDEF USETIMER
		invoke ShowWindow,hGen,0
		invoke ShowWindow,hExit,0
		invoke SetLayeredWindowAttributes,hWnd,NULL,204,2
		invoke GetWindowLong,hWnd,GWL_EXSTYLE 
		or eax,WS_EX_LAYERED 
		invoke SetWindowLong,hWnd,GWL_EXSTYLE,eax 
		invoke SetLayeredWindowAttributes,hWnd,TransColor,0,LWA_ALPHA or LWA_COLORKEY
		invoke ShowWindow,hWnd,SW_SHOW
		invoke SetTimer,hWnd,222,40,addr FadeIn
		invoke SetTimer, hWnd, 01, 25, NULL       ; handle,TimerId,scroll speed,timer process
        mov posn, XRScroll+Blanking+StartDelay
        ENDIF
		
		invoke SetWindowLong,hName,GWL_WNDPROC,addr EditCustomCursor      ;set cursor on Name Edir
		mov OldWndProc,eax
		invoke SetWindowLong,hSerial,GWL_WNDPROC,addr EditCustomCursor2   ;set cursor on Serial Edit
		mov OldWndProc2,eax
		invoke SetWindowLong,hStatus,GWL_WNDPROC,addr EditCustomCursor3   ;set cursor on Status Edit
		mov OldWndProc3,eax
		invoke SetWindowLong,hGen,GWL_WNDPROC,addr EditCustomCursor4      ;set cursor on Name Edit
		mov OldWndProc4,eax
		invoke SetWindowLong,hExit,GWL_WNDPROC,addr EditCustomCursor5      ;set cursor on Name Edit
		mov OldWndProc5,eax
		
		invoke SetFocus,hName
		invoke SetCursor,hCursor
		
		IF USETHREAD
		invoke ScrollerInit,hWnd
		ENDIF
		
	 IFDEF USETIMER
	 .elseif uMsg == WM_TIMER

          invoke GetDC,hWnd
          mov hDC, eax
          invoke Timer_Proc, hWnd, hDC
          invoke ReleaseDC,hWnd,hDC
          return 0
     	
	 .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWnd,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWnd,hDC,0
        invoke EndPaint,hWnd,ADDR Ps
        return 0
        ENDIF
     
	.elseif uMsg==WM_COMMAND
		mov eax, wParam
		mov edx,eax
		shr edx,16
		and eax,0ffffh
		.if edx==BN_CLICKED
			.if ax== IDC_GENERATE
				invoke GetDlgItemText,hWnd,IDC_NAME,addr NameBuffer,sizeof NameBuffer
				.if ax>MaxName
					invoke SetDlgItemText,hWnd,IDC_SERIAL,addr LName
					invoke SetDlgItemText,hWnd,IDC_STATUS,addr StatusError
				.elseif ax<MinName
					invoke SetDlgItemText,hWnd,IDC_SERIAL,addr SName
					invoke SetDlgItemText,hWnd,IDC_STATUS,addr StatusError
				.else
					mov NameLen,eax
					invoke ShowWindow,hGen,0
					invoke ShowWindow,hExit,0
					invoke SetDlgItemText,hWnd,IDC_STATUS,addr WaitTxt
					invoke CreateThread,0,0,addr Generate,hWnd,0,addr ThreadID2
					invoke Sleep,WAIT_TIME
					invoke ShowWindow,hGen,1
					invoke ShowWindow,hExit,1
				    invoke SetDlgItemText,hWnd,IDC_STATUS,addr Success
				.endif
				
			.elseif ax==IDC_EXIT
				IFDEF USETIMER
				invoke ShowWindow,hGen,0
				invoke ShowWindow,hExit,0
				invoke SetTimer,hWnd,333,20,addr FadeOut
				ELSEIF USETHREAD
				invoke SendMessage,hWnd,WM_CLOSE,0,0
				ENDIF
			.endif
			
		.elseif dx==EN_CHANGE
			.if ax==IDC_NAME
			    invoke GetDlgItemText,hWnd,IDC_NAME,addr NameBuffer,sizeof NameBuffer
				.if ax>MaxName
					invoke SetDlgItemText,hWnd,IDC_SERIAL,addr LName
					invoke SetDlgItemText,hWnd,IDC_STATUS,addr StatusError
				.elseif ax<MinName
					invoke SetDlgItemText,hWnd,IDC_SERIAL,addr SName
					invoke SetDlgItemText,hWnd,IDC_STATUS,addr StatusError
				.else
					invoke SetDlgItemText,hWnd,IDC_SERIAL,addr PressGen
					invoke SetDlgItemText,hWnd,IDC_STATUS,addr Ready
				.endif
			.endif
		.endif
		
	.elseif uMsg==WM_LBUTTONDOWN
		invoke SetCursor,hCursor
		mov MoveDlg,TRUE
		invoke SetCapture,hWnd
		invoke GetCursorPos,addr OldPos
		
	.elseif uMsg==WM_MOUSEMOVE		
		invoke SetCursor,hCursor
		
		.if MoveDlg==TRUE
			invoke GetWindowRect,hWnd,addr Rect
			invoke GetCursorPos,addr NewPos
			mov eax,NewPos.x
			mov ecx,eax
			sub eax,OldPos.x
			mov OldPos.x,ecx
			add eax,Rect.left
			mov ebx,NewPos.y
			mov ecx,ebx
			sub ebx,OldPos.y
			mov OldPos.y,ecx
			add ebx,Rect.top
			mov ecx,Rect.right
			sub ecx,Rect.left
			mov edx,Rect.bottom
			sub edx,Rect.top
			invoke MoveWindow,hWnd,eax,ebx,ecx,edx,TRUE
		.endif
		
	.elseif uMsg==WM_LBUTTONUP
			invoke SetCursor,hCursor
			mov MoveDlg,FALSE
			invoke ReleaseCapture
		
	.elseif uMsg==WM_CLOSE
	
		if Music
			invoke FreeResource,pMusic
			invoke uFMOD_PlaySong,0,0,0
		endif
		
		invoke DeleteObject,hBrush
		invoke DeleteObject,hBmp
		
		
		invoke EndDialog, hWnd, 0
		
	.elseif uMsg==VK_DOWN
	   invoke SetCursor,hCursor
	   
	.elseif uMsg==WM_LBUTTONDBLCLK
		invoke SetCursor,hCursor
		
	.elseif uMsg==WM_RBUTTONDOWN
		invoke SetCursor,hCursor
	
	.elseif uMsg==WM_RBUTTONDBLCLK
		invoke SetCursor,hCursor
		
	.elseif uMsg==WM_RBUTTONUP
		invoke SetCursor,hCursor
		invoke ShowWindow,hWnd,SW_MINIMIZE
		
	.elseif uMsg==WM_CTLCOLORDLG
		mov eax,hBrush
		ret
	
	.elseif uMsg==WM_CTLCOLOREDIT || uMsg==WM_CTLCOLORSTATIC ;<------| EditBoxes
	    invoke GetDlgCtrlID,lParam
		.if ax==IDC_NAME
		  invoke SetBkMode,wParam,TRANSPARENT
		  invoke SetTextColor,wParam,0FFFFFFh  ;<------| Text color
		  RGB 255,102,121
		  invoke SetBkColor,wParam,eax
		  invoke SetBrushOrgEx,wParam,-9,116,0 ;<------| EditBox Position (x,y,z) /// keep "z" value NULL.
		  mov eax,hBrush
		  ret
	   .elseif ax==IDC_SERIAL
		  invoke SetBkMode,wParam,TRANSPARENT
		  invoke SetTextColor,wParam,0FFFFFFh
		  RGB 255,102,121
		  invoke SetBkColor,wParam,eax
		  invoke SetBrushOrgEx,wParam,-9,71,0
		  mov eax,hBrush
		  ret
	   .elseif ax==IDC_STATUS
		  invoke SetBkMode,wParam,TRANSPARENT
		  invoke SetTextColor,wParam,0000FFFFh
		  RGB 255,102,121
		  invoke SetBkColor,wParam,eax
		  invoke SetBrushOrgEx,wParam,-9,268,0
		  mov eax,hBrush
		  ret
		.endif	
	.endif	
	
	_Exit:
	xor eax,eax
	ret
DlgProc EndP

EditCustomCursor	proc	hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	.if uMsg==WM_SETCURSOR
		invoke SetCursor,hCursor
	.else
	invoke CallWindowProc,OldWndProc,hWnd,uMsg,wParam,lParam
	ret
	.endif
	
	xor eax,eax
	ret
EditCustomCursor EndP

EditCustomCursor2	proc	hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	.if uMsg==WM_SETCURSOR
		invoke SetCursor,hCursor
	.else
	invoke CallWindowProc,OldWndProc2,hWnd,uMsg,wParam,lParam
	ret
	.endif
	
	xor eax,eax
	ret
EditCustomCursor2 EndP

EditCustomCursor3	proc	hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	.if uMsg==WM_SETCURSOR
		invoke SetCursor,hCursor
	.else
	invoke CallWindowProc,OldWndProc3,hWnd,uMsg,wParam,lParam
	ret
	.endif
	
	xor eax,eax
	ret
EditCustomCursor3 EndP

EditCustomCursor4	proc	hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	.if uMsg==WM_SETCURSOR
		invoke SetCursor,hCursor
	.else
	invoke CallWindowProc,OldWndProc4,hWnd,uMsg,wParam,lParam
	ret
	.endif
	
	xor eax,eax
	ret
EditCustomCursor4 EndP

EditCustomCursor5	proc	hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	.if uMsg==WM_SETCURSOR
		invoke SetCursor,hCursor
	.else
	invoke CallWindowProc,OldWndProc5,hWnd,uMsg,wParam,lParam
	ret
	.endif
	
xor eax,eax
ret
EditCustomCursor5 EndP


FadeOut proc
	sub Transparency,5
	invoke SetLayeredWindowAttributes,handle,TransColor,Transparency,LWA_ALPHA or LWA_COLORKEY
	mov eax, Transparency
	shr eax,3
	add eax,10                 ; set fade out
	invoke uFMOD_SetVolume,eax
	cmp Transparency,0
	jne @f
	invoke SendMessage,handle,WM_CLOSE,0,0
	@@:
	ret
FadeOut EndP

FadeIn proc
	add Transparency,5
	invoke SetLayeredWindowAttributes,handle,TransColor,Transparency,LWA_ALPHA or LWA_COLORKEY
	mov eax, Transparency
	shr eax,3
	add eax,10  ; set fade in speed (speed must factor of transparency below               
	invoke uFMOD_SetVolume,eax
	cmp Transparency,235 ; set transparency window max 255
	jne @f
	invoke ShowWindow,hGen,1
	invoke ShowWindow,hExit,1
	invoke KillTimer,handle,222
	@@:
	ret
FadeIn EndP

MD5hash			proc	uses eax ebx ecx edx edi esi,ptBuffer:dword,dtBufferLength:dword,ptMD5Result:dword
	local	dta:dword,dtb:dword,dtc:dword,dtd:dword

	; phase I � padding
	mov	edi,ptBuffer
	mov	eax,dtBufferLength

	inc	eax
	add	edi,eax
	mov	byte ptr [edi-1],080h

	xor	edx,edx

	mov	ebx,64
	div	ebx

	neg	edx
	add	edx,64

	cmp	edx,8
	jae	@f

	add	edx,64

	@@:			
	mov	ecx,edx
	xor	al,al
	rep	stosb

	mov	eax,dtBufferLength

	inc	edx
	add	dtBufferLength,edx

	xor	edx,edx

	mov	ebx,8
	mul	ebx

	mov	dword ptr [edi-8],eax
	mov	dword ptr [edi-4],edx

	mov	edx,dtBufferLength

	mov	edi,ptBuffer

	; phase II � chaining variables initialization
	mov	esi,ptMD5Result
	assume	esi:ptr MD5RESULT

	mov dword ptr ds:[esi],04552205bh		;aha
	mov dword ptr ds:[esi+4],0474e4556h		;aha
	mov dword ptr ds:[esi+8],072432045h		;aha
	mov dword ptr ds:[esi+0ch],05d207765h	;aha


	; phase III � hashing
	hashloop:		
		mov	eax,[esi].dtA
		mov	dta,eax
		mov	eax,[esi].dtB
		mov	dtb,eax
		mov	eax,[esi].dtC
		mov	dtc,eax
		mov	eax,[esi].dtD
		mov	dtd,eax

		; round 1
		FF	dta,dtb,dtc,dtd,dword ptr [edi+00*4],07,0d76aa478h
		FF	dtd,dta,dtb,dtc,dword ptr [edi+01*4],12,0e8c7b756h
		FF	dtc,dtd,dta,dtb,dword ptr [edi+02*4],17,0242070dbh
		FF	dtb,dtc,dtd,dta,dword ptr [edi+03*4],22,0c1bdceeeh
		FF	dta,dtb,dtc,dtd,dword ptr [edi+04*4],07,0f57c0fafh
		FF	dtd,dta,dtb,dtc,dword ptr [edi+05*4],12,04787c62ah
		FF	dtc,dtd,dta,dtb,dword ptr [edi+06*4],17,0a8304613h
		FF	dtb,dtc,dtd,dta,dword ptr [edi+07*4],22,0fd469501h
		FF	dta,dtb,dtc,dtd,dword ptr [edi+08*4],07,0698098d8h
		FF	dtd,dta,dtb,dtc,dword ptr [edi+09*4],12,08b44f7afh
		FF	dtc,dtd,dta,dtb,dword ptr [edi+10*4],17,0ffff5bb1h
		FF	dtb,dtc,dtd,dta,dword ptr [edi+11*4],22,0895cd7beh
		FF	dta,dtb,dtc,dtd,dword ptr [edi+12*4],07,06b901122h
		FF	dtd,dta,dtb,dtc,dword ptr [edi+13*4],12,0fd987193h
		FF	dtc,dtd,dta,dtb,dword ptr [edi+14*4],17,0a679438eh
		FF	dtb,dtc,dtd,dta,dword ptr [edi+15*4],22,049b40821h

		; round 2
		GG	dta,dtb,dtc,dtd,dword ptr [edi+01*4],05,0f61e2562h
		GG	dtd,dta,dtb,dtc,dword ptr [edi+06*4],09,0c040b340h
		GG	dtc,dtd,dta,dtb,dword ptr [edi+11*4],14,0265e5a51h
		GG	dtb,dtc,dtd,dta,dword ptr [edi+00*4],20,0e9b6c7aah
		GG	dta,dtb,dtc,dtd,dword ptr [edi+05*4],05,0d62f105dh
		GG	dtd,dta,dtb,dtc,dword ptr [edi+10*4],09,002441453h
		GG	dtc,dtd,dta,dtb,dword ptr [edi+15*4],14,0d8a1e681h
		GG	dtb,dtc,dtd,dta,dword ptr [edi+04*4],20,0e7d3fbc8h
		GG	dta,dtb,dtc,dtd,dword ptr [edi+09*4],05,021e1cde6h
		GG	dtd,dta,dtb,dtc,dword ptr [edi+14*4],09,0c33707d6h
		GG	dtc,dtd,dta,dtb,dword ptr [edi+03*4],14,0f4d50d87h
		GG	dtb,dtc,dtd,dta,dword ptr [edi+08*4],20,0455a14edh
		GG	dta,dtb,dtc,dtd,dword ptr [edi+13*4],05,0a9e3e905h
		GG	dtd,dta,dtb,dtc,dword ptr [edi+02*4],09,0fcefa3f8h
		GG	dtc,dtd,dta,dtb,dword ptr [edi+07*4],14,0676f02d9h
		GG	dtb,dtc,dtd,dta,dword ptr [edi+12*4],20,08d2a4c8ah

		; round 3
		HH	dta,dtb,dtc,dtd,dword ptr [edi+05*4],04,0fffa3942h
		HH	dtd,dta,dtb,dtc,dword ptr [edi+08*4],11,08771f681h
		HH	dtc,dtd,dta,dtb,dword ptr [edi+11*4],16,06d9d6122h
		HH	dtb,dtc,dtd,dta,dword ptr [edi+14*4],23,0fde5380ch
		HH	dta,dtb,dtc,dtd,dword ptr [edi+01*4],04,0a4beea44h
		HH	dtd,dta,dtb,dtc,dword ptr [edi+04*4],11,04bdecfa9h
		HH	dtc,dtd,dta,dtb,dword ptr [edi+07*4],16,0f6bb4b60h
		HH	dtb,dtc,dtd,dta,dword ptr [edi+10*4],23,0bebfbc70h
		HH	dta,dtb,dtc,dtd,dword ptr [edi+13*4],04,0289b7ec6h
		HH	dtd,dta,dtb,dtc,dword ptr [edi+00*4],11,0eaa127fah
		HH	dtc,dtd,dta,dtb,dword ptr [edi+03*4],16,0d4ef3085h
		HH	dtb,dtc,dtd,dta,dword ptr [edi+06*4],23,004881d05h
		HH	dta,dtb,dtc,dtd,dword ptr [edi+09*4],04,0d9d4d039h
		HH	dtd,dta,dtb,dtc,dword ptr [edi+12*4],11,0e6db99e5h
		HH	dtc,dtd,dta,dtb,dword ptr [edi+15*4],16,01fa27cf8h
		HH	dtb,dtc,dtd,dta,dword ptr [edi+02*4],23,0c4ac5665h

		; round 4
		II	dta,dtb,dtc,dtd,dword ptr [edi+00*4],06,0f4292244h
		II	dtd,dta,dtb,dtc,dword ptr [edi+07*4],10,0432aff97h
		II	dtc,dtd,dta,dtb,dword ptr [edi+14*4],15,0ab9423a7h
		II	dtb,dtc,dtd,dta,dword ptr [edi+05*4],21,0fc93a039h
		II	dta,dtb,dtc,dtd,dword ptr [edi+12*4],06,0655b59c3h
		II	dtd,dta,dtb,dtc,dword ptr [edi+03*4],10,08f0ccc92h
		II	dtc,dtd,dta,dtb,dword ptr [edi+10*4],15,0ffeff47dh
		II	dtb,dtc,dtd,dta,dword ptr [edi+01*4],21,085845dd1h
		II	dta,dtb,dtc,dtd,dword ptr [edi+08*4],06,06fa87e4fh
		II	dtd,dta,dtb,dtc,dword ptr [edi+15*4],10,0fe2ce6e0h
		II	dtc,dtd,dta,dtb,dword ptr [edi+06*4],15,0a3014314h
		II	dtb,dtc,dtd,dta,dword ptr [edi+13*4],21,04e0811a1h
		II	dta,dtb,dtc,dtd,dword ptr [edi+04*4],06,0f7537e82h
		II	dtd,dta,dtb,dtc,dword ptr [edi+11*4],10,0bd3af235h
		II	dtc,dtd,dta,dtb,dword ptr [edi+02*4],15,02ad7d2bbh
		II	dtb,dtc,dtd,dta,dword ptr [edi+09*4],21,0eb86d391h

		mov	eax,dta
		add	[esi].dtA,eax
		mov	eax,dtb
		add	[esi].dtB,eax
		mov	eax,dtc
		add	[esi].dtC,eax
		mov	eax,dtd
		add	[esi].dtD,eax

		add	edi,64

		sub	edx,64
	jnz	hashloop

	; phase IV � results

	mov	ecx,4

	@@:	
		mov	eax,dword ptr [esi]
		xchg	al,ah
		rol	eax,16
		xchg	al,ah
		mov	dword ptr [esi],eax

		add	esi,4

	loop	@b

	mov esi, ptMD5Result
  	 invoke wsprintf, ADDR MD5Result, ADDR FormatMD5, [esi].dtA, [esi].dtB, [esi].dtC, [esi].dtD

	ret

MD5hash	endp

Generate proc hWnd:HWND  ;<----| example of algo.

	local big_n: dword
	local big_d: dword
	local big_c: dword
	local big_m: dword

	; hash inputed name with MD5
	mov eax,NameLen
	invoke MD5hash,addr NameBuffer,eax,addr MD5Result

	mov ebx,offset MD5Result
	mov eax,0fh
	mov byte ptr ds:[ebx+eax],0

	; copy first 8 bytes from MD5 result to part 1
	mov edi,offset Part1
	mov esi,offset MD5Result
	mov ecx,8
	rep movs byte ptr es:[edi],byte ptr es:[esi]
	
	; copy the other half MD5 result to part 2
	mov edi,offset Part2
	mov esi,offset MD5Result
	add esi,8
	mov ecx,7
	rep movs byte ptr es:[edi],byte ptr es:[esi]

	; big number initialization
	invoke _BigCreate,0
	mov big_n,eax
	invoke _BigCreate,0
	mov big_d,eax
	invoke _BigCreate,0
	mov big_c,eax
	invoke _BigCreate,0
	mov big_m,eax
	
	; set N and D
	invoke _BigIn,addr _n,10h,big_n
	invoke _BigIn,addr _d,10h,big_d
	
	; set M as bytes from part 1
	invoke _BigInBytes,addr Part1,8,100h,big_m
	; RSA decrypt  M^D mod N
	invoke _BigPowMod,big_m,big_d,big_n,big_c
	; output signature to base 16 (hexadecimal)
	invoke _BigOutB16,big_c,addr RSABuff
	
	; encrypt part 2 with base64
	push offset B64Buff
	push 7
	push offset Part2
	call Base64Encode
	
	; formatting serial = (rsa)-(base64)!
	invoke lstrcpy,addr FinalSerial,addr RSABuff
	invoke lstrcat,addr FinalSerial,chr$("-")
	invoke lstrcat,addr FinalSerial,addr B64Buff
	invoke lstrcat,addr FinalSerial,chr$("!")
	
	; show serial to end user
	invoke SetDlgItemText,hWnd,IDC_SERIAL,addr FinalSerial
	; set in clipboard
	invoke SetClipboard,addr FinalSerial
	; free memory
	invoke BurnProc,hWnd
	invoke _BigDestroy, big_n
	invoke _BigDestroy, big_d
	invoke _BigDestroy, big_m
	invoke _BigDestroy, big_c
	ret
Generate EndP

SetClipboard	proc	txtSerial:DWORD
	
	invoke lstrlen, txtSerial
	inc eax
	mov sLen, eax
	invoke OpenClipboard, 0
	invoke GlobalAlloc, GHND, sLen
	mov hMem, eax
	invoke GlobalLock, eax
	mov pMem, eax
	mov esi, txtSerial
	mov edi, eax
	mov ecx, sLen
	rep movsb
	invoke EmptyClipboard
	invoke GlobalUnlock, hMem
	invoke SetClipboardData, CF_TEXT, hMem
	invoke CloseClipboard
	
	ret

SetClipboard endp

BurnProc	proc	hWnd:DWORD

	invoke RtlZeroMemory,addr FinalSerial,sizeof FinalSerial
	invoke RtlZeroMemory,addr RSABuff,sizeof RSABuff
	invoke RtlZeroMemory,addr B64Buff,sizeof B64Buff
	invoke RtlZeroMemory,addr NameBuffer,sizeof NameBuffer
	invoke RtlZeroMemory,addr MD5Result,sizeof MD5Result

	ret
BurnProc EndP

IFDEF USEPNG
	LoadPng proc ID:DWORD,pSize:DWORD
		LOCAL pngInfo:PNGINFO
	
		invoke PNG_Init, addr pngInfo
		invoke PNG_LoadResource, addr pngInfo, hInstance, ID
		.if !eax
			xor eax, eax
			jmp @cleanup
		.endif
		invoke PNG_Decode, addr pngInfo
		.if !eax
			xor eax, eax
			jmp @cleanup
		.endif
		invoke PNG_CreateBitmap, addr pngInfo, handle, PNG_OUTF_AUTO, FALSE
		.if		!eax
			xor eax, eax
			jmp @cleanup
		.endif
		mov edi,pSize
		.if edi!=0
			lea esi,pngInfo
			movsd
			movsd
		.endif
		
	@cleanup:
		push eax	
		invoke PNG_Cleanup, addr pngInfo
		
		pop eax
		ret
	
	LoadPng ENDP
ENDIF

InitializeKeygen proc hWnd:HWND

	invoke LoadCursor,hInstance,300
	mov hCursor,eax
	IFDEF USEBMP
	invoke LoadImage,hInstance,100,IMAGE_BITMAP,0,0,LR_DEFAULTSIZE
	ELSEIFDEF USEPNG
	invoke LoadPng,100,addr sizeFrame
	ENDIF
	
	IFDEF USEJPG
	invoke BitmapFromResource, hInstance, 100
	ENDIF
	
	mov hBmp,eax
	invoke CreatePatternBrush,hBmp
	mov hBrush,eax
	invoke FindResource,hInstance,101,RT_RCDATA
	mov hResInfo,eax
	invoke LoadResource,hInstance,hResInfo
	mov hResData,eax
	invoke SizeofResource,hInstance,hResInfo
	mov hResSize,eax
	invoke LockResource,hResData
	mov hRgnData,eax
	invoke ExtCreateRegion,NULL,hResSize,hRgnData
	invoke SetWindowRgn,hWnd,eax,TRUE
	invoke CreateFontIndirect,addr MyFont
	push ebx
	xchg eax,ebx
	invoke SendDlgItemMessage,hWnd,IDC_NAME,WM_SETFONT,ebx,0
	invoke SendDlgItemMessage,hWnd,IDC_SERIAL,WM_SETFONT,ebx,0
	invoke SendDlgItemMessage,hWnd,IDC_STATUS,WM_SETFONT,ebx,0
	pop ebx
	
	invoke LoadIcon, hInstance, KIcon
	invoke SendMessage, hWnd, WM_SETICON, 1, eax

	invoke SetWindowText,hWnd,addr szApp
	
;*****[Buttons]******************
	
	invoke ImageButton,hWnd,19,268,110,112,111,IDC_GENERATE ;<------| (x,y,UP,DOWN,OVER)
	invoke ImageButton,hWnd,308,268,120,122,121,IDC_EXIT
	
;********************************

	cmp NameNeeded,0
	jnz @f
	invoke GetDlgItem,hWnd,IDC_NAME
	invoke SendMessage,eax,EM_SETREADONLY,TRUE,NULL
@@:
	invoke SetDlgItemText,hWnd,IDC_NAME,SADD("Jowy [CiM]") ;<------| Default name 
	
@OK:	
	if Music
	   IFDEF USETIMER
	    invoke uFMOD_SetVolume,uFMOD_MIN_VOL
	   ENDIF
		invoke uFMOD_PlaySong,200,hInstance,XM_RESOURCE
	endif

	Ret
InitializeKeygen EndP

IFDEF USETHREAD

ScrollerInit proc hWnd:HWND
	
	invoke MakeDialogTransparentValue,hWnd,TRANSPARENT_VALUE
	
	m2m scr.scroll_hwnd,hWnd
		
		mov scr.scroll_text,offset ScrollText
		
		mov scr.scroll_x,10
		mov scr.scroll_y,10
		
		mov scr.scroll_width,380
		
		invoke CreateFontIndirect,addr ScrollFont
		mov scr.scroll_hFont,eax
		
		mov scr.scroll_alpha,TRANSPARENT_VALUE
		RGB  255, 255,255
		mov scr.scroll_textcolor,eax
		
		invoke CreateScroller,addr scr
	Ret
ScrollerInit EndP

MakeDialogTransparentValue proc _dialoghandle:dword,_value:dword
	
	pushad
	
	invoke GetModuleHandle,chr$("user32.dll")
	invoke GetProcAddress,eax,chr$("SetLayeredWindowAttributes")
	.if eax!=0
		;---yes, its win2k/xp system---
		mov edi,eax
		invoke GetWindowLong,_dialoghandle,GWL_EXSTYLE	;get EXSTYLE
		
		.if _value==255
			xor eax,WS_EX_LAYERED	;remove WS_EX_LAYERED
		.else
			or eax,WS_EX_LAYERED	;eax = oldstlye + new style(WS_EX_LAYERED)
		.endif
		
		invoke SetWindowLong,_dialoghandle,GWL_EXSTYLE,eax
		
		.if _value<255
			push LWA_ALPHA
			push _value						;set level of transparency
			push 0							;transparent color
			push _dialoghandle				;window handle
			call edi
		.endif	
	.endif
	
	popad
	ret
MakeDialogTransparentValue endp

CreateScroller proc _scrollstruct:dword
	
	LOCAL ThreadID		:DWORD
	
	invoke CreateThread,0,0,addr ScrollThread,_scrollstruct,0,addr ThreadID
	invoke CloseHandle,eax
	
	ret
CreateScroller endp


PauseScroller proc _scrollstruct:dword
	
	mov eax,_scrollstruct
	assume eax:ptr SCROLLER_STRUCT
	
	mov cl,[eax].scroll_pause
	
	.if cl==0
		inc cl
	.else
		dec cl
	.endif		
	
	mov [eax].scroll_pause,cl
		
	assume eax:nothing
	
	ret
PauseScroller endp


;---private---
ScrollThread proc _scrollstruct:dword
	
	LOCAL local_hdc_window		:DWORD
	LOCAL local_hdc_window_copy	:DWORD
	LOCAL local_hdc_text		:DWORD
	
	LOCAL local_window_copy_width	:DWORD
	LOCAL local_window_copy_height	:DWORD
	
	LOCAL local_scroll_height	:DWORD
	
	LOCAL local_text_len		:DWORD
	LOCAL local_text_width		:DWORD
	LOCAL local_text_endpos		:DWORD
	
	LOCAL local_sz 			:SIZEL
	
	
	;---scroller structure---
	mov esi,_scrollstruct
	assume esi:ptr SCROLLER_STRUCT
	
	
	;---wait before draw---
	mov eax,[esi].scroll_wait
	.if eax<500
		mov eax,500
	.endif	
	invoke Sleep,eax		;important!
	
	
	;---Textlen---
	invoke lstrlen,[esi].scroll_text
	mov local_text_len,eax
	
	
	
	;---get window dc---
	invoke GetDC,[esi].scroll_hwnd
	mov local_hdc_window,eax
	
	
	
	;---HDC for text---
	invoke GetDC,0
	invoke CreateCompatibleDC,eax
	mov local_hdc_text,eax
	
	;---use custom font---
	invoke SelectObject,eax,[esi].scroll_hFont
	
	;---get Textheight and width---
	invoke GetTextExtentPoint,local_hdc_text,[esi].scroll_text,local_text_len,addr local_sz
	
	m2m local_scroll_height,local_sz.y
	m2m local_text_width,local_sz.x
	
	;---..hdc for text---
	invoke CreateCompatibleBitmap,local_hdc_window,[esi].scroll_width,local_scroll_height
	invoke SelectObject,local_hdc_text,eax
	
	
	
	;---HDC for windowcopy---
	invoke GetDC,0
	invoke CreateCompatibleDC,eax
	mov local_hdc_window_copy,eax
	
	;---calc size for windowcopy---
	mov eax,[esi].scroll_x
	add eax,[esi].scroll_width
	mov local_window_copy_width,eax
	
	mov ecx,[esi].scroll_y
	add ecx,local_scroll_height
	mov local_window_copy_height,ecx
	
	;---...do window copy---
	invoke CreateCompatibleBitmap,local_hdc_window,eax,ecx
	invoke SelectObject,local_hdc_window_copy,eax
	
	invoke BitBlt,local_hdc_window_copy,0,0,local_window_copy_width,local_window_copy_height,local_hdc_window,0,0,SRCCOPY
	
	
	
	;---Set Text Color---
	invoke	SetBkMode,local_hdc_text,TRANSPARENT
	invoke	SetTextColor,local_hdc_text,[esi].scroll_textcolor
	
	
	;---for transparent windows---
	invoke GetModuleHandle,chr$("user32.dll")
	invoke GetProcAddress,eax,chr$("SetLayeredWindowAttributes")
	mov edi,eax
	
	;---calc endposition of text---
	xor eax,eax
	sub eax,local_text_width
	sub eax,8
	mov local_text_endpos,eax
	
	
	;---prepare loop---
	mov ebx,[esi].scroll_width	;ebx=text position
	add ebx,4
	

	@loop:
	
	.if [esi].scroll_pause==0
		
		;---draw background for scroll gfx---
		invoke BitBlt,local_hdc_text,0,0,[esi].scroll_width,local_scroll_height,local_hdc_window_copy,[esi].scroll_x,[esi].scroll_y,SRCCOPY
		
		;---draw scrolltext on background---
		invoke TextOut,local_hdc_text,ebx,0,[esi].scroll_text,local_text_len
		
		;---fade text in and out---
		invoke BlendBitmap,local_hdc_text,local_hdc_window_copy,local_scroll_height,[esi].scroll_width,[esi].scroll_x,[esi].scroll_y,[esi].scroll_textcolor
		
		;---draw scrolltext on window---
		invoke BitBlt,local_hdc_window,[esi].scroll_x,[esi].scroll_y,[esi].scroll_width,local_scroll_height,local_hdc_text,0,0,SRCCOPY			

		dec ebx
	
		.if ebx==local_text_endpos
			;---reset text position to begining---
			mov ebx,[esi].scroll_width
		.endif
		
		;---important for transparent window---
		.if edi!=0
			movzx eax,[esi].scroll_alpha
			.if al!=0 && al!=255
				Scall edi,[esi].scroll_hwnd,0,eax,LWA_ALPHA
			.endif
		.endif	
	.endif
	
	invoke Sleep,15
	
	jmp @loop
	
	assume esi:nothing
	
	ret
ScrollThread endp


;---Blend Routine---
;align 16
BlendBitmap proc uses esi edi ebx _text_hdc:dword,_window_hdc:dword,_height:dword,_width:dword,_x:dword,_y:dword,_textcolor:dword
	
	LOCAL local_blendvalue	:DWORD
	LOCAL local_fadeout_pos	:DWORD
	
	.const
	FADE_WIDTH	equ 25
	FADE_STEP	equ 4
	
	.code
	mov eax,_width
	
	.if eax>=2*FADE_WIDTH	;only works with minimum width
		
		
		;---calc x-coordinate where to start fade out---
		sub eax,FADE_WIDTH
		mov local_fadeout_pos,eax
		
		
		;---prepare loop--
		xor esi,esi		;x=width
		mov local_blendvalue,0
	
		
		.while esi!=_width
			
			xor edi,edi	;y=height
			
			.while edi!=_height
				
				;---get pixel of scrolltext hdc---
				invoke GetPixel,_text_hdc,esi,edi
				.if eax==_textcolor
					mov ebx,eax
					
					;---get correct pixel of source window---
					mov ecx,esi
					add ecx,_x
					
					mov edx,edi
					add edx,_y
					invoke GetPixel,_window_hdc,ecx,edx
					
					
					invoke BlendPixel,eax,ebx,local_blendvalue
					invoke SetPixel,_text_hdc,esi,edi,eax
					
				.else
					mov eax,ebx	
				.endif
				
				inc edi
			.endw
			
			
			;---for fading---
			.if 	esi<FADE_WIDTH
				add local_blendvalue,FADE_STEP	;4 * 25pixel = 100 %
				
			.elseif esi==FADE_WIDTH
				mov esi,local_fadeout_pos
					
			.elseif esi>local_fadeout_pos
				sub local_blendvalue,FADE_STEP	;4 * 25pixel = 100 %
				
			.endif	
	
			inc esi	
		.endw
	.endif	
	
	ret
BlendBitmap endp


;align 16
BlendPixel proc uses esi edi ebx _sourcepixel:dword,_overpixel:dword,_transparency:dword
	
	;---parameters---
	;_sourcepixel  : Pixel of Backgroundimage
	;_overpixel    : Pixel which overlaps the sourcepixel
	;_transparency : 5 - 90 %  (using 100 % is stupid)
	
	;---Color Format---
	; 00 00 00 00
	; xx BB GG RR
	
	.if _transparency<100
		
		mov eax,_overpixel
		.if eax!=_sourcepixel
			
			;---calc new colors of _sourcepixel---
			mov eax,100
			sub eax,_transparency
			
			invoke PercentColor,_sourcepixel,eax
			mov ebx,eax
			
			
			;---calc new colors of _overpixel---	
			invoke PercentColor,_overpixel,_transparency
			
			
			;---add each color---
			xor esi,esi
			
			.while esi!=3
				
				movzx edx,al
				movzx ecx,bl
				
				add edx,ecx
				.if edx>255
					mov dl,255
				.endif
				
				mov al,dl
					
				ror eax,8
				ror ebx,8
				
				inc esi
			.endw
			
			rol eax,3*8
		.else	
			mov eax,_overpixel
		.endif	
	.else	
		mov eax,_overpixel
	
	.endif
	
	ret
BlendPixel endp


;align 16
PercentValue proc _value:dword,_percent:dword

	mov eax,_value
	
	mul _percent
	
	mov ecx,100
	
	xor edx,edx
	div ecx
	
	ret
PercentValue endp


;align 16
PercentColor proc uses esi edi ebx _color:dword,_percent:dword
	
	;---reduce color by certain percent---
	
	mov ebx,_color
	
	;---Red--
	movzx eax,bl
	
	invoke PercentValue,eax,_percent
	mov edi,eax
	
	
	;---Green---
	ror ebx,8
	movzx eax,bl
	invoke PercentValue,eax,_percent
	
	ror edi,8 
	mov edx,edi
	mov dl,al
	mov edi,edx
	
	
	;---Blue---
	ror ebx,8
	movzx eax,bl
	invoke PercentValue,eax,_percent
	
	ror edi,8 
	mov edx,edi
	mov dl,al
	mov edi,edx
	
	
	;---return new color value---
	rol edi,16
	mov eax,edi
	
	ret
PercentColor endp
ENDIF

IFDEF USETIMER
	Timer_Proc proc hWin:DWORD, hDC:DWORD
	
		.if init == FALSE
			 mov init, TRUE ; only do the copy once
			
			 invoke CreateCompatibleDC, hDC
			 mov hdcSave, eax
			 invoke SelectObject,hdcSave,hBmp
			 mov hOld, eax
			 invoke CreateCompatibleDC, hDC
			 mov hdcTemp, eax
			 invoke CreateCompatibleBitmap,hDC,400,300
			 mov memSave, eax
			 invoke SelectObject,hdcTemp,memSave
			 
			 ; save a copy of the client area
			 invoke BitBlt,hDC,0,0,400,10,hdcSave,0,0,SRCCOPY
		      
		.endif
		
		 ; do the following every timer period
		 
		 ; create temporary copy
		 invoke BitBlt,hdcTemp,0,0,400,300,hdcSave,0,0,SRCCOPY
		
		 ;set text colour on transparent background
		 invoke SetBkMode, hdcTemp, TRANSPARENT
		 RGB  255, 255,255 ; set text colour
		 invoke SetTextColor,hdcTemp,eax
		 invoke CreateFontIndirect,addr ScrollFont
		 invoke SelectObject,hdcTemp,eax
		 
		 invoke lstrlen, addr ScrollText
		 mov ScrollLen, eax
		 mov eax, posn
		 sub eax, Blanking
		
		; write the scroll text
		 invoke TextOut, hdcTemp, eax ,YScroll, addr ScrollText, ScrollLen
		 
		  dec posn ; move 1 pixel left
		  
		 .if posn <= 0 ; need to reset pixel position?
			mov posn, XRScroll+Blanking+StartDelay
		 .endif
		
		 ; copy the temporary saved copy to the client screen area
		 invoke BitBlt,hDC,XScroll,YScroll,XRScroll,YScroll+20,hdcTemp,XScroll,YScroll,SRCCOPY
			
		ret 0
	
	Timer_Proc ENDP

	Paint_Proc proc hWin:DWORD, hDC:DWORD, movit:DWORD
		invoke BitBlt,hDC,0,0,400,10,hdcSave,0,0,SRCCOPY
	    	ret 0
	Paint_Proc ENDP
ENDIF

END code
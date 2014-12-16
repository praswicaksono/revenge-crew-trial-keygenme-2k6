; -----------+ NEW FUNCTION :) +-----------

; scroller type
;USETIMER    = 1
USETHREAD  = 1

; background image format
USEPNG	    = 1
;USEBMP		= 1
;USEJPG		= 1

; Anti debug code
USEANTIDBG  =   1

; Button Image Type
PNGBTN		=	1
;JPGBTN		=	1
;BMPBTN		=	1

include kernel32.inc
include user32.inc
include windows.inc
include gdi32.inc
include masm32.inc
include ole32.inc
include oleaut32.inc
include comctl32.inc
include MyMacros.asm
include macros.asm

includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
includelib ole32.lib
includelib oleaut32.lib
includelib comctl32.lib
includelib masm32.lib

IFDEF USETHREAD
	;include textscroller.inc
	;includelib textscroller.lib
	SCROLLER_STRUCT struct
		scroll_hwnd		dd ? ;handle of window where to draw
		scroll_text		dd ? ;pointer scrolltext
		scroll_x		dd ? ;x position
		scroll_y		dd ? ;y position
		scroll_width		dd ? ;width of scroller
		scroll_hFont		dd ? ;Handle of Font
		scroll_textcolor	dd ? ;example: 00F7DDCCh (00BBGGRR)
		scroll_alpha		db ? ;value for transparency (if using it on WS_EX_LAYERED window)
		scroll_wait		dd ? ;wait time (milliseconds) before draw scrolltext
		scroll_pause		db ? ;dont modify this! Use PauseScroller function!
		SCROLLER_STRUCT ends
	
		CreateScroller	PROTO :DWORD
		PauseScroller	PROTO :DWORD
		ScrollThread	PROTO :DWORD
		BlendBitmap		PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
		BlendPixel		PROTO :DWORD,:DWORD,:DWORD
		PercentValue	PROTO :DWORD,:DWORD
		PercentColor	PROTO :DWORD,:DWORD
ENDIF

IFDEF USEPNG
	include	GFX\pnglib.inc
	includelib	GFX\pnglib.lib
ENDIF

IFDEF USEJPG
	include GFX\BmpFrom.inc
	include GFX\image.inc
	includelib GFX\image.lib
ENDIF


if Music
	include winmm.inc
	includelib winmm.lib
	include SFX/ufmod.inc
	includelib SFX/ufmod.lib

endif

include Keygen\Base64.asm
include Keygen\Biglib.inc
includelib Keygen\Biglib.lib

DlgProc		       		proto:DWORD,:DWORD,:DWORD,:DWORD
Generate	       			proto:DWORD
LoadPng			   	proto:DWORD,:DWORD
BurnProc		   		proto:DWORD
Paint_Proc   	   		proto:DWORD,:DWORD,:DWORD
Timer_Proc		   	proto:DWORD,:DWORD
InitializeKeygen   		proto:DWORD
EditCustomCursor   	proto:DWORD,:DWORD,:DWORD,:DWORD
EditCustomCursor2  	proto:DWORD,:DWORD,:DWORD,:DWORD
EditCustomCursor3  	proto:DWORD,:DWORD,:DWORD,:DWORD
EditCustomCursor4  	proto:DWORD,:DWORD,:DWORD,:DWORD
EditCustomCursor5  	proto:DWORD,:DWORD,:DWORD,:DWORD
MakeDialogTransparentValue	proto:DWORD,:DWORD
SetClipboard	   		proto:DWORD
ScrollerInit       			proto:HWND
FadeIn			   	proto
FadeOut			   	proto

MD5hash				proto:DWORD,:DWORD,:DWORD

MD5RESULT		STRUCT
	dtA		dd	?
	dtB		dd	?
	dtC		dd	?
	dtD		dd	?
MD5RESULT		ENDS

.data

NameNeeded		BOOL	TRUE

;**********-ScrollText-**************************************************************
IFDEF USETHREAD
	scr						SCROLLER_STRUCT <>
	lf						LOGFONT<>
	TRANSPARENT_VALUE		equ 220

ELSEIFDEF USETIMER
	hOld    		dd 0
	hdcSave 		dd 0  ; saved copy of the client area
	hdcTemp 		dd 0  ; temporary saved copy of the client area
	memSave 	dd 0
	ScrollLen   	dd 0
	posn    		dd 0
	init    		dd FALSE
ENDIF

; Change this freely :P
ScrollFont		LOGFONT <-12,0,0,0,FW_NORMAL,0,0,0,0,3,2,1,34,"Tahoma">

ScrollText	    		db		"-+Crack iN Morocco+-                                                "
			    	db		"Presents another Quality release                                                "
			    	db		"Revenge-Crew Trial KeygenMe 2006 - KeyGen                                                "
			    	db		"Protection: RSA-64 + MD5+ Base64                                                "
			    	db		"KeyGen by Jowy [CiM]                                                ",0
;************************************************************************************

szApp			db		"-+Crack iN Morocco+-",0 
MyFont			LOGFONT <-12,0,0,0,FW_NORMAL,1,0,0,0,3,2,1,34,"courier new">  ;<------| Main window font params
MaxName		    	equ		15
MinName		    	equ		4

;**********-Hints-;******************************************************************
Ready	            	db	 "Good!! Click on <generate> to make/copy your key !!",0
PressGen        		db	 "Ready!! waiting your command",0
StatusError        	db	 "Dammit!! There is some error dude!!",0
LName    	        		db	 "Entered Name must be less than 15 chars!!",0
SName   	        		db	 "Entered Name must be more than 4 chars!!",0
WaitTxt			db	"Please wait keygen is calculating serial...",0
Success	    	    	db	 "Congratz!! Your key is coppied into clipboard !!",0
;************************************************************************************

IFDEF USEANTIDBG
	_ret                		dd  ?
	OldProtect          	dd 02040001h
ENDIF

Transparency		dd 0
TransColor		COLORREF	0FFFFFFFh

IFDEF USEPNG
	sizeFrame		dd	?,?
ENDIF
          
MoveDlg			BOOL		?
OldPos			POINT		<>
NewPos			POINT		<>
Rect				RECT		<>

_n			db	"80FCD59237BDF149",0
_d			db	"17911A5C18507F99",0
FormatMD5	db	"%.8X%.8X%.8X%.8X",0

.data?

hInstance			HINSTANCE	?
NewInstance     	HINSTANCE      ?
OldWndProc		dd	?
OldWndProc2		dd	?
OldWndProc3		dd	?
OldWndProc4		dd	?
OldWndProc5		dd	?
SavedESP        		dd     ?
hCursor			dd	?
handle			dd	?
hName			dd	?
hSerial			dd	?
hStatus			dd	?
hGen            		dd     ?
hExit           		dd     ?		
NameBuffer		db	128 dup(?)
NameLen			dd	?
FinalSerial		db	50 dup(?)
RSABuff			db	100 dup(?)
B64Buff			db	100 dup(?)
Part1			db	50 dup(?)
Part2			db	50 dup(?)
hashedName  		MD5RESULT     <?>
MD5Result		db	50 dup(?)
Counter			dd	?
Tick				dd	?
ZeroBuffer		equ	$-NameBuffer

pMusic  			dd	?
hMem			dd	?
pMem			dd	?
sLen			dd	?
hResInfo			dd	?
hResData		dd	?
hResSize			dd	?
hRgnData		dd	?
hBmp	    		dd	?
hBrush	    		dd	?

.const

IDD_DLGBOX		equ	500
IDC_NAME		equ	501
IDC_SERIAL		equ	502
IDC_STATUS      	equ  503
IDC_GENERATE	equ	505
IDC_EXIT			equ	506
KIcon			equ	504
WAIT_TIME		equ	200

; scroll text using WM_TIMER
IFDEF USETIMER
	XScroll  		equ	0 		; left side of scroll space
	XRScroll 		equ 400 		; right side of scroll space
	YScroll  		equ 10 		; Scroll height
	
	   
	Blanking    	equ	3800     	; need to increase as text string length increases
	StartDelay  	equ	50       	; delay before first appearance of text string
ENDIF
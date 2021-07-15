;************************************************
; ����஫��� AT-���������� �� 51-�� ����஫��� *
; ����� 3.2m ��� �奬� � ��ࠢ����� RESET	*
; � �����஢��� /WAIT ᨣ����� /KEYRD		*
; 15/11/2019 - 㢥��祭� ��㡨�� �⥪� �� 16����*
;************************************************
$mod52
;================================================
; ���⥫쭮��� ᨣ���� /WR �� �뢮�� ����஫���
; �� ������� movx ࠢ�� 6 ⠪⠬ �������.
; �� ��᮪�� ⠪⮢�� ���� �⮩ ���⥫쭮��
; �� 墠⠥� ��� ��������� �⥭�� ���� � 設� Z80.
; �᫨ �ᯮ�짮���� ��אַ� �ࠢ����� ��⮬ /WR,
; � ���⥫쭮��� ᨣ���� �㤥� ࠢ�� 12 ⠪⠬.
en_movx	equ	1	;1 - ࠧ�襭� movx
			;0 - ��אַ� �ࠢ�����
; ࠧ�襭�� ࠡ��� � ���뢠����
en_int	equ	0	;0 - �� ࠧ�襭
; ����� ⠪⮢�� ����� ���ப���஫���
ft_07	equ	0	;7 ���
ft_11	equ	1	;11.0592 ���
;------------------------------------------
; R1 - �।��騩 code key
; R2 - ⥪�騩 code key
; R3 - flags
;	d0 - Left Shift
;	d1 - Ctrl
;	d2 - ALT
;	d3
;	d4 - Caps Lock trigger
;	d5 - Num Lock trigger
;	d6 - Scroll Lock trigger
;	d7 - RUS(1)/LAT(0)
; R4 -	d0 - Right Shift
;-------------------------------------------
; �����
; ���� P1(A)
RS_CD	equ	P1.0	; PA0 - CD     input
RS_CTS	equ	P1.1	; PA1 - CTS    input
RS_RI	equ	P1.2	; PA2 - RI     input
RS_DTR	equ	P1.3	; PA3 - DTR    out
RS_RTS	equ	P1.4	; PA4 - RTS    out
SP_INT	equ	P1.5	; PA5 - INT_T  out
SP_RES	equ	P1.6	; PA6 - /RES  -out
SP_WT	equ	P1.7	; PA7 - W_ON  -out
; ���� P3
RS_RX	equ	P3.0	; P30 - RX     input
RS_TX	equ	P3.1	; P31 - TX    -output
KB_CLK	equ	P3.2	; P32 - CLK_K  input	INT0
SP_KBD	equ	P3.3	; P33 - /KEYRD inpit	INT1
SP_VE1	equ	P3.4	; P34 - VE1    input
KB_DAT	equ	P3.5	; P35 - DATA_K input
VWR	equ	P3.6	; P36 - /VWR  -output
VRD	equ	P3.7	; P37 - /VRD  -output
;-----------------------------------------
	dseg
	org	00h
; PAGE 00 - ������� ��࠭��
R0_00:  ds 1 		;R0
R1_00:  ds 1 		;R1 ���������� spec-cod
R2_00:  ds 1 		;R2 ⥪�騩 spec-cod
R3_00:  ds 1 		;R3 䫠�� 1 ��.������
R4_00:  ds 1 		;R4 䫠�� 2 ��.������
R5_00:  ds 1 		;R5 ⥪�騩 ᪠�-���
R6_00:  ds 1 		;R6 䫠� ��䨪�
R7_00:  ds 1 		;R7
;---------------------------
; PAGE 08 - ��࠭�� /RDKBD
	ds 8		;R0..R7
;---------------------------
; PAGE 10 - ��࠭�� /CLK_K
R0_10:	ds 1 		;R0
R1_10:	ds 1 		;R1
	ds 5 		;R2..R6
R7_10:	ds 1 		;R7
;---------------------------
; PAGE 18 - ��࠭�� RTC � Serial
adr_rt: ds 1		;R0 - 㪠��⥫� RTC
adr_rs: ds 1		;R1 - 㪠��⥫� �ਥ�� RS232
	ds 1		;R2 - RTC
	ds 1		;R3 - RTC
adr_rd: ds 1		;R4 - 㪠��⥫� ���� �ਥ��
cnt_rd: ds 1		;R5 - ���稪 �ਥ��
cnt_wr: ds 1		;R6 - ���稪 ��।��
rtc_to: ds 1		;R7 - RTC time-out
;--------------------------------------------
	org	20h
b_sadr: ds 1		;���� ᪠�-����
mode:	ds 1		;०�� ����஫���
;--------------------------------
flags:		ds 1
f_wait	  equ	flags.0	;䫠� �����
f_unpres  equ	flags.1	;䫠� �⦠�� ������
f_pref	  equ	flags.2	;䫠� ��䨪� E0h
f_press   equ	flags.3	;
f_decod   equ	flags.5 ;
;
stat_md:	ds 1	;⥪�騩 ����� ������
stat_rs:	ds 1	;⥪�騩 ����� RS232
f_int	  equ	stat_rs.7
;--------------------------------
adr_wr: ds 1		;⥪�騩 ���� � ���� ��।��稪�
adr_ws: ds 1		;⥪�騩 ���� ��� ����� � ���.
;
t_res:	ds 3		;���� ����஫쭮� ��ப�
;
len_bwr equ	8
buf_wr: 	ds len_bwr	;���� ��।��
;
len_brd equ	54-8		;����� ���� �ਥ��
len_ird	equ	50-8		;����� ���� ��� INT (�᫨ ࠧ�襭)
buf_rd: 	ds len_brd	;���� �ਥ��
		ds 0
;--------------------------------
	org	128-16-16
; Bufer KBD
buf_kbd:	ds 8		;���� ����������
; ���� �ᮢ
tics:		ds 1		;50 ⨪�� � ᥪ㭤�
b_time: 	ds 3		;ᥪ㭤�,������,���
b_date: 	ds 4		;����,�����,���,�⮫�⨥
b_stek: 	ds 16		;�⥪ -> �����
;*************************************************
; ���� ॠ�쭮�� �६���
f_tic	equ	50	;����� ⨪�� �.�.�  (��)
;f_proc	equ	7000	;����� ⠪�஢���� (���)
; �����.������� ⠩��� 0 ࠢ��
;KF_T0	equ	-f_proc*1000/12/f_tic
 if ft_07
KF_T0	equ	0D26Eh	; 7.0000 ���
 endif
 if ft_11
KF_T0	equ	0B800h	;11.0592 ���
 endif
;*****************************************
;**	������ �������� ��������	**
;*****************************************
CSEG
	ORG	000h
;-----------------------------------------
; ���⮢� ����
start:	ljmp	prog	;-> ����� �ணࠬ��
; ========================================
	ORG	003h
; External interrupt 0 ~\_ (⠪⮢�� ����������)
extint0:
	push	PSW
	push	ACC
	ajmp	L_23C	; int /CLK_K
; ========================================
	ORG	00Bh
; Timer interrupt 0 (���� ॠ�쭮�� �६���)
timint0:                ;3
	push	PSW	;2
	push	ACC     ;2
	ajmp	int_rtc ;2
			;9
; ========================================
	ORG	013h
; External interrupt 1 ~\_ (�⥭�� ���� KBD)
extint1:		;2
	push	PSW	;2
	push	ACC	;2
	push	DPH	;2
	ajmp	RD_KBD	;2  int /RDKEY
; ========================================
	ORG	01Bh
; Timer interrupt 1
timint1:reti
; ========================================
	ORG	023h
; Serial port interrupt (SERIAL)
serint: push	PSW
	push	ACC
	mov	PSW,#18h	;PAGE 18
	ajmp	ser_int
; ========================================
	ORG	02Ch
; Ver 3.1xx
VERS:	db	3,2		;3.2
 if ft_07
	db	0,7	;���⮢�� ����� � ���
 endif
 if ft_11
	db	1,1	;���⮢�� ����� � ���
 endif
;**********************************************
t_10	equ	10*4	;10 �ᥪ (40*0.25 �ᥪ)
; ����⠭� ��� 250 ��ᥪ ������ �� ⠪�. �����
 if ft_07
t_025	equ	73	;Ft=7 ���
 endif
 if ft_11
t_025	equ	115	;Ft=11.0592 ���	
 endif
;=============================================
; ���� ��������
reset:	clr	SP_RES		;RESET = 0
	acall	del_10ms	; ���⥫쭮��� ������
	setb	SP_RES		;RESET = 1
; �஢���� ���� ����஫쭮� ��ப�
	mov	R0,#t_res	;��砫� ����
	cjne	@R0,#'A',prog	; ��१���� �ணࠬ��
	inc	R0
	cjne	@R0,#'T',prog	;
	inc	R0
	cjne	@R0,#'M',prog	;
	ajmp	c0main		; � ������ 横� ࠡ���
; ��㧠 10 �ᥪ
del_10ms:
	mov	R1,#t_10 	;����⠭� ��� 10 �ᥪ
c_del:	mov	R0,#t_025	;����⠭� ��� 250 ��ᥪ
	djnz	R0,$		;t_05*2*12/Ft
	djnz	R1,c_del
	ret
;*********************************************
;******* START PROGRAMM **********************
;*********************************************
; �室 �� ����祭�� ��⠭��
prog:	mov	P1, #0FFh	;/RESET=1;W_ON=1
	mov	SP, #b_stek-1	;�����⥫� �⥪�
	mov	PSW,#00h
	acall	del_10ms	;��㧠 10 ms
	mov	R0,#t_res	;���� �����.��ப�
	mov	@R0,#'A'
	inc	R0
	mov	@R0,#'T'
	inc	R0
	mov	@R0,#'M'
;--------------------------------
; ������������� ����� �����������
	mov	SCON, #50h	; Serial Port Control
				;SM0,SM1 = 01;UART 8 ���
				;REN=1 �ਥ� ࠧ�襭
	mov	TMOD, #21h	;Timer1=mode2  8-���
				;Timer0=mode1 16-���
; Set Timer 0 (50 ����)
	call	set_T0		;
	mov	TCON, #55h	;Timer0,1-On/INT0,1 -Impuls
; Init MEM; 00h -> RAM 02h..38h
	mov	R0, #02h	;�� 02h
	mov	R1, #36h	; �� 38h
	clr	A		;
c_clr:	mov	@R0, A		; ���㫨��
	inc	R0
	djnz	R1,c_clr        ;
;-----------------------------------------------
; ��⠭���� ᪮��� ࠡ��� RS232
	mov	R6,#6		;19200 ���
	acall	set_speed
;
	mov	IP,#01h		; Interrupt Priority
	mov	IE,#97h		; Interrupt Enable INT0,1,T0,USART
	mov	P1,#7Fh		; P1.7 -> ������� /WAIT (W_ON=0)
;/======================================================\
c0main: acall	clr_buf 	; Clear buf KBD
;/-------------------------------
; Main Cikl Wait press key
c_main:
 if en_int	;�஢�ઠ ࠧ�襭�� ࠡ��� �� ���뢠���
; �஢���� 䫠� ����祭�� INT �� RS232
	jnb	f_int,no_int	;INT �� ࠧ�襭
; �᫨ 䫠� ��⠭�����, �஢���� �ॢ�襭�� ���稪�
	setb	SP_INT 		;P1.5	INT_T=1
	mov	A,cnt_rd	;���稪 �ਥ�� RS232
	cjne	A,#len_ird,no_int
; ������� ���뢠��� �᫨ � ���� ᫨誮� ����� ������
	clr	SP_INT		;P1.5	INT_T=0
;------
no_int:
 endif
	mov	R6, #0		; ���� ��䨪� E0h
	acall	L_102		; Wait Code KBD
	cjne	R5, #0E1h, L_66 ; Pause/Break ?
; �ਭ�� ���� ᪠�-��� ������ PAUSE
; Press Pause/Break [E1,14,77,E1,F0,14,F0,77]
	mov	R0, #7-2	; Count Code (-2 ���� F0)
;//---
L_5C:	acall	L_102		; Wait Code KBD
	djnz	R0, L_5C	; ����� 5 ����� + 2 ��䨪�
;\\---
; ��४������� � ०�� <�����> ��� 祣� ����
; ������� ���뢠��� �� /RDKBD (INT1)
	clr	EX1		; ������� INT1
	setb	f_wait		; Flag Wait = 1
	sjmp	c_main		; ����� ����⨩
;\---------------------------------------------
; �஢���� �� �����⨬���� ᪠�-����
L_66:	clr	C
	mov	A, R5
	subb	A, #84h 	; Scan-Code >= 84h
	jnc	c0main		;	err code kbd
; Scan-code normal 0..83h
	jnb	f_wait, L_7D	; ��� Pause
; �᫨ �� ����祭 ०�� Pause - �����
	clr	f_press 	; Clear Flag Press
	clr	f_wait		; Clear Flag Wait
	mov	DPTR, #0	; P2.0 = 0
	movx	@DPTR, A	; /VWR=0 (��� /WAIT)
	setb	EX1		; ������� INT1
	sjmp	c0main		; ����� �� ������
;\==================================================
; Press new key
L_7D:	mov	A, R5		; =Scan-code AT IBM
	mov	DPTR, #at2xt	; ������ ��४���஢��
	movc	A, @A+DPTR	;code set2(AT) -> set1(XT)
	jz	c_main		; �᫨ 00h -> non code
;\-------------------------------
; Yes normal scan-code set1
	mov	R7, A		; R7 = scan code set1(XT)
	jnb	f_unpres,no_unpres ;������ �����
; ������ ���饭�
	orl	R7_00,#80h	;��⠭����� ��� �⦠��
no_unpres:
	mov	R7_10,R7	;��������� ᪠�-��� set1
	dec	A
	mov	R5, A		; R5 = scan code - 1
;
	mov	A, mode 	;Mode
	jnz	L_AC		;�� 00h
; Mode = 00 (Spectrum KBD)
	mov	A, R5		;(Number key-1) (0..
	mov	DPTR, #L_527	;Code XT -> Code Spec
	movc	A, @A+DPTR	; -> Code key
	mov	R1, A
	acall	L_134		;code key -> bufer KBD
;/---- �஢���� ���� �� �।��� ������� ������
	mov	R0, #buf_kbd
	mov	R1, #8
	mov	A, #0FFh
L_9D:	anl	A, @R0
	inc	R0
	djnz	R1, L_9D
;\----
	xrl	A, #1Fh
	anl	A, #1Fh
; No press key �᫨ ��� = 00h
	clr	f_press 	;=0
	jz	L_B6		; No press KBD
; Yes press key
L_AC:	setb	f_press 	;=1
;==============================================
; mode non Spectrum KBD
L_B6:	mov	A, R2
	mov	R1, A		;R1=R2 - �।��騩 ��� ������
	setb	f_decod 	;
; ��砫��� ������஢���� ᪠�-���� ���������� IBM
	mov	A, R5		;
	rl	A		;
	mov	R5, A		;R5=Scan-code*2
	mov	DPTR, #L_471
	jb	f_unpres, L_C9	;������ �⦠�
;----
; new code key press
	movc	A, @A+DPTR	;Scan-code -> Sym Code
	jz	L_C9
;
	mov	R2, A		;R2_00=Sym-code 1
;----
; code key unpress
L_C9:	mov	A, R5		;
	inc	A
	movc	A, @A+DPTR
	mov	R5, A		;R5=Sym-code 2
	acall	L_16A		;Decode
	clr	f_decod
;
	ajmp	c_main		;Wait next key
;\--------------
;****************************************************
; ��楤�� �ਥ�� ᪠�-���� ����⮩ ������ ********
L_100:	acall	clr_buf 	; Clear Buf KBD
;/-----
;	Wait Code KBD
L_102:	clr	f_unpres	; Flag unpress = 0
;//----
; wait code after prefix 0E0h ��� 0F0h
L_104:	mov	A, R0_10	; R0 page 10 # 0?
	jnz	L_11E		; yes new code
; Bufer code KBD empty
L_108:	mov	A, R1_10	; R1 page 10 = 0?
	jz	L_108		; Wait begin resive
;\----
	mov	rtc_to, #3	; R7 page 18=3
;//----
L_10F:	mov	A, R0_10	; R0 page 10
	jnz	L_11E		; yes code key
;
	mov	A, rtc_to	;
	jnz	L_10F		; wait code
;\\---- ��⥪ ⠩�-��� �ਥ�� ᪠�-���� -----
	mov	R0_10, A	; 00h -> R0 page 10
	mov	R1_10, A	; 00h -> R1 page 10
	mov	R6, A		; 00h -> R6
	sjmp	L_102		; wait new code
;\------
; �ਭ�� ᪠�-��� ����������
L_11E:	mov	R5, A		; Get code KBD
	mov	R0_10, #0	; 00h -> R0 Page 10
	cjne	A, #0E0h, L_129
; �ਭ�� ��䨪� 0E0h - ��������� � �ਭ��� ᫥�.
	mov	R6, #1		; flag prefix key
	sjmp	L_104		; Get Second code
;\-------------------------------
; NO prefix = 0E0h
L_129:	cjne	A, #0F0h, L_130
; Resive ptefix 0F0h (unpress)
	setb	f_unpres	; Flag unpress=1
	sjmp	L_104		;Get second code
;\-------------------------------
; No prefix 0E0h & 0F0h
L_130:	inc	A		;�᫨ = 0FFh
	jz	L_100		;err code
	ret
; ����� ��楤��� �ਥ�� ᪠�-���� ���������� ***
;************************************************
; R1 (code key) -> bufer Spectrum KBD
; f_unpress = 1 - clear code from bufer
L_134:	mov	A, R1		;
	jnb	ACC.3, L_13E	;���� Caps Shift = 0
; ACC.3 = 1 -> Caps Shift
	mov	A, #1		;D0
	mov	R0, #0		;A8
	acall	L_15D		;�������� Caps Shift
; ACC.3 = 0
L_13E:	mov	A, R1
	jnb	ACC.7, L_148	;���� Symbol Shift = 0
; ACC.7 = 1 -> Symbol Shift
	mov	A, #2		;D1
	mov	R0, #7		;A15
	acall	L_15D		;�������� Symbol Shift
; ACC.7 = 0
L_148:	mov	A, R1
	anl	A, #7		;����� ��� 設� ������
	jnz	L_14E		;1..5
; d2..d0 = 000
	ret			;
; d2..d0 <> 000 (���� 設� ������ 1-> D0)
L_14E:	mov	R0, A		;1..
	clr	A
	setb	C		;CY=1
L_151:	rlc	A		;
	djnz	R0, L_151	;
; � ACC 1 ����ᠭ� � ��� � ����஬ [(d2..d0)-1]
	push	ACC
	mov	A, R1
	swap	A
	anl	A, #7		;
	mov	R0, A		;Adress
	pop	ACC		;Date
;-----
L_15D:	orl	R0_00, #buf_kbd ;R0=���᭠� 設�
	jnb	f_unpres, L_166 ;������ �⦠�
; Press key  - set code
	orl	A, @R0		;�������� ��� ������
	mov	@R0, A
	ret
; Unpress key - clear code from bufer
L_166:	cpl	A
	anl	A, @R0
	mov	@R0, A
	ret
; end mode Spectrum KBD
; ========================================
; DECODE Second byte in Tab
; R5 -> ctrl code (mode CP/M)
; R6=1 prefix 0E0h
;
L_16A:	mov	A, R5		;
	jnz	L_16E
; 00h -> exit
L_16D:	ret
;
L_16E:	anl	A, #3		;d1,d0
	jnz	L_1A6		;ALT,Ctrl,Shift
; d1,d0=00
	jb	f_unpres, L_16D ;exit
;--------------
; press new key
	mov	A, R5
	anl	A, #0Ch 	;d3,d2
	jnz	L_1D2
;d3,d2=00
	mov	A, R5
	anl	A, #30h 	;d5,d4
	jnz	L_1E4		;
;d5,d4=00
L_17F:	mov	A, R5
	jb	ACC.6, L_19F	;*40h
;d6=0
	jnb	ACC.7, L_16D	;d7,d6=0 Exit
;d6=0,d7=1 (80h)
	mov	A, R3
	orl	A, R4
	anl	A, #6
	cjne	A, #6, L_192	;bits Ctrl,Alt
; Ctrl+Alt
	cjne	R2, #2Eh, L_16D ;����� [./Del]?
; + [./Del]
	ajmp	reset		;Reset COMP
;-------
; no Ctrl+Alt
L_192:	cjne	R6, #1, L_1A2	;set D7
; R6=1 (prefix 0E0h)
	mov	A, R7		;Scan code set1
	clr	C
	subb	A, #47h 	;-47h ��� [dig.7]
	mov	DPTR, #L_582	;������ ����� ��.������
	movc	A, @A+DPTR
	mov	R2, A		;new code
	ret
;-------
;^ D6=1
L_19F:	mov	A, R6		; R6=0?
	jz	L_16D		; exit
; R6=1 (prefix 0E0h)
L_1A2:	orl	R2_00, #80h	;set D7(R2)
	ret
;----------
; d1,d0 <>0
L_1A6:	anl	R7_00, #7Fh	;R7(7)=0
	cjne	A, #3, L_1FC
; R5=03h (Left Shift & Right Shift)
	mov	A, #1		;bit0 (Flag Shift)
	mov	R6, #0
	cjne	R7, #36h, L_1B5 ;Code set1 Right Shift ?
; press Right Shift
	mov	R6, #1		;Flag Right Shift=1
L_1B5:	jnb	f_unpres, L_1C2
; key unpress
	cpl	A
	cjne	R6, #1, L_1BF
; R6=1 (Right Shift)
	anl	R4_00,A	;R4(d0)=0
	ret
; R6=0 (Left Shift)
L_1BF:	anl	R3_00, A	;R3(d0)=0
	ret
; key press
L_1C2:	cjne	R6, #1, L_1D4
; Right Shift
	cjne	A, #1, L_1CE
; ����� Right Shift
	mov	A, R3		;�஢���� Left Shift
	anl	A,#1
	jnz	L_1DC
; Left Shift �� �� �����
	inc	A		;A=1
L_1CE:	orl	R4_00, A	;R4 bit 0=1
	sjmp	L_1EC
;------
;^ d3,d2<>0
L_1D2:	sjmp	L_203
;--------------------------------
;
L_1D4:	cjne	A, #1, L_1EA
; ����� Left Shift
	mov	A,R4		;�஢���� Right Shift
	anl	A,#1
	jz	L_1E8		;�� �� �����
; �� �����
L_1DC:	mov	R2, #7Ah	;'z' (� XT R2) �뫮 R0
	cpl	A
	anl	R3_00, A	;
	anl	R4_00, A	;
	ret
;-------
;^ d5,d4<>0
L_1E4:	sjmp	L_21A		;test 20,30
;-------
;v non Ctrl+Alt
L_1E6:	sjmp	L_17F
;--------------------------------
; ����� Left Shift ��� Right Shift
L_1E8:	mov	A, #1
L_1EA:	orl	R3_00, A	;R3(d0)=1
;
L_1EC:	mov	A, R3
	orl	A, R4
	anl	A, #6
	cjne	A, #6, L_1E6
; press Ctrl(d1)+Alt(d2)
	cjne	R7, #53h, L_219 ;Scan-cod1 DEL =53h
; Ctrl+Alt+Del
	ajmp	reset		;���� Speccy
;-----
L_1FC:	cjne	A, #1, L_1B5
; Code ALT = 1
	mov	A, #4		;bit2 (flag ALT)
	sjmp	L_1B5
;------
;^ d3,d2<>0
L_203:	jb	f_unpres, L_1E6 ;
; key press
	cjne	A, #0Ch, L_20F	;d3,d2=11
; A=0Ch (Scroll Lock)
	cjne	R6, #1, L_20F
; R6=1 (prefix 0E0h)
	mov	R2, #6Fh	;'o'
	ret
;-----
L_20F:	rr	A		;/2
	rr	A		;/4
	mov	R5, A
	mov	A, #8		;bit3=1
L_214:	rl	A
	djnz	R5, L_214
; trigger bit
	xrl	R3_00, A	;R3
L_219:	ret
;------
; ��ன ��� = 20h/30h
L_21A:	cjne	A, #20h, L_21F
; A=20h
	sjmp	L_1EC
L_21F:	cjne	A, #30h, L_219	;ret
; A=30h
; ========================================
; Clear buf KBD
clr_buf:
	mov	A, #0FFh
	mov	R0, #buf_kbd
	mov	R1, #8		;8 ����
L_228:	mov	@R0, A
	inc	R0
	djnz	R1, L_228
;\----
	clr	A
	clr	f_press
	mov	R1_10, A	;R1 page10=0
	mov	R0_10, A	;R0 page10=0
	mov	R2, A
	mov	R3, A
	mov	R4, A
	mov	R6, A
	ret
; ==========================================
; �ਥ� ᪠� ���� ����⮩ ��� �⦠⮩ ������
; CLK_KBD = ~\_
L_23C:			; int0
	mov	PSW, #10h
;-----
	mov	C, P3.5 ; P3.5 <- DAT_KBD
	mov	A, R1
	jz	L_257	;R1=0 START
;-----
	dec	A
	jz	L_25B	;R1=1 �ਥ� ������
;-----
	dec	A
	jz	L_266	;R1=2 �����
;-----			;R1=3 STOP
	mov	R1, #0	;00h -> R1_10
	mov	A, R5	;������� �ਥ��
	mov	R0, A	;code -> R0_10
;-----
	pop	ACC
	pop	PSW
	reti
;-----
; �ਭ�� ���⮢� ��� ������
L_257:	mov	R6, #8	;Resive 8 bit
	sjmp	L_260
; -------------------------
; �ਥ� ��⮢ ������
L_25B:	mov	A, R5
	rrc	A
	mov	R5, A
	djnz	R6, L_261
; �ਭ�� 8 ��� ������
L_260:	inc	R1
L_261:	pop	ACC
	pop	PSW
	reti
;-----
; �ਥ� ��� �����
L_266:	mov	A, R5		;�ਭ��� ����
	jc	L_270		;��� ����� = 1
;
	jb	PSW.0, L_260	; PSW.0 - ACCUMULATOR PARITY FLAG
L_26C:	mov	R5, #0FFh	; १���� �� �訡�� �����
	sjmp	L_260
; -------------------------
L_270:	jnb	PSW.0, L_260	; PSW.0 - ACCUMULATOR PARITY FLAG
	sjmp	L_26C
; =============================================
; �室 ����� ���� ���������� �� Spectruma
; =============================================
;int1:	push	PSW		;2
;	push	ACC		;2
;	push	DPH		;2
;	ajmp	RD_KBD		;2
; Int /RDKBD
RD_KBD: 			; extint1
	mov	PSW, #08h	;2  PAGE 01
	jnb	SP_VE1, L_2AF	;2 VE1=0
; ����� ����஫��� ����饭�
	mov	A, #0FFh	;1
	mov	DPH, #01h	;1  DPTR=#01xx P2.0 = 1
	movx	@DPTR, A	;2  /VWR=0 -> ������ /WAIT
	setb	SP_WT		;1 P1.7  W_ON=1 ����� ���뢠���
; ������� ࠡ�⠥� ��� /WAIT � ��堭��᪮� ��������ன
	jb	SP_VE1,$	;2  ���� VE1=0
; ��������� ࠧ�襭�� ࠡ��� � AT ��������ன
	clr	SP_WT		;1 P1.7  W_ON=0 ������� ���뢠���
	clr	A		;1
	clr	f_press 	;1
	mov	R6_00, A	;1 R6 PAGE 00
	mov	R0_10, A	;1 R0 PAGE 10
	mov	R1_10, A	;1 R1 PAGE 10
	mov	R7, A		;1 䫠� �������=0
	mov	R1, A		;1 Z ��� ���������� = 0
	sjmp	ex_kbd		;2
;************************************************
; �ਭ�� ��� ᪠��஢���� �� 55h (�� �������)
no_comm:
	mov	b_sadr,A	;����-���� -> ���-ॣ����
	inc	DPH		;DPTR=#01xx
	mov	A, mode 	;����騩 ०�� ?
	jnz	no_m00		;mode>00h
;================================================
; mode = 00 -> Spectrum KBD
	jb	f_press,kbd_ve	;���� ����⨥
; �᫨ ��� ������, �
	movx	A,@DPTR 	;���� �ਭ�� Speccy
 if en_movx
	movx	@DPTR,A 	; ����� /WAIT
 else
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
ex_kbd: pop	DPH
	pop	ACC
	pop	PSW
	reti
; ================================================
; mode = 00 -> Spectrum KBD (���� ����⨥)
kbd_ve:
; ��������� 横� ᪠��஢���� ������
	dec	A		;A=#0FFh
	jb	b_sadr.0,A08_1
	anl	A,buf_kbd	;
A08_1:	jb	b_sadr.1,A09_1
	anl	A,buf_kbd+1
A09_1:	jb	b_sadr.2,A10_1
	anl	A,buf_kbd+2
A10_1:	jb	b_sadr.3,A11_1
	anl	A,buf_kbd+3
A11_1:	jb	b_sadr.4,A12_1
	anl	A,buf_kbd+4
A12_1:	jb	b_sadr.5,A13_1
	anl	A,buf_kbd+5
A13_1:	jb	b_sadr.6,A14_1
	anl	A,buf_kbd+6
A14_1:	jb	b_sadr.7,A15_1
	anl	A,buf_kbd+7
A15_1:	mov	R4,A		;��� ����஫���
;\----
	movx	A,@DPTR 	;���� Spec KBD
	anl	A,R4		;+ ��� ����஫���
; -------------------------
 if en_movx
	movx	@DPTR,A 	; ����� /WAIT
 else
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
	pop	DPH
	pop	ACC
	pop	PSW
	reti
;=========================================
; VE1=0 ࠧ�襭� ࠡ�� ����஫���
L_2AF:	mov	DPH, #00h	;2  DPTR=#00xx P2.0 = 0
; �⥭�� ॣ���� ���襣� ���� ���� Z80
	movx	A, @DPTR	;2  A=Adress A15..A8
; �஢���� �ਧ��� �ਥ�� ������� (R7)
	cjne	R7,#0,L_31B	;2  ������ ��ࠬ��஢ �������
;--------------------------------
; Test COMM=055h
	cjne	A,#55h,no_comm	;2  �᫨ �� 55h, � �� �������
;--------------------------------
; �⢥��� �� �ਥ� ���� 55h
	inc	R7		;1  R7=1 (�ਭ�� ��� �������)
	mov	A,#0AAh 	;1  Request = 0AAh
; ��।�� ���� � 設� ������ Z80
 if en_movx
	inc	DPH		;1  DPH=#01h  P2.0 = 1
	movx	@DPTR,A 	; ����� /WAIT
 else
	setb	P2.0		; ��� �롮� ����=0/�����=1
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
	pop	DPH		;2
	pop	ACC		;2
	pop	PSW		;2
	reti			;2
;*****************************************
; mode = 01,02,03
no_m00: cjne	A,#01h,no_m01	;01h ?
;========================================
; Mode = 01h - RD code KBD
; �⠥��� ��� ���������� (R2) ��� (R1)
L_2EB:	mov	A,R1_00	;R1 page 00
	jb	f_decod, L_2F2	;
; no decode
	mov	A,R2_00	;R2 page 00
	mov	R2_00,#0	;00h -> R2
L_2F2:
 if en_movx
	movx	@DPTR,A 	; ����� /WAIT
 else
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
	pop	DPH
	pop	ACC
	pop	PSW
	reti
;============================================
no_m01: cjne	A,#02h,no_m02	;02h ?
; ===========================================
; Mode =02h - CP/M
; ������� ॣ����� R2(��� R1),(R3),(R4)
; � ����ᨬ��� �� ���ﭨ� ��⮢ A15,A14
	mov	A,b_sadr	; Adress ᪠��஢���� Axx
	rl	A
	rl	A
	anl	A, #3		; A15.A14 ?
	jz	L_2EB		; A15,A14=00
; -------------------------------
	add	A,#R2_00	;1..3 + #R2_00
	mov	R1,A		;
	mov	A,@R1		;(R3)..(R5)
 if en_movx
	movx	@DPTR,A 	; ����� /WAIT
 else
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
	pop	DPH
	pop	ACC
	pop	PSW
	reti
;=========================================
; Mode = 03h - Direct RD
no_m02: mov	A,R7_10		;R7 Page10
	mov	R7_10,#0	;
 if en_movx
	movx	@DPTR,A 	; ����� /WAIT
 else
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
	pop	DPH
	pop	ACC
	pop	PSW
	reti
;************************************************
;****** �ਥ� ��ࠬ��஢ ������� ****************
;************************************************
L_31B:	mov	R6,A		;����-���� -> R6
	cjne	R7,#1,L_344	;R7=2 (��ன ��ࠬ���)
; ���� ��ࠬ��� - ��� ������� � ��䨪�
	rl	A
	rl	A
	anl	A, #3
	mov	R5, A		;R5 - ��䨪� �������
;
	mov	A, R6		;A15..A8
	anl	A, #3Fh
	jnz	ex1cmd		;�᫨ �� 0 - �믮�����
	ajmp	L_33E		;�� NOP
ex1cmd:	mov	R3, A		;R3 - ��� �������
;*************************************************
;********** TEST CODE COMM  **********************
;*************************************************
; R3 - ��� �������
; R5 - ��䨪� �������
; R6 - ��ࠬ��� �������
; R7 - 䫠� �������
L_344:	cjne	R3, #02h, no_c02
; COMM = 02h �⥭�� ॣ���஢ ���� RS232
	cjne	R5,#0,no_c02_0
;--------------------------------
; COMM = 02h - ������ ॣ���� ������ RS232 (�ਥ�)
	mov	A, cnt_rd	; �᫨ ���稪 = 0
	jz	ex_A		; � ��室 � 00h
; � ���� ���� �����
	dec	A		;
	mov	cnt_rd, A	;���稪 - 1
	mov	R0, adr_rd	;⥪�騩 ���� �ਥ��
	mov	A,@R0		;���� �� ����
	inc	R0
	cjne	R0, #buf_rd+len_brd, no_e_brd
; ��諨 �� ���� ���� �ਥ��, ������� � ��砫�
	mov	R0, #buf_rd	;
no_e_brd:
	mov	adr_rd, R0	;���� ���� � ����
ex_A:	ajmp	L_340		;��室 � ���⮬ �ਥ��
;--------------------------------
no_c02_0:
	cjne	R5,#01h,no_c02_1
; COMM = 42h - �⥭�� ॣ���� ����� RS232
; d0 - ��⮢����� �ਥ�����   RD
; d1..d4=0
; d5 - ��⮢����� ��।��稪� TD
; d6 - ���� ��।��稪� ���� TE
; d7 - ࠡ�� � ���뢠��ﬨ FINT
	mov	A,stat_rs	;��騩 ����� RS232
	anl	A,#9Eh		;TD,TE,RD=0
	mov	stat_rs,A
	mov	A,cnt_rd	;�᫨ = 0
	jz	no_rd		; ��� ������
; � ���� ���� �ਭ��� �����
	setb	stat_rs.0	; RD=1
no_rd:	mov	A,cnt_wr	;�᫨ = len_bwr
	cjne	A,#len_bwr,no_wr
; ���� ��।�� �������� - ��室 � TD,TE=0
	mov	A,stat_rs	;⥪�騩 �����
	ajmp	L_340		;��室
no_wr:	mov	A,stat_rs	;⥪�騩 �����
	orl	A,#60h		;TD,TE=1
	ajmp	L_340		;��室
;--------------------------------
no_c02_1:
	cjne	R5,#2,no_c02_2
; COMM = 82h - �⥭�� ॣ���� ������
; d7 - DCD (Data Carrier Detect)
; d6 - RI  (Ring Indicator)
; d5 - DSR (Data Set Ready)
; d4 - CTS (Clear To Send)
; d3..d0 = 0
; ����� ���� P1
; PA2 - /RI     input -> d6
; PA1 - /CTS    input -> d4,d5
; PA0 - /CD     input -> d7
	mov	R5,#00h 	;���� �� 0
	mov	A, P1		;���� ������
	jb	ACC.1,no_cts	;/CTS ?
; CTS=1 (ᨣ��� �������)
	mov	R5,#30h 	;CTS,DSR=1
no_cts: mov	stat_md,R5	;
	jb	ACC.0,no_dcd	;/DCD ?
; DCD=1 (ᨣ��� �������)
	setb	stat_md.7	;DCD=1
no_dcd: jb	ACC.2,no_ri	;/RI ?
; RI=1	(ᨣ��� �������)
	setb	stat_md.6	;RI=1
no_ri:	mov	A,stat_md	;⥪�騩 ����� ������
	ajmp	L_340		;��室
;--------------------------------
no_c02_2:
; COMM = 0C2h - �⥭�� ���稪� ���� �ਥ��
	mov	A, cnt_rd	;
	ajmp	L_340		;��室
; ����� ࠡ��� ������� xx02h - �⥭�� ॣ���஢ RS232
;=============================================
no_c02: cjne	R3, #3, no_c03
; COMM = 03h|43h|83h|C3h ������ ॣ���஢ ���� RS232
	cjne	R7,#1, no_1c03	; R7=2 - �믮����� ������
; ��⠭����� �ਧ��� �ਥ�� ᫥���饣� ����
	inc	R7		;�ਭ��� �� ���� ����
	mov	A,#0FFh
	ajmp	L_2F3		;���� ���
;=============================================
no_1c03:
; �ਭ�� ���� (R6) ��� ����� � ॣ���� RS232
	cjne	R5,#0,no_c03_0
;---------------------------------------------
; COMM=03h,<data> - ������ <data> � ॣ���� ������ RS232
; �஢���� ������������� ���� ��।��稪�
	mov	A,cnt_wr	;���稪 ���� ��।��稪�
	jz	clr_bwr 	;�᫨ ���⮩, � ��।���
; � ���� ��।��稪� 㦥 ��-� ����
	jb	ACC.3,no_inc	;cnt_wr �� 0 �� 7
	inc	A		;cnt_wr+1
	mov	cnt_wr,A	;���� ���稪
no_inc:
; ������� ⥪�騩 ���� � ���� ��।��稪�
	mov	R0,adr_ws	;⥪�騩 ���� �����
	mov	A,R6		;<data>
	mov	@R0,A		;-> � ����
	inc	R0
	cjne	R0,#buf_wr+len_bwr,no_ebwr
	mov	R0,#buf_wr	;� ��砫� ����
no_ebwr:
	mov	adr_ws,R0	;���� ����
ex_cmd: ajmp	L_33E		;���
;
clr_bwr:
	mov	SBUF,R6 	;�ࠧ� ��।���
	inc	A
	mov	cnt_wr,A	;cnt_wr+1
	mov	A,#buf_wr
	mov	adr_wr,A
	mov	adr_ws,A
	ajmp	L_33E		;��室
;---------------------------------------------
no_c03_0:
	cjne	R5,#01h,no_c03_1
; COMM= 43h,<data> - ॣ���� �ࠢ����� ��⠬� ������
; d0 - DTR Data Terminal Ready
; d1 - RTS Request To Send
; d2..d7 - �� �ᯮ�������
; ���� P1
; PA0 - CD     input
; PA1 - CTS    input
; PA2 - RI     input
; PA3 - DTR    out	<- d0
; PA4 - RTS    out	<- d1
; PA5 - INT_T  out
; PA6 - /RES  -out
; PA7 - W_ON  -out
	mov	A,R6		;<data>
	rl	A
	rl	A
	rl	A
	cpl	A		;������� ��⮢
	anl	A,#18h		;RTS(4),DTR(3)
	orl	A,#67h		;W_ON(7)=0
	mov	P1,A		;��⠭����� ����
	ajmp	L_33E		;��室
;--------------------------------------
no_c03_1:
	cjne	R5,#02h,no_c03_2
; COMM 83h,<data> - ������� ���� �ࠢ����� �������
	mov	stat_rs,R6	;
	ajmp	L_33E		;
;--------------------------------------
no_c03_2:
; COMM 0C3h,<data> - ������� ᪮���� RS232
	call	set_speed	;R6 -> ᪮����
	ajmp	L_33E		;��室
;***** ����� �믮������ ������ xx03h  *************
;**************************************************
no_c03: cjne	R3, #1, L_34E	;��� ������� # 01h ?
; COMM = 01h|41h|81h|0C1h Get Vers.
	push	DPL
	mov	DPTR, #vers	;Buf Ver.
	mov	A, R5		;0..3 (Adress Param)
	movc	A, @A+DPTR	;
	pop	DPL
	sjmp	L_340		;
;=================================================
L_34E:	cjne	R3, #7, L_35C
; COMM = 07h (���⪠ ���� ����������)
	mov	R0,#buf_kbd	;���� ����������
	mov	R1,#8
L_355:	mov	@R0, #0FFh	;�� <1>
	inc	R0
	djnz	R1, L_355
;-----
	sjmp	L_33E
;=================================================
L_35C:	cjne	R3, #8, L_376
; COMM = 08h,<mode> (��⠭���� ०��� ࠡ��� ����஫���)
	cjne	R7, #2, L_3C5	;
; Second param =<mode>
	mov	A, R6		;��ன ��ࠬ��� �������
	anl	A,#03h		;����訥 2 ���
	mov	mode, A 	; Mode
	mov	R2_00,#0	;���� ⥪�饣� ᪠�-����
; �����襭�� ������� - ��室 � ����� 0FFh
L_33E:	mov	A, #0FFh	;��室 � A=0FFh
L_340:	mov	R7, #0		;
L_2F3:	mov	DPH,#01h	;DPTR=#01xx
 if en_movx
	movx	@DPTR,A 	; ����� /WAIT
 else
	mov	P0,A		; �뤠�� ��� ����������
	clr	VWR		;������ /WR
	setb	VWR
 endif
	pop	DPH
	pop	ACC
	pop	PSW
	reti
;=================================================
L_376:	cjne	R3, #9, L_37F
; COMM = 09h,49h,89h,C9h ������ ॣ����� ����������
	mov	A, R5		;0..3
	inc	A		;1..4
	mov	R0, A
	mov	A, @R0		;A=(R1)..(R4)
	sjmp	L_340
;=================================================
L_37F:	cjne	R3, #0Ah, L_387
; COMM=0Ah Set RUS
	orl	R3_00, #80h	; Set RUS (�뫮 R1_00)
	sjmp	L_33E		;��室 � A=0FFh
;=================================================
L_387:	cjne	R3, #0Bh, L_38F
; COMM=0Bh Set LAT
	anl	R3_00, #7Fh	; Set LAT (�뫮 R1_00)
	sjmp	L_33E		;��室 � A=0FFh
;=================================================
L_38F:	cjne	R3, #0Ch, L_396
; COMM=0Ch  ��⠭����� ०�� ��������
	setb	f_wait		; Set Wait ON
	sjmp	L_33E		;��室 � A=0FFh
;=================================================
L_396:	cjne	R3, #0Dh, L_39B
; COMM=0Dh   �ணࠬ��� ��� ��������
	ajmp	reset		; Reset Computer
;=================================================
L_39B:	cjne	R3, #10h, L_3A4
; COMM=10h..0D0h (����� ⥪�饣� �६���)
	mov	A, #b_time	;ᥪ㭤�
	acall	L_3E7		; Get Time
	ajmp	L_2F3		;
;=================================================
L_3A4:	cjne	R3, #11h, L_3AD
; COMM=11h..0D1h (��⠭���� ⥪�饣� �६���)
	mov	A, #b_time
	acall	L_3ED		; Set Time
	ajmp	L_2F3
;=================================================
L_3AD:	cjne	R3, #12h, L_3B6
; COMM=12h..0D2h (����� ⥪�饩 ����)
	mov	A, #b_date	; ���� ����
	acall	L_3E7		; Get DATA
	ajmp	L_2F3
;=================================================
L_3B6:	cjne	R3, #13h, L_3BF
; COMM=13h..0D3h (��⠭���� ⥪�饩 ����)
	mov	A, #b_date	; ���� ����
	acall	L_3ED		; Set DATA
	ajmp	L_2F3
;=================================================
L_3BF:	cjne	R3, #14h, L_3CD ;
; COMM=14h,<data> (��⠭���� ��⮢ ���� P1)
	cjne	R7, #1, L_3C8
; R7=1
L_3C5:	inc	R7		; R7=2
	mov	A,#0FFh
	ajmp	L_2F3
; ---
; R7=2
L_3C8:	mov	A, R6		;<data>
	orl	P1, A		;
	ajmp	L_33E		;��室 � A=0FFh
;=================================================
L_3CD:	cjne	R3, #15h, L_3D9
; COMM=15h,<data> (��� ��⮢ ���� P1)
	cjne	R7, #2, L_3C5	;R7=1
; R7=2
	mov	A, R6		;<data>
	cpl	A
	anl	P1, A
L_3D7:	ajmp	L_33E		;��室 � A=0FFh
;=================================================
L_3D9:	cjne	R3, #16h, L_3E0
; COMM=16h (�⥭�� ���� P3)
	mov	A, P3		;
	ajmp	L_340		;��室 � A=P3
;=================================================
L_3E0:	cjne	R3, #17h, L_3D7 ;��室 � A=0FFh
; COMM=17h (�⥭�� ���� P1)
	mov	A, P1		;
	ajmp	L_340		;��室 � A=P1
; End Decode Command
;*************************************************
; Get data
L_3E7:	add	A, R5
	mov	R0, A
	mov	A, @R0
	mov	R7, #0
	ret
;=================================================
L_3ED:	cjne	R7, #2, L_3F9
; Set <data>
	add	A, R5
	mov	R0, A
	mov	A, R6		;<data>
	mov	@R0, A
	mov	R7, #0FFh	;-1
; First Param = adress param -> R5
L_3F9:	mov	A, #0FFh
	inc	R7		; R7=2
	ret
;*********************************************
;------ ����ன�� RS-232 (�� ⠡��� ����⠭�)
; R6 - �����樥�� ������� 1,2,3,6,12,24,48
set_speed:
	mov	A,R6		;
	jz	no_set_spd	;0 - �����
;
	clr	C
	subb	A,#4		;1,2,3 -> CY=1
	mov	A,R6
	jc	set_spd 	;��⠭����� �1,�2,�3
; R6>3
	cjne	A,#6,no_spd_6
; 19200 ���
	mov	A,#4
	sjmp	set_spd 	;��⠭����� �4
no_spd_6:
	cjne	A,#12,no_spd_12
; 9600 ���
	mov	A,#5
	sjmp	set_spd 	;��⠭����� �5
no_spd_12:
	cjne	A,#24,no_spd_24
; 4800 ���
	mov	A,#6
	sjmp	set_spd 	;��⠭����� �6
no_spd_24:
	cjne	A,#48,no_spd_48
; 2400 ���
	mov	A,#7
	sjmp	set_spd 	;��⠭����� �7
no_spd_48:
	cjne	A,#96,no_set_spd
; 1200 ���
	mov	A,#8		;��⠭����� �8
set_spd:
	push	DPL
	mov	DPTR,#tab_spd-1
	movc	A,@A+DPTR	;��� ����⥫�
	mov	PCON,#80h	;SMOD=1 ��������� ᪮����
	jbc	ACC.7,yes_smod	;
	mov	PCON,#00h	;SMOD=0 �����ୠ� ᪮����
yes_smod:
	cpl	A
	mov	TH1,A		; ����� ᪮����
	pop	DPL
no_set_spd:
	mov	A,#buf_wr	;���� ��।��稪�
	mov	adr_wr,A	;
	mov	adr_ws,A
	mov	A,#buf_rd	;���� �ਥ��
	mov	adr_rd,A	;���� �ਥ�� ��� Speccy
	mov	adr_rs,A	;���� �ਥ�� ��� ����஫���
	clr	A
	mov	cnt_rd,A	;���稪 �⥭��
	mov	cnt_wr,A	;���稪 �����
	ret
;****************************************
; �ਥ� �� Rs232			*
;****************************************
;serint:
;	push	PSW
;	push	ACC
;	mov	PSW, #18h	;PAGE 18
;	ajmp	ser_int
ser_int:
	jbc	RI,ser_rx	;��⮢����� �ਥ�����
; ��⮢����� ��।��稪� RS232
	clr	TI		;��� ��⮢���� ���.
; �᫨ � ���� ��।��稪� ���� ����� - ��।���
	mov	A,R6		;cnt_wr ? (��.��)
	jz	no2end_buf	;��祣� ���
; ��।��� ���� �� ���� ��।��稪�
	dec	R6		;���稪 - 1
	mov	A,R6		; �᫨ cnt_wr=1
	jz	no2end_buf	;�� �ਧ��� ��।�� ����
; � ���� ���� �� ����� ��� ��।��
	clr	EA		;������� ���뢠���
	mov	R0,adr_wr	;���� ���� ��।��
	mov	A,@R0		;⥪�騩 ����
	mov	SBUF,A		; ��।���
	inc	R0		;� ᫥���饬� �����
	cjne	R0,#buf_wr+len_bwr,no_ewr
	mov	R0,#buf_wr	;����� � ��砫� ����
no_ewr:
	mov	adr_wr,R0	;���� ���� � ����
	setb	EA		;ࠧ���� ���뢠���
	sjmp	no2end_buf	;��室
;------------------------------------------
; �ਭ�� ���� �� RS232
ser_rx:
; R5 = cnt_rd - ���稪 �ਥ��
	cjne	R5,#len_brd,no_end_buf ;�� �� ����� ����
; ���� �� ��砫� ���� 㤠���� ���� ᨬ���
	dec	R5		;cnt_rd-1
	inc	R4		;㪠��⥫� �ਥ�� ���।
	cjne	R4,#buf_rd+len_brd,no_end_buf
	mov	R4,#buf_rd	;adr_rd � ��砫� ����
no_end_buf:
	mov	A,SBUF		;���� �ਥ��
	mov	@R1,A		;� ���� (R1 - ���� ���� �ਥ��)
	inc	R5		;cnt_rd+1
	inc	R1		;㪠��⥫� ���।
	cjne	R1,#buf_rd+len_brd,no2end_buf
	mov	R1,#buf_rd	;㪠��⥫� �ਥ�� � ��砫� ����
no2end_buf:
	pop	ACC
	pop	PSW
	reti
;****************************************
; Timer 0 (��� ॠ�쭮�� �६���)	*
;****************************************
int_rtc:			;9 timint0
	mov	PSW, #18h	;1 PAGE 11
; ���稪 ⠩�-��� ����������
	mov	A, R7		;1 rtc_to
	jz	L_408		;2
	dec	R7		;1 -1
L_408:
;--------------------------------
	djnz	tics,L_45A	;2
;
	mov	tics, #f_tic	;50 ⨪�� � ᥪ㭤�
	mov	R0, #b_time	;���� �६���
	inc	@R0
	cjne	@R0, #60, L_45A ;<60 ᥪ㭤
;
	mov	@R0, #0 	;
	inc	R0
	inc	@R0
	cjne	@R0, #60, L_45A ;<60 �����
;
	mov	@R0, #0
	inc	R0
	inc	@R0
	cjne	@R0, #24, L_45A ;<24 �ᮢ
;
	mov	@R0, #0
;
	inc	R0
	inc	@R0		;᫥�.����
	mov	A, @R0
	mov	R2, A
	inc	R0
	mov	A, @R0		;����� �����
	push	DPL
	push	DPH
	mov	DPTR, #L_465-1	;������ ����
	movc	A, @A+DPTR
	pop	DPH
	pop	DPL
	cjne	@R0, #2, L_445
;
	inc	R0
	mov	R3, A
	mov	A, @R0
	dec	R0
	rrc	A
	jc	L_444
	rrc	A
	jc	L_444
	inc	R3
L_444:	mov	A, R3
;
L_445:	clr	C
	subb	A, R2
	jnc	L_45A
;
	dec	R0
	mov	@R0, #1
	inc	R0
	inc	@R0
	cjne	@R0, #13, L_45A ;<13
;
	mov	@R0, #1
	inc	R0
	inc	@R0
	cjne	@R0, #100, L_45A ;<100
;
	mov	@R0, #0
;
L_45A:	call	set_T0		;T0 = 50 ����
	pop	ACC
	pop	PSW
	reti
; -------------------------
;
	ORG	600h
;----------------------------------------
; ��᫮ ���� � ������
L_465:	db  31	;������
	db  28	;���ࠫ�
	db  31	;����
	db  30	;��५�
	db  31	;���
	db  30	;���
	db  31	;���
	db  31	;������
	db  30	;�������
	db  31	;������
	db  30	;�����
	db  31	;�������
;----------------------------------------
; ������ CP/M - ����� ����������
L_471:	db  1Bh ; ESC
	db    0 ;
;
	db  31h ; 1
	db    0 ;
;
	db  32h ; 2
	db    0 ;
;
	db  33h ; 3
	db    0 ;
;
	db  34h ; 4
	db    0 ;
;
	db  35h ; 5
	db    0 ;
;
	db  36h ; 6
	db    0 ;
;
	db  37h ; 7
	db    0 ;
;
	db  38h ; 8
	db    0 ;
;
	db  39h ; 9
	db    0 ;
;
	db  30h ; 0
	db    0 ;
;
	db  2Dh ; -/_
	db    0 ;
;
	db  3Dh ; =/+
	db    0 ;
;
	db    8 ; BS
	db    0 ;
;
	db    9 ; TAB
	db    0 ;
;
	db  51h ; Q
	db    0 ;
;
	db  57h ; W
	db    0 ;
;
	db  45h ; E
	db    0 ;
;
	db  52h ; R
	db    0 ;
;
	db  54h ; T
	db    0 ;
;
	db  59h ; Y
	db    0 ;
;
	db  55h ; U
	db    0 ;
;
	db  49h ; I
	db    0 ;
;
	db  4Fh ; O
	db    0 ;
;
	db  50h ; P
	db    0 ;
;
	db  5Bh ; [
	db    0 ;
;
	db  5Dh ; ]
	db    0 ;
;
	db  0Dh ; Enter
	db 0C0h ;
;
	db    0 ; Ctrl
	db    2 ; bit 1 (R3)
;
	db  41h ; A
	db    0 ;
;
	db  53h ; S
	db    0 ;
;
	db  44h ; D
	db    0 ;
;
	db  46h ; F
	db    0 ;
;
	db  47h ; G
	db    0 ;
;
	db  48h ; H
	db    0 ;
;
	db  4Ah ; J
	db    0 ;
;
	db  4Bh ; K
	db    0 ;
;
	db  4Ch ; L
	db    0 ;
;
	db  3Bh ; ;
	db    0 ;
;
	db  27h ; '
	db    0 ;
;
	db  60h ; `
	db    0 ;
;
	db    0 ; Left Shift
	db    3 ; bit0 R3
;
	db  5Ch ; \
	db    0 ;
;
	db  5Ah ; Z
	db    0 ;
;
	db  58h ; X
	db    0 ;
;
	db  43h ; C
	db    0 ;
;
	db  56h ; V
	db    0 ;
;
	db  42h ; B
	db    0 ;
;
	db  4Eh ; N
	db    0 ;
;
	db  4Dh ; M
	db    0 ;
;
	db  2Ch ; ,
	db    0 ;
;
	db  2Eh ; .
	db    0 ;
;
	db  2Fh ; /
	db  40h ;
;
	db    0 ; Rght Shift
	db    3 ; bit0 R4
;
	db 0AAh ; \/|
	db    0 ;
;
	db    0 ; ALT
	db    1 ; bit2 R3
;
	db  20h ; SPACE
	db    0 ;
;
	db    0 ; CapS LOck
	db    4 ; bit4 R3 (trigger)
;----
	db  61h ; F1
	db    0 ;
;
	db  62h ; F2
	db    0 ;
;
	db  63h ; F3
	db    0 ;
;
	db  64h ; F4
	db    0 ;
;
	db  65h ; F5
	db    0 ;
;
	db  66h ; F6
	db    0 ;
;
	db  67h ; F7
	db    0 ;
;
	db  68h ; F8
	db    0 ;
;
	db  69h ; F9
	db    0 ;
;
	db  6Ah ; F10
	db    0 ;
;
	db    0 ; Num Lock
	db    8 ; bit5 R3 (trigger)
;
	db    0 ; Scroll Lock
	db  0Ch ; bit6 R3 (trigger)
;----------------------------------
; Num keyboard scan code set1 > 47h
	db  37h ;47h [7]
	db  80h ;set bit7 R2
;
	db  38h ;48h [8]
	db  80h ;
;
	db  39h ;49h [9]
	db  80h ;
;
	db  2Dh ;4Ah [-]
	db  80h ;
;
	db  34h ;4Bh [4]
	db  80h ;
;
	db  35h ;4Ch [5]
	db  80h ;
;
	db  36h ;4Dh [6]
	db  80h ;
;
	db  2Bh ;4Eh [+]
	db  80h ;
;
	db  31h ;4Fh [1]
	db  80h ;
;
	db  32h ;50h [2]
	db  80h ;
;
	db  33h ;51h [3]
	db  80h ;
;
	db  30h ;52h [0]
	db  80h ;
;
	db  2Eh ;53h [.]
	db  80h ;
;
	db    0 ;54h
	db    0 ;
;
	db    0 ;55h
	db    0 ;
;
	db    0 ;56h
	db  30h ;
;
	db  6Bh ;57h F11
	db    0 ;
;
	db  6Ch ;58h F12
	db    0 ;
;
	db    0 ;59h
	db    0 ;
;
	db    0 ;5Ah
	db    0 ;
;
	db    0 ;5Bh
	db    0 ;
;
;----------------------------------------
; Scan-code IBM(1) -> code Spectrum
; D7 - Symbol Shift
; D6..D4 - Number bit Adress (A8=000..A15=111)
; D3 - Caps Shift
; D2..D0 - Number bit Data (D0=001..D4=101)
L_527:	db  39h ;01 ESC 	CapSh + Kl_1
;
	db  31h ;02 1/!         Kl_1
	db  32h ;03 2/@         Kl_2
	db  33h ;04 3/#         Kl_3
	db  34h ;05 4/$         Kl_4
	db  35h ;06 5/%         Kl_5
;
	db  45h ;07 6/^         Kl_6
	db  44h ;08 7/&         Kl_7
	db  43h ;09 8/*         Kl_8
	db  42h ;0A 9/(         Kl_9
	db  41h ;0B 0/)         Kl_0
;
	db 0E4h ;0C -/_ 	SymSh+Kl_J
	db 0E2h ;0D =/+ 	SymSh+Kl_L
	db  49h ;0E BS		CapSh+Kl_0
	db  3Bh ;0F TAB 	CapSh+Kl_3
;
	db  21h ;10 Q           Kl_Q
	db  22h ;11 W           Kl_W
	db  23h ;12 E           Kl_E
	db  24h ;13 R           Kl_R
	db  25h ;14 T           Kl_T
;
	db  55h ;15 Y           Kl_Y
	db  54h ;16 U           Kl_U
	db  53h ;17 I           Kl_I
	db  52h ;18 O           Kl_O
	db  51h ;19 P           Kl_P
;
	db 0D5h ;1A [/{ 	SymSh+Kl_Y
	db 0D4h ;1B ]/} 	SymSh+Kl_U
	db  61h ;1C ENTER
	db  88h ;1D Ctrl	CapSh+SymSh
;
	db  11h ;1E A           Kl_A
	db  12h ;1F S           Kl_S
	db  13h ;20 D           Kl_D
	db  14h ;21 F           Kl_F
	db  15h ;22 G           Kl_G
;
	db  65h ;23 H           Kl_H
	db  64h ;24 J           Kl_J
	db  63h ;25 K           Kl_K
	db  62h ;26 L           Kl_L
;
	db 0D2h ;27 ;/: 	SymSh+Kl_O
	db 0D1h ;28 '/" 	SymSh+Kl_P
	db  91h ;29 `/~ 	CapSh+Kl_A
;
	db  08h ;2A Left Shift	CapSh
	db  92h ;2B \/| 	CapSh+Kl_S
;
	db  02h ;2C Z           Kl_Z
	db  03h ;2D X           Kl_X
	db  04h ;2E C           Kl_C
	db  05h ;2F V           Kl_V
;
	db  75h ;30 B           Kl_B
	db  74h ;31 N           Kl_N
	db  73h ;32 M           Kl_M
;
	db 0F4h ;33 ,/< 	SymSh+Kl_N
	db 0F3h ;34 ./> 	SymSh+Kl_M
	db  85h ;35 //? 	SymSh+Kl_V
	db  80h ;36 Rght Shift	SymSh
	db 0F5h ;37 [*] 	SymSh+Kl_B
	db  3Ch ;38 Alt 	CapSh+Kl_4
;
	db  71h ;39 SPACE       Kl_SP
;
	db  3Ah ;3A CapsLock	CapSh+Kl_2
;
	db 0B1h ;3B F1		SymSh+Kl_1
	db 0B2h ;3C F2		SymSh+Kl_2
	db 0B3h ;3D F3		SymSh+Kl_3
	db 0B4h ;3E F4		SymSh+Kl_4
	db 0B5h ;3F F5		SymSh+Kl_5
	db 0C5h ;40 F6		SymSh+Kl_6
	db 0C4h ;41 F7		SymSh+Kl_7
	db 0C3h ;42 F8		SymSh+Kl_8
	db 0C2h ;43 F9		SymSh+Kl_9
	db 0C1h ;44 F10 	SymSh+Kl_0
;
	db    0 ;45 NumLock
	db    0 ;46 ScrollLock
; ������ ��஢��� ����� ����������
	db  3Ch ;47 [7] 	CapSh+Kl_4
	db  4Ch ;48 [8] [Up]	CapSh+Kl_7
	db  3Dh ;49 [9] 	CapSh+Kl_5
	db 0E4h ;4A [-] 	SymSh+Kl_J
	db  3Dh ;4B [4] 	CapSh+Kl_5
	db  35h ;4C [5] 	5
	db  4Bh ;4D [6] 	CapSh+Kl_8
	db 0E3h ;4E [+] 	SymSh+Kl_K
	db  4Ah ;4F [1] 	CapSh+Kl_9
	db  4Dh ;50 [2] 	CapSh+Kl_6
	db  4Bh ;51 [3] 	CapSh+Kl_8
	db  84h ;52 [Insert]	SymSh+Kl_C
	db  49h ;53 [Delete]	CapSh+Kl_0
	db    0 ;54
	db    0 ;55
	db    0 ;56
	db 0E5h ;57 F11 	SymSh+Kl_H
	db  94h ;58 F12 	SymSh+Kl_F
	db    0 ;59
	db    0 ;5A
	db    0 ;5B
;-----------------------------------------
; ������ ��� ������ �ࠢ����� ����஬
; �ਧ����� ��� ������ ���� ��䨪� E0
L_582:	db  76h ;47h Home
	db  70h ;48h Cur Up
	db  74h ;49h Page Up
	db 0ADh ;4Ah [-]
	db  72h ;4Bh Cur Left
	db 0B5h ;4Ch [5]
	db  73h ;4Dh Cur Right
	db 0ABh ;4Eh [+]
	db  77h ;4Fh End
	db  71h ;50h Cur Down
	db  75h ;51h Page Down
	db  78h ;52h Insert
	db  79h ;53h Del
;=========================================
; Tab Scan-code Set 2(AT) -> Set 1(XT)
; ���� + � ᪠� ���� ����砥� ����稥 ��䨪� 0E0h
;           XT   AT   N_Kl
at2xt:	db    0 ;00h
	db  43h ;01h  120    F9
	db    0 ;02h
	db  3Fh ;03h  116    F5
	db  3Dh ;04h  114    F3
	db  3Bh ;05h  112    F1
	db  3Ch ;06h  113    F2
	db  58h ;07h  123    F12
	db    0 ;08h
	db  44h ;09h  121    F10
	db  42h ;0Ah  119    F8
	db  40h ;0Bh  117    F6
	db  3Eh ;0Ch  115    F4
	db  0Fh ;0Dh   16    [Tab]
	db  29h ;0Eh    1    ~/`
	db    0 ;0Fh
	db    0 ;10h
	db  38h ;11h   60    [ALT Left]
;+		;11h+  62    [ALT Right]
	db  2Ah ;12h   44    [Shift Left]
	db    0 ;13h
	db  1Dh ;14h   58    [Ctrl Left]
	db  10h ;15h   17    Q
	db  02h ;16h    2    1/!
	db    0 ;17h
	db    0 ;18h
	db    0 ;19h
	db  2Ch ;1Ah   46    Z
	db  1Fh ;1Bh   32    S
	db  1Eh ;1Ch   31    A
	db  11h ;1Dh   18    W
	db  03h ;1Eh    3    2/@
	db    0 ;1Fh+ ---   [Left Fly Win]
	db    0 ;20h
	db  2Eh ;21h   48    C
	db  2Dh ;22h   47    X
	db  20h ;23h   33    D
	db  12h ;24h   19    E
	db  05h ;25h    5    4/$
	db  04h ;26h    4    3/#
	db    0 ;27h+ ---    [Right Fly Win]
	db    0 ;28h
	db  39h ;29h   61    [Space]
	db  2Fh ;2Ah   49    V
	db  21h ;2Bh   34    F
	db  14h ;2Ch   21    T
	db  13h ;2Dh   20    R
	db  06h ;2Eh    6    5/%
	db    0 ;2Fh+ ---    [Win Menu]
	db    0 ;30h
	db  31h ;31h   51    N
	db  30h ;32h   50    B
	db  23h ;33h   36    H
	db  22h ;34h   35    G
	db  15h ;35h   22    Y
	db  07h ;36h    7    6/^
	db    0 ;37h+  ---   [Power]
	db    0 ;38h
	db    0 ;39h
	db  32h ;3Ah   52    M
	db  24h ;3Bh   37    J
	db  16h ;3Ch   23    U
	db  08h ;3Dh    8    7/&
	db  09h ;3Eh    9    8/*
	db    0 ;3Fh+ ---    [Sleep]
	db    0 ;40h
	db  33h ;41h   53    ,/<
	db  25h ;42h   38    K
	db  17h ;43h   24    I
	db  18h ;44h   25    O
	db  0Bh ;45h   11    0/)
	db  0Ah ;46h   10    9/(
	db    0 ;47h
	db    0 ;48h
	db  34h ;49h   54    ./>
	db  35h ;4Ah   55    //?
;+		;4Ah+  95    [/]
	db  26h ;4Bh   39    L
	db  27h ;4Ch   40    ;/:
	db  19h ;4Dh   26    P
	db  0Ch ;4Eh   12    -/_
	db    0 ;4Fh
	db    0 ;50h
	db    0 ;51h
	db  28h ;52h   41    '/"
	db    0 ;53h
	db  1Ah ;54h   27    [/{
	db  0Dh ;55h   13    =/+
	db    0 ;56h
	db    0 ;57h
	db  3Ah ;58h   39    [Caps Lock]
	db  36h ;59h   57    [Shift Right]
	db  1Ch ;5Ah   43    [Enter]
;+		;5Ah+ 108    [+Enter]
	db  1Bh ;5Bh   28    ]/}
	db    0 ;5Ch
	db  2Bh ;5Dh   29    \/|
	db    0 ;5Eh+ ---    [Wake]
	db    0 ;5Fh
	db    0 ;60h
	db    0 ;61h
	db    0 ;62h
	db    0 ;63h
	db    0 ;64h
	db    0 ;65h
	db  0Eh ;66h   15    [BS]
	db    0 ;67h
	db    0 ;68h
	db  4Fh ;69h   93    [1/End]
;+		;69h+  81    [End]
	db    0 ;6Ah
	db  4Bh ;6Bh   92    [4/Left]
;+		;6Bh+  79    [<-]
	db  47h ;6Ch   91    [7/Home]
;+		;6Ch+  80    [Home]
	db    0 ;6Dh
	db    0 ;6Eh
	db    0 ;6Fh
	db  52h ;70h   99    [0/Ins]
;+		;70h+  75    [Insert]
	db  53h ;71h  104    [./Del]
;+		;71h+  76    [Delete]
	db  50h ;72h   98    [2/Down]
;+		;72h+  84    [Down]
	db  4Ch ;73h   97    [5]
	db  4Dh ;74h  102    [6/Right]
;+		;74h+  89    [->]
	db  48h ;75h   96    [8/Up]
;+		;75h+  83    [Up]
	db  01h ;76h  110    [Esc]
	db  45h ;77h   90    [Num Lock]
	db  57h ;78h  122    F11
	db  4Eh ;79h  106    [+]
	db  51h ;7Ah  103    [3/Pg Dn]
;+		;7Ah+  86    [Page Down]
	db  4Ah ;7Bh  105    [-]
	db  37h ;7Ch  100    [*]
	db  49h ;7Dh  101    [9/Pg Up]
;+		;7Dh+  85    [Page Up]
	db  46h ;7Eh  125    [Scroll Lock]
	db    0 ;7Fh
	db    0 ;80h
	db    0 ;81h
	db    0 ;82h
	db  41h ;83h  118    F7
;===================================================
	org	7B0h
; ��⠭���� ��ࠬ��஢ ������ 0 (50 ����)
set_T0: mov	TH0,#HIGH KF_T0 ; Timer0 - High Byte
	mov	TL0,#LOW  KF_T0 ; Timer0 - Low Byte
	ret
;===================================================
	org	7B8h
; ⠡��� ����ன�� ᪮��� RS232
; N = (Fosc/192)/Baud  SMOD=1
; N = (Fosc/384)/Baud  SMOD=0
tab_spd:
 if ft_07
; ��� ����� 7 ��� (� �訡��� �����祭�� ᪮���)
;		N
	db	1-1+80h ;1	36458(115200) SMOD=1
	db	1-1+80h ;2	36458(57600)  SMOD=1
	db	1-1+80h	;3	36458(38400)  SMOD=1
	db	1-1	;4(6)	18229(19200)  SMOD=0
	db	4-1+80h	;5(12)	9114(9600)   SMOD=1
	db	4-1	;6(24)	4557(4800)   SMOD=0
	db	15-1+80h;7(48)	2430(2400)   SMOD=1
	db	15-1	;8(98)	1215(1200)   SMOD=0
 endif
 if ft_11
; ��� ����� 11.0592 (�筠� ��⠭���� ᪮���)
;		N
	db	1-1+80h ;1      57600(115200) SMOD=1
	db	1-1+80h ;2	57600  SMOD=1
	db	1-1	;3	28800  SMOD=0
	db	3-1+80h ;4(6)	19200  SMOD=1
	db	3-1	;5(12)	9600   SMOD=0
	db	6-1	;6(24)	4800   SMOD=0
	db	12-1	;7(48)	2400   SMOD=0
	db	24-1	;8(98)	1200   SMOD=0
 endif
;----------------------------------------------
	org	7C0h
aCopyrightC1995:
	db 0Dh,0Ah
	db 'Copyright (C) 1995 Honey Soft',0Dh,0Ah
	db '  AT Keyboard Driver V3.2'
 if ft_07
	db	'07'
 endif
 if ft_11
	db	'11'
 endif
	db	0Dh,0Ah,0
	db 0FFh
; =================================================
;
	end

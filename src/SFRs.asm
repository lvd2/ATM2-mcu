ACC	equ	$E0
B	equ	$F0
PSW	equ	$D0
SP	equ	$81
DPL	equ	$82
DPH	equ	$83
P0	equ	$80
P1	equ	$90
P2	equ	$A0
P3	equ	$B0
IP	equ	$B8
IE	equ	$A8
TMOD	equ	$89
TCON	equ	$88
T2CON	equ	$C8
TH0	equ	$8C
TL0	equ	$8A
TH1	equ	$8D
TL1	equ	$8B
TH2	equ	$CD
TL2	equ	$CC
RCAP2H	equ	$CB
RCAP2L	equ	$CA
SCON	equ	$98
SBUF	equ	$99
PCON	equ	$87

;PSW flags
CY	bit	PSW.7
AC	bit	PSW.6
F0	bit	PSW.5
RS1	bit	PSW.4
RS0	bit	PSW.3
OV	bit	PSW.2
P	bit	PSW.0

;TCON flags
TR0	bit	TCON.4
TR1	bit	TCON.6
TF0	bit	TCON.5
TF1	bit	TCON.7

;IE interrupt flags
EA	bit	IE.7
ET2	bit	IE.5
ES	bit	IE.4
ET1	bit	IE.3
EX1	bit	IE.2
ET0	bit	IE.1
EX0	bit	IE.0

;IP bits
PT2	bit	IP.5
PS	bit	IP.4
PT1	bit	IP.3
PX1	bit	IP.2
PT0	bit	IP.1
PX0	bit	IP.0

;SCON flags
SM0	bit	SCON.7
SM1	bit	SCON.6
SM2	bit	SCON.5
REN	bit	SCON.4
TB8	bit	SCON.3
RB8	bit	SCON.2
TI	bit	SCON.1
RI	bit	SCON.0

;PCON flag
SMOD	equ	7



;CodeVisionAVR C Compiler V3.04 Evaluation
;(C) Copyright 1998-2013 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Release
;Chip type              : ATmega168V
;Program type           : Boot Loader
;Clock frequency        : 0,460000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 256 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: No
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega168V
	#pragma AVRPART MEMORY PROG_FLASH 16384
	#pragma AVRPART MEMORY EEPROM 512
	#pragma AVRPART MEMORY INT_SRAM SIZE 1024
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR=0x2D
	.EQU SPDR=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x04FF
	.EQU __DSTACK_SIZE=0x0100
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _Pagedata=R2
	.DEF _Pagedata_msb=R3
	.DEF _PageAddress=R4
	.DEF _PageAddress_msb=R5
	.DEF _CurrentAddress=R6
	.DEF _CurrentAddress_msb=R7
	.DEF _spmcrval=R10
	.DEF _rx_wr_index0=R9
	.DEF _rx_counter0=R8
	.DEF _sensor_address=R11
	.DEF _com_bytes_rx=R13
	.DEF _writePageSegmentsCounter=R12

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x1C00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  _ext_int0_isr
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  _usart_rx_isr
	JMP  0x1C00
	JMP  _usart_tx_isr
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00
	JMP  0x1C00

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x2,0x0,0x0


__GLOBAL_INI_TBL:
	.DW  0x03
	.DW  0x0B
	.DW  __REG_VARS*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF THE BOOT LOADER
	LDI  R31,1
	OUT  MCUCR,R31
	LDI  R31,2
	OUT  MCUCR,R31

;DISABLE WATCHDOG
	LDI  R31,0x18
	WDR
	IN   R26,MCUSR
	CBR  R26,8
	OUT  MCUSR,R26
	STS  WDTCSR,R31
	STS  WDTCSR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x200

	.CSEG
;/*****************************************************
;Project :
;Version :
;Date    : 12.03.2013
;Author  :
;Company :
;Comments:
;
;
;Chip type           : ATmega168
;Program type        : Boot Loader - Size:1024words
;Clock frequency     : 0,460000 MHz
;Memory model        : Small
;External RAM size   : 0
;Data Stack size     : 256
;*****************************************************/
;
;/*
;***********Функционал Bootloaderа************************
;1. Осуществление связи с ПК по протоколу HART-loader,
;   реализация должна подразумевать корректную работу
;   с ПО Конфигуратор ДВСТ-3.
;2. Возможность записи информации (самопрограммирование)
;   как во flash память устройства, так и в eeprom.
;3. Проверка CRC загруженного кода для определения
;   корректности записи.
;*********************************************************
;
;***********Формат фрейма протокола обмена HART-loader****
;Следует заметить, что протокол HART-loader является по сути тем же
;протоколом HART. Поэтому отличия в части формирования фреймов,
;проверки КС и управления коммуникационными данными практически
;отсутствуют. Однако, ввиду того, что реализация полной версии
;протокола для  Bootloadera проблематична и избыточна, создался
;этот урезанный вариант HART-протокола. Единственным дополнением
;в листе команд протокола является набор команд для
;самопрограммирования контроллера. В свою очередь, подавляющая
;часть "лишних" команд удалена из данной реализации.
;**********************************************************
;
;***********команды протокола обмена HART-loader**********
;00 - чтение идентификационной информации
;06 - запись адреса устройства в HART-сети
;0f - чтение серийного номера датчика
;13 - запись серийного номера датчика
;A9 - запись байта
;AA - запись страницы, при этом страница заполненяется автоматически (если не получен сигнал завершения программирования  ...
;   - старт программирования
;АВ - конец программирования
;   - КС, расчитанная внешним ПО, эту часть скорее всего упраздним, т.к. кс проверяется у нас на следующем этапе - загруз ...
;*********************************************************
;*/
;//#include <mega168.h>
;
;#include <delay.h>
;#include <data_arrays.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
;//#include <mega328p_bits.h>
;#define  PageByte 	 128     // 64 Bytes
;#define  AddressLshift    6
;#asm(".EQU SpmcrAddr=0x57")
	.EQU SpmcrAddr=0x57
;#define IVCE 0
;#define RXB8 1
;#define TXB8 0
;#define WDCE 4
;#define WDE 3
;#define WDP2 2
;#define WDP1 1
;#define WDP0 0
;//#define UPE 2
;//#define OVR 3
;//#define FE 4
;#define UDRE 5
;#define RXC 7
;//#define FRAMING_ERROR (1<<FE)
;//#define PARITY_ERROR (1<<UPE)
;//#define DATA_OVERRUN (1<<OVR)
;//#define DATA_REGISTER_EMPTY (1<<UDRE)
;#define RX_COMPLETE (1<<RXC)
;#define RxEn UCSR0B=(UCSR0B&0xc0)|0x10
;#define TxEn UCSR0B=(UCSR0B&0xc0)|0x08
;#define Transmit PORTD.3=0//=PORTD&0xf7
;#define Recieve PORTD.3=1//PORTD|0x08
;#define wait_startOCD EICRA=0x03
;#define wait_stopOCD EICRA=0x00
;#define disable_uart UCSR0B=0xc0
;#define disable_eints {EIMSK=0x00;EIFR=0x00;}
;#define enable_eints {EIMSK=0x01;EIFR=0x01;}
;//#define enable_led PORTD=PORTD|0x40
;//#define disable_led PORTD=PORTD&0xbf
;#define start_wait_Rx_timer {TIMSK0=0x01;TCCR0A=0x00;TCCR0B=0x04;TCNT0=0xA0;}
;#define stop_wait_Rx_timer {TIMSK0=0x00;TCCR0A=0x00;TCCR0B=0x00;TCNT0=0x00;}
;//#define setlevel_0_10 {PORTD.7=0;PORTD.6=0;}
;//#define setlevel_0_20 {PORTD.7=0;PORTD.6=1;}
;//#define setlevel_0_30 {PORTD.7=1;PORTD.6=0;}
;//#define setlevel_0_50 {PORTD.7=1;PORTD.6=1;}
;// USART Receiver buffer
;register unsigned int Pagedata @2; //program data to be written from this and read back for checking
;register unsigned int PageAddress @4; //address of the page
;register unsigned int CurrentAddress @6; //address of the current data -  PageAddress + loop counter
;//register char inchar @8; //data received from RS232
;register char spmcrval @10; //value to write to SPM control register
;//register unsigned int i @11;   //loop counter
;//register unsigned int j @13;  //loop counter
;#define RX_BUFFER_SIZE0 64
;unsigned char rx_wr_index0,rx_counter0;
;char rx_buffer0[RX_BUFFER_SIZE0];
;//char com_data_rx[25];
;char sensor_address=0x02,com_bytes_rx=0,writePageSegmentsCounter=0,p_bank_addr=0,checking_result=0,command_rx_val=0, pre ...
;
;bit rx_buffer_overflow0,message_recieved=0,answering=0,burst_mode=0;
;volatile char runApplication = 0x00;
;//unsigned int ubbr;
;//unsigned int Checkdata ; //compared with Pagedata for checking
;char PageBuffer[PageByte]; //buffer for data to be written
;eeprom char tmpval[256];
;void transmit_HART(void);
;//int writePageToFlash(void);
;int check_recieved_message();
;int generate_command_data_array_answer(char command_recieved);
;//void update_eeprom_parameters(char update_flag);
;void start_transmit(int transmit_param);
;void clear_buffer();
;void BootLoad(void);
;void eraseApplicationSection();
;void (*voidFuncPtr)(void);
;void (*APPLICATION)(void)=0x0000;
;typedef void (*fptr_t)(void);
;volatile fptr_t reset = (fptr_t)0x0000;
;//void spmMacro(char val);
;// Declare your global variables here
;interrupt [USART_RXC] void usart_rx_isr(void)//прием по USART
; 0000 0084 {

	.CSEG
_usart_rx_isr:
; .FSTART _usart_rx_isr
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0085 
; 0000 0086 char data;
; 0000 0087 #asm("cli")
	ST   -Y,R17
;	data -> R17
	cli
; 0000 0088 //status=UCSR0A;
; 0000 0089 
; 0000 008A data=UDR0;
	LDS  R17,198
; 0000 008B //#asm("sei")
; 0000 008C 
; 0000 008D //if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)//если нет ошибок, то читаем данные в буфере USART
; 0000 008E //   {
; 0000 008F    rx_buffer0[rx_wr_index0]=data;
	MOV  R30,R9
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	ST   Z,R17
; 0000 0090    if (++rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
	INC  R9
	LDI  R30,LOW(64)
	CP   R30,R9
	BRNE _0x3
	CLR  R9
; 0000 0091    if (++rx_counter0 == RX_BUFFER_SIZE0)
_0x3:
	INC  R8
	LDI  R30,LOW(64)
	CP   R30,R8
	BRNE _0x4
; 0000 0092       {
; 0000 0093       rx_counter0=0;
	CLR  R8
; 0000 0094       rx_buffer_overflow0=1;
	SBI  0x1E,0
; 0000 0095 
; 0000 0096      };
_0x4:
; 0000 0097 //   };
; 0000 0098  #asm("sei")
	sei
; 0000 0099 }
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
; .FEND
;// USART Transmitter buffer
;#define TX_BUFFER_SIZE0 64
;char tx_buffer0[TX_BUFFER_SIZE0];
;
;unsigned char tx_rd_index0,tx_counter0;
;
;
;// USART Transmitter interrupt service routine
;interrupt [USART_TXC] void usart_tx_isr(void)//передача по USART соответственно
; 0000 00A3 {
_usart_tx_isr:
; .FSTART _usart_tx_isr
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 00A4 
; 0000 00A5 
; 0000 00A6 if (tx_counter0)
	LDS  R30,_tx_counter0
	CPI  R30,0
	BREQ _0x7
; 0000 00A7    {
; 0000 00A8    --tx_counter0;
	SUBI R30,LOW(1)
	STS  _tx_counter0,R30
; 0000 00A9 
; 0000 00AA    UDR0=tx_buffer0[tx_rd_index0];
	LDS  R30,_tx_rd_index0
	RCALL SUBOPT_0x0
	STS  198,R30
; 0000 00AB 
; 0000 00AC    if (++tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
	LDS  R26,_tx_rd_index0
	SUBI R26,-LOW(1)
	STS  _tx_rd_index0,R26
	CPI  R26,LOW(0x40)
	BRNE _0x8
	LDI  R30,LOW(0)
	STS  _tx_rd_index0,R30
; 0000 00AD    };
_0x8:
_0x7:
; 0000 00AE 
; 0000 00AF }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;// External Interrupt 0 service routine
;interrupt [EXT_INT0] void ext_int0_isr(void)//первоначально прерывание работает по нарастающему уровню (set_rising_edge_ ...
; 0000 00B2 //изменено, таймер, отсчитывающий задержку, сейчас не активен, пользуемся только OCD ногой модема
; 0000 00B3 {
_ext_int0_isr:
; .FSTART _ext_int0_isr
	ST   -Y,R26
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 00B4 if(EICRA==0x03)                    //если сработало прерывание по верхнему уровню, то переключаемся на отлов нижнего уро ...
	LDS  R26,105
	CPI  R26,LOW(0x3)
	BRNE _0x9
; 0000 00B5                 {
; 0000 00B6                 Recieve;
	SBI  0xB,3
; 0000 00B7                 RxEn;
	RCALL SUBOPT_0x1
; 0000 00B8                 //wait_stopOCD;
; 0000 00B9                 //start_wait_Rx_timer;
; 0000 00BA                 //disable_eints;
; 0000 00BB                 wait_stopOCD;           //EICRA=0x00
	LDI  R30,LOW(0)
	STS  105,R30
; 0000 00BC                 message_recieved=0;
	CBI  0x1E,1
; 0000 00BD                 //mono_channel_mode;
; 0000 00BE                 }
; 0000 00BF else
	RJMP _0xE
_0x9:
; 0000 00C0                 {
; 0000 00C1                 //Transmit;
; 0000 00C2 
; 0000 00C3                 //stop_wait_Rx_timer;
; 0000 00C4                 wait_startOCD;            //EICRA=0x03
	LDI  R30,LOW(3)
	STS  105,R30
; 0000 00C5                 disable_uart;             //отключаем USART, переходим в режим приема
	LDI  R30,LOW(192)
	STS  193,R30
; 0000 00C6                 message_recieved=1;
	SBI  0x1E,1
; 0000 00C7 
; 0000 00C8                 }
_0xE:
; 0000 00C9 //start_check_OCD_timer;//стартуем таймер отсчитывающий задержку 3.33 мс (4 цикла при минимальной частоте 1200Гц)
; 0000 00CA 
; 0000 00CB }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;
;
;unsigned char USART_Receive( void )
; 0000 00D0 {
; 0000 00D1 /* Wait for data to be received */
; 0000 00D2 while ( (UCSR0A&0x80)!=0 );
; 0000 00D3 /* Get and return received data from buffer */
; 0000 00D4 rx_counter0++;
; 0000 00D5 //Parameter_bank[1]=0x02;
; 0000 00D6 return UDR0;
; 0000 00D7 }
;void transmit_HART(void)//подпрограмма передачи в по HART
; 0000 00D9 {
_transmit_HART:
; .FSTART _transmit_HART
; 0000 00DA int error_log;
; 0000 00DB error_log=check_recieved_message();    //здесь проверяем корректность принятого сообщения и устанавливаем значение перем ...
	ST   -Y,R17
	ST   -Y,R16
;	error_log -> R16,R17
	RCALL _check_recieved_message
	MOVW R16,R30
; 0000 00DC if(answering)                         //если нужен ответ
	SBIS 0x1E,2
	RJMP _0x14
; 0000 00DD         {
; 0000 00DE         if (!error_log)               //ошибок нет
	MOV  R0,R16
	OR   R0,R17
	BRNE _0x15
; 0000 00DF                 {
; 0000 00E0                 error_log=error_log|(generate_command_data_array_answer(command_rx_val));//здесь обращаемся в генератор  ...
	LDS  R26,_command_rx_val
	RCALL _generate_command_data_array_answer
	__ORWRR 16,17,30,31
; 0000 00E1                 start_transmit(error_log);
	RJMP _0x88
; 0000 00E2                 }
; 0000 00E3         else
_0x15:
; 0000 00E4                 { //соответственно, если ошибки есть
; 0000 00E5                 //PORTD=0x08;
; 0000 00E6                 //Parameter_bank[4]=0x05;
; 0000 00E7                 Recieve;
	SBI  0xB,3
; 0000 00E8 //                rx_buffer_overflow0=0;
; 0000 00E9 //                checking_result=0;
; 0000 00EA //                rx_wr_index0=0;
; 0000 00EB                 message_recieved=0;
	CBI  0x1E,1
; 0000 00EC                 start_transmit(error_log);
_0x88:
	MOVW R26,R16
	RCALL _start_transmit
; 0000 00ED                 }
; 0000 00EE         }
; 0000 00EF else                              //ответ по HART не нужен
	RJMP _0x1B
_0x14:
; 0000 00F0         {
; 0000 00F1 //        rx_buffer_overflow0=0;
; 0000 00F2 //        checking_result=0;
; 0000 00F3 //        rx_wr_index0=0;
; 0000 00F4         RxEn;
	RCALL SUBOPT_0x1
; 0000 00F5         Recieve;
	SBI  0xB,3
; 0000 00F6         }
_0x1B:
; 0000 00F7     checking_result=0;                //сбрасываем "результат проверки"
	LDI  R30,LOW(0)
	STS  _checking_result,R30
; 0000 00F8     rx_wr_index0=0;
	CLR  R9
; 0000 00F9     rx_buffer_overflow0=0;
	CBI  0x1E,0
; 0000 00FA //clear_buffer();
; 0000 00FB }
	LD   R16,Y+
	LD   R17,Y+
	RET
; .FEND
;
;void start_transmit(int transmit_param)  // здесь происходит финализация отправки сообщения, к этому моменту входящее со ...
; 0000 00FE {                                                          //
_start_transmit:
; .FSTART _start_transmit
; 0000 00FF char i=0,j=0;
; 0000 0100 char check_sum_tx=0;
; 0000 0101 while(UCSR0A<0x20){;}
	ST   -Y,R27
	ST   -Y,R26
	RCALL SUBOPT_0x2
;	transmit_param -> Y+4
;	i -> R17
;	j -> R16
;	check_sum_tx -> R19
_0x20:
	LDS  R26,192
	CPI  R26,LOW(0x20)
	BRLO _0x20
; 0000 0102 
; 0000 0103 //if(!RxTx){
; 0000 0104 preambula_bytes=Parameter_bank[3];
	__POINTW2MN _Parameter_bank,3
	RCALL __EEPROMRDB
	STS  _preambula_bytes,R30
; 0000 0105 delay_ms(25);
	LDI  R26,LOW(25)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0106 Transmit;
	CBI  0xB,3
; 0000 0107 TxEn;
	LDS  R30,193
	ANDI R30,LOW(0xC0)
	ORI  R30,8
	STS  193,R30
; 0000 0108 delay_ms(15);
	LDI  R26,LOW(15)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0109 for (i=0;i<preambula_bytes;i++)
	LDI  R17,LOW(0)
_0x26:
	LDS  R30,_preambula_bytes
	CP   R17,R30
	BRSH _0x27
; 0000 010A         {
; 0000 010B         tx_buffer0[i]=0xff;
	RCALL SUBOPT_0x3
	LDI  R26,LOW(255)
	STD  Z+0,R26
; 0000 010C         tx_counter0++;
	LDS  R30,_tx_counter0
	SUBI R30,-LOW(1)
	STS  _tx_counter0,R30
; 0000 010D         }
	SUBI R17,-1
	RJMP _0x26
_0x27:
; 0000 010E //i++;
; 0000 010F if(burst_mode)tx_buffer0[i]=0x01;//стартовый байт
	SBIS 0x1E,3
	RJMP _0x28
	RCALL SUBOPT_0x3
	LDI  R26,LOW(1)
	RJMP _0x89
; 0000 0110 else tx_buffer0[i]=0x06;
_0x28:
	RCALL SUBOPT_0x3
	LDI  R26,LOW(6)
_0x89:
	STD  Z+0,R26
; 0000 0111 check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 0112 i++;
	SUBI R17,-1
; 0000 0113 tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i];//адрес
	RCALL SUBOPT_0x3
	RCALL SUBOPT_0x4
; 0000 0114 check_sum_tx=check_sum_tx^tx_buffer0[i];
	EOR  R19,R30
; 0000 0115 i++;
	SUBI R17,-1
; 0000 0116 tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i];//команда
	RCALL SUBOPT_0x3
	RCALL SUBOPT_0x4
; 0000 0117 check_sum_tx=check_sum_tx^tx_buffer0[i];
	EOR  R19,R30
; 0000 0118 i++;
	SUBI R17,-1
; 0000 0119 if(!transmit_param)
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	SBIW R30,0
	BRNE _0x2A
; 0000 011A         {
; 0000 011B         tx_buffer0[i]=bytes_quantity_ans+2;                                                  //число байт  //нужно созда ...
	RCALL SUBOPT_0x5
	LDS  R30,_bytes_quantity_ans
	RCALL SUBOPT_0x6
; 0000 011C         check_sum_tx=check_sum_tx^tx_buffer0[i];
	EOR  R19,R30
; 0000 011D         i++;
	SUBI R17,-1
; 0000 011E         tx_buffer0[i]=p_bank_addr;                                             //статус 1й байт
	RCALL SUBOPT_0x3
	LDS  R26,_p_bank_addr
	STD  Z+0,R26
; 0000 011F         check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 0120         i++;
	SUBI R17,-1
; 0000 0121         tx_buffer0[i]=0x00;                                             //статус 2й байт
	RCALL SUBOPT_0x3
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 0122         check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 0123         i++;
	SUBI R17,-1
; 0000 0124         for(j=0;j<bytes_quantity_ans;j++)
	LDI  R16,LOW(0)
_0x2C:
	LDS  R30,_bytes_quantity_ans
	CP   R16,R30
	BRSH _0x2D
; 0000 0125                 {
; 0000 0126                 tx_buffer0[i]=Command_data[j];                                                //данные //здесь нужно соз ...
	RCALL SUBOPT_0x5
	MOV  R30,R16
	LDI  R31,0
	SUBI R30,LOW(-_Command_data)
	SBCI R31,HIGH(-_Command_data)
	LD   R30,Z
	ST   X,R30
; 0000 0127                 check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 0128                 i++;
	SUBI R17,-1
; 0000 0129                 }
	SUBI R16,-1
	RJMP _0x2C
_0x2D:
; 0000 012A         }
; 0000 012B else {
	RJMP _0x2E
_0x2A:
; 0000 012C         tx_buffer0[i]=com_bytes_rx+2;       //здесь просто берем количество байт из принятого сообщения                  ...
	RCALL SUBOPT_0x5
	MOV  R30,R13
	RCALL SUBOPT_0x6
; 0000 012D         //bytes_quantity_ans=rx_buffer0[preambula_bytes_rec-preambula_bytes+i]+2;  //эту величину все же нужно сохранить ...
; 0000 012E         check_sum_tx=check_sum_tx^tx_buffer0[i];
	EOR  R19,R30
; 0000 012F         i++;
	SUBI R17,-1
; 0000 0130         tx_buffer0[i]=transmit_param>>8;                                       //статус 1й байт
	RCALL SUBOPT_0x5
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	RCALL __ASRW8
	ST   X,R30
; 0000 0131         check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 0132         i++;
	SUBI R17,-1
; 0000 0133         tx_buffer0[i]=transmit_param;                                          //статус 2й байт
	RCALL SUBOPT_0x3
	LDD  R26,Y+4
	STD  Z+0,R26
; 0000 0134         check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 0135         i++;
	SUBI R17,-1
; 0000 0136         j=i;
	MOV  R16,R17
; 0000 0137         for(i=j;i<com_bytes_rx+j;i++)
	MOV  R17,R16
_0x30:
	MOV  R26,R13
	CLR  R27
	MOV  R30,R16
	RCALL SUBOPT_0x7
	BRGE _0x31
; 0000 0138                 {
; 0000 0139                 tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i-2];                                       ...
	RCALL SUBOPT_0x3
	MOVW R22,R30
	LDS  R26,_preambula_bytes_rec
	CLR  R27
	LDS  R30,_preambula_bytes
	LDI  R31,0
	SUB  R26,R30
	SBC  R27,R31
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	RCALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 013A                 check_sum_tx=check_sum_tx^tx_buffer0[i];
	MOV  R30,R17
	RCALL SUBOPT_0x0
	EOR  R19,R30
; 0000 013B                 //i++;
; 0000 013C                 }
	SUBI R17,-1
	RJMP _0x30
_0x31:
; 0000 013D         }
_0x2E:
; 0000 013E         //i++;
; 0000 013F tx_buffer0[i]=check_sum_tx;
	RCALL SUBOPT_0x3
	ST   Z,R19
; 0000 0140 tx_rd_index0=1;
	LDI  R30,LOW(1)
	STS  _tx_rd_index0,R30
; 0000 0141 //if(!transmit_param){
; 0000 0142 //for(i=0;i<=rx_counter0;i++)tx_buffer0[i]=rx_buffer0[i]; }
; 0000 0143 //tx_rd_index0=1;
; 0000 0144 tx_counter0=i;
	STS  _tx_counter0,R17
; 0000 0145 UDR0=tx_buffer0[0];
	LDS  R30,_tx_buffer0
	STS  198,R30
; 0000 0146 //Parameter_bank[5]=0x06;
; 0000 0147 while(tx_counter0){;}
_0x32:
	LDS  R30,_tx_counter0
	CPI  R30,0
	BRNE _0x32
; 0000 0148 delay_ms(15);
	LDI  R26,LOW(15)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0149 //RxEn;
; 0000 014A Recieve;
	SBI  0xB,3
; 0000 014B message_recieved=0;
	CBI  0x1E,1
; 0000 014C rx_counter0=0;
	CLR  R8
; 0000 014D 
; 0000 014E }
	RCALL __LOADLOCR4
	RJMP _0x2000002
; .FEND
;
;
;
;int generate_command_data_array_answer(char command_recieved)//загружаем из эсппзу сохраненный массив параметров (Parame ...
; 0000 0153 {
_generate_command_data_array_answer:
; .FSTART _generate_command_data_array_answer
; 0000 0154 char i=0,error=0,j=0;
; 0000 0155 //char *dataPtr ;
; 0000 0156 //*dataPtr = Parameter_bank[98];
; 0000 0157 
; 0000 0158 //runApplication=0x00;
; 0000 0159 bytes_quantity_ans=1;
	ST   -Y,R26
	RCALL SUBOPT_0x2
;	command_recieved -> Y+4
;	i -> R17
;	error -> R16
;	j -> R19
	LDI  R30,LOW(1)
	STS  _bytes_quantity_ans,R30
; 0000 015A //if((command_recieved==0x00)|(command_recieved==0x06)|(command_recieved==0x16)|(command_recieved==0x19)|(command_reciev ...
; 0000 015B if(command_recieved == 0x00)
	LDD  R30,Y+4
	CPI  R30,0
	BRNE _0x39
; 0000 015C {
; 0000 015D 
; 0000 015E     bytes_quantity_ans=12;
	LDI  R30,LOW(12)
	STS  _bytes_quantity_ans,R30
; 0000 015F     //while(i<12)
; 0000 0160     for(i=1;i<12;i++)
	LDI  R17,LOW(1)
_0x3B:
	CPI  R17,12
	BRSH _0x3C
; 0000 0161     Command_data[i]=Parameter_bank[i];
	RCALL SUBOPT_0x8
	MOV  R26,R17
	LDI  R27,0
	SUBI R26,LOW(-_Parameter_bank)
	SBCI R27,HIGH(-_Parameter_bank)
	RCALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	SUBI R17,-1
	RJMP _0x3B
_0x3C:
; 0000 0163 }
; 0000 0164 if(command_recieved==0x06)
_0x39:
	LDD  R26,Y+4
	CPI  R26,LOW(0x6)
	BRNE _0x3D
; 0000 0165 {
; 0000 0166     // bytes_quantity_ans=1;
; 0000 0167      sensor_address = rx_buffer0[preambula_bytes_rec+4];
	LDS  R30,_preambula_bytes_rec
	LDI  R31,0
	__ADDW1MN _rx_buffer0,4
	LD   R11,Z
; 0000 0168      Parameter_bank[25] = sensor_address;
	__POINTW2MN _Parameter_bank,25
	MOV  R30,R11
	RCALL __EEPROMWRB
; 0000 0169      Command_data[0] =  sensor_address;
	STS  _Command_data,R11
; 0000 016A  //    error=0;
; 0000 016B }
; 0000 016C if(command_recieved==16)
_0x3D:
	LDD  R26,Y+4
	CPI  R26,LOW(0x10)
	BRNE _0x3E
; 0000 016D {
; 0000 016E     bytes_quantity_ans=3;
	RCALL SUBOPT_0x9
; 0000 016F    for(i=0;i<3;i++)
_0x40:
	CPI  R17,3
	BRSH _0x41
; 0000 0170    Command_data[i] = Parameter_bank[98+i];
	RCALL SUBOPT_0x8
	RCALL SUBOPT_0xA
	MOVW R26,R30
	RCALL __EEPROMRDB
	MOVW R26,R0
	ST   X,R30
	SUBI R17,-1
	RJMP _0x40
_0x41:
; 0000 0176 }
; 0000 0177 if(command_recieved==19)
_0x3E:
	LDD  R26,Y+4
	CPI  R26,LOW(0x13)
	BRNE _0x42
; 0000 0178 {
; 0000 0179     bytes_quantity_ans=3;
	RCALL SUBOPT_0x9
; 0000 017A     for(i=0;i<3;i++)
_0x44:
	CPI  R17,3
	BRSH _0x45
; 0000 017B     Parameter_bank[98+i]=rx_buffer0[preambula_bytes_rec+4+i];
	RCALL SUBOPT_0xA
	RCALL SUBOPT_0xB
	MOV  R30,R17
	RCALL SUBOPT_0xC
	RCALL __EEPROMWRB
	SUBI R17,-1
	RJMP _0x44
_0x45:
; 0000 017F }
; 0000 0180 //if(command_recieved==42)
; 0000 0181 //{
; 0000 0182 //   //bytes_quantity_ans=0;
; 0000 0183 //   //Command_data[0]=
; 0000 0184 //   //if(rx_buffer0[]
; 0000 0185 //   Command_data[0] =  0x0C;
; 0000 0186 //}
; 0000 0187 if(command_recieved>=0xaa)
_0x42:
	LDD  R26,Y+4
	CPI  R26,LOW(0xAA)
	BRLO _0x46
; 0000 0188 {
; 0000 0189 
; 0000 018A 
; 0000 018B //    if(writePageSegmentsCounter<3)writePageSegmentsCounter++;
; 0000 018C //    else writePageSegmentsCounter = 0;
; 0000 018D     if(command_recieved==0xaa)
	CPI  R26,LOW(0xAA)
	BRNE _0x47
; 0000 018E     {
; 0000 018F         for(i=writePageSegmentsCounter*32; i<(writePageSegmentsCounter+1)*32;i++,j++)
	MOV  R30,R12
	LDI  R26,LOW(32)
	MULS R30,R26
	MOV  R17,R0
_0x49:
	MOV  R30,R12
	LDI  R31,0
	ADIW R30,1
	LSL  R30
	ROL  R31
	RCALL __LSLW4
	MOV  R26,R17
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRGE _0x4A
; 0000 0190             PageBuffer[i]=rx_buffer0[preambula_bytes_rec+4+j];
	RCALL SUBOPT_0xD
	RCALL SUBOPT_0xB
	MOV  R30,R19
	RCALL SUBOPT_0xC
	ST   X,R30
	SUBI R17,-1
	SUBI R19,-1
	RJMP _0x49
_0x4A:
; 0000 0191 if(writePageSegmentsCounter==3)
	LDI  R30,LOW(3)
	CP   R30,R12
	BRNE _0x4B
; 0000 0192         {
; 0000 0193             #asm("cli")
	cli
; 0000 0194             BootLoad();
	RCALL _BootLoad
; 0000 0195             #asm("sei")
	sei
; 0000 0196             writePageSegmentsCounter=0;
	CLR  R12
; 0000 0197 
; 0000 0198             //PageAddress+=128;
; 0000 0199         }
; 0000 019A         else writePageSegmentsCounter++;
	RJMP _0x4C
_0x4B:
	INC  R12
; 0000 019B     }
_0x4C:
; 0000 019C     else
	RJMP _0x4D
_0x47:
; 0000 019D     {
; 0000 019E      runApplication=0x11;
	LDI  R30,LOW(17)
	STS  _runApplication,R30
; 0000 019F      writePageSegmentsCounter=0;
	CLR  R12
; 0000 01A0 //    MCUCR = 0x01;
; 0000 01A1 //    MCUCR = 0x00;
; 0000 01A2 ////Parameter_bank[0]=0x11;
; 0000 01A3 //    //delay_ms(100);
; 0000 01A4 //    voidFuncPtr=(void(*)(void))0x00B8;   //адресс куда переходим
; 0000 01A5 //    voidFuncPtr();
; 0000 01A6 //    #asm("jmp 0x00B8");
; 0000 01A7      }
_0x4D:
; 0000 01A8     Command_data[0] =  0x0C;
	LDI  R30,LOW(12)
	STS  _Command_data,R30
; 0000 01A9  //   error=0;
; 0000 01AA 
; 0000 01AB }
; 0000 01AC //if(command_recieved==0xab)
; 0000 01AD //{
; 0000 01AE //    runApplication=0x11;
; 0000 01AF //    Command_data[0] =  0x0C;
; 0000 01B0 //     error=0;
; 0000 01B1 //}
; 0000 01B2 return error;
_0x46:
	MOV  R30,R16
	LDI  R31,0
	RCALL __LOADLOCR4
	ADIW R28,5
	RET
; 0000 01B3 }
; .FEND
;
;int check_recieved_message(){
; 0000 01B5 int check_recieved_message(){
_check_recieved_message:
; .FSTART _check_recieved_message
; 0000 01B6 char i=0,j=0,k=0,tmp_i=0;//здесь i - счетчик всех байт j- счетчик байт преамбул
; 0000 01B7 
; 0000 01B8 int check_sum=0;
; 0000 01B9 checking_result=0;
	RCALL __SAVELOCR6
;	i -> R17
;	j -> R16
;	k -> R19
;	tmp_i -> R18
;	check_sum -> R20,R21
	LDI  R17,0
	LDI  R16,0
	LDI  R19,0
	LDI  R18,0
	__GETWRN 20,21,0
	LDI  R30,LOW(0)
	STS  _checking_result,R30
; 0000 01BA answering=1;
	SBI  0x1E,2
; 0000 01BB while ((rx_buffer0[j])==0xff)
_0x50:
	RCALL SUBOPT_0xE
	CPI  R26,LOW(0xFF)
	BRNE _0x52
; 0000 01BC         {
; 0000 01BD         if(8<j)
	CPI  R16,9
	BRLO _0x53
; 0000 01BE                 {checking_result=0x90;//ошибка формирования фрейма, если количество преамбул больше либо равно количеств ...
	LDI  R30,LOW(144)
	STS  _checking_result,R30
; 0000 01BF                  //rx_buffer0[i+1]=0x00;
; 0000 01C0                  return checking_result;
	RJMP _0x2000001
; 0000 01C1                  }
; 0000 01C2          j++;
_0x53:
	SUBI R16,-1
; 0000 01C3         }
	RJMP _0x50
_0x52:
; 0000 01C4         preambula_bytes_rec=j;
	STS  _preambula_bytes_rec,R16
; 0000 01C5         i=j;
	MOV  R17,R16
; 0000 01C6 if ((rx_buffer0[j])!=0x02)
	RCALL SUBOPT_0xE
	CPI  R26,LOW(0x2)
	BREQ _0x54
; 0000 01C7 //if ((rx_buffer0[i])!=0x02)
; 0000 01C8         {
; 0000 01C9         checking_result=0x02;
	LDI  R30,LOW(2)
	STS  _checking_result,R30
; 0000 01CA         //return checking_result;
; 0000 01CB         }//диагностируем ошибку команд "неверный выбор", если не от главного устройства
; 0000 01CC //else    {
; 0000 01CD         check_sum=check_sum^rx_buffer0[i];
_0x54:
	RCALL SUBOPT_0xF
	RCALL SUBOPT_0x10
; 0000 01CE //        }
; 0000 01CF i++;
; 0000 01D0 if (((rx_buffer0[i])&0x30)!=0x00)
	ANDI R30,LOW(0x30)
	BREQ _0x55
; 0000 01D1         {checking_result=0x90;
	LDI  R30,LOW(144)
	STS  _checking_result,R30
; 0000 01D2         //return checking_result;
; 0000 01D3         }
; 0000 01D4 //burst_mode=(rx_buffer0[i]&0x40)>>6;                          //burst_mode нужно вообще-то прописывать в команде
; 0000 01D5 if((rx_buffer0[i]&0x0f)==Parameter_bank[25])answering=1;       //это проверка адреса, если адрес не тот, датчик молчит
_0x55:
	RCALL SUBOPT_0xF
	ANDI R30,LOW(0xF)
	MOV  R0,R30
	__POINTW2MN _Parameter_bank,25
	RCALL __EEPROMRDB
	CP   R30,R0
	BRNE _0x56
	SBI  0x1E,2
; 0000 01D6 else answering=0;
	RJMP _0x59
_0x56:
	CBI  0x1E,2
; 0000 01D7 check_sum=check_sum^rx_buffer0[i];
_0x59:
	RCALL SUBOPT_0xF
	RCALL SUBOPT_0x10
; 0000 01D8 i++;
; 0000 01D9 command_rx_val=rx_buffer0[i];// здесь надо бы делать проверку команды: если она состоит в листе команд, то ошибку не выд ...
	STS  _command_rx_val,R30
; 0000 01DA check_sum=check_sum^rx_buffer0[i];
	RCALL SUBOPT_0xF
	RCALL SUBOPT_0x11
; 0000 01DB i++;
; 0000 01DC com_bytes_rx=rx_buffer0[i];                    //количество байт, зная их проверяем число байт данных и если оно не совп ...
	RCALL SUBOPT_0x12
	LD   R13,Z
; 0000 01DD check_sum=check_sum^rx_buffer0[i];
	RCALL SUBOPT_0xF
	RCALL SUBOPT_0x11
; 0000 01DE i++;
; 0000 01DF tmp_i=i;
	MOV  R18,R17
; 0000 01E0 j=tmp_i;
	MOV  R16,R18
; 0000 01E1 for (i=tmp_i;i<tmp_i+com_bytes_rx;i++)
	MOV  R17,R18
_0x5D:
	MOV  R26,R18
	CLR  R27
	MOV  R30,R13
	RCALL SUBOPT_0x7
	BRGE _0x5E
; 0000 01E2        {
; 0000 01E3        j++;
	SUBI R16,-1
; 0000 01E4        //com_data_rx[k]=rx_buffer0[i];
; 0000 01E5        check_sum=check_sum^rx_buffer0[i];
	RCALL SUBOPT_0xF
	LDI  R31,0
	__EORWRR 20,21,30,31
; 0000 01E6        k++;
	SUBI R19,-1
; 0000 01E7        }
	SUBI R17,-1
	RJMP _0x5D
_0x5E:
; 0000 01E8                 //j++;
; 0000 01E9 //        if(com_bytes_rx!=0)i--;
; 0000 01EA if (j!=i)
	CP   R17,R16
	BREQ _0x5F
; 0000 01EB        {checking_result=0x90;
	LDI  R30,LOW(144)
	STS  _checking_result,R30
; 0000 01EC        //return checking_result;
; 0000 01ED        }
; 0000 01EE //i++;
; 0000 01EF if(rx_buffer0[i]!=check_sum)
_0x5F:
	RCALL SUBOPT_0x12
	LD   R26,Z
	MOVW R30,R20
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BREQ _0x60
; 0000 01F0         {
; 0000 01F1         checking_result=0x88;
	LDI  R30,LOW(136)
	STS  _checking_result,R30
; 0000 01F2         //return checking_result;
; 0000 01F3         }
; 0000 01F4 return checking_result;
_0x60:
_0x2000001:
	LDS  R30,_checking_result
	LDI  R31,0
	RCALL __LOADLOCR6
_0x2000002:
	ADIW R28,6
	RET
; 0000 01F5 }
; .FEND
;
;void clear_buffer()
; 0000 01F8 {
; 0000 01F9 char i=0;
; 0000 01FA for (i=0;i<RX_BUFFER_SIZE0;i++)
;	i -> R17
; 0000 01FB         {
; 0000 01FC         rx_buffer0[i]=0;
; 0000 01FD         tx_buffer0[i]=0;
; 0000 01FE         }
; 0000 01FF for (i=0;i<25;i++)
; 0000 0200         {
; 0000 0201 //        com_data_rx[i]=0;
; 0000 0202         Command_data[i]=0;
; 0000 0203         }
; 0000 0204 }
;
;void system_init(){
; 0000 0206 void system_init(){
_system_init:
; .FSTART _system_init
; 0000 0207 //#asm("wdr")
; 0000 0208 //WDTCSR=0x38;
; 0000 0209 //WDTCSR=0x0E;
; 0000 020A // Crystal Oscillator division factor: 1
; 0000 020B /*#pragma optsize-
; 0000 020C CLKPR=0x80;
; 0000 020D CLKPR=0x00;
; 0000 020E #ifdef _OPTIMIZE_SIZE_
; 0000 020F #pragma optsize+
; 0000 0210 #endif
; 0000 0211   */
; 0000 0212 // Input/Output Ports initialization
; 0000 0213 // Port B initialization
; 0000 0214 // Func7=In Func6=In Func5=Out Func4=In Func3=Out Func2=Out Func1=In Func0=In
; 0000 0215 // State7=T State6=T State5=0 State4=T State3=0 State2=0 State1=T State0=T
; 0000 0216 PORTB=0x00;
	LDI  R30,LOW(0)
	OUT  0x5,R30
; 0000 0217 DDRB=0x2c;
	LDI  R30,LOW(44)
	OUT  0x4,R30
; 0000 0218 
; 0000 0219 // Port D initialization
; 0000 021A // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 021B // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 021C //PORTD=0x00;
; 0000 021D DDRD.3=1;
	SBI  0xA,3
; 0000 021E PORTD.3=1;
	SBI  0xB,3
; 0000 021F //DDRD.6=1;
; 0000 0220 //DDRD.7=1;
; 0000 0221 //PORTD.6=0;
; 0000 0222 //PORTD.7=0;
; 0000 0223 
; 0000 0224 stop_wait_Rx_timer;
	LDI  R30,LOW(0)
	STS  110,R30
	OUT  0x24,R30
	OUT  0x25,R30
	OUT  0x26,R30
; 0000 0225 /*USART predefinition: 1200 baud rate, tx enable, all interrutpts enabled 8bit buffer*/
; 0000 0226 //UCSR0A=0x00;
; 0000 0227 UCSR0B=0xc0;
	LDI  R30,LOW(192)
	STS  193,R30
; 0000 0228 UCSR0C=0x06;
	LDI  R30,LOW(6)
	STS  194,R30
; 0000 0229 //UBRR0H=0x00;
; 0000 022A UBRR0L=0x17;
	LDI  R30,LOW(23)
	STS  196,R30
; 0000 022B 
; 0000 022C 
; 0000 022D // External Interrupt(s) initialization
; 0000 022E // INT0: On
; 0000 022F // INT0 Mode: Any change
; 0000 0230 // INT1: Off
; 0000 0231 // Interrupt on any change on pins PCINT0-7: Off
; 0000 0232 // Interrupt on any change on pins PCINT8-14: Off
; 0000 0233 // Interrupt on any change on pins PCINT16-23: Off
; 0000 0234 wait_startOCD;
	LDI  R30,LOW(3)
	STS  105,R30
; 0000 0235 EIMSK=0x01;
	LDI  R30,LOW(1)
	OUT  0x1D,R30
; 0000 0236 EIFR=0x01;
	OUT  0x1C,R30
; 0000 0237 //PCICR=0x00;
; 0000 0238 MCUCR = 0x01;
	OUT  0x35,R30
; 0000 0239 MCUCR = 0x03;
	LDI  R30,LOW(3)
	OUT  0x35,R30
; 0000 023A 
; 0000 023B }
	RET
; .FEND
;
;void BootLoad(void)
; 0000 023E {
_BootLoad:
; .FSTART _BootLoad
; 0000 023F     char i=0;
; 0000 0240     for (i=0;i<PageByte;i+=2) //fill temporary buffer in 2 byte chunks from PageBuffer
	ST   -Y,R17
;	i -> R17
	LDI  R17,0
	LDI  R17,LOW(0)
_0x6C:
	CPI  R17,128
	BRSH _0x6D
; 0000 0241 
; 0000 0242         {
; 0000 0243         Pagedata=PageBuffer[i]+(PageBuffer[i+1]<<8);
	RCALL SUBOPT_0xD
	LD   R26,Z
	LDI  R27,0
	MOV  R30,R17
	LDI  R31,0
	__ADDW1MN _PageBuffer,1
	LD   R31,Z
	LDI  R30,LOW(0)
	ADD  R30,R26
	ADC  R31,R27
	MOVW R2,R30
; 0000 0244         CurrentAddress=PageAddress+i;
	MOV  R30,R17
	LDI  R31,0
	ADD  R30,R4
	ADC  R31,R5
	MOVW R6,R30
; 0000 0245 //        spmMacro(1);
; 0000 0246         while (SPMCSR&1); //wait for spm complete
_0x6E:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x6E
; 0000 0247         spmcrval=1;
	LDI  R30,LOW(1)
	MOV  R10,R30
; 0000 0248         #asm
; 0000 0249         movw r30, r6    ;//move CurrentAddress to Z pointer
        movw r30, r6    ;//move CurrentAddress to Z pointer
; 0000 024A         mov r1, r3        ;//move Pagedata MSB reg 1
        mov r1, r3        ;//move Pagedata MSB reg 1
; 0000 024B         mov r0, r2        ;//move Pagedata LSB reg 1
        mov r0, r2        ;//move Pagedata LSB reg 1
; 0000 024C         sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
        sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
; 0000 024D         spm                ;//store program memory
        spm                ;//store program memory
; 0000 024E         #endasm
; 0000 024F         }
	SUBI R17,-LOW(2)
	RJMP _0x6C
_0x6D:
; 0000 0250 //         spmMacro(3);
; 0000 0251 //         spmMacro(5);
; 0000 0252     while (SPMCSR&1);  //wait for spm complete
_0x71:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x71
; 0000 0253     spmcrval=3;        //erase page
	LDI  R30,LOW(3)
	MOV  R10,R30
; 0000 0254     #asm
; 0000 0255     movw r30, r4       ;//move PageAddress to Z pointer
    movw r30, r4       ;//move PageAddress to Z pointer
; 0000 0256     sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
; 0000 0257     spm                 ;//erase page
    spm                 ;//erase page
; 0000 0258     #endasm
; 0000 0259 
; 0000 025A     while (SPMCSR&1); //wait for spm complete
_0x74:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x74
; 0000 025B     spmcrval=5;        //write page
	LDI  R30,LOW(5)
	MOV  R10,R30
; 0000 025C     #asm
; 0000 025D     movw r30, r4       ;//move PageAddress to Z pointer
    movw r30, r4       ;//move PageAddress to Z pointer
; 0000 025E     sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
; 0000 025F     spm                 ;//write page
    spm                 ;//write page
; 0000 0260     #endasm
; 0000 0261     PageAddress +=128 ; //essentially the same as multiply by PageSize
	MOVW R30,R4
	SUBI R30,LOW(-128)
	SBCI R31,HIGH(-128)
	MOVW R4,R30
; 0000 0262   }
	LD   R17,Y+
	RET
; .FEND
;//void spmMacro(char val)
;//{
;//    while (SPMCSR&1); //wait for spm complete
;//    spmcrval=val;        //if val = 5 - write page if val = 3 - erase page, if val = 1 save data to buffe
;//    #asm
;//    movw r30, r4       ;//move PageAddress to Z pointer
;//    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
;//    spm                 ;//write page
;//    #endasm
;//}
;void eraseApplicationSection()
; 0000 026E {
_eraseApplicationSection:
; .FSTART _eraseApplicationSection
; 0000 026F #asm("cli");
	cli
; 0000 0270 for(PageAddress=0; PageAddress<12288; PageAddress++)
	CLR  R4
	CLR  R5
_0x78:
	LDI  R30,LOW(12288)
	LDI  R31,HIGH(12288)
	CP   R4,R30
	CPC  R5,R31
	BRSH _0x79
; 0000 0271 {
; 0000 0272     while (SPMCSR&1);  //wait for spm complete
_0x7A:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x7A
; 0000 0273     spmcrval=3;        //erase page
	LDI  R30,LOW(3)
	MOV  R10,R30
; 0000 0274     #asm
; 0000 0275     movw r30, r4       ;//move PageAddress to Z pointer
    movw r30, r4       ;//move PageAddress to Z pointer
; 0000 0276     sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
; 0000 0277     spm                 ;//erase page
    spm                 ;//erase page
; 0000 0278     #endasm
; 0000 0279 }
	MOVW R30,R4
	ADIW R30,1
	MOVW R4,R30
	RJMP _0x78
_0x79:
; 0000 027A PageAddress=0;
	CLR  R4
	CLR  R5
; 0000 027B runApplication=0x00;
	LDI  R30,LOW(0)
	STS  _runApplication,R30
; 0000 027C #asm("sei");
	sei
; 0000 027D 
; 0000 027E }
	RET
; .FEND
;void executeLoadedCode(void)
; 0000 0280 {
; 0000 0281 #asm("sei");
; 0000 0282 system_init();
; 0000 0283 RxEn;
; 0000 0284 Recieve;
; 0000 0285 //#asm("wdr");
; 0000 0286 //Parameter_bank[0]=0x11;
; 0000 0287 //delay_ms(1000);
; 0000 0288 
; 0000 0289 //Parameter_bank[0]=0x11;
; 0000 028A SPMCSR = 0x00;
; 0000 028B delay_ms(100);
; 0000 028C 
; 0000 028D //reset();
; 0000 028E //APPLICATION();
; 0000 028F //voidFuncPtr=(void(*)(void))0x0000;   //адресс куда переходим
; 0000 0290 //voidFuncPtr();
; 0000 0291 
; 0000 0292 }
;void main(void)
; 0000 0294 {
_main:
; .FSTART _main
; 0000 0295 // Declare your local variables here
; 0000 0296 //int i=0,j=0;
; 0000 0297 //int a = 0;
; 0000 0298 system_init();
	RCALL _system_init
; 0000 0299 
; 0000 029A //for(i =0; i<128; i++)
; 0000 029B //PageBuffer[i]=i;
; 0000 029C //BootLoad();
; 0000 029D //SPMCSR = 0x00;
; 0000 029E //#asm("wdr")
; 0000 029F //
; 0000 02A0 //for(i=0; i < 64;i++)
; 0000 02A1 //{
; 0000 02A2 //
; 0000 02A3 //formTmpBuffer(i);
; 0000 02A4 //
; 0000 02A5 //}
; 0000 02A6 //erasePageFromMemory(0x0000);
; 0000 02A7 
; 0000 02A8 //while (SPMCSR&1);
; 0000 02A9 //writePageToMemory(0x0000);
; 0000 02AA 
; 0000 02AB 
; 0000 02AC //sensor_address=Parameter_bank[14];
; 0000 02AD //writePageToFlash();
; 0000 02AE #asm("sei")
	sei
; 0000 02AF //#asm("wdr")
; 0000 02B0         runApplication=Parameter_bank[0];
	LDI  R26,LOW(_Parameter_bank)
	LDI  R27,HIGH(_Parameter_bank)
	RCALL __EEPROMRDB
	STS  _runApplication,R30
; 0000 02B1 //        Parameter_bank[0]++;
; 0000 02B2         //runApplication=0x11;
; 0000 02B3         RxEn;
	RCALL SUBOPT_0x1
; 0000 02B4         Recieve;
	SBI  0xB,3
; 0000 02B5 //delay_ms(2000);
; 0000 02B6 
; 0000 02B7 
; 0000 02B8 
; 0000 02B9         while (1)
_0x81:
; 0000 02BA               {
; 0000 02BB                 #asm("wdr")
	wdr
; 0000 02BC                 if(runApplication==0x11)//&(runApplication<0x15))
	LDS  R26,_runApplication
	CPI  R26,LOW(0x11)
	BRNE _0x84
; 0000 02BD                     {
; 0000 02BE                     delay_ms(10);
	RCALL SUBOPT_0x13
; 0000 02BF                     //executeLoadedCode();
; 0000 02C0                     Parameter_bank[0]=0x11;
	LDI  R30,LOW(17)
	RCALL __EEPROMWRB
; 0000 02C1                     delay_ms(10);
	LDI  R26,LOW(10)
	LDI  R27,0
	RCALL _delay_ms
; 0000 02C2                     #asm("sei");
	sei
; 0000 02C3                     MCUCR = 0x01;
	LDI  R30,LOW(1)
	OUT  0x35,R30
; 0000 02C4                     MCUCR = 0x00;
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 02C5                     reset();
	__CALL1MN _reset,0
; 0000 02C6 //                   #asm
; 0000 02C7 //                                  ldi r16, 0;\n\t"
; 0000 02C8 //                                  push r16;\n\t"
; 0000 02C9 //                                  ldi r16, 0;\n\t"
; 0000 02CA //                                  push r16; \n\t"
; 0000 02CB //                                  ret;   \n\t"
; 0000 02CC //
; 0000 02CD //                   #endasm
; 0000 02CE //                    #asm ("jmp 0x0000");
; 0000 02CF                     }
; 0000 02D0                // if((runApplication>=0x15)&(runApplication<0xee))Parameter_bank[0]=0x00;
; 0000 02D1                 if(runApplication>=0xee)
_0x84:
	LDS  R26,_runApplication
	CPI  R26,LOW(0xEE)
	BRLO _0x85
; 0000 02D2                     {
; 0000 02D3                     eraseApplicationSection();
	RCALL _eraseApplicationSection
; 0000 02D4 
; 0000 02D5                     delay_ms(10);
	RCALL SUBOPT_0x13
; 0000 02D6                     Parameter_bank[0]=0x00;
	LDI  R30,LOW(0)
	RCALL __EEPROMWRB
; 0000 02D7                     Parameter_bank[2]=0xA3;
	__POINTW2MN _Parameter_bank,2
	LDI  R30,LOW(163)
	RCALL __EEPROMWRB
; 0000 02D8                     }
; 0000 02D9                // if(runApplication==0x01)Parameter_bank[0]=0x00;
; 0000 02DA                 if(message_recieved)
_0x85:
	SBIC 0x1E,1
; 0000 02DB                 {
; 0000 02DC                 transmit_HART();
	RCALL _transmit_HART
; 0000 02DD                 }
; 0000 02DE 
; 0000 02DF               }
	RJMP _0x81
; 0000 02E0 }
_0x87:
	RJMP _0x87
; .FEND

	.ESEG
_Parameter_bank:
	.DB  0x0,0x56,0xA3,0x4
	.DB  0x1,0x1,0x1,0x21
	.DB  0x0,0x0,0xBF,0xBC
	.DB  0x6D,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x2,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x1
	.DB  0x2,0x3,0x42,0x48
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x3C,0x23
	.DB  0xD7,0xA,0x0,0x0
	.DB  0x0,0x0,0xA0,0x41
	.DB  0x0,0x0,0x0,0x0
	.DB  0xF0,0xF,0x5,0x0
	.DB  0x1,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x80
	.DB  0x40,0x0,0x0,0xA0
	.DB  0x41,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0

	.DSEG
_rx_buffer0:
	.BYTE 0x40
_p_bank_addr:
	.BYTE 0x1
_checking_result:
	.BYTE 0x1
_command_rx_val:
	.BYTE 0x1
_preambula_bytes_rec:
	.BYTE 0x1
_bytes_quantity_ans:
	.BYTE 0x1
_Command_data:
	.BYTE 0x19
_preambula_bytes:
	.BYTE 0x1
_runApplication:
	.BYTE 0x1
_PageBuffer:
	.BYTE 0x80
_reset:
	.BYTE 0x2
_tx_buffer0:
	.BYTE 0x40
_tx_rd_index0:
	.BYTE 0x1
_tx_counter0:
	.BYTE 0x1

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 12 TIMES, CODE SIZE REDUCTION:31 WORDS
SUBOPT_0x0:
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R30,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x1:
	LDS  R30,193
	ANDI R30,LOW(0xC0)
	ORI  R30,0x10
	STS  193,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2:
	RCALL __SAVELOCR4
	LDI  R17,0
	LDI  R16,0
	LDI  R19,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x3:
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x4:
	MOVW R0,R30
	LDS  R26,_preambula_bytes_rec
	CLR  R27
	LDS  R30,_preambula_bytes
	LDI  R31,0
	SUB  R26,R30
	SBC  R27,R31
	MOV  R30,R17
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R30,Z
	MOVW R26,R0
	ST   X,R30
	MOV  R30,R17
	RJMP SUBOPT_0x0

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5:
	MOV  R26,R17
	LDI  R27,0
	SUBI R26,LOW(-_tx_buffer0)
	SBCI R27,HIGH(-_tx_buffer0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x6:
	SUBI R30,-LOW(2)
	ST   X,R30
	MOV  R30,R17
	RJMP SUBOPT_0x0

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x7:
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	MOV  R26,R17
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x8:
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_Command_data)
	SBCI R31,HIGH(-_Command_data)
	MOVW R0,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x9:
	LDI  R30,LOW(3)
	STS  _bytes_quantity_ans,R30
	LDI  R17,LOW(0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xA:
	MOV  R30,R17
	LDI  R31,0
	__ADDW1MN _Parameter_bank,98
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xB:
	MOVW R0,R30
	LDS  R30,_preambula_bytes_rec
	LDI  R31,0
	ADIW R30,4
	MOVW R26,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0xC:
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R30,Z
	MOVW R26,R0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xD:
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_PageBuffer)
	SBCI R31,HIGH(-_PageBuffer)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0xE:
	MOV  R30,R16
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R26,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:26 WORDS
SUBOPT_0xF:
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R30,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x10:
	LDI  R31,0
	__EORWRR 20,21,30,31
	SUBI R17,-1
	RJMP SUBOPT_0xF

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x11:
	LDI  R31,0
	__EORWRR 20,21,30,31
	SUBI R17,-1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x12:
	MOV  R30,R17
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x13:
	LDI  R26,LOW(10)
	LDI  R27,0
	RCALL _delay_ms
	LDI  R26,LOW(_Parameter_bank)
	LDI  R27,HIGH(_Parameter_bank)
	RET


	.CSEG
_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USB 0x99
	wdr
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__LSLW4:
	LSL  R30
	ROL  R31
__LSLW3:
	LSL  R30
	ROL  R31
__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

__ASRW8:
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	RET

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:

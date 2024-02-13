$NOLIST
$MODN76E003
$LIST

$NOLIST
$include(math32.inc)
$LIST

$NOLIST
$include(LCD_4bit.inc)
$LIST


;  N76E003 pinout:
;                               -------
;       PWM2/IC6/T0/AIN4/P0.5 -|1    20|- P0.4/AIN5/STADC/PWM3/IC3
;               TXD/AIN3/P0.6 -|2    19|- P0.3/PWM5/IC5/AIN6
;               RXD/AIN2/P0.7 -|3    18|- P0.2/ICPCK/OCDCK/RXD_1/[SCL]
;                    RST/P2.0 -|4    17|- P0.1/PWM4/IC4/MISO
;        INT0/OSCIN/AIN1/P3.0 -|5    16|- P0.0/PWM3/IC3/MOSI/T1
;              INT1/AIN0/P1.7 -|6    15|- P1.0/PWM2/IC2/SPCLK
;                         GND -|7    14|- P1.1/PWM1/IC1/AIN7/CLO
;[SDA]/TXD_1/ICPDA/OCDDA/P1.6 -|8    13|- P1.2/PWM0/IC0
;                         VDD -|9    12|- P1.3/SCL/[STADC]
;            PWM5/IC7/SS/P1.5 -|10   11|- P1.4/SDA/FB/PWM1
;                               -------
;
;  N76E003 pinout:
;                               ----
;                 (FREE) P0.5 -|1    20|- P0.4 (FREE)
;      Serial to COM TXD/P0.6 -|2    19|- P0.3 LCD.3
;      Serial to COM RXD/P0.7 -|3    18|- P0.2 LCD.2
;                    RST P2.0 -|4    17|- P0.1 LCD.1
;            LM335 INPUT P3.0 -|5    16|- P0.0 LCD.0
;       PUSHBUTTONS AIN0/P1.7 -|6    15|- P1.0 (FREE)
;                         GND -|7    14|- P1.1 THERMOCOUPLE INPUT
;         SPEAKER OUTPUT P1.6 -|8    13|- P1.2 OVEN CONTROL PIN
;                         VDD -|9    12|- P1.3 LCD RS
;                 (FREE) P1.5 -|10   11|- P1.4 LCD E
;                               -------
;
## SYMBOLIC CONSTANTS
CLK           EQU 16600000 ; Microcontroller system oscillator frequency in Hz
BAUD          EQU 115200 ; Baud rate of UART in bps

DSEG
; Addresses of custom setting variables
soak_time ds 1
soak_temp ds 1
reflow_time ds 1
reflow_temp ds 1

; INPUTS
tempsensor_in equ p3.0
thermocouple_in equ p1.1

; OUTPUTS
oven_out equ p1.2
speaker_out equ p1.6

CSEG
; LCD
LCD_RS equ P1.3
LCD_E equ P1.4
LCD_D4 equ P0.0
LCD_D5 equ P0.1
LCD_D6 equ P0.2
LCD_D7 equ P0.3

;Initialization Messages
temperature_message:     db 'To=   C  Tj=   C', 0



## INITIALIZATION SUBROUTINES

; INTERRUPTS


; SUBROUTINES
;******************************************************************************
; This is the code from the example file, modified for use in
; the oven controller. 
; (The base of this code is listed in the N76E003 user manual)
;******************************************************************************
PAGE_ERASE_AP   EQU 00100010b
BYTE_PROGRAM_AP EQU 00100001b

Save_Variables:
	CLR EA  ; MUST disable interrupts for this to work!
	
	MOV TA, #0aah ; CHPCON is TA protected
	MOV TA, #55h
	ORL CHPCON, #00000001b ; IAPEN = 1, enable IAP mode
	
	MOV TA, #0aah ; IAPUEN is TA protected
	MOV TA, #55h
	ORL IAPUEN, #00000001b ; APUEN = 1, enable APROM update
	
	MOV IAPCN, #PAGE_ERASE_AP ; Erase page 3f80h~3f7Fh
	MOV IAPAH, #3fh ; Address high byte
	MOV IAPAL, #80h ; Address low byte
	MOV IAPFD, #0FFh ; Data to load into the address byte
	MOV TA, #0aah ; IAPTRG is TA protected
	MOV TA, #55h
	ORL IAPTRG, #00000001b ; write �1� to IAPGO to trigger IAP process
	
	MOV IAPCN, #BYTE_PROGRAM_AP
	MOV IAPAH, #3fh
	
	;Load 3f80h with soak_time
	MOV IAPAL, #80h
	MOV IAPFD, soak_time
	MOV TA, #0aah
	MOV TA, #55h
	ORL IAPTRG,#00000001b ; Basically, this executes the write to flash memory
	
	;Load 3f81h with soak_temp
	MOV IAPAL, #81h
	MOV IAPFD, soak_temp
	MOV TA, #0aah
	MOV TA, #55h
	ORL IAPTRG,#00000001b
	
	;Load 3f82h with reflow_time
	MOV IAPAL, #82h
	MOV IAPFD, reflow_time
	MOV TA, #0aah
	MOV TA, #55h
	ORL IAPTRG,#00000001b
	
	;Load 3f83h with reflow_temp
	MOV IAPAL, #83h
	MOV IAPFD, reflow_temp
	MOV TA, #0aah
	MOV TA, #55h
	ORL IAPTRG,#00000001b

	;Load 3f84h with 55h
	MOV IAPAL,#84h
	MOV IAPFD, #55h
	MOV TA, #0aah
	MOV TA, #55h
	ORL IAPTRG, #00000001b

	;Load 3f85h with aah (spacer value indicating EOF, will load if something funny happens)
	MOV IAPAL, #85h
	MOV IAPFD, #0aah
	MOV TA, #0aah
	MOV TA, #55h
	ORL IAPTRG, #00000001b

	MOV TA, #0aah
	MOV TA, #55h
	ANL IAPUEN, #11111110b ; APUEN = 0, disable APROM update
	MOV TA, #0aah
	MOV TA, #55h
	ANL CHPCON, #11111110b ; IAPEN = 0, disable IAP mode
	
	setb EA  ; Re-enable interrupts

	ret

Load_Variables:
	mov dptr, #0x3f84  ; First key value location.  Must be 0x55
	clr a
	movc a, @a+dptr
	cjne a, #0x55, Load_Defaults ; Load default values if an error occurs 
	inc dptr      ; Second key value location.  Must be 0xaa
	clr a
	movc a, @a+dptr ; 
	cjne a, #0xaa, Load_Defaults ; Load defaults if another error occurs
	
	mov dptr, #0x3f80 ; Start accessing values in flash memory
	clr a
	movc a, @a+dptr
	mov soak_time, a
	
	inc dptr
	clr a
	movc a, @a+dptr
	mov soak_temp, a
	
	inc dptr
	clr a
	movc a, @a+dptr
	mov reflow_time, a
	
	inc dptr
	clr a
	movc a, @a+dptr
	mov reflow_temp, a
	ret

Load_Defaults:
	mov soak_time, #60 ; Whatever we need our default reflow profile values to be
	mov soak_temp, #140
	mov reflow_time, #30
	mov reflow_temp, #230
	ret

Average_ADC
    Load_x(0)
    mov r5, #255
Sum_loop:
    lcall READ_ADC
    mov y+3, #0
    mov y+2, #0
    mov y+1, R1
    mov y+0, R0
    lcall add32
    djnr R5, Sum_loop
    load_y(255)
    lcall div32
ret

## MAIN 
main:

    ; initial messages in LCD
    Set_Cursor(1,1)
    Send_Constant_String(#temperature_message)

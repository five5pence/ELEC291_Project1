$NOLIST
$MODN76E003
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

; INPUTS
tempsensor_in equ p3.0
thermocouple_in equ p1.1

; OUTPUTS
oven_out equ p1.2
speaker_out equ p1.6

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

## MAIN 
main:

    ; initial messages in LCD
    Set_Cursor(1,1)
    Send_Constant_String(#temperature_message)

#define __SFR_OFFSET 0x00
#include "avr/io.h"
#include <avr/interrupt.h>
;------------------------
.global main


;========================================================================
.org 0x0000             ; Reset Interrupt Handler
    rjmp main_loop
;========================================================================


;========================================================================
main:
;------------------------------------------------------------------
; Uses R16 temporarily
; Setup for main program
;------------------------------------------------------------------
    RCALL init_serial       ; Initialize Serial Communication
    LDI   R16, 0xff
    OUT   DDRB, R16         ; Set all pin B for output
    CBI   DDRD, 7           ; Set pin pD7 Input for Shoot
;========================================================================




;========================================================================
main_loop:
;------------------------------------------------------------------
; Getting all data needed to start the game
;------------------------------------------------------------------
    RCALL print_intro       ; Print game is about to start in 5 Second

    RCALL delay_sec         ; 5 second delay
    RCALL delay_sec
    RCALL delay_sec
    RCALL delay_sec
    RCALL delay_sec

    RCALL init_ADC0         ; Setting up analog input for PC0
    RCALL read_ADC          ; Read input for PC0
    RCALL get_counter       ; Get Counter value from analog read
;========================================================================





;========================================================================
rounds:
;------------------------------------------------------------------
; Uses R16 and R25 temporarily
; Each round, a player will try to shoot
;------------------------------------------------------------------
    LDI   R16, 0b00010000         
    OUT   PORTB, R16            ; Turn on Yellow LED to indicate a bullet is ready to be fired
    RCALL shoot                 ; Wait for the player to shoot
    CPI   R25, 0                ; Check if a bullet iss fired
    BRNE  no_bullet
;========================================================================





;========================================================================
bullet:
;------------------------------------------------------------------
; Uses R16 temporarily
; If a bullet is fired, the player will lose
;------------------------------------------------------------------
    RCALL delay_sec
    RCALL print_death           ; Announce the player is dead

    LDI   R16, 0b00100000
    OUT   PORTB, R16            ; Turn on Red LED to indicate a bullet is fired

    RCALL delay_sec             ; 3 Second delay before game ends
    RCALL delay_sec
    RCALL delay_sec

    RJMP  main_loop
;========================================================================





;========================================================================
no_bullet:
;------------------------------------------------------------------
; Uses R16 temporarily
; If a bullet is not fired, the player will survive
;------------------------------------------------------------------
    RCALL delay_sec             
    RCALL print_alive           ; Announce the player is dead

    LDI   R16, 0b00001000   
    OUT   PORTB, R16            ; Turn on Green LED to indicate a bullet is not fired

    RCALL init_ADC1             ; Setting up for analog input in PC1
;========================================================================





;========================================================================
next_round:
;------------------------------------------------------------------
; Uses R19 temporarily
; Enter next round if photoresistor is pressed
;------------------------------------------------------------------
    RCALL read_ADC              ; Read analog input in PC1
    CPI   R19, 3                ; Check if the photoresistor is dark
    BREQ  rounds                ; If the photoresistor is dark, then enter next round
    RJMP  next_round            ; If not, hold in this round
;========================================================================





;========================================================================
init_ADC0:
;------------------------------------------------------------------
; Uses R20 temporarily
; Input in pin PC0
;------------------------------------------------------------------
    SBI   DDRC, 0     ;set pin PC0 as i/p for ADC0
    ;--------------------------------------------------------------
    LDI   R20, 0x40   ;internal 2.56V, right-justified data, ADC0
    STS   ADMUX, R20
    LDI   R20, 0x87   ;enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R20
    RET
;========================================================================





;========================================================================
init_ADC1:
;------------------------------------------------------------------
; Uses R20 temporarily
; Input in pin PC1
;------------------------------------------------------------------
    SBI   DDRC, 1     ;set pin PC1 as i/p for ADC1
    ;--------------------------------------------------------------
    LDI   R20, 0x41   ;internal 2.56V, right-justified data, ADC1
    STS   ADMUX, R20
    LDI   R20, 0x87   ;enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R20
    RET
;========================================================================





;========================================================================
read_ADC:
;------------------------------------------------------------------
; Uses R17, R20, R21 temporarily
; R18 is Output low
; R19 is Output high
;------------------------------------------------------------------
    LDI   R20, 0xC7   ;set ADSC in ADCSRA to start conversion
    STS   ADCSRA, R20
    ;--------------------------------------------------------------
wait_ADC:
    LDS   R21, ADCSRA ;check ADIF flag in ADCSRA
    SBRS  R21, 4      ;skip jump when conversion is done (flag set)
    RJMP  wait_ADC    ;loop until ADIF flag is set
    ;--------------------------------------------------------------
    LDI   R17, 0xD7   ;set ADIF flag again
    STS   ADCSRA, R17 ;so that controller clears ADIF
    ;--------------------------------------------------------------
    LDS   R18, ADCL   ;get low-byte result from ADCL
    LDS   R19, ADCH   ;get high-byte result from ADCH
    RET
;========================================================================





;========================================================================
init_serial:
;------------------------------------------------------------------
; Uses R24 temporarily
;------------------------------------------------------------------
    CLR   R24
    STS   UCSR0A, R24                 ;clear UCSR0A register
    STS   UBRR0H, R24                 ;clear UBRR0H register
    LDI   R24, 51                     ;& store in UBRR0L 51 value
    STS   UBRR0L, R24                 ;to set baud rate 19200
    LDI   R24, 1<<RXEN0 | 1<<TXEN0    ;enable RXB & TXB
    STS   UCSR0B, R24
    LDI   R24, 1<<UCSZ00 | 1<<UCSZ01  ;asynch, no parity, 1 stop, 8 bits
    STS   UCSR0C, R24
    RET
;========================================================================





;========================================================================
print_serial:
;------------------------------------------------------------------
; Uses R16, R23, R27, R28 temporarily
; This is used for debugging purposes only
;------------------------------------------------------------------
    MOV   R23, R19
    MOV   R16, R19
    RCALL ASCII_LSD
    RCALL LCD_buffer
    STS   UDR0, R16     ;print digit1 of 10-bit result
    ;----------------------------------------------------------------
    MOV   R16, R18
    RCALL ASCII_MSD
    RCALL LCD_buffer
    STS   UDR0, R16     ;print digit2 of 10-bit result
    ;----------------------------------------------------------------
    MOV   R16, R18
    RCALL ASCII_LSD
    RCALL LCD_buffer
    STS   UDR0, R16     ;print digit3 of 8-bit result
    ;----------------------------------------------------------------
    LDI   R16, 0x0A
    RCALL LCD_buffer
    STS   UDR0, R16     ;Enter in Serial
    ;--------------------------------------------------------------------   
    LDI   R16, 0x0D
    RCALL LCD_buffer
    STS   UDR0, R16     ;Finish Statement
    ;--------------------------------------------------------------------   
    RET                 ;return to loop()
;====================================================================
LCD_buffer:
    LDS   R27, UCSR0A
    SBRS  R27, UDRE0    ;test data buffer if data can be sent
    RJMP  LCD_buffer
    RET
;====================================================================
ASCII_MSD:
    MOV   R23, R16      ;save copy of result
    ANDI  R16, 0xF0     ;extract & swap high-nibble
    SWAP  R16 
    SUBI  R16, -48      ;R16 = R16 - (48) = R16 + 48
    MOV   R28, R16      ;save a copy of high-byte result
    SUBI  R28, 58       ;if +ve       
    BRPL  A_F_D1        ;branch & add 7 to get ASCII A to F
adc_loop1: RET
;====================================================================
ASCII_LSD:
    MOV   R16, R23      ;restore copy of result
    ANDI  R16, 0x0F     ;extract low-nibble
    SUBI  R16, -48      ;R16 = R16 - (48) = R16 + 48
    MOV   R28, R16      ;save a copy of high-byte result
    SUBI  R28, 58       ;if +ve
    BRPL  A_F_D0        ;branch & add 7 to get ASCII A to F
adc_loop2: RET    
;====================================================================
A_F_D1:
    SUBI  R16, -7       ;R16 = R16 - (7) = R16 + 7
    RJMP  adc_loop1
;---------------------------------------------------------------
A_F_D0:
    SUBI  R16, -7       ;R16 = R16 - (7) = R16 + 7
    RJMP  adc_loop2
;========================================================================




;========================================================================
delay_sec:                
;------------------------------------------------------------------
; Gives 1 second delay
;------------------------------------------------------------------
    RCALL delay_timer1
    RCALL delay_timer1
    RET
;========================================================================





;========================================================================
delay_timer1:             
;------------------------------------------------------------------
; Uses R20 temporarily
; Create 0.5 sec delay
;------------------------------------------------------------------
.EQU value, 57724         ;value to give 0.5 sec delay
    LDI   R20, hi8(value)
    STS   TCNT1H, R20
    LDI   R20, lo8(value)
    STS   TCNT1L, R20     ;initialize counter TCNT1 = value
    ;-------------------------------------------------------
    LDI   R20, 0b00000000
    STS   TCCR1A, R20
    LDI   R20, 0b00000101
    STS   TCCR1B, R20     ;normal mode, prescaler = 1024
    ;-------------------------------------------------------
timer_loop: 
    IN    R20, TIFR1      ;get TIFR1 byte & check
    SBRS  R20, TOV1       ;if TOV1=1, skip next instruction
    RJMP  timer_loop      ;else, loop back & check TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 1<<TOV1
    OUT   TIFR1, R20      ;clear TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 0b00000000
    STS   TCCR1B, R20     ;stop timer0
    RET
;========================================================================





;========================================================================
get_counter:
;------------------------------------------------------------------
; Uses result from R19 to get counter
; Counter is saved in R25
;------------------------------------------------------------------
    LDI   R25, 1
counter_loop:
    SUBI  R19, 1
    BRLO  done_counter
    INC   R25
    RJMP  counter_loop
done_counter: RET
;========================================================================





;========================================================================
shoot:
;------------------------------------------------------------------
; Hold until button in pin PD7 is clicked
; Once clicked, decrement Counter (R25)
;------------------------------------------------------------------
    SBIS  PIND, 7
    RJMP  shoot
    DEC   R25
    RET
;========================================================================




;========================================================================
print_alive:
;------------------------------------------------------------------
; Uses R17, R18, R30, R31 temporarily
; Announce the player survived the round
;------------------------------------------------------------------
    LDI   R30, lo8(msg_alive)
    LDI   R31, hi8(msg_alive)               ;Z points to string message
alive_agn:
    LPM   R18, Z+                           ;load char of string onto R18
    CPI   R18, 0                            ;check if R18=0 (end of string)
    BREQ  alive_exit                        ;if yes, exit
    ;--------------------------------------------------------------------
alive_loop:
    LDS   R17, UCSR0A
    SBRS  R17, UDRE0                        ;test data buffer if data can be sent
    RJMP  alive_loop
    STS   UDR0, R18                         ;send char in R18 to serial monitor
    ;--------------------------------------------------------------------
    RJMP  alive_agn                         ;loop back & get next character
    ;--------------------------------------------------------------------
alive_exit:
    RET
;------------------------------------------------------------------------
msg_alive:
    .ascii "Alive"
    .byte 10,13,0
;========================================================================




;========================================================================
print_death:
;------------------------------------------------------------------
; Uses R17, R18, R30, R31 temporarily
; Announce the player did not survive the round
;------------------------------------------------------------------
    LDI   R30, lo8(msg_death)
    LDI   R31, hi8(msg_death)               ;Z points to string message
death_agn:
    LPM   R18, Z+                           ;load char of string onto R18
    CPI   R18, 0                            ;check if R18=0 (end of string)
    BREQ  death_exit                        ;if yes, exit
    ;--------------------------------------------------------------------
death_loop:
    LDS   R17, UCSR0A
    SBRS  R17, UDRE0                        ;test data buffer if data can be sent
    RJMP  death_loop
    STS   UDR0, R18                         ;send char in R18 to serial monitor
    ;--------------------------------------------------------------------
    RJMP  death_agn                         ;loop back & get next character
    ;--------------------------------------------------------------------
death_exit:
    RET
;------------------------------------------------------------------------
msg_death:
    .ascii "Death" 
    .byte 10,13,0
;========================================================================





;========================================================================
print_intro:
;------------------------------------------------------------------
; Uses R17, R18, R30, R31 temporarily
; Announce the game is about to start
;------------------------------------------------------------------
    LDI   R30, lo8(msg_intro)
    LDI   R31, hi8(msg_intro)               ;Z points to string message
intro_agn:
    LPM   R18, Z+                           ;load char of string onto R18
    CPI   R18, 0                            ;check if R18=0 (end of string)
    BREQ  intro_exit                        ;if yes, exit
    ;--------------------------------------------------------------------
intro_loop:
    LDS   R17, UCSR0A
    SBRS  R17, UDRE0                        ;test data buffer if data can be sent
    RJMP  intro_loop
    STS   UDR0, R18                         ;send char in R18 to serial monitor
    ;--------------------------------------------------------------------
    RJMP  intro_agn                         ;loop back & get next character
    ;--------------------------------------------------------------------
intro_exit:
    RET
;------------------------------------------------------------------------
msg_intro:
    .ascii "Game starts in 5sec..."
    .byte 10,13,0
;========================================================================
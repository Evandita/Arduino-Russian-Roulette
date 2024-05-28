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
;-----------------------------
; Title: Thermostat
;-----------------------------
; Purpose: The program determines the temperature through a sensor and adjust temperature by user input 
; Dependencies: Are you using any header files - if no say NONE
; Compiler: pic-as V3.0, IDE 6.20
; Author: Andres Briseno Camacho 
; OUTPUTS: PORTD.2-cool, PORTD.1-Heat 
; INPUTS: PortD3-Keypad, PortD4-Temperature sensor  
; Versions:
;  	V1.0: March 11, 2025 - First version 
;-----------------------------

; Initialization - make sure the path is correct
;---------------------
#include ".\ConfigFile.inc"
#include "C:\Users\e_nan\OneDrive\EE310 Labs\MPLABs\Thermostat.X\ConfigFile.inc"

#include <xc.inc>

;----------------
; PROGRAM INPUTS
;----------------
;The DEFINE directive is used to create macros or symbolic names for values.
;It is more flexible and can be used to define complex expressions or sequences of instructions.
;It is processed by the preprocessor before the assembly begins.

measuredTempInput   equ	45 ; this is the input value
refTempInput	    equ	25 ; this is the input value

;---------------------
; Definitions
;---------------------
#define SWITCH    LATD,2  
#define LED0      PORTD,0
#define LED1	  PORTD,1
    
 
;---------------------
; Program Constants
;---------------------
; The EQU (Equals) directive is used to assign a constant value to a symbolic name or label.
; It is simpler and is typically used for straightforward assignments.
;It directly substitutes the defined value into the code during the assembly process.
    
REG10   equ     10h     ; 10 in HEX
REG11   equ     11h	; 11 in HEX
REG01   equ     1h	; 01 in HEX

; Define Registers
refTemp      equ    0x20  ; Reference temperature register
measuredTemp equ    0x21  ; Measured temperature register
contReg      equ    0x22  ; Control register for heating/cooling status
NUME	     equ    0x30    ; Temporary value storage
QU	     equ    0x31    ; Tens counter
;---------------------
; Main Program
;---------------------  
      PSECT absdata,abs,ovrld
      
    ORG     0x20         ; Start program at memory address 0x20
    GOTO    _START

_START:
    CLRF    PORTD, 0     ; Clear PORTD (turn off all LEDs)

    ; Set TRISD to Output Mode
    MOVLW   0x00
    MOVWF   TRISD, 0

    ; Store Predefined Values in Registers
    MOVLW   15         
    MOVWF   refTemp, 0    
    MOVLW   -5         
    MOVWF   measuredTemp, 0 

    ; Convert to Decimal and Store in Registers
    CALL    CHECK_NEGATIVE
    CALL    CONVERT_REF_TEMP
    CALL    CONVERT_MEASURED_TEMP

MAIN_LOOP:
    ; IF (measuredTemp > refTemp) ? COOLING ON
    MOVF    refTemp, 0,1
    CPFSGT  measuredTemp, 0
    GOTO    CHECK_EQUAL
    MOVLW   0x2
    MOVWF   contReg, 0
    BSF     PORTD, 2, 0
    BCF     PORTD, 1, 0
    GOTO    MAIN_LOOP

CHECK_EQUAL:
    CPFSEQ  measuredTemp, 0
    GOTO    HEATING_ON

    ; IF EQUAL ? TURN OFF BOTH
    CLRF    contReg, 0
    BCF     PORTD, 2, 0
    BCF     PORTD, 1, 0
    GOTO    MAIN_LOOP

HEATING_ON:
    MOVLW   0x1
    MOVWF   contReg, 0
    BSF     PORTD, 1, 0
    BCF     PORTD, 2, 0
    GOTO    MAIN_LOOP
    
; ---------------------
; Check if Measured Temperature is Negative
; ---------------------
CHECK_NEGATIVE:
    MOVF    measuredTemp, 0, 0  ;Move measuredTemp to WREG
    BNN     _RETURN             ;Branch if Not Negative (N = 0), exit
    COMF    measuredTemp, 1, 0  ;If Negative, take Two?s Complement
    INCF    measuredTemp, 1, 0
_RETURN:
    RETURN

; --------------------------
; Convert `refTemp` to Decimal Using Book?s Method (Stored in 0x60, 0x61, 0x62)
; --------------------------
CONVERT_REF_TEMP:
    MOVF    refTemp, 0, 0   
    MOVWF   NUME, 1        
    MOVLW   10
    CLRF    QU, 1          

D1:
    INCF    QU, 1, 0
    SUBWF   NUME, 1, 0
    BC      D1	;branch if carry is set

    ADDWF   NUME, 1, 0
    DECF    QU, 1, 0
    MOVFF   NUME, 0x60 ; store ones digits
    MOVFF   QU, NUME
    CLRF    QU, 1

D2:
    INCF    QU, 1, 0
    SUBWF   NUME, 1, 0
    BC      D2	;branch if carry is set

    ADDWF   NUME, 1, 0
    DECF    QU, 1, 0
    MOVFF   NUME, 0x61 ;store tens digits
    MOVFF   QU, 0x62	;store hundreds digit

    RETURN

; --------------------------
; Convert `measuredTemp` to Decimal Using Book?s Method (Stored in 0x70, 0x71, 0x72)
; --------------------------
CONVERT_MEASURED_TEMP:
    MOVF    measuredTemp, 0, 0   
    MOVWF   NUME, 1        
    MOVLW   10
    CLRF    QU, 1

D3:
    INCF    QU, 1, 0
    SUBWF   NUME, 1, 0
    BC      D3	;branc if carry is set

    ADDWF   NUME, 1, 0
    DECF    QU, 1, 0
    MOVFF   NUME, 0x70 ; store ones digit
    MOVFF   QU, NUME
    CLRF    QU, 1

D4:
    INCF    QU, 1, 0
    SUBWF   NUME, 1, 0
    BC      D4	;branch if carry is set

    ADDWF   NUME, 1, 0
    DECF    QU, 1, 0
    MOVFF   NUME, 0x71 ; store tens digit
    MOVFF   QU, 0x72	; store hudreds digit

    RETURN

END_PROGRAM:
    BRA     END_PROGRAM
    END
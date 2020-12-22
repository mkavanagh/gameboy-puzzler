; PURPOSE: Contains macros for working with the LCD
; LABELS: (as below)

INCLUDE "hardware.inc"


IF !DEF(LCD_INC)
LCD_INC SET 1


; PURPOSE: Wait for the LCD to enter VBlank
; IN: None
; DESTROYS: af
; CYCLES: minimum 8
; BYTES: 7
WaitVBlank: MACRO
.loop\@: ; loop: wait for VBlank
    ld a, [rSTAT]
    and STATF_VBL
    jr nz, .loop\@
; end loop
ENDM
; end WaitVBlank


ENDC
; end LCD_INC

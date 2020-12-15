; PURPOSE: Contains macros for working with the LCD
; LABELS: (as below)

INCLUDE "hardware.inc"


; PURPOSE: Wait for the LCD to enter VBlank
; IN: None
; OUT:
;  - a: bit 1 set (as per VBlank flag from rSTAT), all other bits unset
;  - flags: Z0 N0 H1 C0
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

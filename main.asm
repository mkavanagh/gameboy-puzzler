INCLUDE "hardware.inc"


; PURPOSE: Contains cartridge metadata and execution entrypoint
; LABELS: None
;
; Execution starts at $100, while $104 to $14F contains required header data in
; a fixed format. As a consequence, meaningful program initialisation cannot be
; done here - we have just enough instructions to jump to a "real" entrypoint
; for the program.
SECTION "Header", ROM0[$0100]
    nop
    jp start

    ; Pad the header with zeros - the real data is written by the toolchain
    ds $0150 - @


; PURPOSE: Program initialisation and main loop
; LABELS:
;  - start: program entrypoint
;
; We initialise the program by loading required data into VRAM, configuring
; system parameters (screen, sound etc.) and then entering the main loop.
SECTION "Main", ROM0
start:

; step: prepare VRAM for initialisation

.waitVBlank: ; loop: wait for LCD to enter VBlank
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank
; end loop

    xor a ; (ld a, 0)
    ld [rLCDC], a ; turn off the LCD so we can access VRAM

; step: load font tile data into VRAM

    ld hl, fontTiles ; source address
    ld de, _VRAM9000 ; destination address
    ld bc, fontTilesEnd - fontTiles ; number of bytes to be copied
    call CopyBytes

; step: fill the tile map with our desired characters
; TODO blank out tiles and tile map first

    ld hl, helloStr ; source address
    ld de, _SCRN0 ; destination address
    call WriteStr

; step: finish initialisation

    ld a, %11100100
    ld [rBGP], a ; set colour palette

    xor a ; (ld a, 0)

    ld [rSCY], a
    ld [rSCX], a ; set scroll to (0, 0)

    ld [rNR52], a ; turn off sound

    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a ; turn screen on, display background

; step: main loop

.loop: ; loop: spin indefinitely
    jr .loop
; end loop


SECTION "Font", ROM0
; PURPOSE: Contains font tile data
; LABELS:
;  - FontTiles: start of font tile data
;  - FontTilesEnd: end of font tile data
;
; Contains 128 tiles corresponding to ASCII characters.

fontTiles:
INCBIN "font.chr"
fontTilesEnd:


SECTION "Messages", ROM0
; PURPOSE: Contains strings for displayable messages
; LABELS: (as below)

helloStr:
    db "Hello World!", 0

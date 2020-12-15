INCLUDE "hardware.inc"

INCLUDE "lcd.inc"


; PURPOSE: Contains cartridge metadata and execution entrypoint
; LABELS: None
;
; Execution starts at $100, while $104 to $14F contains required header data in
; a fixed format. As a consequence, meaningful program initialisation cannot be
; done here - we have just enough instructions to jump to a "real" entrypoint
; for the program.
SECTION "Header", ROM0[$0100]
    nop
    jp Start

    ; Pad the header with zeros - the real data is written by the toolchain
    ds $0150 - @


; PURPOSE: Program initialisation and main loop
; LABELS:
;  - Start: program entrypoint
;
; We initialise the program by loading required data into VRAM, configuring
; system parameters (screen, sound etc.) and then entering the main loop.
SECTION "Main", ROM0

Start::

; step: prepare VRAM for initialisation

    WaitVBlank

    xor a ; (ld a, 0)
    ld [rLCDC], a ; turn off the LCD so we can access VRAM at our leisure

; step: load font tile data into VRAM

    ld hl, FontTiles ; source address
    ld de, _VRAM9000 ; destination address (tile data block 2)
    ld bc, FontTilesEnd - FontTiles ; number of bytes to be copied
    call CopyBytes

; step: fill the tile map with our desired characters
; TODO blank out tiles and tile map first

    ld hl, HelloStr ; source address
    ld de, _SCRN0 ; destination address (tile map 0)
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
    halt
    nop
    jr .loop
; end loop

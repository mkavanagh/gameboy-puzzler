INCLUDE "hardware.inc"


SECTION "Header", ROM0[$0100]
; PURPOSE: Contains cartridge metadata and execution entrypoint
; LABELS: None
;
; Execution starts at $100, while $104 to $14F contains required header data in
; a fixed format. As a consequence, meaningful program initialisation cannot be
; done here - we have just enough instructions to jump to a "real" entrypoint
; for the program.

    nop
    jp Start

    ; Pad the header with zeros - the real data is written by the toolchain
    ds $0150 - @


SECTION "Main", ROM0
; PURPOSE: Program initialisation and main loop
; LABELS:
;  - Start: program entrypoint
;
; We initialise the program by loading required data into VRAM, configuring
; system parameters (screen, sound etc.) and then entering the main loop.

Start:

; step: prepare VRAM for initialisation

.waitVBlank: ; loop: wait for LCD to enter VBlank
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank
; end loop

    xor a ; (ld a, 0)
    ld [rLCDC], a ; turn off the LCD so we can access VRAM

; step: load font tile data into VRAM

    ld de, _VRAM9000 ; copy font tile data here
    ld hl, FontTiles ; copy from here
    ld bc, FontTilesEnd - FontTiles ; number of bytes remaining

.loadFontTiles: ; loop: load each byte of tile data
    ; load this byte
    ld a, [hl+]
    ld [de], a

    inc de ; move to next position
    dec bc ; decrease bytes remaining

    ; check if bytes remain
    ld a, b
    or c

    jr nz, .loadFontTiles
; end loop

; step: fill the tile map with our desired tiles

    ld de, _SCRN0 ; write tiles here
    ld hl, HelloStr ; read tiles from here

.copyStrTiles: ; loop: copy each tile into tile map
    ld a, [hl+]
    ld [de], a ; copy this tile

    inc de ; move to next position

    and a ; check if string is terminated

    jr nz, .copyStrTiles
; end loop

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

FontTiles:
INCBIN "font.chr"
FontTilesEnd:


SECTION "Messages", ROM0
; PURPOSE: Contains character data for displayable messages
; LABELS: (as below)
;
; Character data is kept separately from code sections for clarity and reuse.

HelloStr:
    db "Hello World!", 0

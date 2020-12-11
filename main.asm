INCLUDE "hardware.inc"


SECTION "Header", ROM0[$100] ; Execution starts at $100

; We only have 4 bytes of code before the header proper - just enough to jump away
EntryPoint:
    di ; disable interrupts for simplicity
    jp Start

; Header is from $104 to $14F - just zero it out, the correct values will be set by the toolchain
REPT $150 - $104
    db 0
ENDR


SECTION "Main", ROM0

; We'll jump in here from the header
Start:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; prepare VRAM for initialisation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; wait for LCD to enter VBlank
.waitVBlank
    ld a, [rLY]
    cp SCRN_Y
    jr c, .waitVBlank

; turn off the LCD so we can access VRAM
    xor a ; (ld a, 0)
    ld [rLCDC], a

    ld hl, _VRAM9000 ; copy font tiles in here
    ld de, FontTiles ; copy from here
    ld bc, FontTilesEnd - FontTiles ; this many bytes remain

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in font tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.loadFontTiles
    ; load this byte
    ld a, [de]
    ld [hli], a

    inc de ; move to next byte
    dec bc ; decrease bytes remaining

    ; check if bytes remain
    ld a, b
    or c

    ; copy next byte
    jr nz, .loadFontTiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fill the tile map with our desired tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ld hl, _SCRN0 ; start writing tiles here
    ld de, HelloStr ; start reading tiles from here

.copyStrTiles
    ; copy this tile
    ld a, [de]
    ld [hli], a

    inc de ; move to next tile
    and a ; check if string is terminated

    ; copy next tile
    jr nz, .copyStrTiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; finish initialisation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; set colour palette
    ld a, %11100100
    ld [rBGP], a

    xor a ; (ld a, 0)

    ; set scroll to (0,0)
    ld [rSCY], a
    ld [rSCX], a

    ; turn off sound
    ld [rNR52], a

    ; turn screen on
    ; ld a, %10000001
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.loop
    jr .loop


SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:


Section "Messages", rom0

HelloStr:
    db "Hello World!", 0

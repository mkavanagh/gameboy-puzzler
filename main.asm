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
    di
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
; step: zero out RAM

    ld hl, $C000
    ld bc, $D000 - $C000
    call ZeroMem ; zero out WRAM0

    ; move stack from HRAM to WRAM0 (stack operations can access WRAM0 just as
    ; fast as HRAM, but _we_ can access HRAM faster than WRAM0 - so it makes no
    ; sense to keep the stack in HRAM)
    ld sp, $CFFF

    ld hl, $D000
    ld bc, $E000 - $D000
    call ZeroMem ; zero out WRAM1

    ld hl, $FF80
    ld bc, $FFFF - $FF80
    call ZeroMem ; zero out HRAM

; step: prepare VRAM for initialisation

    WaitVBlank

    xor a ; (ld a, 0)
    ld [rLCDC], a ; turn off the LCD so we can access VRAM at our leisure

    ld hl, $8000
    ld bc, $A000 - $8000
    call ZeroMem ; zero out VRAM

    ld hl, $FE00
    ld bc, $FEA0 - $FE00
    call ZeroMem ; zero out OAM

; step: load font tile data into VRAM

    ld hl, FontTiles ; source address
    ld de, _VRAM9000 ; destination address (tile data block 2)
    ld bc, FontTilesEnd - FontTiles ; number of bytes to be copied
    call CopyBytes

; step: finish initialisation

    ld a, %11100100
    ld [rBGP], a ; set colour palette

    xor a ; (ld a, 0)

    ld [rSCY], a
    ld [rSCX], a ; set scroll to (0, 0)

    ld [rNR52], a ; turn off sound

    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a ; turn screen on, display background

; step: enable interrupts

    ld a, IEF_VBLANK
    ldh [rIE], a ; enable VBlank interrupt

    xor a ; (ld a, 0)
    ld [rIF], a ; clear pending interrupts before reenabling
    ei

; step: idle loop

.mainLoop: ; loop: spin indefinitely
    halt
    nop
    jr .mainLoop
; end loop

VBlank::
; step: fill the tile map with our desired characters

    push af
    push bc
    push de
    push hl

    ld hl, HelloStr ; source address
    ld de, _SCRN0 ; destination address (tile map 0)
    call WriteStr_GetLen

    ld a, c ; width of text in tiles (assuming < 255)
    rla
    rla
    rla ; multiply by 8 to get width in pixels
    ld h, a

    ld a, 1 ; height of text in tiles (WriteStr_* can only write a single line)
    rla
    rla
    rla ; multiply by 8 to get height in pixels
    ld l, a

; move either right or left, bouncing off the edge
    ld a, [DirX]
    or a
    jr nz, .moveLeft

; scroll horizontally right 1px per frame
    ld a, [rSCX]
    dec a
    ld [rSCX], a

 ; detect right-edge collision
    xor $FF ; (xpos = 256 - scrollx)
    add h ; add text width in pixels
    cp SCRN_X
    jr nz, .moveVertical

.changeLeft: ; change direction to left
    ld a, 1
    ld [DirX], a
    jr .moveVertical

.moveLeft: ; scroll horizontally left 1px per frame
    ld a, [rSCX]
    inc a
    ld [rSCX], a

 ; detect left-edge collision
    or a
    jr nz, .moveVertical

 ; change direction to right
    xor a ; (ld a, 0)
    ld [DirX], a

.moveVertical: ; move either up or down, bouncing off the edge
    ld a, [DirY]
    or a
    jr nz, .moveUp

; scroll vertically down 1px per frame
    ld a, [rSCY]
    dec a
    ld [rSCY], a

 ; detect bottom-edge collision
    xor $FF ; (ypos = 256 - scrolly)
    add l ; add text height in pixels
    cp SCRN_Y
    jr nz, .exit

; change direction to up
    ld a, 1
    ld [DirY], a
    jr .moveVertical

.moveUp: ; scroll vertically up 1px per frame
    ld a, [rSCY]
    inc a
    ld [rSCY], a

; detect top-edge collision
    or a
    jr nz, .exit

; change direction to down
    xor a ; (ld a, 0)
    ld [DirY], a

.exit:
    pop hl
    pop de
    pop bc
    pop af

    reti


SECTION "Globals", HRAM

DirX::
    db
DirY::
    db

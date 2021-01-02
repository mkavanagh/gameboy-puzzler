INCLUDE "hardware.inc"

INCLUDE "lcd.inc"


; PURPOSE: Contains cartridge metadata and execution entrypoint
;
; LABELS: None
;
; Execution starts at $100, while $104 to $14F contains required header data in
; a fixed format. As a consequence, meaningful program initialisation cannot be
; done here - we have just enough instructions to jump to a "real" entrypoint
; for the program.
SECTION "Header", ROM0[$0100]
    di ; disable interrupts until we're ready to handle them
    jp start

    ; Cartridge header data - beginning with required logo
    NINTENDO_LOGO

    db "Word Puzzle", 0, 0, 0, 0, 0 ;  $0134 - $0143: game title
    db 0, 0 ; $0144 - $0145: licensee (0: no licensee)
    db 0 ; $0146: SGB flag (0: no SGB support)
    db $01 ; $0147: cartridge type (01h: MBC1)
    db 0 ; $0148: ROM size (to be set during build)
    db 0 ; $0149: external RAM size (0: none)
    db 0 ; $014A: region code (0: Japan)
    db 0 ; $014B: licensee code (old. 0: none)
    db 0 ; $014C: ROM version number
    db 0 ; $014D: header checksum (to be set during build)
    db 0, 0 ; $014E - $014F: global checksum (to be set during build)

    ASSERT @ == $0150, "Header must end at $0150"


; PURPOSE: Program initialisation and main loop
;
; LABELS:
;  - start: program entrypoint
;  - vBlank: vBlank handler
;
; We initialise the program by loading required data into VRAM and configuring
; system parameters (screen, sound etc.). We then enter an idle loop, with
; frame rendering performed by the vertical blank interrupt handler.
SECTION "Main", ROM0

start::
; step: zero out RAM

    xor a ; (ld a, 0)

    ld hl, $C000
    ld bc, $D000 - $C000
    call SetMem ; zero out WRAM0

    ; move stack from HRAM to WRAM0 (stack operations can access WRAM0 just as
    ; fast as HRAM, but _we_ can access HRAM faster than WRAM0 - so it makes no
    ; sense to keep the stack in HRAM)
    ld sp, $CFFF

    ld hl, $D000
    ld bc, $E000 - $D000
    call SetMem ; zero out WRAM1

    ld hl, $FF80
    ld bc, $FFFF - $FF80
    call SetMem ; zero out HRAM

; step: prepare VRAM for initialisation

    WaitVBlank

    xor a ; (ld a, 0)

    ld [rLCDC], a ; turn off the LCD so we can access VRAM at our leisure

    ld hl, $8000
    ld bc, $A000 - $8000
    call SetMem ; zero out VRAM

    ld hl, $FE00
    ld bc, $FEA0 - $FE00
    call SetMem ; zero out OAM

; step: load font tile data into VRAM

    ld hl, fontTiles ; source address
    ld de, _VRAM9000 ; destination address (tile data block 2)
    ld bc, fontTilesEnd - fontTiles ; number of bytes to be copied
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

; step: find words

    ld hl, words
    ld de, graph
    call SolvePuzzle

; step: idle loop

.mainLoop: ; loop: spin indefinitely
    halt
    nop
    jr .mainLoop
; end loop

vBlank::
; step: fill the tile map with our desired characters

    push af
    push bc
    push de
    push hl

    ld hl, matchCount ; source address
    ld de, _SCRN0 + 12 ; destination address (tile map 0, right -8)
REPT 4
    ld a, [hl+]
    ld b, a

    and $F0
    swap a
    add $30
    ld [de], a
    inc de
    ld a, b

    and $0F
    add $30
    ld [de], a
    inc de
ENDR

    ld hl, helloStr ; source address
    ld de, _SCRN0 + 64 ; destination address (tile map 0, third line)
    call WriteStr

    pop hl
    pop de
    pop bc
    pop af

    reti


SECTION "Globals", HRAM

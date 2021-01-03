SECTION "Puzzle", ROM0


; PURPOSE: Solve a Word Puzzle by matching input against a finite state machine
;
; IN:
;  - hl: start address of input (8-bit aligned)
;  - de: start address of finite state machine (8-bit aligned)
;
; OUT:
;  - [matchCount]: number of matches found (BCD, 4-byte big-endian)
;
; DESTROYS: af, bc, de, hl
SolvePuzzle::
    ld c, 0 ; record start position of first input

    jr .findNextState

.moveNextState:
    ld a, [de]
    ld e, a

.findNextState:
    ld a, [hl+] ; get next input symbol

    and a ; if symbol is nul, the full input was matched
    jr z, .acceptMatch

    ld b, a

.checkNextTransition:
    ld a, [de] ; get symbol for this transition

    and a ; if symbol is nul, the input did not match any transition
    jr z, .discardInput

    inc e ; otherwise, advance to state pointer

    cp b ; if symbol matches, follow the state pointer
    jr z, .moveNextState

    inc e ; otherwise, advance to next transition
    jr .checkNextTransition

.discardInput:
    ld a, [hl+] ; get next input symbol

    and a ; if symbol is nul, we have reached the end of this input
    jr nz, .discardInput

    jr .afterInput

.acceptMatch:
    push de ; save state machine location

    di ; disable interrupts so we can update multi-byte values atomically

    ld l, c ; go back to start position
    ld de, matchList
    call WriteStr ; write match

    xor a ; (ld a, 0)
    ld [de], a ; write nul-terminator

    pop de ; restore state machine location

    ; increment match count
    ld c, LOW(matchCountEnd - 1)

REPT 4 ; increment each two-digit BCD byte
    ldh a, [c]
    inc a
    daa
    ldh [c], a
    jr nc, .afterMatch
    ccf
    dec c
ENDR

.afterMatch:
    ei ; reenable interrupts

.afterInput:
    ld e, 0 ; reset state machine

    ld c, l ; record start position of next input
    ld a, [hl] ; get first symbol of next input

    and a ; if symbol is nul, no further inputs are available
    jr nz, .findNextState

    ret
; end SolvePuzzle


SECTION "PuzzleGlobals", HRAM

; number of matches found (BCD, big-endian)
matchCount::
    ds 4
matchCountEnd::


SECTION "PuzzleResults", WRAM0, ALIGN[8, 0]

matchList::
    ds 256

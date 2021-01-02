SECTION "Puzzle", ROM0


; PURPOSE: Solve a Word Puzzle by matching input against a finite state machine
;
; IN:
;  - hl: start address of input
;  - de: start address of finite state machine
;
; OUT:
;  - [matchCount]: the number of matches found
;
; DESTROYS: af, b
SolvePuzzle::
    ; reset match count
    xor a ; (ld a, 0)
    ld [matchCount], a
    ld [matchCount+1], a

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
    ; increment match count
    push hl ; save current input position
    ld hl, matchCount

    di ; disable interrupts so we can update 16-bit value atomically

    ; increment low-byte
    inc [hl]

    jr nz, .afterMatch

    ; carry to high-byte if necessary
    inc hl
    inc [hl]

.afterMatch:
    ei ; reenable interrupts

    pop hl ; restore current input position

.afterInput:
    ld e, 0 ; reset state machine

    ld a, [hl] ; get first symbol of next input

    and a ; if symbol is nul, no further inputs are available
    jr nz, .findNextState

    ret
; end SolvePuzzle


SECTION "PuzzleGlobals", HRAM

; number of matches found
matchCount::
    ds 2

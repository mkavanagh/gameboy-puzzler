; PURPOSE: Contains common general-purpose functions
; LABELS: (as below)
SECTION "Functions", ROM0


; PURPOSE: Set a memory range to contain all zeros
; IN:
;  - hl: start address (inclusive)
;  - bc: number of bytes to zero out
; OUT:
;  - hl: address after the last byte which was zeroed out
; DESTROYS: af, bc
; CYCLES: 12N + 7 (where N is number of bytes to be zeroed out)
ZeroMem:: ; loop: zero out each byte in range
    ld a, b
    or c
    ret z ; return if no bytes remain

    xor a ; (ld a, 0)

    ld [hl+], a ; zero out byte and move to next
    dec bc ; decrease bytes remaining

    jr ZeroMem
; end loop
; end ZeroMem


; PURPOSE: Copy a specified number of bytes
; IN:
;  - hl: source address
;  - de: destination address
;  - bc: number of bytes to be copied
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
; DESTROYS: af, bc
; CYCLES: 15N + 7 (where N is number of bytes to be copied)
CopyBytes:: ; loop: copy each byte to destination
    ld a, b
    or c
    ret z ; return if no bytes remain

    ld a, [hl+] ; read byte and move to next

    ld [de], a ; write byte
    inc de ; move to next
    dec bc ; decrease bytes remaining

    jr CopyBytes
; end loop
; end CopyBytes


; PURPOSE: Copy a length-prefixed string (excluding the length byte)
; IN:
;  - hl: source address
;  - de: destination address
; OUT:
;  - hl: address after last character read
;  - de: address after last character written
; DESTROYS: af, c
; CYCLES: 10N + 8 (where N is the length of the string)
WriteStr::
    ld a, [hl+] ; read length and move to first character

    and a
    ret z ; return if length is zero

    ld c, a

 .loop: ; loop: copy each character to destination
    ld a, [hl+]; read character and move to next
    ld [de], a ; write character
    inc de ; move to next

    dec c
    jr nz, .loop ; loop until no remaining bytes
; end loop

    ret
; end WriteStr

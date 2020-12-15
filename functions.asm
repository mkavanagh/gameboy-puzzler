; PURPOSE: Contains common general-purpose functions
; LABELS: (as below)
SECTION "Functions", ROM0


; PURPOSE: Copy a specified number of bytes
; IN:
;  - hl: source address
;  - de: destination address
;  - bc: number of bytes to be copied
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
;  - bc: 0
;  - a: 0
;  - flags: Z1 N0 H0 C0
; CYCLES: 15N + 6 (where N is number of bytes to be copied)
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


; PURPOSE: Copy a nul-terminated string (excluding the terminator)
; IN:
;  - hl: source address
;  - de: destination address
; OUT:
;  - hl: address after the nul terminator in the source
;  - de: address after the last character in the destination
;  - a: 0
;  - flags: Z1 N0 H1 C0
; CYCLES: 12N + 8 (where N is the length of the string)
WriteStr:: ; loop: copy each character to destination
    ld a, [hl+] ; read character and move to next

    and a
    ret z ; return if character is terminator

    ld [de], a ; write character
    inc de ; move to next

    jr WriteStr
; end loop
; end WriteStr

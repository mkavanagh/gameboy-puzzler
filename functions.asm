; PURPOSE: Contains common general-purpose functions
;
; LABELS: (as below)
SECTION "Functions", ROM0


; PURPOSE: Set a memory range to contain the same value for each byte
;
; IN:
;  - hl: start address (inclusive)
;  - bc: number of bytes to set
;  - a: value to set
;
; OUT:
;  - hl: address after the last byte which was set
;  - a: the value which was set
;
; DESTROYS: f, bc
;
; CYCLES: 6N + 3(N/256) + 15 (where N is number of bytes to be set)
SetMem::
    inc b
    inc c
    jr .check

.loop:
    ld [hl+], a ; write byte

.check:
    dec c ; continue if more bytes remain in this 8-bit aligned chunk
    jr nz, .loop

    dec b ; continue if more 8-bit aligned chunks remain
    jr nz, .loop
; end loop

    ret
; end SetMem


; PURPOSE: Copy a specified number of bytes
;
; IN:
;  - hl: source address
;  - de: destination address
;  - bc: number of bytes to be copied
;
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
;
; DESTROYS: af, bc
;
; CYCLES: 10N + 3(N/256) + 15 (where N is number of bytes to be copied)
CopyBytes::
    inc b
    inc c
    jr .check

.loop:
    ld a, [hl+] ; read byte and move to next

    ld [de], a ; write byte
    inc de ; move to next

.check:
    dec c ; continue if more bytes remain in this 8-bit aligned chunk
    jr nz, .loop

    dec b ; continue if more 8-bit aligned chunks remain
    jr nz, .loop
; end loop

    ret
; end CopyBytes


; PURPOSE: Copy a chunk of memory to an 8-bit aligned start address ($xx00)
;
; IN:
;  - hl: source address (end, inclusive)
;  - de: destination address (end, inclusive)
; OUT:
;  - hl: address of the first byte in the source
;  - de: address of the first byte in the destination
;
; DESTROYS: af
;
; CYCLES: 8N + 3, min 13 (where N is number of bytes to be copied, at least 1)
CopyBytes_Aligned_NonEmpty::
    xor a ; (ld a, 0)
    cp e
    jr z, CopyBytes_Aligned_exit

; PURPOSE: Copy a chunk of memory to an 8-bit aligned start address ($xx00)
;
; IN:
;  - hl: source address (end, inclusive - at least $xx01)
;  - de: destination address (end, inclusive - at least $xx01)
;
; OUT:
;  - hl: address of the first byte in the source
;  - de: address of the first byte in the destination
;
; DESTROYS: af
;
; CYCLES: 8N - 1 (where N is number of bytes to be copied, at least 2)
CopyBytes_Aligned_Multiple:: ; loop: copy each byte to destination
    ld a, [hl-] ; read byte and move to prev

    ld [de], a ; write byte
    dec e ; move to prev

    jr nz, CopyBytes_Aligned_Multiple
; end loop

CopyBytes_Aligned_exit:
    ld a, [hl] ; read first byte
    ld [de], a ; write first byte

    ret
; end CopyBytes_Aligned_NonEmpty
; end CopyBytes_Aligned_Multiple


; PURPOSE: Copy a chunk of memory to an 8-bit aligned end address ($xxFF)
;
; IN:
;  - hl: source address
;  - de: destination address
;
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
;
; DESTROYS: af
;
; CYCLES: 8N + 3 (where N is number of bytes to be copied, at least 1)
CopyBytes_EndAligned_NonEmpty:: ; loop: copy each byte to destination
    ld a, [hl+] ; read byte and move to next

    ld [de], a ; write byte
    inc e ; move to next

    jr nz, CopyBytes_EndAligned_NonEmpty
; end loop

    ret
; end CopyBytes_EndAligned_NonEmpty


; PURPOSE: Copy a specified number of bytes, without crossing 8-bit alignment
;
; IN:
;  - hl: source address
;  - de: destination address
;  - c: number of bytes to be copied
;
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
;
; DESTROYS: af, c
;
; CYCLES: 9N + 7 (where N is number of bytes to be copied)
CopyBytes_InAligned::
    xor a ; (ld a, 0)
    cp c
    ret nz ; return if no bytes remain, or continue below

; PURPOSE: Copy a specified number of bytes, without crossing 8-bit alignment
;
; IN:
;  - hl: source address
;  - de: destination address
;  - c: number of bytes to be copied (non-zero)
;
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
;
; DESTROYS: af, c
;
; CYCLES: 9N + 3 (where N is number of bytes to be copied, at least 1)
CopyBytes_InAligned_NonEmpty:: ; loop: copy each byte to destination
    ld a, [hl+] ; read byte and move to next

    ld [de], a ; write byte
    inc e ; move to next
    dec c ; decrease bytes remaining

    jr nz, CopyBytes_InAligned_NonEmpty
; end loop

    ret
; end CopyBytes_InAligned
; end CopyBytes_AlignedPartial_NonEmpty


; PURPOSE: Copy a nul-terminated string (excluding the terminator)
;
; IN:
;  - hl: source address
;  - de: destination address
;
; OUT:
;  - hl: address after the nul terminator in the source
;  - de: address after the last character in the destination
;
; DESTROYS: af
;
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

; PURPOSE: Contains strings for displayable messages
; LABELS: (as below)
;
; Strings should be prefixed with a single byte indicating the length of the
; string.
SECTION "Messages", ROM0

HelloStr::
    db .end - (HelloStr + 1), "Hello world!"
.end:

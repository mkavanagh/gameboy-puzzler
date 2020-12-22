; PURPOSE: Contains strings for displayable messages
; LABELS: (as below)
;
; Strings should be prefixed with a single byte indicating the length of the
; string.
SECTION "Messages", ROM0

helloStr::
    db .end - (helloStr + 1), "Hello world!"
.end:

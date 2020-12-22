; PURPOSE: Contains font tile data
;
; LABELS:
;  - FontTiles: start of font tile data
;  - FontTilesEnd: end of font tile data
;
; Contains 128 tiles corresponding to ASCII characters.
SECTION "Font", ROM0

fontTiles::
INCBIN "font.chr"
fontTilesEnd::

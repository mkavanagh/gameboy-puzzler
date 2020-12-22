; PURPOSE: Contains macros for working with the letter-graph
; LABELS: (as below)

IF !DEF(GRAPH_INC)
GRAPH_INC SET 1


; PURPOSE: Output (as data) the list of valid transitions for a state in the
; letter-graph
; CYCLES: n/a
; BYTES: 2N + 1 (where N is the number of transitions)
Graph_Edges: MACRO
    REPT _NARG
    db \1
nextstate EQUS STRCAT("db LOW(._", STRCAT(\1, ")"))
    nextstate
    SHIFT
PURGE nextstate
    ENDR
    db 0
ENDM
; end Edges


ENDC
; end GRAPH_INC

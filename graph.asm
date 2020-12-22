INCLUDE "graph.inc"


; PURPOSE: Contains data for the letter-graph component of the words puzzle, in
; the form of a finite state machine.
;
; LABELS:
;  - graph: the initial state
;
; Each state is represented as an address in memory pointing to a list of valid
; state transitions, and each state transition is given as two bytes; the first
; byte is the symbol associated with that state transition, and the second byte
; is the lower 8 bits of the address of the new state. The list of state
; transitions is terminated with a zero byte.
SECTION "Graph", ROM0, ALIGN[8, 0]

graph::
    Graph_Edges "o", "l", "r", "e", "c", "g", "h", "w", "s", "n", "y", "t", "b"
._o:
    Graph_Edges "l", "r", "e", "c", "g", "h", "w", "s", "n", "y", "t", "b"
._l:
    Graph_Edges "r", "e", "o", "t", "b"
._r:
    Graph_Edges "c", "e", "o", "l", "b"
._e:
    Graph_Edges "r", "c", "g", "o", "l"
._c:
    Graph_Edges "h", "h", "o", "e", "r"
._g:
    Graph_Edges "e", "c", "h", "w", "o"
._h:
    Graph_Edges "g", "c", "s", "w", "o"
._w:
    Graph_Edges "o", "g", "h", "s", "n"
._s:
    Graph_Edges "n", "o", "w", "h", "y"
._n:
    Graph_Edges "t", "o", "w", "s", "y"
._y:
    Graph_Edges "b", "t", "o", "n", "s"
._t:
    Graph_Edges "b", "l", "o", "n", "y"
._b:
    Graph_Edges "r", "l", "o", "t", "y"

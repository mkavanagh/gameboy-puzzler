; PURPOSE: Reset vectors and interrupt handlers
;
; LABELS: None
;
; Reset vectors are small subroutines with fixed sizes and locations, which can
; be called with a dedicated instruction (RST) that is faster and more compact
; than the standard CALL instruction. They can be used to implement small,
; frequently used routines with greater space efficiency than macros, and
; with greater time and space efficiency than normal subroutines. As with
; normal subroutines, the RET instruction is used to exit the reset vector and
; return execution to the address on the top of the stack.
;
; Interrupt handlers are subroutines which can be invoked at any time during
; the execution of normal code, provided that:
;  - interrupts are enabled, and
;  - an interruptible event has occurred, and
;  - the interrupt handler for this event is enabled.
;
; When an interrupt is triggered, further interrupts will be disabled.
; Normally, the RETI instruction (rather than the RET instruction) should be
; used to exit an interrupt handler; in addition to moving execution to the
; address on the top of the stack, this instruction will re-enable interrupts.
;
; Interrupts are used to respond to system or user-driven events, such as
; timers, changes in the screen state, or joypad input.
;
; Even when not all reset vectors and/or interrupt handlers are all in use, it
; is good practice to define them at the correct locations and include a
; RET/RETI instruction as appropriate.


SECTION "RST1", ROM0[$0000]
    ret


SECTION "RST2", ROM0[$0008]
    ret


SECTION "RST3", ROM0[$0010]
    ret


SECTION "RST4", ROM0[$0018]
    ret


SECTION "RST5", ROM0[$0020]
    ret


SECTION "RST6", ROM0[$0028]
    ret


SECTION "RST7", ROM0[$0030]
    ret


SECTION "RST8", ROM0[$0038]
    ret


SECTION "VBlank", ROM0[$0040]
    jp vBlank


SECTION "STAT", ROM0[$0048]
    reti


SECTION "Timer", ROM0[$0050]
    reti


SECTION "Serial", ROM0[$0058]
    reti


SECTION "Joypad", ROM0[$0060]
    reti


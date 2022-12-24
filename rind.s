.segment "HEADER"
    .byte "NES" ;identification
    .byte $1A
    .byte $02 ;Amount of PRG ROM in 16k units
    .byte $01 ;amount of CHR ROM in 8k units
    .byte $00 ;mapper and mirroring
    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00
.segment "ZEROPAGE"
.segment "STARTUP"

RESET:

    INFLOOP:
        JMP INFLOOP
NMI:
    rti
.segment "VECTORS" ;what happens on interruption
.segment "CHARS"

.segment "CODE"

.proc Main
    ldx #5
    ldy #5
    inx
    iny
    dey
    dey
    dex
    rts
.endproc
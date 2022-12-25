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
    sei
    cld
    ldx #%1000000
    stx $4017
    ldx #$00
    stx $4010
    ;initialize stack register
    ldx #$FF
    txs ;transfers x to stack
:    
    ;clear PPU registers
    ldx #$00
    stx $2000
    stx $2001
:
    ;wait for VBLANK
    bit $2002
    bpl :-

    ;clear 2k memory
    txa
CLEARMEMORY:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne CLEARMEMORY

    INFLOOP:
        JMP INFLOOP
NMI:
    rti
.segment "VECTORS" ;what happens on interruption
.segment "CHARS"

;.segment "CODE"

;.proc Main
;    ldx #5
;    ldy #5
;    inx
;    iny
;    dey
;    dey
;    dex
;    rts
;.endproc
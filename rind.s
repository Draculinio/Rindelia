.segment "HEADER" ;header, for emulators, no need for cartridge
    .byte "NES" ;Beggining of the HEADER of iNes header
    .byte $1A ;Signature of iNes header, the emulator will look at this
    .byte $02 ;Amount of PRG ROM in 16k units
    .byte $01 ;amount of CHR ROM in 8k units
    .byte $00 ;mapper and mirroring
    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00
.segment "ZEROPAGE"
.segment "STARTUP"
.segment "CODE"

RESET:
    SEI ;disable IRQs (for some kind of sound?)
    CLD ;disable decimal mode
    LDX #$40
    STX $4017 ;disable APU frame counter IRQ - disable sound
    LDX #$ff
    TXS ;setup stack starting at FF as it decrments instead if increments
    INX ;overflox x to $00
    STX $2000 ;disable NMI - PPUCTRL reg
    STX $2001 ;disable rendering - PPUMASK reg
    STX $4010 ;disable DMC IRQs

vblankwait1: ;wait for vblank to make sure PPU is ready
    BIT $2002 ; return bit 7 of ppustatus register, vblank status. 0 flase, 1 true
    BPL vblankwait1

clearmem:
    LDA #$00
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$fe
    STA $0200, x ;set space in RAM for sprite data
    INX
    BNE clearmem ;Branch if not zero (?)

vblankwait2: ;PPU ready after this
    BIT $2002
    BPL vblankwait2

clearpalette:
    ;need to clear both palettes to $00
    LDA $2002 ;read PPU status to reset PPU address
    LDA #$3F ;set PPU address to BG palette RAM ($3F00)
    STA $2006
    LDA #$00
    STA $2006

    LDX #$20 ;Loop $20 (16) times (up to $3F20)
    LDA #$00 ;Set each entry to $00

:
    STA $2007
    DEX
    BNE :-

    LDA #%01000000 ;intensify green (????)
    STA $2001 ;in $2001 bits are BGRs bMmG (BGR is colour emphasis)

forever:
    JMP forever ;infinite loop when init code runs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
NMI:
    RTI ;this is not doing anything, just return from interrupt

.segment "VECTORS" ;what happens on interruption
    .word NMI
    .word RESET
    .word 0

.segment "CHARS"
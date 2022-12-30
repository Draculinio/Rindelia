.segment "HEADER" ;header, for emulators, no need for cartridge
    .byte "NES" ;Beggining of the HEADER of iNes header
    .byte $1A ;Signature of iNes header, the emulator will look at this
    .byte $02 ;Amount of PRG ROM in 16k units
    .byte $01 ;amount of CHR ROM in 8k units
    .byte %00000000
    .byte $00
    .byte $00
    .byte $00
    .byte $00
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
    BIT $2002 ; return bit 7 of ppustatus register, vblank status. 0 false, 1 true
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
    BNE clearmem ;Branch if not equal (?)

vblankwait2: ;PPU ready after this
    BIT $2002
    BPL vblankwait2

loadpalettes:
    LDA #$02 ; Most significant byte of memory range that we want to read to sprite memory, as set aside $0200 for sprite loading
    STA $4014 ; OAM DMA register - access to sprite memory
    NOP ;needs a cycle

    LDA $2002 ;read ppu status to reset the high/low latch
    LDA #$3F
    STA $2006 ; write high byte of $3F address
    LDA #$00
    STA $2006 ;write low byte of $3F00 address
              ; the $3F00 address is the memory location for the background palette, going to $3F0F (16 bytes)
              ; the sprite palette is at $3F10, ending at $3F1F, which is 32 bytes > $3F00, so want to loop 32 times
    LDX #$00

loadpaletteloop:
    LDA palettedata,X   ; load palette byte
    STA $2007           ; write to PPU
    INX                 ; increment X
    CPX #$20            ; loop 32 times to write address from $3F00 -> $3F1F 20h == 32d
    BNE loadpaletteloop ; if x = $20, 32 bytes copied, all done, else loop back

    LDX #$00

loadsprites:
    LDA spritedata,X
    STA $0200,X
    INX
    CPX #$20
    BNE loadsprites

    CLI ;clear interrups, NMI can be called
    LDA #%10000000 
    STA $2000 ;the left most bit of $200 sets wheter NMI is enabled or not

    LDA #%00010000 ;enable sprites
    STA $2001

forever:
    JMP forever ;infinite loop when init code runs

VBLANK:
    ; at start of each frame, has to be here
    LDA #$02
    STA $4014 ;set high byte (02) of RAM, start transfer
    RTI

palettedata:
    .byte $22, $30, $1a, $0F, $22, $36, $17, $0F, $22, $30, $21, $0F, $22, $27, $17, $0F  ; background palette data
    .byte $22, $16, $27, $18, $22, $1A, $30, $27, $22, $16, $30, $27, $22, $0F, $36, $17  ; sprite palette data

spritedata:
    .byte $00, $00, $00, $08 ; YCoord, tile number, attr, XCoord
    .byte $00, $01, $00, $10
    .byte $08, $02, $00, $08
    .byte $08, $03, $00, $10
    .byte $10, $04, $00, $08
    .byte $10, $05, $00, $10
    .byte $18, $06, $00, $08
    .byte $18, $07, $00, $10


.segment "VECTORS" ;what happens on interruption
    .word VBLANK
    .word RESET
    .word 0

.segment "CHARS"
    .incbin "mario.chr"
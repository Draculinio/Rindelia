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

vblankwait: ;wait for vblank to make sure PPU is ready
    BIT $2002 ; return bit 7 of ppustatus register, vblank status. 0 false, 1 true
    BPL vblankwait
    RTS

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

JSR vblankwait ;jumps and saves return address. This jumps and comes back here. We need a second blank wait
TXA ; A = $00

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
    LDA #$00
    INX
    BNE clearmem ;Branch if not equal (?)

JSR vblankwait
    
LDA #$02    ; load A with the high byte for sprite memory
STA $4014   ; this uploads 256 bytes of data from the CPU page $XX00 - $XXFF (XX is 02 here) to the internal PPU OAM
NOP         ; takes 513 or 514 CPU cycles, so this basically pauses program I think?

clearnametables:
    LDA $2002   ; reset PPU status
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$08    ; prepare to fill 8 pages ($800 bytes)
    LDY #$00    ; X/Y is 16-bit counter, bigh byte in X
    LDA #$24    ; fill with tile $24 (sky block)
:
    STA $2007
    DEY 
    BNE :-
    DEX 
    BNE :-

loadpalettes:
    LDA $2002 ;read ppu status to reset the high/low latch
    LDA #$3F
    STA $2006 ; write high byte of $3F address
    LDA #$00
    STA $2006 ;write low byte of $3F00 address
              ; the $3F00 address is the memory location for the background palette, going to $3F0F (16 bytes)
              ; the sprite palette is at $3F10, ending at $3F1F, which is 32 bytes > $3F00, so want to loop 32 times
    LDX #$00

loadPaletteLoop:
    LDA palettedata,X   ; load palette byte. First palette+0, then palette+1, palette+2
    STA $2007           ; write to PPU
    INX                 ; increment X
    CPX #$20            ; loop 32 times to write address from $3F00 -> $3F1F 20h == 32d
    BNE loadPaletteLoop ; if x = $20, 32 bytes copied, all done, else loop back
    LDX #$00

loadsprites:
    LDA spritedata,X ;spritedata +x
    STA $0200,X
    INX
    CPX #$20
    BNE loadsprites

loadBackground:
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
loadBackgroundLoop:
    LDA background, X
    STA $2007
    INX
    CPX #$80
    BNE loadBackgroundLoop
loadAttribute:
    LDA $2002
    LDA #$23
    STA $2006   ; write the high byte of $23C0 address
    LDA #$C0
    STA $2006   ; write the low byte of $23C0 address
    LDX #$00    ; start out at 0
loadAttributeLoop:
    LDA attribute, X
    STA $2007
    INX
    CPX #$08
    BNE loadAttributeLoop

    CLI ;clears interrupt disable bit
    LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
    STA $2000

    LDA #%00011110   ; enable sprites, enable background, no clipping on left side
    STA $2001
                  
forever:
    JMP forever ;infinite loop when init code runs

VBLANK:
    ; at start of each frame, has to be here
    LDA #$02
    STA $4014 ;set high byte (02) of RAM, start transfer

latchcontroller: ;First control at $4016 and second at $4017
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016 ;tell controller to latch buttons

;----Let's go buttons!----

readA: ;player 1 A
    LDA $4016
    AND #%00000001  ;looks at first bit, 1 if pressed
    BEQ buttonAdone ;If A not pressed
    
buttonAdone:

readB: ;player 1 B
    LDA $4016
    AND #%00000001  ;looks at first bit, 1 if pressed
    BEQ buttonBdone ;If B not pressed
buttonBdone:

readSTART:
    LDA $4016
    AND #%00000001
    BEQ buttonSTARTdone

buttonSTARTdone:

readSELECT:
    LDA $4016
    AND #%00000001
    BEQ buttonSELECTdone

buttonSELECTdone:

readUp:
    LDA $4016
    AND #%00000001
    BEQ readUpDone

readUpDone:

readDown:
    LDA $4016
    AND #%00000001
    BEQ readDownDone

readDownDone:

readLeft:
    LDA $4016
    AND #%00000001
    BEQ readLeftDone
    ;;If pressed
    JSR move_left
    
readLeftDone:

readRight:
    LDA $4016
    AND #%00000001
    BEQ readRightDone
    ;;If pressed
    JSR move_right

readRightDone:

@done: 
    LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
    STA $2000
    LDA #%00011110   ; enable sprites, enable background, no clipping on left side
    STA $2001
    LDA #$00        ;;tell the ppu there is no background scrolling
    STA $2005
    STA $2005
    RTI


; ---------------------------- Game engine ----------------------------


move_left:
    LDA $0203 ;load sprite 0 x position
    CLC ; clear carry flag for addition
    SBC #$01 ; x = x-1 - move to the right
    STA $0203 ; store back into sprite 0 x position
    LDA $0207 ;load sprite 1 x position
    CLC 
    SBC #$01
    STA $0207
    LDA $020B ;load sprite 2 x position
    CLC
    SBC #$01
    STA $020B
    LDA $020F ;load sprite 3 x position
    CLC
    SBC #$01
    STA $020F
    LDA $0213 ;load sprite 4 x position
    CLC
    SBC #$01
    STA $0213
    LDA $0217 ;load sprite 5 x position
    CLC
    SBC #$01
    STA $0217
    LDA $021B ;load sprite 6 x position
    CLC
    SBC #$01
    STA $021B
    LDA $021F ;load sprite 7 x position
    CLC
    SBC #$01
    STA $021F
    RTS

move_right:
    LDA $0203 ;load sprite 0 x position
    CLC ; clear carry flag for addition
    ADC #$01 ; x = x+1 - move to the right
    STA $0203 ; store back into sprite 0 x position
    LDA $0207 ;load sprite 1 x position
    CLC
    ADC #$01
    STA $0207
    LDA $020B
    CLC
    ADC #$01
    STA $020B
    LDA $020F
    CLC
    ADC #$01
    STA $020F
    LDA $0213
    CLC
    ADC #$01
    STA $0213
    LDA $0217
    CLC
    ADC #$01
    STA $0217
    LDA $021B
    CLC
    ADC #$01
    STA $021B
    LDA $021F ;load sprite 7 x position
    CLC
    ADC #$01
    STA $021F
    RTS
    
; GRAPHICS
palettedata:
    .byte $22, $30, $1a, $0F, $22, $36, $17, $0F, $22, $30, $21, $0F, $22, $27, $17, $0F  ; background palette data
    .byte $22, $16, $27, $18, $22, $1A, $30, $27, $22, $16, $30, $27, $22, $0F, $36, $17  ; sprite palette data

spritedata:
    .byte $0A, $00, $01, $08 ; YCoord, tile number, attr, XCoord
    .byte $0A, $01, $01, $10
    .byte $12, $02, $01, $08
    .byte $12, $03, $01, $10
    .byte $1A, $04, $01, $08
    .byte $1A, $05, $01, $10
    .byte $22, $06, $01, $08
    .byte $22, $07, $01, $10
    ;.byte $24, $00, $01, $10 ; If for example I want to add more things as sprites
    ;.byte $24, $01, $01, $12
    ;.byte $32, $02, $01, $10
    ;.byte $32, $03, $01, $12

background:
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 2
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .byte $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24  ;;row 3
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;;some brick tops

  .byte $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24  ;;row 4
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;;brick bottoms

attribute:
    .byte %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
    ;.byte $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F

; SEGMENTS
.segment "VECTORS" ;what happens on interruption
    .word VBLANK
    .word RESET
    .word 0
.segment "CHARS"
    .incbin "mario.chr"
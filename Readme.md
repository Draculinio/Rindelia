# NES GAME

# Compile: 

C:\\cc65\\bin\\ca65 rind.s -o rind.o -t nes
C:\\cc65\\bin\\ld65 rind.o -o rind.nes -t nes
You can replace the path as you wish...

## Sites:

### FCEUX: Nintendo Emulator with tools https://fceux.com/web/download.html
### cc65: Assembler https://cc65.github.io/getting-started.html
### nesdev wiki: Wiki about nes development https://www.nesdev.org/wiki/Nesdev_Wiki

## Youtube channels:

NesHacker

https://www.youtube.com/watch?v=V5uWqdK92i0

# 6502

6502
----

El procesador 6502 tiene 6 registros de 8 bits (excepto el contador de programa que es de 16 bits)

- Acumulador (A): puede leer y escribir en memoria. Usado para aritmética y lógica.
- X Index: puede leer y escribir a la memoria.Se usa más que nada para loops o para direccionar memoria, pero también para guardar data como el acumulador
- Y Index: como el X Index pero no completamente intercambiable. Algunas operaciones solo están disponibles para uno de los registros

- Flag(P): Siete bits que representan el estado del procesador
- Stack Pointer(S) : Tiene las direcciones del sitio exacto en el stack. El stack es una forma de guardar datos pusheando o popeando datos desde y hacia direcciones de memoria.
- Program Counter (PC): Guarda el lugar actual en el que se encuentra el programa.



## X e Y

Data: 

- 1 byte
- On Processor

Operaciones: 

- Ponel el valor inmediato
- Copiar la direccion de memoria
- Incrementar
- Decrementar

## Program Counter

Direcciones de 16 bits LO-HI

Las direcciones van entre $00-$80 a $FF-$FF

## Processor Status

Registro de 8 bits que contiene flags

### Carry Flag

- Cuando en la suma, adelante tenemos 1 + 1, CF va a valer 1.
- Si en cmp, A >= M

### Negative Flag

Cuando de un cmp A < Memoria entonces N = 1

### Zero Flag

Cuando de un cmp A = Memoria entonces Z = 1
Si luego de una comparación (and, or) A = 0, entonces Z = 1

## Forma de compilacion

lda #10 equivale a $A9 $0A

### Memoria del sistema: 

- 64kb
- Ram, PRG-ROM
- Direcciones de 16 bits

#### regiones
- 1: $0000 - $07FF (System Ram: 2kb) Tiene los datos del juego, variables temporales
- 2: $0800 - $0FFF (Mirror 1 de la RAM)
- 3: $1000 - $17FF (Mirror 2 de la RAM)
- 4: $1800 - $1FFF (Mirror 3 de la RAM)
- 5: $2000 - $401F (I/O) Gráficos, Sonidos, input del control, PRG-ROM Bank Swapping
- 6: $4020 - Cartridge zone.

La región 1 es llamada ZeroPage, la cual suele andar algo más rápido.

## Instrucciones

### .byte
Pone datos en posiciones de memoria de la ROM

### adc 
Add with Carry, suma el acumularod a una direccion de memoria teniendo en cuenta el carry flag

Ejemplo: adc $01  A <- $01+A+C

### and
Bitwise operation. Compara dos valores y da como resultado un tercero

Ejemplo and $40
Compara con el acumulador

Usándolo con el acumulador, hace la comparacion bit a bit entre una posicion de memoria y el acumulador. Pone el resultado en el acumulador.

Si el resultado en A es cero, pone el flag Z en 1

### bcc
Branch if carry clear. Salta si el Carry Flag está en 0

Ejemplo: bcc not_lethal (salta a una porción del código llamado not_lethal si CF=0)

### beq
Branch if equal: Hace el branch cuando zero flag = 1

Ejemplo: beq jump (va  a la posición jump si Z = 1)

### bpl
Branch on positive result (muy usado en loops)
Salta (a un label) si el valor del Negative Flag es 0

Si no quiero nombrar un label puedo usar :+ (va al primer label despues de ejecutarse)
Tambien puedo usar :- (va al primer label anterior a la ejecucion)
Se puede :++ o :-- o más.

Ejemplo: bpl initialize_loop
Ejemplo: bpl :+

### clc 
Clear Carry, limpia el carry flag del procesador

### cld
Deshabilita el modo decimal

### cmp
Compare, compara un valor en memoria con lo que está en el acumulador

Si A < Memoria se activa el Negative Flag (N) (A-M = Negativo)
Si A = Memoria se activa el Zero Flag (Z) (A-M = 0 )
Si A >= Memoria se activa el Carri Flag (C)

### cpx

Compara el registro X con la memoria

### dec 
Decrementa un valor en memoria

Ejemplo dec $01

### dex 
decrementa x

### dey 
decrementa y

### eor
Bitwise operator. Exclusive or with accumulator

### inc 
Incrementa un valor en memoria

Ejemplo: inc $00

### inx 
Incrementa x

### iny 
Incrementa y

### lda 
Load A, guarda datos en el registro acumulador

Ejemplo: lda $00    Entonces A <- #$B2

### ldx 
carga el valor en el registro x

Ejemplo: ldx #5

### ldy 
carga el valor en el registro y

Ejemplo: ldy #5

### or
Bitwise operatr. Compara dos valores como exclusive or y retorna el resultado

Ejemplo: OR(A, B) ->C

### ora

Bitwise Operator. Or con el acumulador

### rts 
Return from subrutine

## sbc

Substract from accumulator. Resta de lo que este en el acumulador.

Ejemplo: sbc #50

## sec

Substraccion con carry

## sei
Deshabilita las interrupciones

## sta 
Store A, guarda los datos del acumulador en memoria

Ejemplo: sta $02

## stx 
Guarda el dato de x en memoria

Ejemplo: stx $00

## txs

Transfiere x al stack

# Datos numéricos

#1 ->Valor en decimal (constante)
$B7 ->Valor hexadecimal
#%10001111 -> Valor binario (para uso de bitwise por ejemplo)

# Modos de Direccionamiento de memoria

## Modo inmediato #$10 (solo para single byte)
## Zero Page manda una direccion de 8 bits $2F
## direccionamiento absoluto: 16 bits $0301, así podemos entrar a cualquier parte a costa de velocidad
## Direccionamiento implícito: por ejemplo inx, no hay uso de direcciones de memoria.
# Operandos

## Loops
.proc Main
ldx #7
initialize_hp_loop:
    lda initial_monster_hp, x
    sta $0300, x
    dex
    bpl initialize_hp_loop
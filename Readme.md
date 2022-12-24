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


X e y

Data: 

- 1 byte
- On Processor

Operaciones: 

- Ponel el valor inmediato
- Copiar la direccion de memoria
- Incrementar
- Decrementar

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

ldx: carga el valor en el registro x

Ejemplo: ldx #5

ldy: carga el valor en el registro y

Ejemplo: ldy #5

dex: decrementa x

dey: decrementa y

dec: Decrementa un valor en memoria

Ejemplo dec $01

iny: Incrementa y

inx: Incrementa x

inc: Incrementa un valor en memoria

Ejemplo: inc $00

rts: Return from subrutine

stx: Guarda el dato de x en memoria

Ejemplo: stx $00

lda: Load A, guarda datos en el registro acumulador

Ejemplo: lda $00    Entonces A <- #$B2

clc: Clear Carry, limpia el carry flag del procesador

adc: Add with Carry, agrega el acumularod a una direccion de memoria

Ejemplo: adc $01  A <- $01+A+C

sta: Store A, guarda los datos del acumulador en memoria

Ejemplo: sta $02

# Datos numéricos

#1 ->Valor en decimal (constante)
$B7 ->Valor hexadecimal

# Modos de Direccionamiento de memoria

## Modo inmediato #$10 (solo para single byte)
## Zero Page manda una direccion de 8 bits $2F
## direccionamiento absoluto: 16 bits $0301, así podemos entrar a cualquier parte a costa de velocidad
## Direccionamiento implícito: por ejemplo inx, no hay uso de direcciones de memoria.
# Operandos


Constraints:
- Bitwidth
  - I wish I could do 32 bit but probably not
  - 16 bits will do, i think
- Memory
  - 16 bits is only 64k
  - will do for now, later address bus with become 32bit

Registers:
  - To facilitate operations in any useful manner i think minimal set is
  - A and B registers for operands, 16bit
  - ALU-OUT 16bit which might be called ACCU register that ALU always targets
  - Literally everything else sits in main memory
  - Stack Pointer SP 16bit
  - Instruction Pointer IP 16bit
  - (Internal) Instruction INST 8bit
  - (Internal) Instruction params INPAR 16bit

Instructions:

I think what I will do is to have 32 bit instructions
but the memory and pu itself will remain 16 bit

so the layout would be: `[opcode 8b][variant 8b][16b data]`

this gives total 256 instructions slots, each with 256 variants
and operating on 16bit wide data param

this can greatly improve the assembler for example LOAD instruction
can be just one and have variants to say where to load and from where

this idea will be followed so instructions are very generic and parametrized

What is not cool is that instructions will waste a lot of space

Maybe instructions should be 8 to 48 bits wide as needed?
Would this overcomplicate it? perhaps

Example of big MOV 
- MOV opcode
  - params split into groups of 4 bits
    - left 4 bits, source
      - memory direct 0
      - memory indirect 1
      - X 2
      - Y 3
      - ACC 4
      - others later like peripheral
    - right 4 bits, destination
      - memory direct 0
      - memory indirect 1
      - X 2
      - Y 3
      - ACC 4
      - others later like peripheral
    - let weird combinations run whatever happens happens
  - data only exists in some situations and has various sizes
    - if src is memory, first 16 bits of data encode address
    - if dst is memory, next 16 bits of data encode address
    - same with peripherals

Example of small MOV if literally everything would be memory mapped
even all registers
this would need the bus to be wider than 16 bit
if i could somehow make the thing 64 bit per instruction it would be then, 8 bit opcode, 28 bit src, 28 bit dst
this could encode the whole ddr ram if needed too
- MOV opcode 8 bit
  - then 28 bit source
  - then 28 bit destination

variable instructions sizes would be better for all of this
as it would be able to pack well the instructions
waste space vs more complicated decoder?

- ADD opcode 8 bit
  - then 28 bit source
  - then 28 bit destination

add would need 3 addresses now so lets fuck it and run with variable sizes and 32 bit wide bus

maybe separate param for adressing would be nice
maybe this can be part of the address?
better separate param

adressing have to support up to 3 params to best adjust it to 4 params. this gives 2 bits per param so 4 values:
in memory addressing:
- 00 - direct memory address
- 01 - indirect memory address, points to memory with address to access in the end
- rest unused for now
in jumps addressing:
- 00 - absolute
- 01 - relative

- PUT opcode 8 bit
  - 8 bit adressing
  - then 32 bit destination
  - then 8 bit value

- MOV opcode 8 bit
  - 8 bit adressing
  - then 32 bit source
  - then 32 bit destination

- ADD/SUB/MUL/DIV opcode 8 bit
  - 8 bit adressing
  - then 32 bit A
  - then 32 bit B
  - then 32 bit destination

- JEQ opcode 8 bit
  - 8 bit adressing
  - then 32 bit value
  - then 32 bit expected
  - then 32 bit jump_destination

- JCRY opcode 8 bit jump only if carry set
  - 8 bit adressing
  - then 32 bit jump_destination

- CRYCLR clears carry

- HALT halts, what to do next is a tricky question, probably only rst

- SPUSH opcode 8 bit - pushes PC to SP and advances SP

- SPOP opcode 8 bit - pops PC from SP and sets PC to it, maybe + 1

actually here its interesting to realize that stack is the only thing that is stateful here, if stack would be removed the cpu would be completely stateless, so could support multiple users simulatenously. interrupts would be needed for that, also just instruction to set stack pointer would suffice

Giga hacky but for now will be useful for serial stuff

probably not good idea, skip for now, will pollute cpu internals with some stupid uart

- PUTC opcode 8 bit
  - 8 bit adressing
  - then 32 bit source_address

- READC opcode 8 bit
  - 8 bit adressing
  - then 32 bit destination_address


Decoding could go like this:
- fetch opcode and enter state respective for this instruction
- each would have their own state machines - good or bad? too many luts? it could certainly be reused


Debugger:
  - Arduino connected to 3 pins:
    - Reset pin that resets all registers if up
        - is this needed? could be a command or even opcode
        - or a button if things get weird
    - Transmission start pin that zeros the buffer
        - is this needed? the buffer can be overwritten by just shifting more stuff to it
    - Signal pin with 0 or 1 data
    - Store
      - on posedge shift buffer to the left
      - on nededge store the Signal in the lowest bit of the buffer
        - could happen simultaneously on psoedge sequentially
    - Run - run whatever command ended up in the buffer
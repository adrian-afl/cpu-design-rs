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
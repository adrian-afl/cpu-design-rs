General info:
- The bus address (depth) is 32 bits
- The bus size (width) is 8 bit
- Peripherals are memory mapped

SOC elements:
- CPU
    - RW bus address
    - RW bus data

- Memory
    - R bus address
    - RW bus data

- UART
    - R bus address
    - RW bus data

- UART bootloader
    - RW bus address
    - RW bus data

At a time there should be
- only 1 driver of bus address
- only 1 driver of bus data

Reads can be feely available I think.

It looks like all chips should be able to drive bus data.

Also some need to write bus address.

Chips then to control the bus should take

input [31:0] bus_raddr // if addr R
output bus_addr_wr_en // if addr W
output [31:0] bus_waddr_wr_data // if addr W

input bus_data_re_en // if data R
input [7:0] bus_rdata // if data R
output bus_data_wr_en // if data W
output [7:0] bus_wdata // if data W
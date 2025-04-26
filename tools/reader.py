import mmap
from math import floor as floor

def get_rom_bytes(offset, len):
# get len number of bytes from offset
    with open('baserom.gb') as rom:
        romMap = mmap.mmap(rom.fileno(), 0, access=mmap.ACCESS_READ)
        return romMap[offset : offset + len]

def get_rom_byte(offset):
# get one byte from offset
    return get_rom_bytes(offset, 1)[0]

def read_symbols():
    symbols = {}

    with open("kirbydreamland2.sym", "r") as file:
        for line in file.readlines():
            line = line.split(":")
            if len(line) != 2:
                continue
            offs = int(line[1][0:4], 16)
            bank = int(line[0], 16)

            if offs > 0x8000:
                continue

            absOffs = offs + (bank - 1) * 0x4000 if bank > 1 else offs
            symString = line[1].split()[1]
            if '.' in symString:
                continue
            symbols[absOffs] = symString

    return symbols

def read_ram():
    ram_symbols = {}

    with open("kirbydreamland.sym", "r") as file:
        for line in file.readlines():
            line = line.split(":")
            if len(line) != 2:
                continue
            offs = int(line[1][0:4], 16)

            if offs < 0x8000:
                continue

            symString = line[1].split()[1]
            ram_symbols[offs] = symString

    return ram_symbols

import reader
import argparse
import re

parser = argparse.ArgumentParser(description='Extracts script.')
parser.add_argument('offsets', metavar='offsets', type=str, nargs='+',
                    help='offset(s) to parse')
args = parser.parse_args()

syms = reader.read_symbols()

SCRIPT_PAUSE_CMD = 0x00
SET_FRAME_CMD = 0x01
UNK02_CMD = 0x02
UNK03_CMD = 0x03
SET_OAM_CMD = 0x04
WAIT_CMD = 0x05
JUMP_CMD = 0x06
SET_X_VEL_CMD = 0x07
SET_Y_VEL_CMD = 0x08
REPEAT_CMD = 0x09
REPEAT_END_CMD = 0x0a
UNK0B_CMD = 0x0b
UNK0C_CMD = 0x0c
EXEC_ASM_CMD = 0x0d
UNK0E_CMD = 0x0e
SET_FIELD_CMD = 0x0f
UNK10_CMD = 0x10
JUMP_IF_NOT_UNK27_CMD = 0x11
JUMP_IF_UNK27_CMD = 0x12
UNK13_CMD = 0x13
UNK14_CMD = 0x14
UNK15_CMD = 0x15
SCRIPT_END_CMD = 0x16
SET_DRAW_FUNC_CMD = 0x17
UNK18_CMD = 0x18
SET_FRAME_WAIT_CMD = 0x19
UNK1A_CMD = 0x1a
UNK1B_CMD = 0x1b
UNK1C_CMD = 0x1c
UNK1D_CMD = 0x1d
UNK1E_CMD = 0x1e
UNK1F_CMD = 0x1f
SET_X_CMD = 0x20
SET_Y_CMD = 0x21
UNK22_CMD = 0x22
UNK23_CMD = 0x23
PLAY_SFX_CMD = 0x24
UNK25_CMD = 0x25
UNK26_CMD = 0x26
UNK27_CMD = 0x27
UNK28_CMD = 0x28
UNK29_CMD = 0x29
SET_Y_ACC_CMD = 0x2a

def parse_byte(data):
    return (1, f"${data[0]:02x}")

def parse_int8(data):
    return (1, f"{data[0]}")

def parse_int16(data):
    val = data[0] + data[1] * 0x100
    return (2, f"{val}")

def parse_oam(data):
    bank = data[2]
    addr = data[0] + data[1] * 0x100
    offs = (bank - 1) * 0x4000 + addr
    return (3, f"${addr:0x}, ${bank:02x} ; OAM_{offs:0x}")

def parse_vel(data):
    val = data[0] / 0x100 + data[1]
    val = val if val < 0x80 else val - 0x100
    return (2, f"{round(val, 3)}")

def parse_acc(data):
    val = data[0] / 0x100
    val = val if val < 0.5 else val - 1.0
    return (1, f"{round(val, 3)}")

def parse_field(data):
    field = data[0]
    return (1, f"OBJSTRUCT_UNK{field:02X}")

def parse_sfx(data):
    sfx = data[0]
    return (1, f"SFX_{sfx:02X}")

def parse_home_func(data):
    addr = data[0] + data[1] * 0x100
    func = ""
    if addr in syms:
        func = syms[addr]
    else:
        func = f"Func_{addr:0x}"
    return (2, f"{func}")

def parse_unk03(data):
    bank = data[2] & 0x1f
    addr = data[0] + data[1] * 0x100
    offs = (bank - 1) * 0x4000 + addr
    return (3, f"Func_{offs:0x}")

def parse_local_addr(data):
    addr = data[0] + data[1] * 0x100
    return (2, addr)

def parse_address(data):
    addr = data[0] + data[1] * 0x100
    return (2, f"${addr:0x}")

cmds = [
    ("script_pause", []), # SCRIPT_PAUSE_CMD
    ("set_frame", [parse_int8]), # SET_FRAME_CMD
    ("unk02_cmd", None), # UNK02_CMD
    ("unk03_cmd", [parse_unk03]), # UNK03_CMD
    ("set_oam", [parse_oam]), # SET_OAM_CMD
    ("wait", [parse_int8]), # WAIT_CMD
    ("jump", [parse_local_addr]), # JUMP_CMD
    ("set_x_vel", [parse_vel]), # SET_X_VEL_CMD
    ("set_y_vel", [parse_vel]), # SET_Y_VEL_CMD
    ("repeat", [parse_int8]), # REPEAT_CMD
    ("repeat_end", []), # REPEAT_END_CMD
    ("unk0b_cmd", None), # UNK0B_CMD
    ("unk0c_cmd", None), # UNK0C_CMD
    ("exec_asm", [parse_address]), # EXEC_ASM_CMD
    ("unk0e_cmd", None), # UNK0E_CMD
    ("set_field", [parse_field, parse_byte]), # SET_FIELD_CMD
    ("unk10_cmd", None), # UNK10_CMD
    ("jump_if_not_unk27", [parse_local_addr]), # JUMP_IF_NOT_UNK27_CMD
    ("jump_if_unk27", [parse_local_addr]), # JUMP_IF_UNK27_CMD
    ("unk13_cmd", None), # UNK13_CMD
    ("unk14_cmd", None), # UNK14_CMD
    ("unk15_cmd", None), # UNK15_CMD
    ("script_end", []), # SCRIPT_END_CMD
    ("set_draw_func", [parse_home_func]), # SET_DRAW_FUNC_CMD
    ("unk18_cmd", None), # UNK18_CMD
    ("set_frame_wait", [parse_int8, parse_int8]), # SET_FRAME_WAIT_CMD
    ("unk1a_cmd", None), # UNK1A_CMD
    ("unk1b_cmd", None), # UNK1B_CMD
    ("unk1c_cmd", None), # UNK1C_CMD
    ("unk1d_cmd", None), # UNK1D_CMD
    ("unk1e_cmd", None), # UNK1E_CMD
    ("unk1f_cmd", None), # UNK1F_CMD
    ("set_x", [parse_int16]), # SET_X_CMD
    ("set_y", [parse_int16]), # SET_Y_CMD
    ("unk22_cmd", None), # UNK22_CMD
    ("unk23_cmd", None), # UNK23_CMD
    ("play_sfx", [parse_sfx]), # PLAY_SFX_CMD
    ("unk25_cmd", None), # UNK25_CMD
    ("unk26_cmd", None), # UNK26_CMD
    ("unk27_cmd", None), # UNK27_CMD
    ("unk28_cmd", None), # UNK28_CMD
    ("unk29_cmd", None), # UNK29_CMD
    ("set_y_acc", [parse_acc]), # SET_Y_ACC_CMD
]

compound_cmds = {
    "Func_f50": ("create_object", [parse_byte, parse_byte, parse_byte])
}

for o in args.offsets:
    offset = int(o, 16)
    cur_bank = int(offset / 0x4000)
    pos = offset
    strings = []

    def get_local_address(a):
        res = a if cur_bank == 0 else (a + 0x4000 * (cur_bank - 1))
        return f"{res:0x}"

    jump_addresses = set()

    while True:
        this_pos = pos
        cmd = reader.get_rom_byte(pos)
        cmd_str, cmd_funcs = cmds[cmd]
        pos += 1

        if cmd == EXEC_ASM_CMD:
            buf = reader.get_rom_bytes(pos, 2)
            addr = buf[0] + buf[1] * 0x100
            if addr < 0x4000 and addr in syms and syms[addr] in compound_cmds:
                cmd_str, cmd_funcs = compound_cmds[syms[addr]]
                pos += 2

        args_str = None

        if cmd_funcs == None:
            print(f"Invalid command 0x{cmd:02x}")
            print(strings)
            raise Exception()

        else:
            args_str = ""
            for cmd_func in cmd_funcs:
                data = reader.get_rom_bytes(pos, 4)
                pos_offs, arg_str = cmd_func(data)
                pos += pos_offs
                args_str += str(arg_str) + ", "
            args_str = args_str[:-2]

        s = f"\t{cmd_str} {args_str}" if args_str else f"\t{cmd_str}"
        if cmd == REPEAT_CMD:
            s = "\n" + s
        elif cmd == REPEAT_END_CMD:
            s += "\n"

        strings.append((this_pos, s))

        if cmd in [JUMP_CMD, JUMP_IF_NOT_UNK27_CMD, JUMP_IF_UNK27_CMD]:
            jump_addresses.add(arg_str)

        if cmd in [JUMP_CMD, SCRIPT_END_CMD]:
            if (pos % 0x4000) + 0x4000 not in jump_addresses:
                break

    contains_jump_addr = False

    out_str = f"Script_{o}:\n"
    for offs, s in strings:
        if (offs % 0x4000) + 0x4000 in jump_addresses:
            contains_jump_addr = True
            out_str += ".script_{:0x}\n".format(offs)
        out_str += s + "\n"

    out_str += f"; 0x{pos:0x}"

    out_str = re.sub(r"\n\n\n", "\n\n", out_str)

    for a in jump_addresses:
        out_str = re.sub(str(a), ".script_{}".format(get_local_address(a)), out_str)

    # if only one local address in script, rename to .loop
    if len(jump_addresses) == 1 and contains_jump_addr:
        out_str = re.sub(r".script_.*", ".loop", out_str)

    print(out_str)

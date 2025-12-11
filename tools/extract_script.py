import reader
import argparse
import re

parser = argparse.ArgumentParser(description='Extracts script.')
parser.add_argument('offsets', metavar='offsets', type=str, nargs='+',
                    help='offset(s) to parse')
args = parser.parse_args()

syms = reader.read_symbols()

SCRIPT_END_CMD = 0x00
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
CALL_CMD = 0x0b
RET_CMD = 0x0c
EXEC_ASM_CMD = 0x0d
VAR_JUMPTABLE_CMD = 0x0e
SET_FIELD_CMD = 0x0f
SET_VAR_TO_FIELD_CMD = 0x10
JUMP_IF_NOT_VAR_CMD = 0x11
JUMP_IF_VAR_CMD = 0x12
UNK13_CMD = 0x13
JUMP_IF_VAR_LT_CMD = 0x14
WAIT_VAR_CMD = 0x15
SCRIPT_STOP_CMD = 0x16
SET_DRAW_FUNC_CMD = 0x17
STOP_MOVEMENT_CMD = 0x18
SET_FRAME_WAIT_CMD = 0x19
SET_FIELD_TO_VAR_CMD = 0x1a
FAR_JUMP_CMD = 0x1b
FARCALL_CMD = 0x1c
FARRET_CMD = 0x1d
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

class Parser:
    def __init__(self):
        self.jump_addresses = set()

    def parse_byte(self, data):
        return (1, f"${data[0]:02x}")

    def parse_word(self, data):
        return (2, f"${data[1]:02x}{data[0]:02x}")

    def parse_uint8(self, data):
        return (1, f"{data[0]}")

    def parse_int8(self, data):
        x = data[0]
        return (1, f"{x if x < 0x80 else x - 0x100}")

    def parse_uint16(self, data):
        val = data[0] + data[1] * 0x100
        return (2, f"{val}")

    def parse_oam(self, data):
        bank = data[2]
        addr = data[0] + data[1] * 0x100
        offs = (bank - 1) * 0x4000 + addr
        return (3, f"${addr:0x}, ${bank:02x} ; OAM_{offs:0x}")

    def parse_vel(self, data):
        val = data[0] / 0x100 + data[1]
        val = val if val < 0x80 else val - 0x100
        return (2, f"{round(val, 3)}")

    def parse_acc(self, data):
        val = data[0] / 0x100
        val = val if val < 0.5 else val - 1.0
        return (1, f"{round(val, 3)}")

    def parse_field(self, data):
        field = data[0]
        return (1, f"OBJSTRUCT_UNK{field:02X}")

    def parse_sfx(self, data):
        sfx = data[0]
        return (1, f"SFX_{sfx:02X}")

    def parse_asm_func(self, data):
        addr = data[0] + data[1] * 0x100
        if addr >= 0x4000:
            addr += (self.cur_bank - 1) * 0x4000
        func = ""
        if addr in syms:
            func = syms[addr]
        else:
            func = f"Func_{addr:0x}"
        return (2, f"{func}")

    def parse_unk03(self, data):
        bank = data[2] & 0x1f
        addr = data[0] + data[1] * 0x100
        if addr >= 0x4000:
            addr += (bank - 1) * 0x4000
        if addr in syms:
            func = syms[addr]
        else:
            func = f"Func_{addr:0x}"
        return (3, f"{func}")

    def parse_local_addr(self, data):
        addr = data[0] + data[1] * 0x100
        self.jump_addresses.add(addr)
        return (2, f"<{addr}>")

    def parse_far_addr(self, data):
        addr = data[0] + data[1] * 0x100
        bank = data[2]
        offs = (bank - 1) * 0x4000 + addr
        return (3, f"Script_{offs:0x}")

    def parse_call_addr(self, data):
        addr = data[0] + data[1] * 0x100
        offs = addr if addr < 0x4000 else (self.cur_bank - 1) * 0x4000 + addr
        return (2, f"Script_{offs:0x}")

    def parse_farcall_addr(self, data):
        addr = data[0] + data[1] * 0x100
        bank = data[2]
        offs = addr if addr < 0x4000 else (bank - 1) * 0x4000 + addr
        return (3, f"Script_{offs:0x}")

    def parse_var_jumptable(self, data):
        n_entries = data[0]
        table = ""
        for i in range(n_entries):
            addr = data[2*i + 1] + data[2*i + 2] * 0x100
            self.jump_addresses.add(addr)
            table += f"\n\tdw <{addr}>"
        return (1 + n_entries * 2, f"{n_entries}{table}")

    def parse(self, offset):
        cmds = [
            ("script_end", []), # SCRIPT_END_CMD
            ("set_frame", [self.parse_uint8]), # SET_FRAME_CMD
            ("unk02_cmd", None), # UNK02_CMD
            ("unk03_cmd", [self.parse_unk03]), # UNK03_CMD
            ("set_oam", [self.parse_oam]), # SET_OAM_CMD
            ("wait", [self.parse_uint8]), # WAIT_CMD
            ("jump", [self.parse_local_addr]), # JUMP_CMD
            ("set_x_vel", [self.parse_vel]), # SET_X_VEL_CMD
            ("set_y_vel", [self.parse_vel]), # SET_Y_VEL_CMD
            ("repeat", [self.parse_uint8]), # REPEAT_CMD
            ("repeat_end", []), # REPEAT_END_CMD
            ("script_call", [self.parse_call_addr]), # CALL_CMD
            ("script_ret", []), # RET_CMD
            ("exec_asm", [self.parse_asm_func]), # EXEC_ASM_CMD
            ("var_jumptable", [self.parse_var_jumptable]), # VAR_JUMPTABLE_CMD
            ("set_field", [self.parse_field, self.parse_byte]), # SET_FIELD_CMD
            ("set_var_to_field", [self.parse_field]), # SET_VAR_TO_FIELD_CMD
            ("jump_if_not_var", [self.parse_local_addr]), # JUMP_IF_NOT_VAR_CMD
            ("jump_if_var", [self.parse_local_addr]), # JUMP_IF_VAR_CMD
            ("unk13_cmd", None), # UNK13_CMD
            ("jump_if_var_lt", [self.parse_byte, self.parse_local_addr]), # JUMP_IF_VAR_LT_CMD
            ("wait_var", []), # WAIT_VAR_CMD
            ("script_stop", []), # SCRIPT_STOP_CMD
            ("set_draw_func", [self.parse_asm_func]), # SET_DRAW_FUNC_CMD
            ("stop_movement", []), # STOP_MOVEMENT_CMD
            ("set_frame_wait", [self.parse_uint8, self.parse_uint8]), # SET_FRAME_WAIT_CMD
            ("set_field_to_var", [self.parse_field]), # SET_FIELD_TO_VAR_CMD
            ("far_jump", [self.parse_far_addr]), # FAR_JUMP_CMD
            ("script_farcall", [self.parse_farcall_addr]), # FARCALL_CMD
            ("script_farret", []), # FARRET_CMD
            ("unk1e_cmd", None), # UNK1E_CMD
            ("unk1f_cmd", None), # UNK1F_CMD
            ("set_x", [self.parse_uint16]), # SET_X_CMD
            ("set_y", [self.parse_uint16]), # SET_Y_CMD
            ("unk22_cmd", [self.parse_word, self.parse_uint8]), # UNK22_CMD
            ("unk23_cmd", None), # UNK23_CMD
            ("play_sfx", [self.parse_sfx]), # PLAY_SFX_CMD
            ("unk25_cmd", None), # UNK25_CMD
            ("set_x_vel_dir", [self.parse_vel]), # SET_X_VEL_DIR_CMD
            ("unk27_cmd", None), # UNK27_CMD
            ("unk28_cmd", None), # UNK28_CMD
            ("unk29_cmd", None), # UNK29_CMD
            ("set_y_acc", [self.parse_acc]), # SET_Y_ACC_CMD
        ]

        compound_cmds = {
            "Func_f50": ("create_object", [self.parse_byte, self.parse_byte, self.parse_byte]),
            "Func_f77": ("exec_func_f77", [self.parse_byte]),
            "Func_f92": ("create_object_rel_1", [self.parse_byte, self.parse_int8, self.parse_int8]),
            "Func_faf": ("create_object_rel_2", [self.parse_byte, self.parse_int8, self.parse_int8]),
            "Func_1032": ("set_x_acc_dir", [self.parse_acc]),
            "Func_3c4f": ("set_copy_ability_icon", [self.parse_uint8]),
            "Func_35e0": ("exec_func_35e0", [self.parse_uint16, self.parse_uint16]),
            "Func_7b2b": ("set_frame_with_orientation", [self.parse_uint8, self.parse_uint8]),
        }
        self.cur_bank = int(offset / 0x4000)
        pos = offset
        strings = []

        def get_local_address(a):
            res = a if self.cur_bank == 0 else (a + 0x4000 * (self.cur_bank - 1))
            return f"{res:0x}"

        while True:
            this_pos = pos
            cmd = reader.get_rom_byte(pos)
            if cmd > len(cmds):
                print(f"Invalid command 0x{cmd:02x}")
                print(strings)
                raise Exception()

            cmd_str, cmd_funcs = cmds[cmd]
            pos += 1

            if cmd == EXEC_ASM_CMD:
                buf = reader.get_rom_bytes(pos, 2)
                addr = buf[0] + buf[1] * 0x100
                addr = addr if addr < 0x4000 else addr + (self.cur_bank - 1) * 0x4000
                if addr in syms and syms[addr] in compound_cmds:
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
                    data = reader.get_rom_bytes(pos, 0x40)
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

            if cmd in [SCRIPT_END_CMD, JUMP_CMD, SCRIPT_STOP_CMD, VAR_JUMPTABLE_CMD, FAR_JUMP_CMD, RET_CMD, FARRET_CMD]:
                if (pos % 0x4000) + 0x4000 not in self.jump_addresses:
                    break

        contains_jump_addr = False

        out_str = f"Script_{o}:\n"
        for offs, s in strings:
            if (offs % 0x4000) + 0x4000 in self.jump_addresses:
                contains_jump_addr = True
                out_str += ".script_{:0x}\n".format(offs)
            out_str += s + "\n"

        out_str += f"; 0x{pos:0x}"

        out_str = re.sub(r"\n\n\n", "\n\n", out_str)

        for a in self.jump_addresses:
            out_str = re.sub(f"<{a}>", ".script_{}".format(get_local_address(a)), out_str)

        # if only one local address in script, rename to .loop
        if len(self.jump_addresses) == 1 and contains_jump_addr:
            out_str = re.sub(r"\.script_.*", ".loop", out_str)

        return out_str

offset_set = {o for o in args.offsets}
offset_list = [o for o in offset_set]
offset_list = sorted(offset_list)

for o in offset_list:
    offset = int(o, 16)
    parser = Parser()
    print(parser.parse(offset))

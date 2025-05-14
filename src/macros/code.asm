MACRO lb ; r, hi, lo
	ld \1, (\2) << 8 + ((\3) & $ff)
ENDM

MACRO incc
	jr nc, :+
	inc \1
:
ENDM

MACRO farcall
IF _NARG == 2
	ld hl, \2
	ld a, \1
ELSE
	ld hl, \1
	ld a, BANK(\1)
ENDC
	call Farcall
ENDM

MACRO farcall_unsafe
	ld a, BANK(\1)
	ld hl, \1
	call UnsafeFarcall
ENDM

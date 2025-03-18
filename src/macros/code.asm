MACRO lb ; r, hi, lo
	ld \1, (\2) << 8 + ((\3) & $ff)
ENDM

MACRO incc
	jr nc, :+
	inc \1
:
ENDM

MACRO farcall
	ld hl, \1
	ld a, BANK(\1)
	call Farcall
ENDM

MACRO farcall_unsafe
	ld a, BANK(\1)
	ld hl, \1
	call UnsafeFarcall
ENDM

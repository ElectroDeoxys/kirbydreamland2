MACRO lb ; r, hi, lo
	ld \1, (\2) << 8 + ((\3) & $ff)
ENDM

MACRO farcall
	ld hl, \1
	ld a, BANK(\1)
	call Farcall
ENDM

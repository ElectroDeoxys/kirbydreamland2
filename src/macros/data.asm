MACRO bigdw ; big-endian word
	db HIGH(\1), LOW(\1)
ENDM

MACRO dbw
	db \1
	dw \2
ENDM

MACRO dwb
	dw \1
	db \2
ENDM

MACRO dba
	dbw BANK(\1), \1
ENDM

MACRO dab
	dwb \1, BANK(\1)
ENDM

MACRO dn ; nybbles
REPT _NARG / 2
	db ((\1) << 4) | (\2)
	shift 2
ENDR
ENDM

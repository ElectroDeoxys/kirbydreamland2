MACRO sgb_header
	db \1 | \2 ; sgb_command and length
ENDM

MACRO sgb_pal_trn
	sgb_header PAL_TRN_CMD, 1
REPT 15
	db $00
ENDR
ENDM

MACRO sgb_data_snd
ASSERT _NARG <= 2 + 11
	sgb_header DATA_SND_CMD, 1
	dw \1 ; SNES RAM address
	db \2 ; SNES RAM bank
SHIFT 2
DEF x = _NARG ; number of bytes to copy
	db x
REPT _NARG
	db \1
SHIFT
ENDR

; pad the rest with $00
REPT 11 - x
	db $00
ENDR
ENDM

MACRO sgb_mlt_req
	sgb_header MLT_REQ_CMD, 1
	db \1 ; MLT_REQ_* parameter
REPT 14
	db $00
ENDR
ENDM

MACRO sgb_pct_trn
	sgb_header PCT_TRN_CMD, 1
REPT 15
	db $00
ENDR
ENDM

MACRO sgb_attr_trn
	sgb_header ATTR_TRN_CMD, 1
REPT 15
	db $00
ENDR
ENDM

MACRO sgb_pal_pri
	sgb_header PAL_PRI_CMD, 1
	db \1 ; PAL_PRI_* parameter
REPT 14
	db $00
ENDR
ENDM

DEF SGB_PACKET_SIZE EQU 16 ; bytes

MACRO sgb_command
DEF \1_CMD EQU (const_value << 3)
	const \1
ENDM

; SGB command constants
	const_def
	sgb_command PAL01    ; $00 ($00)
	sgb_command PAL23    ; $01 ($08)
	sgb_command PAL03    ; $02 ($10)
	sgb_command PAL12    ; $03 ($18)
	sgb_command ATTR_BLK ; $04 ($20)
	sgb_command ATTR_LIN ; $05 ($28)
	sgb_command ATTR_DIV ; $06 ($30)
	sgb_command ATTR_CHR ; $07 ($38)
	sgb_command SGBSOUND ; $08 ($40)
	sgb_command SOU_TRN  ; $09 ($48)
	sgb_command PAL_SET  ; $0a ($50)
	sgb_command PAL_TRN  ; $0b ($58)
	sgb_command ATRC_EN  ; $0c ($60)
	sgb_command TEST_EN  ; $0d ($68)
	sgb_command ICON_EN  ; $0e ($70)
	sgb_command DATA_SND ; $0f ($78)
	sgb_command DATA_TRN ; $10 ($80)
	sgb_command MLT_REQ  ; $11 ($88)
	sgb_command SGB_JUMP ; $12 ($90)
	sgb_command CHR_TRN  ; $13 ($98)
	sgb_command PCT_TRN  ; $14 ($a0)
	sgb_command ATTR_TRN ; $15 ($a8)
	sgb_command ATTR_SET ; $16 ($b0)
	sgb_command MASK_EN  ; $17 ($b8)
	sgb_command OBJ_TRN  ; $18 ($c0)
	sgb_command PAL_PRI  ; $19 ($c8)

; parameters for SGBSOUND

DEF SGBSOUNDA_SWORD_SWING    EQU $1f
DEF SGBSOUNDA_PIC_FLOATS     EQU $26
DEF SGBSOUNDA_SMALL_LASER    EQU $30

DEF SGBSOUNDB_APPLAUSE_SMALL EQU $01
DEF SGBSOUNDB_WIND           EQU $04
DEF SGBSOUNDB_THUNDERSTORM   EQU $07
DEF SGBSOUNDB_LIGHTNING      EQU $08
DEF SGBSOUNDB_WAVE           EQU $0b
DEF SGBSOUNDB_STOP           EQU $80

	const_def
	const SGB_SFX_STOP         ; $0
	const SGB_SFX_LASER        ; $1
	const SGB_SFX_PIC_FLOATS   ; $2
	const SGB_SFX_SWORD_SWING  ; $3
	const SGB_SFX_WIND_HIGH    ; $4
	const SGB_SFX_WAVE         ; $5
	const SGB_SFX_APPLAUSE     ; $6
	const SGB_SFX_WIND_LOW     ; $7
	const SGB_SFX_THUNDERSTORM ; $8
	const SGB_SFX_LIGHTNING    ; $9
DEF NUM_SGB_SFX EQU const_value

; parameters for MLT_REQ
	const_def
	const MLT_REQ_1P ; $0
	const MLT_REQ_2P ; $1
	const_skip
	const MLT_REQ_4P ; $3

; parameters for MASK_EN
	const_def
	const MASK_EN_CANCEL       ; $0
	const MASK_EN_FREEZE       ; $1
	const MASK_EN_BLANK_BLACK  ; $2
	const MASK_EN_BLANK_COLOR0 ; $3

; parameters for PAL_PRI
	const_def
	const PAL_PRI_DISABLE ; $0
	const PAL_PRI_ENABLE  ; $1

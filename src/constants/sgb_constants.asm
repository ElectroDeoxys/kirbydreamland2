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

; palette groups
; each of these represent 4 consecutive palettes in SGB WRAM
	const_def
	const SGB_PALS_00 ; $00
	const SGB_PALS_01 ; $01
	const SGB_PALS_02 ; $02
	const SGB_PALS_03 ; $03
	const SGB_PALS_04 ; $04
	const SGB_PALS_05 ; $05
	const SGB_PALS_06 ; $06
	const SGB_PALS_07 ; $07
	const SGB_PALS_08 ; $08
	const SGB_PALS_09 ; $09
	const SGB_PALS_0A ; $0a
	const SGB_PALS_0B ; $0b
	const SGB_PALS_0C ; $0c
	const SGB_PALS_0D ; $0d
	const SGB_PALS_0E ; $0e
	const SGB_PALS_0F ; $0f
	const SGB_PALS_10 ; $10
	const SGB_PALS_11 ; $11
	const SGB_PALS_12 ; $12
	const SGB_PALS_13 ; $13
	const SGB_PALS_14 ; $14
	const SGB_PALS_15 ; $15
	const SGB_PALS_16 ; $16
	const SGB_PALS_17 ; $17
	const SGB_PALS_18 ; $18
	const SGB_PALS_19 ; $19
	const SGB_PALS_1A ; $1a
	const SGB_PALS_1B ; $1b
	const SGB_PALS_1C ; $1c
	const SGB_PALS_1D ; $1d
	const SGB_PALS_1E ; $1e
	const SGB_PALS_1F ; $1f
	const SGB_PALS_20 ; $20
	const SGB_PALS_21 ; $21
	const SGB_PALS_22 ; $22
	const SGB_PALS_23 ; $23
	const SGB_PALS_24 ; $24
	const SGB_PALS_25 ; $25
	const SGB_PALS_26 ; $26
	const SGB_PALS_27 ; $27
	const SGB_PALS_28 ; $28
	const SGB_PALS_29 ; $29
	const SGB_PALS_2A ; $2a
	const SGB_PALS_2B ; $2b
	const SGB_PALS_2C ; $2c
	const SGB_PALS_2D ; $2d
	const SGB_PALS_2E ; $2e
	const SGB_PALS_2F ; $2f
	const SGB_PALS_30 ; $30
	const SGB_PALS_31 ; $31
	const SGB_PALS_32 ; $32
	const SGB_PALS_33 ; $33
	const SGB_PALS_34 ; $34
	const SGB_PALS_35 ; $35
	const SGB_PALS_36 ; $36
	const SGB_PALS_37 ; $37
	const SGB_PALS_38 ; $38
	const SGB_PALS_39 ; $39
	const SGB_PALS_3A ; $3A
	const SGB_PALS_3B ; $3B
	const SGB_PALS_3C ; $3C
	const SGB_PALS_3D ; $3D
	const SGB_PALS_3E ; $3E
	const SGB_PALS_3F ; $3F
	const SGB_PALS_40 ; $40
	const SGB_PALS_41 ; $41
	const SGB_PALS_42 ; $42
	const SGB_PALS_43 ; $43
	const SGB_PALS_44 ; $44
	const SGB_PALS_45 ; $45
	const SGB_PALS_46 ; $46
	const SGB_PALS_47 ; $47
	const SGB_PALS_48 ; $48
	const SGB_PALS_49 ; $49
	const SGB_PALS_4A ; $4a
	const SGB_PALS_4B ; $4b
	const SGB_PALS_4C ; $4c
	const SGB_PALS_4D ; $4d
	const SGB_PALS_4E ; $4e
	const SGB_PALS_4F ; $4f
	const SGB_PALS_50 ; $50
	const SGB_PALS_51 ; $51
	const SGB_PALS_52 ; $52
	const SGB_PALS_53 ; $53
	const SGB_PALS_54 ; $54
	const SGB_PALS_55 ; $55
	const SGB_PALS_56 ; $56
	const SGB_PALS_57 ; $57
	const SGB_PALS_58 ; $58
	const SGB_PALS_59 ; $59
	const SGB_PALS_5A ; $5a
	const SGB_PALS_5B ; $5b
	const SGB_PALS_5C ; $5c
	const SGB_PALS_5D ; $5d
	const SGB_PALS_5E ; $5e
	const SGB_PALS_5F ; $5f
	const SGB_PALS_60 ; $60
	const SGB_PALS_61 ; $61
	const SGB_PALS_62 ; $62
	const SGB_PALS_63 ; $63
	const SGB_PALS_64 ; $64
	const SGB_PALS_65 ; $65
	const SGB_PALS_66 ; $66
	const SGB_PALS_67 ; $67
	const SGB_PALS_68 ; $68
	const SGB_PALS_69 ; $69
	const SGB_PALS_6A ; $6a
	const SGB_PALS_6B ; $6b
	const SGB_PALS_6C ; $6c
	const SGB_PALS_6D ; $6d
	const SGB_PALS_6E ; $6e
	const SGB_PALS_6F ; $6f
	const SGB_PALS_70 ; $70
	const SGB_PALS_71 ; $71
	const SGB_PALS_72 ; $72
	const SGB_PALS_73 ; $73
	const SGB_PALS_74 ; $74
	const SGB_PALS_75 ; $75
	const SGB_PALS_76 ; $76
	const SGB_PALS_77 ; $77
	const SGB_PALS_78 ; $78
	const SGB_PALS_79 ; $79
	const SGB_PALS_7A ; $7a
	const SGB_PALS_7B ; $7b
	const SGB_PALS_7C ; $7c
	const SGB_PALS_7D ; $7d
	const SGB_PALS_7E ; $7e
	const SGB_PALS_7F ; $7f

; each of these represent a sequence of SGB_PALS_* constants
; to be used in fade in or fade out
	const_def
	const SGB_PALSEQUENCE_00 ; $00
	const SGB_PALSEQUENCE_01 ; $01
	const SGB_PALSEQUENCE_02 ; $02
	const SGB_PALSEQUENCE_03 ; $03
	const SGB_PALSEQUENCE_04 ; $04
	const SGB_PALSEQUENCE_05 ; $05
	const SGB_PALSEQUENCE_06 ; $06
	const SGB_PALSEQUENCE_07 ; $07
	const SGB_PALSEQUENCE_08 ; $08
	const SGB_PALSEQUENCE_09 ; $09
	const SGB_PALSEQUENCE_0A ; $0a
	const SGB_PALSEQUENCE_0B ; $0b
	const SGB_PALSEQUENCE_0C ; $0c
	const SGB_PALSEQUENCE_0D ; $0d
	const SGB_PALSEQUENCE_0E ; $0e
	const SGB_PALSEQUENCE_0F ; $0f
	const SGB_PALSEQUENCE_10 ; $10
	const SGB_PALSEQUENCE_11 ; $11
	const SGB_PALSEQUENCE_12 ; $12
	const SGB_PALSEQUENCE_13 ; $13
	const SGB_PALSEQUENCE_14 ; $14
	const SGB_PALSEQUENCE_15 ; $15
	const SGB_PALSEQUENCE_16 ; $16
	const SGB_PALSEQUENCE_17 ; $17
	const SGB_PALSEQUENCE_18 ; $18
	const SGB_PALSEQUENCE_19 ; $19
	const SGB_PALSEQUENCE_1A ; $1a
DEF SGB_LEVEL_PALSEQUENCES EQU const_value
	const SGB_PALSEQUENCE_GRASS_LAND   ; $1b
	const SGB_PALSEQUENCE_BIG_FOREST   ; $1c
	const SGB_PALSEQUENCE_RIPPLE_FIELD ; $1d
	const SGB_PALSEQUENCE_ICEBERG      ; $1e
	const SGB_PALSEQUENCE_RED_CANYON   ; $1f
	const SGB_PALSEQUENCE_CLOUDY_PARK  ; $20
	const SGB_PALSEQUENCE_DARK_CASTLE  ; $21
DEF NUM_SGB_PALSEQUENCES EQU const_value

; SGB ATF constants
	const_def
	const SGB_ATF_00 ; $00
	const SGB_ATF_01 ; $01
	const SGB_ATF_02 ; $02
	const SGB_ATF_03 ; $03
	const SGB_ATF_04 ; $04
	const SGB_ATF_05 ; $05
	const SGB_ATF_06 ; $06
	const SGB_ATF_07 ; $07
	const SGB_ATF_08 ; $08
	const SGB_ATF_09 ; $09
	const SGB_ATF_0A ; $0a
	const SGB_ATF_0B ; $0b
	const SGB_ATF_0C ; $0c
	const SGB_ATF_0D ; $0d
	const SGB_ATF_0E ; $0e
	const SGB_ATF_0F ; $0f
	const SGB_ATF_10 ; $10
	const SGB_ATF_11 ; $11
	const SGB_ATF_12 ; $12
	const SGB_ATF_13 ; $13
	const SGB_ATF_14 ; $14
	const SGB_ATF_15 ; $15
	const SGB_ATF_16 ; $16
	const SGB_ATF_17 ; $17
	const SGB_ATF_18 ; $18
	const SGB_ATF_19 ; $19
	const SGB_ATF_1A ; $1a
	const SGB_ATF_1B ; $1b
	const SGB_ATF_1C ; $1c
	const SGB_ATF_1D ; $1d
	const SGB_ATF_1E ; $1e
	const SGB_ATF_1F ; $1f
	const SGB_ATF_20 ; $20
	const SGB_ATF_21 ; $21
	const SGB_ATF_22 ; $22
	const SGB_ATF_23 ; $23
	const SGB_ATF_24 ; $24
	const SGB_ATF_25 ; $25
	const SGB_ATF_26 ; $26
	const SGB_ATF_27 ; $27
	const SGB_ATF_28 ; $28
	const SGB_ATF_29 ; $29
	const SGB_ATF_2A ; $2a
	const SGB_ATF_2B ; $2b
	const SGB_ATF_2C ; $2c
	const SGB_ATF_2D ; $2d
	const SGB_ATF_2E ; $2e
	const SGB_ATF_2F ; $2f
	const SGB_ATF_30 ; $30
	const SGB_ATF_31 ; $31
	const SGB_ATF_32 ; $32
	const SGB_ATF_33 ; $33
	const SGB_ATF_34 ; $34
	const SGB_ATF_35 ; $35

Func_20000::
	ld a, HIGH(sObjects)
	ld [wda48], a
	xor a
	ld [wda46], a
	ld [wda47], a
	ld hl, sb200Unk01
	ld [hl], a
	dec h
	; hl = sb101
	ld b, $12
	ld a, HIGH(sb200)
.asm_20015
	ld [hl], a
	dec h
	dec a
	dec b
	jr nz, .asm_20015

	ld a, $ff
	ld b, $13
	ld hl, sa000
.asm_20022
	ld [hl], a
	inc h
	dec b
	jr nz, .asm_20022
	ret
; 0x20028

SECTION "Func_20057", ROMX[$4057], BANK[$8]

Func_20057:
	xor a
	ld b, $2f
	ld hl, sa000Unk50
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

_GameLoop::
	; handle intial SGB configuration
	farcall DetectSGB
	farcall InitSGB

	; reset Demo
	xor a
	ld [wNextDemo], a

	; play starting intro
	farcall StartIntro

.title_screen
	farcall TitleScreen

	ld a, [wNextDemo]
	or a
	jp nz, $43f3 ; Func_203f3

	farcall FileSelectMenu

	ld a, [wdf0a]
	cp $ff
	jr z, .title_screen
	cp $03
	jr c, .asm_200ab
	cp $04
	jp c, $43e8 ; Func_203e8
	jp z, $432c ; Func_2032c
	jp $438c ; Func_2038c

.asm_200ab
	call Func_2049b
	ld hl, wdb39
	ld [hl], $00

	ld e, SGB_SFX_WIND_LOW
	farcall SGBPlaySFX

	farcall Func_32ff

	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX

	call Func_206ef
	cp $ff
	jr z, .asm_200e8
	cp $07
	jr nc, .asm_200e8
	ld e, a
	farcall Func_2a2b

	ld a, $01
	ld [wdb38], a
.asm_200e8
	farcall Func_10e6
	farcall Func_1166

	ld a, [wLevel]
	ld hl, PtrTable_20278
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
Func_20107:
	call LoadLevel
	farcall LevelLoop

	ld a, [sa000Unk82]
	dec a
	ld hl, .PointerTable
	add a
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.PointerTable:
	dw Func_20135 ; $1
	dw Func_201a4 ; $2
	dw $423b ; $3
	dw $4286 ; $4
	dw $42be ; $5
	dw $4306 ; $6
	dw $431e ; $7
	dw $4363 ; $8
	dw $4487 ; $9

Func_20135:
	ld a, [wdb61]
	ld [wdb6d], a
	cp $08
	jr nz, .asm_20149
	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX
.asm_20149
	farcall Func_1220
	ld a, [hl]
	cp $20
	jp nc, Func_20107
	cp $01
	jp nz, Func_20107
	ld a, $ff
	ld [wdb57], a
	farcall Func_3212
	farcall Func_10e6
	farcall Func_1166
	ld a, [wdb61]
	ld e, a
	ld a, [wLevel]
	call Func_162a
	or a
	jr nz, .asm_2018d
	ld a, $01
	ld [wdb3a], a
	jr .asm_20195
.asm_2018d
	farcall WriteSaveData
.asm_20195
	xor a
	ld [wdb6e], a
	farcall Func_20851
	jp Func_20107

Func_201a4:
	ld e, $04
	farcall Func_68280
	call Func_437
	ld a, [wdf0a]
	cp $04
	jp z, _GameLoop.title_screen
	call Func_206cb
	ld a, [sa000Unk84]
	or a
	jr z, .asm_201fb
	dec a
	daa
	ld [sa000Unk84], a
	farcall WriteSaveData
	ld hl, wHUDUpdateFlags
	set UPDATE_LIVES_F, [hl]
	farcall Func_1166

	ld e, $01
	farcall Func_1c59c
	ld e, $02
	farcall Func_1c59c

	ld a, [wdb36 + 0]
	ld l, a
	ld a, [wdb36 + 1]
	ld h, a
	jp Func_20107

.asm_201fb
	ld a, $02
	ld [sa000Unk84], a
	farcall Func_1da7c
	farcall WriteSaveData
	farcall Func_2a29
	ld a, [wda2c]
	cp $01
	jp z, _GameLoop.title_screen
	farcall Func_10e6
	farcall Func_1166
	farcall Func_20851
	jp Func_20107
; 0x2023b

SECTION "PtrTable_20278", ROMX[$4278], BANK[$8]

PtrTable_20278:
	table_width 2
	dw Data_20881 ; GRASS_LAND
	dw Data_2090a ; BIG_FOREST
	dw Data_20994 ; RIPPLE_FIELD
	dw Data_20a55 ; ICEBERG
	dw Data_20b2e ; RED_CANYON
	dw Data_20c90 ; CLOUDY_PARK
	dw Data_20e12 ; DARK_CASTLE
	assert_table_length NUM_LEVELS
; 0x20286

SECTION "Func_2049b", ROMX[$449b], BANK[$8]

Func_2049b:
	farcall Func_1da7c

	ld a, $86
	ld [sa000Unk83], a
	call Func_206cb

	xor a
	ld [wdb7b], a
	ld [wdb6e], a

	ld hl, wdbd0
	ld bc, $12c
	ld a, $00
	call FillHL

	ld a, LOW(wdbd0)
	ld [wdcfd + 0], a
	ld a, HIGH(wdbd0)
	ld [wdcfd + 1], a
	farcall ReadSaveData
	ret

; input:
; - hl = ?
LoadLevel:
	push hl
	xor a
	ld [sa000Unk7e], a
	ld [wdb73], a
	ld [wdb74], a
	ld [wdb75], a
	ld [wdb76], a
	ld [wdb77], a
	ld hl, sa000Unk77
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld hl, wdb78
	ld a, $e4
	ld [hli], a
	ld a, $d0
	ld [hli], a
	ld a, $e4
	ld [hli], a
	farcall Func_20000
	pop hl

	ld a, l
	ld [wdb36 + 0], a
	ld a, h
	ld [wdb36 + 1], a
.loop_cmds
	ld a, [hl]
	and LOAD_CMD_MASK
	cp LOAD_SET_LEVEL_CMD
	jp z, .set_level
	cp LOAD_UNK40_CMD
	jp z, .asm_20650
	cp $80
	jp z, .asm_20694
	cp $60
	jr nz, .asm_20521
	inc hl
	jr .loop_cmds
.asm_20521
	ld a, [wdb3a]
	or a
	jr z, .asm_20532
	xor a
	ld [wdb3a], a
	ld a, [hli]
	and $0f
	add $03
	jr .asm_20565
.asm_20532
	ld a, [wda2c]
	cp $02
	jr nz, .asm_20542
	xor a
	ld [wda2c], a
	inc hl
	ld a, $00
	jr .asm_20565
.asm_20542
	ld a, [wLevel]
	cp DARK_CASTLE
	jr nc, .asm_20562
	ld a, [wdb61]
	cp $09
	jr nz, .asm_20562
	push hl
	ld a, [wLevel]
	call GetPowerOfTwo
	pop hl
	ld e, a
	ld a, [wdb6a]
	and e
	jr z, .asm_20562
	ld [wdb73], a
.asm_20562
	ld a, [hli]
	and LOAD_ARG_MASK
.asm_20565
	ld [sa000Unk7f], a
	ld a, [hli]
	ld [wdb57], a
	ld a, [hli]
	ld c, a
	rla
	sbc a
	scf
	rl c
	rla
	sla c
	rla
	sla c
	rla
	sla c
	rla
	ld b, a ; *16
	ld a, [hli]
	ld e, a
	rla
	sbc a
	scf
	rl e
	rla
	sla e
	rla
	sla e
	rla
	sla e
	rla
	ld d, a ; *16
	inc de
	ld a, UNK_OBJ_00
	lb hl, HIGH(sObjectGroup1), HIGH(sObjectGroup1End)
	call CreateObject
	ld a, $08
	ld [sa000Unk0b], a
	ld [sa000Unk09], a

	farcall Func_1286
	farcall Func_2073a
	farcall Func_1c1dc
	farcall Func_1c584
	farcall Func_1c3a0

	ld a, [sa000Unk7f]
	cp $02
	jr nz, .asm_205e0
	ld a, BANK(Gfx_42211)
	ld hl, Gfx_42211
	ld de, vTiles0 tile $10
	ld bc, $36 tiles
	call FarCopyHLToDE
	jr .asm_205f4
.asm_205e0
	cp $05
	jr nz, .asm_205f4
	ld a, $0b
	ld hl, $6980
	ld de, vTiles0
	call FarDecompress
	ld a, $01
	ld [wdb74], a
.asm_205f4
	farcall Func_1c105
	farcall Func_1c128
	farcall Func_1c0e2

	ld hl, wdb78
	ld de, wcd09
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	call Func_3131

	ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d
	ld hl, wdedf
	res 0, [hl]
	ld a, [wLevel]
	cp RIPPLE_FIELD
	jr nz, .asm_2063c
	ld a, [wdb61]
	cp $09
	jr nz, .asm_2063c
	ld a, $01
	ld [wdb75], a
.asm_2063c
	ld e, $04
	farcall Func_6824e
	ret

.set_level
	ld a, [hli]
	and LOAD_ARG_MASK
	ld [wLevel], a
	jp .loop_cmds

.asm_20650
	ld a, [hli]
	and LOAD_ARG_MASK
	ld [wdb61], a
	push hl
	cp $08
	jr nc, .asm_20690
	ld e, $01
	farcall Func_1c59c
	ld e, $02
	farcall Func_1c59c
	ld a, [wdb3b]
	ld b, a
	ld a, [wLevel]
	cp b
	jr z, .asm_20690
	ld [wdb3b], a
	ld e, $00
	farcall Func_1c59c
	ld e, $03
	farcall Func_1c59c
.asm_20690
	pop hl
	jp .loop_cmds

.asm_20694
	ld a, [hli]
	push hl
	and $1f
	cp $04
	jr z, .asm_206b8
	ld bc, $80
	ld hl, sa000Unk77
	cp $02
	jr c, .asm_206ae
	ld bc, hff80
	jr z, .asm_206ae
	ld hl, sa000Unk79
.asm_206ae
	ld [hl], c
	inc hl
	ld [hl], b
	ld [wdb77], a
	pop hl
	jp .loop_cmds

.asm_206b8
	ld a, $01
	ld [wdb76], a
	ld a, $fa
	ld hl, wdb78
	ld [hli], a
	ld a, $f8
	ld [hli], a
	ld [hl], a
	pop hl
	jp .loop_cmds

Func_206cb:
	farcall Func_20057
	ld hl, wdedf
	res 1, [hl]
	ld a, $0c
	ld [sa000Unk4c], a
	ld a, $06
	ld [sa000Unk72], a
	xor a
	ld [wdee3], a
	ld [wdee5], a
	ld a, $ff
	ld [sa000Unk5b], a
	ret

; output:
; - a = ?
Func_206ef:
	ld hl, wLevel
	ld a, [hl]
	ld b, $01
	and a
.asm_206f6
	jr z, .asm_206fd
	sla b
	dec a
	jr .asm_206f6

.asm_206fd
	ld hl, wdb39
	ld a, [hl]
	and b
	jr nz, .asm_2070b
	ld a, [hl]
	or b
	ld [hl], a
	ld a, [wLevel]
	ret
.asm_2070b
	ld a, $ff
	ret
; 0x2070e

SECTION "Script_2073a", ROMX[$473a], BANK[$8]

Func_2073a:
	ld a, [wdb61]
	cp $08
	ret nz
	ld a, [wLevel]
	ld hl, $47c0
	add a
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
.asm_2074f
	ld a, [hli]
	cp $ff
	ret z
	ld c, a
	ld a, [hli]
	ld e, a
	push bc
	push de
.asm_20758
	ld a, [hl]
	and $e0
	cp $40
	jr z, .asm_2076b
	inc hl
	jr .asm_20758
.asm_20762
	pop hl
	pop de
	pop bc
.asm_20765
	inc hl
	inc hl
	inc hl
	inc hl
	jr .asm_2074f
.asm_2076b
	ld a, [hli]
	push hl
	and $1f
	cp $09
	ld e, a
	ld a, [wLevel]
	jr z, .asm_20784
	inc e
	dec e
	jr z, .asm_20762
	dec e
	call Func_162a
	or a
	jr nz, .asm_20762
	jr .asm_2079c
.asm_20784
	call Func_1611
	or a
	jr nz, .asm_2079c
	ld a, [wdb3c]
	or a
	jr nz, .asm_20762
	ld a, [wLevel]
	call GetPowerOfTwo
	ld hl, wdb6e
	and [hl]
	jr z, .asm_20762
.asm_2079c
	pop hl
	pop de
	pop bc
	push hl
	swap c
	ld a, c
	and $0f
	ld b, a
	swap e
	ld a, e
	and $0f
	ld d, a
	call Func_15e3
	inc [hl]
	swap e
	dec e
	swap e
	ld a, e
	and $0f
	ld d, a
	call Func_15e3
	inc [hl]
	pop hl
	jr .asm_20765
; 0x207c0

SECTION "Data_20851", ROMX[$4851], BANK[$8]

Func_20851:
	ld a, [wLevel]
	ld hl, .data
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wdb61]
	inc a
	cp $09
	jr c, .asm_20869
	xor a
.asm_20869
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

.data
	table_width 2
	dw $48ee ; GRASS_LAND
	dw $4978 ; BIG_FOREST
	dw $4a39 ; RIPPLE_FIELD
	dw $4b0b ; ICEBERG
	dw $4c66 ; RED_CANYON
	dw $4de1 ; CLOUDY_PARK
	dw $50ac ; DARK_CASTLE
	assert_table_length NUM_LEVELS

Data_20881:
	ld_set_level GRASS_LAND
	ld_unk40 $08
	ld_start_level $02, $0b, 32, -48
; 0x20887

SECTION "Data_2090a", ROMX[$490a], BANK[$8]

Data_2090a:
	ld_set_level BIG_FOREST
	ld_unk40 $08
	ld_start_level $02, $18, 32, -48
; 0x20910

SECTION "Data_20994", ROMX[$4994], BANK[$8]

Data_20994:
	ld_set_level RIPPLE_FIELD
	ld_unk40 $08
	ld_start_level $02, $28, 0, -32
; 0x2099a

SECTION "Data_20a55", ROMX[$4a55], BANK[$8]

Data_20a55:
	ld_set_level ICEBERG
	ld_unk40 $08
	ld_start_level $02, $3c, 16, -48
; 0x20a5b

SECTION "Data_20b2e", ROMX[$4b2e], BANK[$8]

Data_20b2e:
	ld_set_level RED_CANYON
	ld_unk40 $08
	ld_start_level $02, $5b, 48, -32
; 0x20b34

SECTION "Data_20c90", ROMX[$4c90], BANK[$8]

Data_20c90:
	ld_set_level CLOUDY_PARK
	ld_unk40 $08
	ld_start_level $02, $80, 16, -32
; 0x20c94

SECTION "Data_20e12", ROMX[$4e12], BANK[$8]

Data_20e12:
	ld_set_level DARK_CASTLE
	ld_unk40 $08
	ld_start_level $02, $b1, 16, -48
; 0x20e18

SECTION "Script_2111d", ROMX[$511d], BANK[$8]

PtrTable_2111d::
	dwb $44b2, $11 ; $00
	dwb $455d, $11 ; $01
	dwb $4751, $11 ; $02
	dwb $495b, $11 ; $03
	dwb $49f5, $11 ; $04
	dwb $4b93, $11 ; $05
	dwb $4d0e, $11 ; $06
	dwb $4d85, $11 ; $07
	dwb $4f45, $11 ; $08
	dwb $5077, $11 ; $09
	dwb $51a8, $11 ; $0a
	dab Data_4537a ; $0b
	dwb $54a5, $11 ; $0c
	dwb $5564, $11 ; $0d
	dwb $5738, $11 ; $0e
	dwb $57e6, $11 ; $0f
	dwb $5a53, $11 ; $10
	dwb $5cfc, $11 ; $11
	dwb $5ede, $11 ; $12
	dwb $5f9e, $11 ; $13
	dwb $612c, $11 ; $14
	dwb $6282, $11 ; $15
	dwb $6334, $11 ; $16
	dwb $6597, $11 ; $17
	dwb $67e0, $11 ; $18
	dwb $692d, $11 ; $19
	dwb $6ada, $11 ; $1a
	dwb $6e97, $11 ; $1b
	dwb $70a4, $11 ; $1c
	dwb $7167, $11 ; $1d
	dwb $72e2, $11 ; $1e
	dwb $7512, $11 ; $1f
	dwb $75af, $11 ; $20
	dwb $7764, $11 ; $21
	dwb $7887, $11 ; $22
	dwb $794d, $11 ; $23
	dwb $7c91, $11 ; $24
	dwb $4101, $12 ; $25
	dwb $4412, $12 ; $26
	dwb $44bd, $12 ; $27
	dwb $45ab, $12 ; $28
	dwb $46b9, $12 ; $29
	dwb $472b, $12 ; $2a
	dwb $48eb, $12 ; $2b
	dwb $498c, $12 ; $2c
	dwb $4b9e, $12 ; $2d
	dwb $4c56, $12 ; $2e
	dwb $4f49, $12 ; $2f
	dwb $50c0, $12 ; $30
	dwb $5195, $12 ; $31
	dwb $534a, $12 ; $32
	dwb $550f, $12 ; $33
	dwb $55dd, $12 ; $34
	dwb $581c, $12 ; $35
	dwb $58fd, $12 ; $36
	dwb $5c70, $12 ; $37
	dwb $5e68, $12 ; $38
	dwb $5f4d, $12 ; $39
	dwb $6184, $12 ; $3a
	dwb $64bd, $12 ; $3b
	dwb $6575, $12 ; $3c
	dwb $6688, $12 ; $3d
	dwb $67a8, $12 ; $3e
	dwb $6952, $12 ; $3f
	dwb $6a28, $12 ; $40
	dwb $6ef9, $12 ; $41
	dwb $70a0, $12 ; $42
	dwb $7143, $12 ; $43
	dwb $7375, $12 ; $44
	dwb $7436, $12 ; $45
	dwb $7656, $12 ; $46
	dwb $7722, $12 ; $47
	dwb $79a2, $12 ; $48
	dwb $7c31, $12 ; $49
	dwb $7dfa, $12 ; $4a
	dwb $7e5d, $12 ; $4b
	dwb $7ee7, $12 ; $4c
	dwb $7f52, $12 ; $4d
	dwb $4000, $13 ; $4e
	dwb $40b3, $13 ; $4f
	dwb $4407, $13 ; $50
	dwb $4494, $13 ; $51
	dwb $4733, $13 ; $52
	dwb $49f5, $13 ; $53
	dwb $4ab5, $13 ; $54
	dwb $4d04, $13 ; $55
	dwb $508b, $13 ; $56
	dwb $5319, $13 ; $57
	dwb $53fa, $13 ; $58
	dwb $549b, $13 ; $59
	dwb $5530, $13 ; $5a
	dwb $5647, $13 ; $5b
	dwb $57a9, $13 ; $5c
	dwb $5887, $13 ; $5d
	dwb $5b17, $13 ; $5e
	dwb $5e64, $13 ; $5f
	dwb $5f71, $13 ; $60
	dwb $6229, $13 ; $61
	dwb $6402, $13 ; $62
	dwb $68c8, $13 ; $63
	dwb $69ba, $13 ; $64
	dwb $6a57, $13 ; $65
	dwb $6ac3, $13 ; $66
	dwb $6b30, $13 ; $67
	dwb $6ba5, $13 ; $68
	dwb $6c3d, $13 ; $69
	dwb $6d88, $13 ; $6a
	dwb $713c, $13 ; $6b
	dwb $75c4, $13 ; $6c
	dwb $7844, $13 ; $6d
	dwb $7ab2, $13 ; $6e
	dwb $7d7e, $13 ; $6f
	dwb $7e9e, $13 ; $70
	dwb $4000, $14 ; $71
	dwb $4324, $14 ; $72
	dwb $4401, $14 ; $73
	dwb $4954, $14 ; $74
	dwb $4b27, $14 ; $75
	dwb $4bc9, $14 ; $76
	dwb $4c52, $14 ; $77
	dwb $4cd7, $14 ; $78
	dwb $4d5c, $14 ; $79
	dwb $4ddf, $14 ; $7a
	dwb $4f5d, $14 ; $7b
	dwb $5472, $14 ; $7c
	dwb $579b, $14 ; $7d
	dwb $5849, $14 ; $7e
	dwb $5908, $14 ; $7f
	dwb $5b03, $14 ; $80
	dwb $5c38, $14 ; $81
	dwb $5cb6, $14 ; $82
	dwb $5f09, $14 ; $83
	dwb $60a3, $14 ; $84
	dwb $6150, $14 ; $85
	dwb $61ed, $14 ; $86
	dwb $63f7, $14 ; $87
	dwb $659d, $14 ; $88
	dwb $6644, $14 ; $89
	dwb $66a4, $14 ; $8a
	dwb $67c8, $14 ; $8b
	dwb $69a6, $14 ; $8c
	dwb $6a2e, $14 ; $8d
	dwb $6bb8, $14 ; $8e
	dwb $6d4f, $14 ; $8f
	dwb $6e05, $14 ; $90
	dwb $6e8a, $14 ; $91
	dwb $7081, $14 ; $92
	dwb $7223, $14 ; $93
	dwb $72ee, $14 ; $94
	dwb $73b8, $14 ; $95
	dwb $7418, $14 ; $96
	dwb $753c, $14 ; $97
	dwb $775a, $14 ; $98
	dwb $77da, $14 ; $99
	dwb $7940, $14 ; $9a
	dwb $7a2f, $14 ; $9b
	dwb $7ae5, $14 ; $9c
	dwb $7b9b, $14 ; $9d
	dwb $7c54, $14 ; $9e
	dwb $7d0d, $14 ; $9f
	dwb $7dc6, $14 ; $a0
	dwb $7e82, $14 ; $a1
	dwb $7f3e, $14 ; $a2
	dwb $4000, $15 ; $a3
	dwb $40bf, $15 ; $a4
	dwb $417e, $15 ; $a5
	dwb $4228, $15 ; $a6
	dwb $42b4, $15 ; $a7
	dwb $435c, $15 ; $a8
	dwb $459f, $15 ; $a9
	dwb $4612, $15 ; $aa
	dwb $4672, $15 ; $ab
	dwb $472d, $15 ; $ac
	dwb $47e3, $15 ; $ad
	dwb $48bf, $15 ; $ae
	dwb $4993, $15 ; $af
	dwb $4a46, $15 ; $b0
	dwb $4b26, $15 ; $b1
; 0x21333

SECTION "Script_218e7", ROMX[$58e7], BANK[$8]

Script_218e7:
	set_draw_func Func_df6
	set_oam $69fb, $7 ; OAM_1e9fb
	unk03_cmd Func_21a2c
	set_field OBJSTRUCT_UNK26, $20
	set_x 0
	set_y 109

	repeat 1
	set_frame 10
	set_x_vel 1.375
	set_y_vel -2.094
	set_y_acc 0.199
	wait 10
	set_frame 9
	wait 10
	set_frame 4
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	wait 6
	repeat_end

.loop
	set_frame 8
	wait 50
	set_frame 0
	wait 16
	set_x 28
	set_y 109

	repeat 5
	set_frame 1
	set_x_vel 0.75
	wait 6
	set_frame 2
	wait 6
	set_frame 3
	wait 6
	set_frame 2
	wait 6
	repeat_end

	set_frame 1
	wait 6
	set_frame 2
	wait 6
	set_frame 3
	wait 6
	set_frame 5
	set_x_vel 0.0
	wait 6
	set_frame 18
	wait 20
	set_frame 0
	wait 6
	set_frame 14
	wait 30

	repeat 5
	set_frame 11
	set_x_vel -0.75
	wait 6
	set_frame 12
	wait 6
	set_frame 13
	wait 6
	set_frame 12
	wait 6
	repeat_end

	set_frame 11
	wait 6
	set_frame 12
	wait 6
	set_frame 6
	wait 6
	set_frame 6
	set_x_vel 0.0
	wait 6
	set_frame 14
	wait 10

	repeat 2
	set_frame 0
	wait 6
	set_frame 14
	wait 6
	repeat_end

	set_frame 0
	set_x_vel 0.0
	wait 30

	repeat 5
	set_frame 1
	set_x_vel 0.75
	wait 6
	set_frame 2
	wait 6
	set_frame 3
	wait 6
	set_frame 2
	wait 6
	repeat_end

	set_frame 7
	wait 18
	set_frame 7
	set_x_vel 0.0
	wait 6
	set_frame 4
	wait 6
	set_frame 0
	wait 6
	set_frame 14
	wait 30

	repeat 4
	set_frame 16
	set_x_vel -0.75
	set_y_vel -1.0
	set_y_acc 0.094
	wait 10
	set_frame 15
	wait 10
	set_frame 17
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	wait 6
	repeat_end

	repeat 2
	set_frame 16
	set_x_vel -0.75
	set_y_vel -1.0
	set_y_acc 0.098
	wait 10
	set_frame 15
	wait 10
	set_frame 17
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	wait 6
	repeat_end

	set_frame 16
	set_x_vel -0.688
	set_y_vel -1.0
	set_y_acc 0.098
	wait 10
	set_frame 15
	wait 10
	set_frame 17
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	wait 6
	set_x 28
	set_y 109
	jump .loop

Func_21a2c:
	call ApplyObjectXAcceleration
	call ApplyObjectYAcceleration
	call ApplyObjectVelocities

	ld e, OBJSTRUCT_UNK26
	ld a, [de]
	or a
	jr z, .read_input
	dec a
	ld [de], a
	ret
.read_input
	ldh a, [hJoypad1Pressed]
	and A_BUTTON | B_BUTTON | START
	ret z ; no input

	ld e, SFX_2D
	farcall PlaySFX
	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX
	ld de, $4
	farcall Func_682a4

	ldh a, [hff9a]
	ld d, a
	ld e, BANK(Script_21a6d)
	ld bc, Script_21a6d
	jp Func_846

Script_21a6d:
	wait 16
	exec_asm Func_21a73
	script_stop

Func_21a73:
	ld a, $01
	ld [wdf02], a
	ret

Demo1Inputs:
	db NO_INPUT, 0
	db NO_INPUT, 49
	db D_RIGHT, 142
	db NO_INPUT, 8
	db B_BUTTON, 12
	db NO_INPUT, 34
	db D_RIGHT, 47
	db A_BUTTON | D_RIGHT, 16
	db D_RIGHT, 21
	db NO_INPUT, 32
	db B_BUTTON, 7
	db NO_INPUT, 33
	db D_RIGHT, 38
	db A_BUTTON | D_RIGHT, 16
	db D_RIGHT, 21
	db NO_INPUT, 28
	db B_BUTTON, 11
	db NO_INPUT, 63
	db B_BUTTON, 7
	db NO_INPUT, 17
	db D_RIGHT, 40
	db A_BUTTON | D_RIGHT, 12
	db D_RIGHT, 13
	db NO_INPUT, 1
	db B_BUTTON, 9
	db NO_INPUT, 37
	db B_BUTTON, 9
	db NO_INPUT, 26
	db D_RIGHT, 3
	db A_BUTTON | D_RIGHT, 8
	db D_RIGHT, 11
	db B_BUTTON | D_RIGHT, 8
	db D_RIGHT, 11
	db NO_INPUT, 36
	db A_BUTTON | D_RIGHT, 29
	db D_RIGHT, 8
	db NO_INPUT, 38
	db B_BUTTON, 7
	db NO_INPUT, 19
	db D_RIGHT, 14
	db NO_INPUT, 9
	db D_RIGHT, 2
	db NO_INPUT, 17
	db D_RIGHT, 22
	db A_BUTTON | D_RIGHT, 13
	db D_RIGHT, 10
	db NO_INPUT, 48
	db B_BUTTON, 18
	db NO_INPUT, 19
	db D_DOWN, 12
	db NO_INPUT, 68
	db D_RIGHT, 40
	db A_BUTTON | D_RIGHT, 10
	db D_RIGHT, 28
	db B_BUTTON | D_RIGHT, 36
	db D_RIGHT, 28
	db NO_INPUT, 22
	db A_BUTTON, 4
	db NO_INPUT, 12
	db B_BUTTON, 54
	db NO_INPUT, 44
	db D_RIGHT, 18
	db NO_INPUT, 11
	db D_UP, 17
	db NO_INPUT, 2
	db D_RIGHT, 19
	db A_BUTTON | D_RIGHT, 10
	db D_RIGHT, 18
	db NO_INPUT, 14
	db A_BUTTON, 7
	db NO_INPUT, 29
	db A_BUTTON, 2
	db A_BUTTON | D_RIGHT, 4
	db D_RIGHT, 19
	db NO_INPUT, 1
	db B_BUTTON, 35
	db NO_INPUT, 33
	db D_LEFT, 4
	db NO_INPUT, 1
	db B_BUTTON, 31
	db NO_INPUT, 19
	db D_RIGHT, 19
	db A_BUTTON | D_RIGHT, 9
	db D_RIGHT, 6
	db B_BUTTON | D_RIGHT, 2
	db B_BUTTON, 46
	db NO_INPUT, 43
	db D_LEFT, 22
	db A_BUTTON | D_LEFT, 9
	db D_LEFT, 31
	db NO_INPUT, 45
	db A_BUTTON, 2
	db A_BUTTON | D_LEFT, 5
	db D_LEFT, 7
	db NO_INPUT, 11
	db B_BUTTON, 45
	db NO_INPUT, 17
	db D_RIGHT, 4
	db NO_INPUT, 20
	db B_BUTTON, 33
	db NO_INPUT, 18
	db D_LEFT, 17
	db A_BUTTON | D_LEFT, 12
	db D_LEFT, 7
	db B_BUTTON | D_LEFT, 1
	db B_BUTTON, 43
	db NO_INPUT, 29
	db D_RIGHT, 29
	db A_BUTTON | D_RIGHT, 15
	db D_RIGHT, 22
	db NO_INPUT, 61
	db D_RIGHT, 5
	db B_BUTTON | D_RIGHT, 2
	db B_BUTTON, 43
	db NO_INPUT, 27
	db D_LEFT, 5
	db NO_INPUT, 2
	db B_BUTTON, 35
	db NO_INPUT, 16
	db D_RIGHT, 11
	db NO_INPUT, 17
	db D_RIGHT, 5
	db A_BUTTON | D_RIGHT, 13
	db D_RIGHT, 15
	db B_BUTTON | D_RIGHT, 3
	db B_BUTTON, 40
	db NO_INPUT, 29
	db D_LEFT, 25
	db NO_INPUT, 72
	db D_LEFT, 9
	db NO_INPUT, 22
	db D_LEFT, 12
	db NO_INPUT, 5
	db B_BUTTON, 45
	db NO_INPUT, 24
	db B_BUTTON | D_RIGHT, 11
	db B_BUTTON, 27
	db NO_INPUT, 19
	db D_LEFT, 9
	db NO_INPUT, 60
	db D_LEFT, 1
	db A_BUTTON | D_LEFT, 18
	db D_LEFT, 4
	db NO_INPUT, 3
	db B_BUTTON, 42
	db NO_INPUT, 57
	db D_RIGHT, 5
	db NO_INPUT, 52
	db B_BUTTON, 44
	db NO_INPUT, 135
	db D_LEFT, 2
	db NO_INPUT, 104
	db A_BUTTON, 6
	db A_BUTTON | D_LEFT, 14
	db D_LEFT, 4
	db NO_INPUT, 12
	db D_RIGHT, 6
	db NO_INPUT, 65
	db B_BUTTON, 83
	db NO_INPUT, 140
	db START, 1
	db $40
Demo1InputsEnd:

Demo2Inputs:
	db NO_INPUT, 0
	db NO_INPUT, 104
	db D_RIGHT, 63
	db NO_INPUT, 3
	db B_BUTTON, 65
	db NO_INPUT, 17
	db D_RIGHT, 52
	db B_BUTTON | D_RIGHT, 6
	db B_BUTTON, 27
	db NO_INPUT, 16
	db D_LEFT, 4
	db NO_INPUT, 36
	db B_BUTTON, 47
	db NO_INPUT, 15
	db D_RIGHT, 4
	db NO_INPUT, 16
	db B_BUTTON, 70
	db NO_INPUT, 30
	db SELECT, 10
	db NO_INPUT, 58
	db D_RIGHT, 91
	db A_BUTTON | D_RIGHT, 16
	db D_RIGHT, 8
	db B_BUTTON | D_RIGHT, 4
	db B_BUTTON, 4
	db NO_INPUT, 28
	db D_RIGHT, 5
	db NO_INPUT, 15
	db D_DOWN, 14
	db NO_INPUT, 97
	db B_BUTTON, 31
	db NO_INPUT, 12
	db D_RIGHT, 16
	db A_BUTTON | D_RIGHT, 23
	db D_RIGHT, 26
	db NO_INPUT, 27
	db B_BUTTON, 26
	db NO_INPUT, 15
	db A_BUTTON, 11
	db A_BUTTON | D_RIGHT, 22
	db D_RIGHT, 16
	db A_BUTTON | D_RIGHT, 42
	db NO_INPUT, 31
	db B_BUTTON, 24
	db NO_INPUT, 16
	db D_LEFT, 1
	db NO_INPUT, 34
	db B_BUTTON, 39
	db NO_INPUT, 16
	db A_BUTTON, 2
	db A_BUTTON | D_RIGHT, 22
	db D_RIGHT, 39
	db A_BUTTON | D_RIGHT, 15
	db D_RIGHT, 95
	db NO_INPUT, 2
	db D_LEFT, 8
	db NO_INPUT, 1
	db B_BUTTON, 41
	db B_BUTTON | D_RIGHT, 29
	db B_BUTTON, 39
	db NO_INPUT, 2
	db D_RIGHT, 85
	db NO_INPUT, 4
	db B_BUTTON, 158
	db NO_INPUT, 24
	db SELECT, 9
	db NO_INPUT, 63
	db A_BUTTON, 13
	db A_BUTTON | D_RIGHT, 6
	db D_RIGHT, 6
	db NO_INPUT, 7
	db B_BUTTON, 10
	db NO_INPUT, 35
	db D_DOWN, 13
	db NO_INPUT, 54
	db D_RIGHT, 25
	db NO_INPUT, 27
	db D_LEFT, 4
	db NO_INPUT, 32
	db B_BUTTON, 22
	db NO_INPUT, 17
	db A_BUTTON, 13
	db A_BUTTON | D_RIGHT, 19
	db D_RIGHT, 10
	db A_BUTTON | D_RIGHT, 20
	db D_RIGHT, 5
	db NO_INPUT, 2
	db D_LEFT, 6
	db NO_INPUT, 2
	db B_BUTTON, 37
	db NO_INPUT, 12
	db D_RIGHT, 19
	db NO_INPUT, 2
	db D_UP, 19
	db NO_INPUT, 41
	db B_BUTTON, 25
	db NO_INPUT, 6
	db D_RIGHT, 16
	db NO_INPUT, 2
	db D_LEFT, 7
	db NO_INPUT, 2
	db B_BUTTON, 19
	db NO_INPUT, 18
	db A_BUTTON, 19
	db A_BUTTON | D_LEFT, 7
	db A_BUTTON, 3
	db NO_INPUT, 4
	db D_RIGHT, 5
	db NO_INPUT, 54
	db B_BUTTON, 25
	db NO_INPUT, 16
	db A_BUTTON, 26
	db NO_INPUT, 13
	db D_RIGHT, 6
	db A_BUTTON | D_RIGHT, 20
	db D_RIGHT, 5
	db NO_INPUT, 25
	db B_BUTTON, 27
	db NO_INPUT, 12
	db D_LEFT, 9
	db A_BUTTON | D_LEFT, 29
	db D_LEFT, 17
	db A_BUTTON | D_LEFT, 30
	db A_BUTTON, 1
	db NO_INPUT, 16
	db D_RIGHT, 18
	db A_BUTTON | D_RIGHT, 31
	db D_RIGHT, 19
	db A_BUTTON | D_RIGHT, 29
	db A_BUTTON, 2
	db NO_INPUT, 23
	db D_LEFT, 14
	db A_BUTTON | D_LEFT, 14
	db D_LEFT, 35
	db A_BUTTON | D_LEFT, 32
	db D_LEFT, 1
	db NO_INPUT, 24
	db D_RIGHT, 14
	db A_BUTTON | D_RIGHT, 19
	db A_BUTTON | B_BUTTON | D_RIGHT, 7
	db A_BUTTON | B_BUTTON, 11
	db A_BUTTON, 2
	db NO_INPUT, 119
	db D_RIGHT, 17
	db A_BUTTON | D_RIGHT, 26
	db D_RIGHT, 2
	db D_RIGHT | D_UP, 4
	db D_UP, 20
	db NO_INPUT, 24
	db D_RIGHT, 40
	db NO_INPUT, 4
	db D_LEFT, 7
	db NO_INPUT, 2
	db B_BUTTON, 15
	db NO_INPUT, 10
	db D_LEFT, 45
	db NO_INPUT, 3
	db D_RIGHT, 8
	db NO_INPUT, 54
	db D_LEFT, 15
	db NO_INPUT, 24
	db B_BUTTON, 35
	db NO_INPUT, 11
	db D_RIGHT, 10
	db A_BUTTON | D_RIGHT, 9
	db D_RIGHT, 6
	db NO_INPUT, 5
	db D_LEFT, 5
	db B_BUTTON | D_LEFT, 19
	db D_LEFT, 31
	db NO_INPUT, 12
	db D_RIGHT, 7
	db A_BUTTON | D_RIGHT, 11
	db D_RIGHT, 5
	db NO_INPUT, 4
	db D_LEFT, 8
	db NO_INPUT, 1
	db B_BUTTON, 24
	db NO_INPUT, 12
	db A_BUTTON, 12
	db NO_INPUT, 12
	db B_BUTTON, 33
	db NO_INPUT, 94
	db B_BUTTON, 30
	db NO_INPUT, 13
	db D_RIGHT, 37
	db NO_INPUT, 73
	db D_RIGHT, 6
	db NO_INPUT, 4
	db D_LEFT, 6
	db NO_INPUT, 77
	db B_BUTTON, 43
	db NO_INPUT, 58
	db D_LEFT, 24
	db NO_INPUT, 49
	db D_UP, 42
	db NO_INPUT, 3
	db B_BUTTON, 152
	db NO_INPUT, 134
	db $08
Demo2InputsEnd:

Demo3Inputs:
	db NO_INPUT, 0
	db NO_INPUT, 79
	db D_RIGHT, 139
	db D_RIGHT | D_DOWN, 3
	db D_DOWN, 16
	db NO_INPUT, 38
	db B_BUTTON, 25
	db NO_INPUT, 15
	db D_RIGHT, 23
	db D_RIGHT | D_UP, 15
	db D_RIGHT, 80
	db NO_INPUT, 7
	db B_BUTTON, 19
	db NO_INPUT, 29
	db D_RIGHT, 5
	db D_RIGHT | D_UP, 14
	db D_RIGHT, 36
	db NO_INPUT, 62
	db B_BUTTON, 26
	db NO_INPUT, 13
	db D_UP, 8
	db D_RIGHT | D_UP, 3
	db D_RIGHT, 53
	db D_RIGHT | D_DOWN, 4
	db D_DOWN, 44
	db NO_INPUT, 142
	db SELECT, 9
	db NO_INPUT, 92
	db D_RIGHT, 21
	db B_BUTTON | D_RIGHT, 8
	db D_RIGHT, 15
	db NO_INPUT, 19
	db D_DOWN, 15
	db NO_INPUT, 58
	db D_RIGHT, 21
	db D_RIGHT | D_UP, 16
	db D_UP, 2
	db NO_INPUT, 15
	db B_BUTTON, 65
	db NO_INPUT, 6
	db D_RIGHT, 20
	db NO_INPUT, 122
	db D_RIGHT, 31
	db D_RIGHT | D_DOWN, 45
	db D_RIGHT, 40
	db NO_INPUT, 36
	db D_UP, 3
	db NO_INPUT, 3
	db B_BUTTON, 16
	db NO_INPUT, 18
	db D_UP, 24
	db D_RIGHT | D_UP, 1
	db D_RIGHT, 22
	db NO_INPUT, 6
	db B_BUTTON, 22
	db NO_INPUT, 28
	db D_RIGHT, 66
	db D_RIGHT | D_DOWN, 22
	db D_RIGHT, 16
	db NO_INPUT, 2
	db B_BUTTON, 10
	db NO_INPUT, 26
	db D_DOWN, 8
	db NO_INPUT, 3
	db D_RIGHT, 20
	db NO_INPUT, 2
	db D_UP, 11
	db NO_INPUT, 93
	db D_RIGHT, 13
	db D_RIGHT | D_UP, 17
	db D_RIGHT, 22
	db NO_INPUT, 7
	db B_BUTTON, 41
	db NO_INPUT, 5
	db D_LEFT, 21
	db D_LEFT | D_DOWN, 29
	db D_DOWN, 1
	db NO_INPUT, 4
	db D_RIGHT, 7
	db NO_INPUT, 24
	db D_RIGHT, 3
	db D_RIGHT | D_UP, 20
	db D_RIGHT, 1
	db B_BUTTON, 18
	db NO_INPUT, 11
	db D_RIGHT, 23
	db B_BUTTON, 154
	db NO_INPUT, 2
	db D_LEFT, 39
	db D_LEFT | D_DOWN, 5
	db D_LEFT, 9
	db D_LEFT | D_DOWN, 3
	db D_DOWN, 8
	db D_RIGHT | D_DOWN, 1
	db D_RIGHT, 11
	db NO_INPUT, 59
	db D_RIGHT, 1
	db D_RIGHT | D_UP, 20
	db D_UP, 2
	db NO_INPUT, 4
	db B_BUTTON, 17
	db NO_INPUT, 24
	db SELECT, 7
	db NO_INPUT, 23
	db D_LEFT, 8
	db B_BUTTON, 4
	db B_BUTTON | D_LEFT, 4
	db D_LEFT, 23
	db NO_INPUT, 3
	db D_RIGHT, 14
	db NO_INPUT, 8
	db B_BUTTON, 9
	db NO_INPUT, 0
	db NO_INPUT, 26
	db D_UP, 20
	db NO_INPUT, 2
	db B_BUTTON, 10
	db NO_INPUT, 84
	db B_BUTTON, 6
	db NO_INPUT, 127
	db B_BUTTON, 22
	db NO_INPUT, 16
	db D_RIGHT, 16
	db D_RIGHT | D_UP, 9
	db D_UP, 23
	db NO_INPUT, 123
	db D_DOWN, 12
	db NO_INPUT, 184
	db D_LEFT, 2
	db D_LEFT | D_UP, 22
	db D_LEFT, 3
	db NO_INPUT, 66
	db D_RIGHT, 6
	db NO_INPUT, 32
	db D_RIGHT, 40
	db A_BUTTON | D_RIGHT, 9
	db D_RIGHT, 13
	db NO_INPUT, 1
	db D_RIGHT, 1
	db NO_INPUT, 2
	db D_UP, 14
	db NO_INPUT, 45
	db D_RIGHT, 52
	db NO_INPUT, 20
	db B_BUTTON, 13
	db B_BUTTON | D_DOWN, 7
	db B_BUTTON | D_RIGHT | D_DOWN, 8
	db D_RIGHT | D_DOWN, 13
	db D_RIGHT, 52
	db NO_INPUT, 7
	db D_RIGHT, 4
	db D_RIGHT | D_DOWN, 4
	db D_RIGHT, 2
	db B_BUTTON, 29
	db D_RIGHT, 45
	db NO_INPUT, 5
	db D_RIGHT, 5
	db B_BUTTON | D_RIGHT, 14
	db B_BUTTON, 2
	db B_BUTTON | D_RIGHT, 12
	db B_BUTTON | D_UP, 3
	db B_BUTTON, 127
	db NO_INPUT, 153
	db $08
Demo3InputsEnd:

; input:
; - [wNextDemo] = DEMO_* constant
Func_21e92:
	ld hl, wNextDemo
	ld a, [hl]
	inc a
	cp NUM_DEMOS
	jr c, .got_demo
	; wrap back to DEMO_1
	ld a, DEMO_1
.got_demo
	ld [hl], a
	dec a
	add a
	add a ; *4
	ld hl, .DemoHeaders
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, sDemoInputs
	call CopyHLToDE
	farcall Func_1c000
	ret

.DemoHeaders:
	; size, inputs
	dw Demo1InputsEnd - Demo1Inputs, Demo1Inputs ; DEMO_1
	dw Demo2InputsEnd - Demo2Inputs, Demo2Inputs ; DEMO_2
	dw Demo3InputsEnd - Demo3Inputs, Demo3Inputs ; DEMO_3
; 0x21ecb

SECTION "Func_22d7a", ROMX[$6d7a], BANK[$8]

Func_22d7a:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	srl a
	srl a
	srl a ; /8
	ld hl, .data
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, d
	ld c, OBJSTRUCT_UNK8D
	ld e, OBJSTRUCT_X_VEL
	ld a, [de]
	ld [bc], a
	add l
	ld [de], a
	inc c
	inc e
	ld a, [de]
	ld [bc], a
	adc h
	ld [de], a
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	inc a
	cp $60
	jr c, .asm_22da7
	xor a
.asm_22da7
	ld [de], a
	ret

.data
	dw  0.5
	dw  0.25
	dw  0.0625
	dw -0.0625
	dw -0.25
	dw -0.5
	dw -0.5
	dw -0.25
	dw -0.0625
	dw  0.0625
	dw  0.25
	dw  0.5

Func_22dc1:
	ld e, OBJSTRUCT_UNK3F
	ld a, [de]
	srl a
	srl a
	srl a ; /8
	ld hl, .data
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, d
	ld c, OBJSTRUCT_UNK8F
	ld e, OBJSTRUCT_Y_VEL
	ld a, [de]
	ld [bc], a
	add l
	ld [de], a
	inc c
	inc e
	ld a, [de]
	ld [bc], a
	adc h
	ld [de], a
	ld e, OBJSTRUCT_UNK3F
	ld a, [de]
	inc a
	cp $60
	jr c, .asm_22dee
	xor a
.asm_22dee
	ld [de], a
	ret

.data
	dw  0.25
	dw  0.125
	dw  0.0313
	dw -0.0313
	dw -0.125
	dw -0.25
	dw -0.25
	dw -0.125
	dw -0.0313
	dw  0.0313
	dw  0.125
	dw  0.25
; 0x22e08

SECTION "Func_22e10", ROMX[$6e10], BANK[$8]

Func_22e10:
	xor a
	ld [wdf14], a
	ld e, OBJSTRUCT_UNK7D
	xor a
	ld [de], a
	push de
	call GetObjectPosition
	call Func_1646
	pop de
	ld b, a
	cp $f0
	jr z, .asm_22e2f
	and $78
	cp $20
	jr c, .asm_22e32
	cp $40
	jr nc, .asm_22e32
.asm_22e2f
	call Func_23171
.asm_22e32
	ld a, [wdf14]
	cp $01
	jr c, .apply_velocities
	jr z, .asm_22e40
	call Func_22dc1
	jr .apply_velocities
.asm_22e40
	call Func_22d7a
.apply_velocities
	call ApplyObjectVelocities

	ld a, [wdb75]
	or a
	jp nz, Func_22f16
	ld a, [wdb74]
	or a
	jp nz, Func_22f9a
	ld a, [wdb77]
	or a
	jp nz, Func_22e9d
	call Func_22e64
	call Func_23012
	jp Func_23067

Func_22e64:
	ld hl, wdb3f
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld h, d
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr nc, Func_22e78
	ld a, b
	ld [hld], a
	ld [hl], c
	jr Func_22e78

Func_22e78:
	ld hl, wdb43
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld h, d
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_22e8a
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_22e8a
	ld hl, wdb41
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld h, d
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr nc, .asm_22e9c
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_22e9c
	ret

Func_22e9d:
	call Func_22ee2
	call Func_22efc
	ld a, [wdb77]
	cp $02
	jr z, .asm_22ec4
	jr nc, .asm_22edc
	ld hl, wdb43
	ld bc, wdb51
	ld a, [bc]
	add $98
	ld [hli], a
	inc bc
	ld a, [bc]
	adc $00
	ld [hl], a
	call Func_22e64
	call Func_23067
	jp Func_22f4d
.asm_22ec4
	ld hl, wdb3f
	ld bc, wdb51
	ld a, [bc]
	add $08
	ld [hli], a
	inc bc
	ld a, [bc]
	adc $00
	ld [hl], a
	call Func_22e64
	call Func_23067
	jp Func_22f80
.asm_22edc
	call Func_22e64
	jp Func_23012

Func_22ee2:
	ld hl, wdb4f
	ld e, OBJSTRUCT_UNK77
	ld a, [de]
	add [hl]
	ld [hl], a
	ld hl, wdb51
	inc e
	ld a, [de] ; OBJSTRUCT_UNK78
	bit 7, a
	ld b, $00
	jr z, .asm_22ef6
	dec b
.asm_22ef6
	adc [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
	ret

Func_22efc:
	ld hl, wdb50
	ld e, OBJSTRUCT_UNK79
	ld a, [de]
	add [hl]
	ld [hl], a
	ld hl, wdb53
	inc e
	ld a, [de]
	bit 7, a
	ld b, $00
	jr z, .asm_22f10
	dec b
.asm_22f10
	adc [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
	ret

Func_22f16:
	call Func_22ee2
	ld a, [wdb3d]
	dec a
	ld c, a
	cp [hl]
	jr nz, .asm_22f38
	dec hl
	ld a, [hli]
	cp $10
	jr c, .asm_22f38
	ld [hl], $00

	ld hl, sObjects + OBJSTRUCT_X_POS + 2
.loop_objs
	ld a, [hl]
	cp c
	jr nz, .next_obj
	ld [hl], 0
.next_obj
	inc h
	ld a, h
	cp HIGH(sObjectsEnd)
	jr nz, .loop_objs

.asm_22f38
	ld hl, wdb43
	ld bc, wdb51
	ld a, [bc]
	add $98
	ld [hli], a
	inc bc
	ld a, [bc]
	adc $00
	ld [hl], a
	call Func_22e78
	jp Func_22f4d

Func_22f4d:
	xor a
	ld [sa000Unk7b], a
	ld hl, wdb51
	ld a, [hli]
	add $08
	ld c, a
	ld a, [hl]
	adc $00
	ld b, a
	ld h, d
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hld]
	sbc b
	ret nc
Func_22f65:
	ld a, c
	ld [sa000Unk7b], a
	cpl
	inc a
	ld c, a
	rla
	sbc a
	ld b, a
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hl]
	add c
	ld [hl], a
	ld l, OBJSTRUCT_UNK8E
	ld a, [hl]
	add c
	ld [hl], a
	ret

Func_22f80:
	xor a
	ld [sa000Unk7b], a
	ld hl, wdb51
	ld a, [hli]
	add $98
	ld c, a
	ld a, [hl]
	adc $00
	ld b, a
	ld h, d
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hld]
	sbc b
	ret c
	jr Func_22f65

Func_22f9a:
	ld e, OBJSTRUCT_UNK39
	ld a, [wdb53]
	ld [de], a
	call Func_22fb9
	call Func_22e64
	ld hl, wdb4d
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld h, d
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_22fb8
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_22fb8
	ret

Func_22fb9:
	call Func_22efc
	ld hl, wdb47
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr nc, .asm_22fce
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_22fce
	ld hl, wdb4b
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_22fe0
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_22fe0
	ld h, d
	ld l, OBJSTRUCT_UNK39
	ld a, [wdb53]
	sub [hl]
	ld c, a
	rla
	sbc a
	ld b, a
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ld hl, wdb41
	ld bc, wdb53
	ld a, [bc]
	add $08
	ld [hli], a
	inc bc
	ld a, [bc]
	adc $00
	ld [hl], a
	ld hl, wdb4d
	ld bc, wdb53
	ld a, [bc]
	add $78
	ld [hli], a
	inc bc
	ld a, [bc]
	adc $00
	ld [hl], a
	ret

Func_23012:
	ld e, OBJSTRUCT_X_POS + 1
	ld hl, wdb51
	ld a, [de]
	sub [hl]
	cp $48
	jr nc, .asm_23047
	ld a, [de]
	inc e
	sub $48
	ld [hli], a
	ld a, [de]
	sbc $00
	ld [hl], a
	jr nc, .asm_23033
	ld hl, wdb45
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb51 + 1
	jr .asm_23042
.asm_23033
	ld hl, wdb45
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb51
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr nc, .asm_23066
.asm_23042
	ld a, b
	ld [hld], a
	ld [hl], c
	jr .asm_23066
.asm_23047
	cp $50
	jr c, .asm_23066
	ld a, [de]
	inc e
	sub $50
	ld [hli], a
	ld a, [de]
	sbc $00
	ld [hl], a
	ld hl, wdb49
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb51
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_23066
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_23066
	ret

Func_23067:
	ld e, OBJSTRUCT_Y_POS + 1
	ld hl, wdb53
	ld a, [de]
	sub [hl]
	cp $38
	jr nc, .asm_2309c
	ld a, [de]
	inc e
	sub $38
	ld [hli], a
	ld a, [de]
	sbc $00
	ld [hl], a
	jr nc, .asm_23088
	ld hl, wdb47
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53 + 1
	jr .asm_23097
.asm_23088
	ld hl, wdb47
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr nc, .asm_230bb
.asm_23097
	ld a, b
	ld [hld], a
	ld [hl], c
	jr .asm_230bb
.asm_2309c
	cp $48
	jr c, .asm_230bb
	ld a, [de]
	inc e
	sub $48
	ld [hli], a
	ld a, [de]
	sbc $00
	ld [hl], a
	ld hl, wdb4b
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_230bb
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_230bb
	ret
; 0x230bc

SECTION "Func_23171", ROMX[$7171], BANK[$8]

Func_23171:
	ld a, b
	cp $f0
	ld a, [sa000Unk71]
	jr nz, .asm_231a7
	cp $03
	jr z, .asm_2318a
.asm_2317d
	ld e, 0.496
	ld bc, -2.75
	call ApplyUpwardsAcceleration_WithDampening
	call SetMinimumVelocity_Up
	jr .asm_231a1
.asm_2318a
	ld a, [sa000Unk50]
	cp $11
	jr z, .asm_2317d
	ld e, 0.094
	ld bc, -2.75
	call ApplyUpwardsAcceleration
	ld e, 0.109
	ld bc, 0.25
	call DecelerateIfOverMaxVelocity_Down
.asm_231a1
	ld e, OBJSTRUCT_UNK7D
	ld a, $01
	ld [de], a
	ret

.asm_231a7
	bit 7, b
	jp nz, .asm_23245
	cp $03
	jr z, .asm_231ed
	bit 3, b
	jr nz, .asm_231d1
	bit 4, b
	jr nz, .asm_231c5

.asm_231b8
	ld e, 0.496
	ld bc, -1.5
	call ApplyUpwardsAcceleration_WithDampening
	call SetMinimumVelocity_Up
	jr .asm_231a1

.asm_231c5
	ld e, 0.156
	ld bc, 3.0
	call ApplyDownwardsAcceleration_WithDampening
	call SetMinimumVelocity_Down
	ret

.asm_231d1
	bit 4, b
	jr nz, .asm_231e1
	ld e, 0.188
	ld bc, 1.5
	call ApplyRightAcceleration_WithDampening
	call SetMinimumVelocity_Right
	ret
.asm_231e1
	ld e, 0.188
	ld bc, -1.5
	call ApplyLeftAcceleration_WithDampening
	call SetMinimumVelocity_Left
	ret

.asm_231ed
	bit 3, b
	jr nz, .asm_2321f
	bit 4, b
	jr nz, .asm_2320e
	ld a, [sa000Unk50]
	cp $11
	jr z, .asm_231b8
	ld e, 0.094
	ld bc, -1.5
	call ApplyUpwardsAcceleration
	ld e, 0.109
	ld bc, 0.25
	call DecelerateIfOverMaxVelocity_Down
	jr .asm_231a1

.asm_2320e
	ld e, 0.063
	ld bc, 3.0
	call ApplyDownwardsAcceleration
	ld e, 0.109
	ld bc, -0.25
	call DecelerateIfOverMaxVelocity_Up
	ret

.asm_2321f
	bit 4, b
	jr nz, .asm_23234
	ld e, 0.063
	ld bc, 1.5
	call ApplyRightAcceleration
	ld e, 0.109
	ld bc, -0.25
	call DecelerateIfOverMaxVelocity_Left
	ret
.asm_23234
	ld e, 0.063
	ld bc, -1.5
	call ApplyLeftAcceleration
	ld e, 0.109
	ld bc, 0.25
	call DecelerateIfOverMaxVelocity_Right
	ret

.asm_23245
	cp $02
	jr z, .asm_23285
	bit 3, b
	jr nz, .asm_23269
	bit 4, b
	jr nz, .asm_2325d
.asm_23251
	ld e, 0.094
	ld bc, -1.5
	call ApplyUpwardsAcceleration_WithDampening
	call SetMinimumVelocity_Up
	ret
.asm_2325d
	ld e, 0.094
	ld bc, 1.5
	call ApplyDownwardsAcceleration_WithDampening
	call SetMinimumVelocity_Down
	ret

.asm_23269
	bit 4, b
	jr nz, .asm_23279
	ld e, 0.094
	ld bc, 1.5
	call ApplyRightAcceleration_WithDampening
	call SetMinimumVelocity_Right
	ret

.asm_23279
	ld e, 0.094
	ld bc, -1.5
	call ApplyLeftAcceleration_WithDampening
	call SetMinimumVelocity_Left
	ret

.asm_23285
	bit 3, b
	jr nz, .asm_232b6
	bit 4, b
	jr nz, .asm_232a5
	ld a, [sa000Unk50]
	cp $12
	jr z, .asm_23251
	ld e, 0.047
	ld bc, -1.5
	call ApplyUpwardsAcceleration
	ld e, 0.078
	ld bc, 0.25
	call DecelerateIfOverMaxVelocity_Down
	ret

.asm_232a5
	ld e, 0.047
	ld bc, 1.5
	call ApplyDownwardsAcceleration
	ld e, 0.078
	ld bc, -0.25
	call DecelerateIfOverMaxVelocity_Up
	ret

.asm_232b6
	bit 4, b
	jr nz, .asm_232cb
	ld e, 0.047
	ld bc, 1.5
	call ApplyRightAcceleration
	ld e, 0.078
	ld bc, -0.25
	call DecelerateIfOverMaxVelocity_Left
	ret

.asm_232cb
	ld e, 0.047
	ld bc, -1.5
	call ApplyLeftAcceleration
	ld e, 0.078
	ld bc, 0.25
	call DecelerateIfOverMaxVelocity_Right
	ret

SetMinimumVelocity_Up:
	ld bc, -0.188
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr nc, .set_to_bc ; moving downwards
	; moving upwards
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret c ; exit if upwards velocity is higher than bc
.set_to_bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ret

SetMinimumVelocity_Down:
	ld bc, 0.188
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr c, .set_to_bc ; moving upwards
	; moving downwards
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret nc ; exit if downwards velocity is higher than bc
.set_to_bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ret

SetMinimumVelocity_Left:
	ld bc, -0.188
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	jr nc, .set_to_bc ; moving right
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret c ; exit if left velocity is higher than bc
.set_to_bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ret

SetMinimumVelocity_Right:
	ld bc, 0.188
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	jr c, .set_to_bc ; moving left
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret nc ; exit if right velocity is higher than bc
.set_to_bc
	ld a, c
	ld [hli], a
	ld [hl], b
	ret

; tests to see if object is moving upwards
; with a velocity faster than bc
; if yes, then apply deceleration with value
; from input register e
; input:
; - bc = maximum upwards velocity
; - e  = y deceleration
DecelerateIfOverMaxVelocity_Up:
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	ret nc ; exit if moving downwards
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret nc ; exit if y vel >= bc
	jp DecelerateObjectY

; tests to see if object is moving downwards
; with a velocity faster than bc
; if yes, then apply deceleration with value
; from input register e
; input:
; - bc = maximum downwards velocity
; - e  = y deceleration
DecelerateIfOverMaxVelocity_Down:
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	ret c ; exit if moving upwards
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret c ; exit if y vel < bc
	jp DecelerateObjectX ; bug, should be DecelerateObjectY

; tests to see if object is moving left
; with a velocity faster than bc
; if yes, then apply deceleration with value
; from input register e
; input:
; - bc = maximum left velocity
; - e  = y deceleration
DecelerateIfOverMaxVelocity_Left:
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	ret nc ; exit if moving right
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret nc ; exit if x vel >= bc
	jp DecelerateObjectX

; tests to see if object is moving right
; with a velocity faster than bc
; if yes, then apply deceleration with value
; from input register e
; input:
; - bc = maximum right velocity
; - e  = y deceleration
DecelerateIfOverMaxVelocity_Right:
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	ret c ; exit if moving left
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	ret c ; exit if x vel < bc
	jp DecelerateObjectX
; 0x23358

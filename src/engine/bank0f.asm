SECTION "Script_3c4e6", ROMX[$44e6], BANK[$0f]

Script_3c4e6:
	exec_asm Func_3c96c
	set_draw_func Func_df3
	set_field OBJSTRUCT_UNK43, $20
	exec_asm Func_3c54b
	unk03_cmd Func_3c841
	set_oam $42c6, $0f ; OAM_3c2c6
	exec_asm Func_3c8ef
	exec_asm Func_3c912
	jump_if_var .script_3c509
	create_object UNK_OBJ_9C, $a0, $b3
.script_3c509
	set_field OBJSTRUCT_UNK40, $00
.loop
	set_y_vel 0.0
	set_y_acc 0.031
	wait 10
	set_y_vel 0.0
	set_y_acc -0.031
	wait 10
	jump .loop
; 0x3c51d

SECTION "Func_3c54b", ROMX[$454b], BANK[$0f]

Func_3c54b:
	xor a
	ld [wdd5b], a
	ret

Script_3c550:
	exec_asm Func_2b91
	script_stop
; 0x3c554

SECTION "Script_3c567", ROMX[$4567], BANK[$0f]

Script_3c567:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 56
	set_y 36
	set_x 56
	set_y 36
	set_x_vel 1.199
	set_y_vel -2.031
	set_y_acc 0.168
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 104
	set_y 92
	jump Script_3c4e6

Script_3c59c:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 104
	set_y 92
	set_x 104
	set_y 92
	set_x_vel -1.199
	set_y_vel -4.031
	set_y_acc 0.129
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 56
	set_y 36
	jump Script_3c4e6

Script_3c5d1:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 104
	set_y 92
	set_x 104
	set_y 92
	set_x_vel 1.199
	set_y_vel -4.0
	set_y_acc 0.137
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 152
	set_y 44
	jump Script_3c4e6

Script_3c606:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 152
	set_y 44
	set_x 152
	set_y 44
	set_x_vel -1.199
	set_y_vel -2.0
	set_y_acc 0.156
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 104
	set_y 92
	jump Script_3c4e6

Script_3c63b:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 152
	set_y 44
	set_x 152
	set_y 44
	set_x_vel 1.199
	set_y_vel -2.031
	set_y_acc 0.168
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 200
	set_y 100
	jump Script_3c4e6

Script_3c670:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 200
	set_y 100
	set_x 200
	set_y 100
	set_x_vel -1.199
	set_y_vel -4.031
	set_y_acc 0.129
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 152
	set_y 44
	jump Script_3c4e6

Script_3c6a5:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 200
	set_y 100
	set_x 200
	set_y 100
	set_x_vel 1.199
	set_y_vel -4.031
	set_y_acc 0.129
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 248
	set_y 44
	jump Script_3c4e6

Script_3c6da:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 248
	set_y 44
	set_x 248
	set_y 44
	set_x_vel -1.199
	set_y_vel -2.031
	set_y_acc 0.168
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 200
	set_y 100
	jump Script_3c4e6

Script_3c70f:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 248
	set_y 44
	set_x 248
	set_y 44
	set_x_vel 1.199
	set_y_vel -2.0
	set_y_acc 0.156
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 296
	set_y 92
	jump Script_3c4e6

Script_3c744:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 296
	set_y 92
	set_x 296
	set_y 92
	set_x_vel -1.199
	set_y_vel -4.0
	set_y_acc 0.137
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 248
	set_y 44
	jump Script_3c4e6

Script_3c779:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 296
	set_y 92
	set_x 296
	set_y 92
	set_x_vel 1.199
	set_y_vel -4.031
	set_y_acc 0.129
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 344
	set_y 36
	jump Script_3c4e6

Script_3c7ae:
	set_draw_func Func_df3
	unk03_cmd Func_3c818
	set_field OBJSTRUCT_VAR, $00
	set_oam $42c6, $0f ; OAM_3c2c6
	set_x 344
	set_y 36
	set_x 344
	set_y 36
	set_x_vel -1.199
	set_y_vel -2.031
	set_y_acc 0.168
	wait 40
	set_x_vel 0.0
	set_y_vel 0.0
	set_y_acc 0.0
	set_x 296
	set_y 92
	jump Script_3c4e6
; 0x3c7e3

SECTION "Script_3c7f8", ROMX[$47f8], BANK[$0f]

Script_3c7f8:
	exec_asm Func_3c95d
	exec_asm Func_3c8e8
	var_jumptable 12
	dw Script_3c567
	dw Script_3c59c
	dw Script_3c5d1
	dw Script_3c606
	dw Script_3c63b
	dw Script_3c670
	dw Script_3c6a5
	dw Script_3c6da
	dw Script_3c70f
	dw Script_3c744
	dw Script_3c779
	dw Script_3c7ae

Func_3c818:
	call ApplyObjectXAcceleration
	call ApplyObjectYAcceleration
	call ApplyObjectVelocities

	ld e, OBJSTRUCT_VAR
	ld a, [de]
	and a
	jr z, .asm_3c82a
	dec a
	ld [de], a
	ret
.asm_3c82a
	ld a, $04
	ld [de], a ; OBJSTRUCT_VAR
	ld bc, .data
	call Func_f50
	ret

.data
	db $9b, $a0, $b3
; 0x3c837

SECTION "Func_3c841", ROMX[$4841], BANK[$0f]

Func_3c841:
	call ReadJoypad
	ldh a, [hff9a]
	ld d, a
	ld a, [wdd5b]
	and a
	jr nz, .skip_a_btn_or_start
	ld e, OBJSTRUCT_UNK43
	ld a, [de]
	and a
	jr z, .check_a_btn_or_start
	dec a
	ld [de], a
	jr .skip_a_btn_or_start
.check_a_btn_or_start
	ldh a, [hJoypad1Pressed]
	bit B_PAD_A, a
	jr nz, .a_btn_or_start
	bit B_PAD_START, a
	jr nz, .a_btn_or_start
.skip_a_btn_or_start
	call ApplyObjectXAcceleration
	call ApplyObjectYAcceleration
	call ApplyObjectVelocities
	ld hl, wLevel
	ld a, [hl]
	add a ; *2
	ld c, a
	ld a, [wdb6a]
	ld hl, wdb7b
	cp [hl]
	ret nz
	ld a, [wdd5b]
	and a
	ret nz
	ld e, OBJSTRUCT_UNK40
	ld a, [de]
	cp $10
	jr c, .asm_3c88f
	ldh a, [hJoypad1Down]
	bit B_PAD_RIGHT, a
	jr nz, .d_right
	bit B_PAD_LEFT, a
	jr nz, .d_left
	ret
.asm_3c88f
	inc a
	ld [de], a ; OBJSTRUCT_UNK40
	ret

.d_right
	ld hl, wdb6a
	ld b, [hl]
	ld hl, wLevel
	ld a, [hl]
	cp DARK_CASTLE
	ret z
	inc a
.asm_3c89e
	and a
	jr z, .asm_3c8aa
	ld e, $00
	srl b
	rl e
	dec a
	jr .asm_3c89e
.asm_3c8aa
	bit 0, e
	ret z
	inc [hl]
	jr .asm_3c8b9
.d_left
	ld hl, wLevel
	ld a, [hl]
	cp GRASS_LAND
	ret z
	dec [hl]
	dec c
.asm_3c8b9
	ld a, c
	cp $0c
	ret nc
	ld [wdd59], a
	push de
	ld e, SFX_56
	farcall PlaySFX
	pop de
	ld e, BANK(Script_3c7f8)
	ld bc, Script_3c7f8
	jp Func_846

.a_btn_or_start
	push de
	ld e, SFX_2D
	farcall PlaySFX
	pop de
	ld e, BANK(Script_3c550)
	ld bc, Script_3c550
	jp Func_846

Func_3c8e8:
	ld e, OBJSTRUCT_VAR
	ld a, [wdd59]
	ld [de], a
	ret

Func_3c8ef:
	ld e, OBJSTRUCT_FRAME
	ld hl, sa000Unk71
	ld a, [hl]
	ld [de], a
	ld a, [wLevel]
	ld hl, LevelSelectionCoordinates
	add a
	add a ; *4
	add l
	ld l, a
	incc h
	ld e, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	ld e, OBJSTRUCT_Y_POS + 1
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	ret

Func_3c912:
	ld hl, wLevel
	ld a, [hl]
	cp DARK_CASTLE
	jr z, .dark_castle
	ld a, [wdb6a]
	ld hl, wdb7b
	cp [hl]
	jr nz, .asm_3c929

.asm_3c923
	ld e, OBJSTRUCT_VAR
	ld a, $01
	ld [de], a
	ret
.asm_3c929
	ld [hl], a
	ld e, OBJSTRUCT_VAR
	xor a
	ld [de], a
	ret

.dark_castle
	ld a, [wdb6a]
	ld hl, wdb7b
	ld [hl], a
	jr .asm_3c923
; 0x3c938

SECTION "Func_3c95d", ROMX[$495d], BANK[$0f]

Func_3c95d:
	push de
	push bc
	ld e, SGB_PALS_07 ; SGB_ATF_07
	farcall SGBSetPalette_WithATF_NoWait
	pop bc
	pop de
	ret

Func_3c96c:
	push de
	push bc
	ld a, [wda36]
	or a
	jr nz, .asm_3c980
	ld hl, wLevel
	ld e, [hl]
	farcall SGBSetPalette_WithATF_NoWait
.asm_3c980
	pop bc
	pop de
	ret
; 0x3c983

SECTION "LevelSelectionCoordinates", ROMX[$6111], BANK[$0f]

LevelSelectionCoordinates::
	table_width 4
	;    x,   y
	dw  56,  36 ; GRASS_LAND
	dw 104,  92 ; BIG_FOREST
	dw 152,  44 ; RIPPLE_FIELD
	dw 200, 100 ; ICEBERG
	dw 248,  44 ; RED_CANYON
	dw 296,  92 ; CLOUDY_PARK
	dw 344,  36 ; DARK_CASTLE
	assert_table_length NUM_LEVELS
; 0x3e12d

SECTION "Data_3e8a4", ROMX[$68a4], BANK[$0f]

Data_3e8a4:
	dbw 1, wLevel     ; FILESTRUCT_CURRENT_LEVEL
	dbw 8, wdb62      ; FILESTRUCT_UNK03
	dbw 1, wdb6a      ; FILESTRUCT_UNK0B
	dbw 1, wdd63      ; FILESTRUCT_UNK0C
	dbw 1, wdd62      ; FILESTRUCT_UNK0D
	dbw 1, wdb6c      ; FILESTRUCT_UNK0E
	dbw 1, wdb6b      ; FILESTRUCT_UNK0F
	dbw 1, wdb7b      ; FILESTRUCT_UNK10
	dbw 1, sa000Unk84 ; FILESTRUCT_LIVES
	dbw 1, sa000Unk4c ; FILESTRUCT_HP
	dbw 1, sa000Unk72 ; FILESTRUCT_UNK13
	dbw 1, sa000Unk51 ; FILESTRUCT_UNK14
	dbw 1, sa000Unk5b ; FILESTRUCT_COPY_ABILITY
	dbw 1, sa000Unk71 ; FILESTRUCT_ANIMAL_FRIEND
	dbw 3, wScore     ; FILESTRUCT_SCORE
	db $00 ; end
; 0x3e8d2

SECTION "FileSelectMenu", ROMX[$68d2], BANK[$0f]

FileSelectMenu:
	call InitFileSelectMenu

	; wait some frames before
	; accepting player input
	ld a, 32
.loop_delay
	push af
	xor a
	ldh [hJoypad1Pressed], a
	call .Func_3e8fe
	pop af
	dec a
	jr nz, .loop_delay

.loop_selection
	call .Func_3e8fe
	call Random
	ld a, [wGameMode]
	cp GAMEMODE_DEMO
	jr z, .loop_selection
	lb de, SGB_PALSEQUENCE_01, 4
	farcall FadeOut_ToBlack
	call TurnLCDOff
	ret

.Func_3e8fe:
	call Func_496
	farcall UpdateObjects
	call Func_4ae
	call DoFrame
	jp ReadJoypad

Script_3e912:
	exec_asm Func_3eb2d
	set_frame_wait -1, 3
	exec_asm Func_3e9bf
	wait 3
	jump Script_3e933

Script_3e920:
	create_object BOMB_FILE_SELECT, HIGH(sObjects), HIGH(sObjectsEnd)
	set_oam $7370, $0f ; OAM_3f370
	set_draw_func Func_df6
	set_y 0
	set_field OBJSTRUCT_UNK39, FILEMENU_1
Script_3e933:
	set_x 14
	exec_asm UpdateFileSelectMenuCursorPosition
Script_3e939:
	set_field OBJSTRUCT_UNK3A, $00
	unk03_cmd Func_3ea2e
Script_3e940:
.loop
	set_frame_wait 0, 8
	set_frame_wait 1, 8
	set_frame_wait 2, 8
	set_frame_wait 1, 8
	jump .loop

Script_3e94f:
	set_field OBJSTRUCT_UNK3A, $01
	unk03_cmd Func_3ea2e
.loop
	set_frame_wait 4, 24
	set_frame_wait 3, 24
	jump .loop

Script_3e95f:
	create_object EXPLOSION_FILE_SELECT, HIGH(sObjects), HIGH(sObjectsEnd)
	set_frame_wait 1, 32
	exec_asm EraseSelectedFile
	jump Script_3e939

Script_3e96e:
	set_field OBJSTRUCT_UNK3B, $01
	jump Script_3e98c

Script_3e974:
	exec_asm Func_3e9d9
	jump_if_not_var .script_3e980
	exec_asm Func_3e9d2
	jump Script_3e940
.script_3e980
	set_field OBJSTRUCT_UNK3A, $02
	set_frame_wait -1, 3
	exec_asm Func_3e9c3
	set_field OBJSTRUCT_UNK3B, $00
Script_3e98c:
	set_frame_wait -1, 3
	exec_asm Func_3eb44
	wait 3
	unk03_cmd Func_3eaa1
	exec_asm Func_3e9f9
.loop
	set_frame_wait 7, 8
	set_frame_wait -1, 8
	jump .loop

Script_3e9a4:
	set_frame_wait -1, 3
	exec_asm Func_3eb3d
	wait 3
	unk03_cmd Func_3eaef
	set_field OBJSTRUCT_UNK3B, $00
	exec_asm Func_3ea07
.loop
	set_frame_wait 7, 8
	set_frame_wait -1, 8
	jump .loop

Func_3e9bf:
	ld e, SGB_PALS_10 ; SGB_ATF_10
	jr Func_3e9c5
Func_3e9c3:
	ld e, SGB_PALS_20 ; SGB_ATF_20
Func_3e9c5:
	push bc
	push de
	farcall SGBPaletteSet_WithATF
	pop de
	pop bc
	ret

Func_3e9d2:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld [wGameMode], a
	ret

Func_3e9d9:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld hl, .FilePtrs
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld e, OBJSTRUCT_VAR
	ld a, [hli]
	or a
	jr nz, .non_zero
	ld a, [hl]
	sub 1
	; if 100% complete, then a = $00
	; else if 0% complete, a = $ff
.non_zero
	ld [de], a
	ret

.FilePtrs:
	dw sFile1 ; FILEMENU_1
	dw sFile2 ; FILEMENU_2
	dw sFile3 ; FILEMENU_3

Func_3e9f9:
	ld e, OBJSTRUCT_UNK3B
	ld a, [de]
	or a
	ld a, 42
	jr z, .asm_3ea03
	ld a, 120
.asm_3ea03
	ld e, OBJSTRUCT_X_POS + 1
	ld [de], a
	ret

Func_3ea07:
	ld e, OBJSTRUCT_UNK3B
	ld a, [de]
	ld hl, .XPositions
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld e, OBJSTRUCT_X_POS + 1
	ld [de], a
	ret

.XPositions:
	db  26
	db  80
	db 132

UpdateFileSelectMenuCursorPosition:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld hl, .YPositions
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld e, OBJSTRUCT_Y_POS + 1
	ld [de], a
	ret

.YPositions:
	db  52 ; FILEMENU_1
	db  76 ; FILEMENU_2
	db 100 ; FILEMENU_3
	db 124 ; FILEMENU_ERASE

Func_3ea2e:
	ldh a, [hJoypad1Pressed]
	ld e, OBJSTRUCT_UNK39
	bit B_PAD_UP, a
	jr nz, .d_up
	bit B_PAD_DOWN, a
	jr nz, .d_down
	bit B_PAD_B, a
	jr nz, .b_btn
	and PAD_A | PAD_START
	jr nz, .a_btn_or_start
	ret
.d_up
	ld a, [de]
	or a
	ret z
	dec a
.update_position
	ld [de], a
	call UpdateFileSelectMenuCursorPosition
	ld e, SFX_2C
	call Func_10aa
	ret
.d_down
	ld a, [de]
	cp FILEMENU_ERASE
	ret z
	inc a
	jr .update_position
.b_btn
	ld e, OBJSTRUCT_UNK3A
	ld a, [de]
	or a
	jr z, .asm_3ea6b
	ld e, SFX_39
	call Func_10aa
	ld e, BANK(Script_3e939)
	ld bc, Script_3e939
	jp Func_846
.asm_3ea6b
	ld a, $ff
	ld [wGameMode], a
	ret
.a_btn_or_start
	ld a, [de]
	cp FILEMENU_ERASE
	ld e, OBJSTRUCT_UNK3A
	jr z, .asm_3ea91
	ld a, [de]
	or a
	jr nz, .asm_3ea89
	ld e, SFX_2D
	call Func_10aa
	ld e, BANK(Script_3e974)
	ld bc, Script_3e974
	jp Func_846
.asm_3ea89
	ld e, BANK(Script_3e95f)
	ld bc, Script_3e95f
	jp Func_846

.asm_3ea91
	ld a, [de]
	or a
	ret nz
	ld e, SFX_2D
	call Func_10aa
	ld e, BANK(Script_3e94f)
	ld bc, Script_3e94f
	jp Func_846

Func_3eaa1:
	ldh a, [hJoypad1Pressed]
	ld e, OBJSTRUCT_UNK3B
	bit B_PAD_RIGHT, a
	jr nz, .d_right
	bit B_PAD_LEFT, a
	jr nz, .d_left
	bit B_PAD_B, a
	jr nz, .b_btn
	and PAD_A | PAD_START
	jr nz, .a_btn_or_start
	ret
.d_right
	ld a, [de]
	or a
	ret nz
	inc a
.update_position
	ld [de], a
	call Func_3e9f9
	ld e, SFX_2C
	call Func_10aa
	ret
.d_left
	ld a, [de]
	or a
	ret z
	dec a
	jr .update_position
.b_btn
	ld e, BANK(Script_3e912)
	ld bc, Script_3e912
	jp Func_846
.a_btn_or_start
	ld a, [de]
	or a
	jr nz, .asm_3eae2
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld [wGameMode], a
	ld e, SFX_2D
	call Func_10aa
	ret
.asm_3eae2
	ld e, SFX_2D
	call Func_10aa
	ld e, BANK(Script_3e9a4)
	ld bc, Script_3e9a4
	jp Func_846

Func_3eaef:
	ldh a, [hJoypad1Pressed]
	ld e, OBJSTRUCT_UNK3B
	bit B_PAD_RIGHT, a
	jr nz, .d_right
	bit B_PAD_LEFT, a
	jr nz, .d_left
	bit B_PAD_B, a
	jr nz, .b_btn
	and PAD_A | PAD_START
	jr nz, .a_btn_or_start
	ret
.d_right
	ld a, [de]
	cp $02
	ret nc
	inc a
.asm_3eb09
	ld [de], a
	call Func_3ea07
	ld e, SFX_2C
	call Func_10aa
	ret
.d_left
	ld a, [de]
	or a
	ret z
	dec a
	jr .asm_3eb09
.b_btn
	ld e, BANK(Script_3e96e)
	ld bc, Script_3e96e
	jp Func_846
.a_btn_or_start
	ld a, [de]
	add $03
	ld [wGameMode], a
	ld e, SFX_2D
	call Func_10aa
	ret

Func_3eb2d:
	ld a, $29
	ld hl, Data_3eb83
	call Func_3eb49
	push bc
	push de
	call PrintFileInfo
	pop de
	pop bc
	ret

Func_3eb3d:
	ld a, $14
	ld hl, Data_3ebfe
	jr Func_3eb49

Func_3eb44:
	ld a, $26
	ld hl, Data_3ebc8
;	fallthrough

; input:
; - a = ?
; - hl = tile data
Func_3eb49:
	call Func_675
	ret c
	push bc
	push de
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hBGMapQueueSize]
	ld c, a
	ld b, HIGH(wBGMapQueue)
.loop_tile_data
	ld a, [hli]
	cp $ff
	jr z, .done
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	ld e, a
	inc c
	ld a, [hli]
	ld d, a
	ld a, [hli]
	push hl
	ld h, a
	ld l, d
.loop_tiles
	ld a, [hli]
	ld [bc], a
	inc c
	dec e
	jr nz, .loop_tiles
	pop hl
	jr .loop_tile_data
.done
	ld a, c
	ldh [hBGMapQueueSize], a
	pop de
	pop bc
	ret

Data_3eb83:
	dw .data_3eb89 ; FILEMENU_1
	dw .data_3eb9e ; FILEMENU_2
	dw .data_3ebb3 ; FILEMENU_3

.data_3eb89
	dw $98a0
	db 6
	dw $73e8

	dw $98c0
	db 6
	dw $73ee

	dw $98c6
	db 14
	dw $741e

	dw $98e0
	db 6
	dw $73f4

	db $ff ; end

.data_3eb9e
	dw $9900
	db 6
	dw $73fa

	dw $9920
	db 6
	dw $7400

	dw $9926
	db 14
	dw $741e

	dw $9940
	db 6
	dw $7406

	db $ff ; end

.data_3ebb3
	dw $9960
	db 6
	dw $740c

	dw $9980
	db 6
	dw $7412

	dw $9986
	db 14
	dw $741e

	dw $99a0
	db 6
	dw $7418

	db $ff ; end

Data_3ebc8:
	dw .data_3ebce ; FILEMENU_1
	dw .data_3ebde ; FILEMENU_2
	dw .data_3ebee ; FILEMENU_3

.data_3ebce
	dw $98a0
	db 6
	dw $742c

	dw $98c0
	db 20
	dw $7432

	dw $98e0
	db 6
	dw $7446

	db $ff ; end

.data_3ebde
	dw $9900
	db 6
	dw $744c

	dw $9920
	db 20
	dw $7432

	dw $9940
	db 6
	dw $7466

	db $ff ; end

.data_3ebee
	dw $9960
	db 6
	dw $746c

	dw $9980
	db 20
	dw $7432

	dw $99a0
	db 6
	dw $7472

	db $ff ; end

Data_3ebfe:
	dw .data_3ec04 ; FILEMENU_1
	dw .data_3ec0a ; FILEMENU_2
	dw .data_3ec10 ; FILEMENU_3

.data_3ec04
	dw $98c0
	db 20
	dw $7452

	db $ff ; end

.data_3ec0a
	dw $9920
	db 20
	dw $7452

	db $ff ; end

.data_3ec10
	dw $9980
	db 20
	dw $7452

	db $ff ; end

Script_3ec16:
	set_oam $7370, $0f ; OAM_3f370
	set_draw_func Func_df6
	set_x 33
	set_y 124
	unk03_cmd Func_3ec34
.loop
	set_field OBJSTRUCT_UNK39, 6
	wait 24
	set_field OBJSTRUCT_UNK39, 5
	wait 24
	jump .loop

Func_3ec34:
	ld e, OBJSTRUCT_PARENT_OBJ
	ld a, [de]
	ld h, a
	ld l, OBJSTRUCT_UNK3A
	ld a, [hl]
	or a
	ld a, -1 ; invisible
	jr nz, .got_frame
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
.got_frame
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	ret

Script_3ec47:
	play_sfx SFX_11
	set_oam $7783, $0b ; OAM_2f783
	set_draw_func Func_df6
	set_x 41

	repeat 2
	set_frame_wait 0, 2
	set_frame_wait 1, 2
	set_frame_wait 2, 2
	set_frame_wait 3, 2
	set_frame_wait 4, 2
	set_frame_wait 5, 2
	set_frame_wait 6, 2
	set_frame_wait 7, 2
	repeat_end

	script_stop

EraseSelectedFile:
	push bc
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld e, a
	call .Erase
	call PrintFileInfo
	ldh a, [hff9a]
	ld d, a
	pop bc
	ret

; input:
; - a = which file to erase (FILESTRUCT_* constant)
.Erase:
	ld a, e
	ld hl, sFile1
	cp FILE_2
	jr c, .got_file
	ld hl, sFile2
	jr z, .got_file
	ld hl, sFile3
.got_file
	ld e, FILESTRUCT_STRUCT_SIZE
	xor a
.loop_clear
	ld [hli], a
	dec e
	jr nz, .loop_clear
	ret

; prints file current level and completion percentage
PrintFileInfo:
	ld a, $0f
	call Func_675
	ret c

	; fill level numbers and completion percentages
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	debgcoord 12, 6
	ld bc, sFile1CurrentLevel
	call .PrintFileLevelAndCompletion
	debgcoord 12, 9
	ld bc, sFile2CurrentLevel
	call .PrintFileLevelAndCompletion
	debgcoord 12, 12
	ld bc, sFile3CurrentLevel
	call .PrintFileLevelAndCompletion
	ld a, l
	ldh [hBGMapQueueSize], a
	ret

; input:
; - de = BGMap address to place tiles
; - bc = file data ptr
.PrintFileLevelAndCompletion:
	ld [hl], e ; destination in VRAM
	inc l      ;
	ld [hl], d ;
	inc l
	ld [hl], 5 ; number of tiles
	inc l
	ld a, [bc]
	inc a
	ld [hl], a ; level number
	inc l
	ld e, $0a ; space
	ld [hl], e
	inc l
	dec bc
	ld a, [bc]
	and $0f
	call .PlaceCompletionDigit
	dec bc
	ld a, [bc]
	swap a
	and $0f
	call .PlaceCompletionDigit
	ld e, $00 ; zero digit
	ld a, [bc]
	and $0f
.PlaceCompletionDigit:
	jr nz, .non_zero
	; is zero, get padding character
	ld a, e
	jr .got_digit
.non_zero
	; e is a space character
	; until a non-zero digit is read
	ld e, $00 ; zero digit
.got_digit
	ld [hl], a
	inc l
	ret

; checks if the checksums of all files are correct
; if not, then clears data for that file
CheckFilesChecksums:
	ld c, NUM_FILES
	ld de, FILESTRUCT_STRUCT_SIZE
	ld hl, sFile1CurrentLevel
.loop_files
	ld b, FILESTRUCT_CHECKSUM1 - FILESTRUCT_UNK03
	push hl
	ld a, [hli]
.loop_xor
	xor [hl]
	inc hl
	dec b
	jr nz, .loop_xor
	cp [hl] ; FILESTRUCT_CHECKSUM1
	jr nz, .checksum_fail
	pop hl
	ld b, FILESTRUCT_CHECKSUM2 - FILESTRUCT_UNK03
	push hl
	ld a, [hli]
.loop_sum
	add [hl]
	inc hl
	dec b
	jr nz, .loop_sum
	cp [hl]
	jr nz, .checksum_fail
.next_file
	pop hl
	add hl, de
	dec c
	jr nz, .loop_files
	ret
.checksum_fail
	pop hl
	push hl
	ld b, FILESTRUCT_STRUCT_SIZE - FILESTRUCT_CURRENT_LEVEL
	xor a
.loop_clear
	ld [hli], a
	dec b
	jr nz, .loop_clear
	; no need to clear completion data since
	; that will be overwritten by CalculateFilesCompletion
	jr .next_file

ReadSaveData:
	ld a, [wGameMode]
	cp SPECIAL_GAME_MODE
	ret nc ; is special game mode
	ld de, sFile1CurrentLevel
	cp FILE_2
	jr c, .got_file
	ld de, sFile2CurrentLevel
	jr z, .got_file
	ld de, sFile3CurrentLevel
.got_file
	ld hl, Data_3e8a4
.loop
	ld a, [hli]
	or a
	jr z, .done_read
	ldh [hff84], a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
.loop_copy
	ld a, [de]
	inc de
	ld [bc], a
	inc bc
	ldh a, [hff84]
	dec a
	ldh [hff84], a
	jr nz, .loop_copy
	jr .loop

.done_read
	ld hl, FILESTRUCT_COMPLETION - FILESTRUCT_CHECKSUM1
	add hl, de
	ld a, [hli]
	or [hl]
	ret nz ; not a new game

	; new game, initialize some variables
	ld a, $02
	ld [sa000Unk84], a
	ld a, $0c
	ld [sa000Unk4c], a
	ld a, $06
	ld [sa000Unk72], a

	; start with no copy ability
	ld a, NO_COPY_ABILITY
	ld [sa000Unk5b], a
	ret

WriteSaveData:
	ld a, [wGameMode]
	cp SPECIAL_GAME_MODE
	ret nc ; is special game mode
	ld de, sFile1CurrentLevel
	cp FILE_2
	jr c, .got_file
	ld de, sFile2CurrentLevel
	jr z, .got_file
	ld de, sFile3CurrentLevel
.got_file
	ld hl, Data_3e8a4
.loop
	ld a, [hli]
	or a
	jr z, .asm_3ed9b
	ldh [hff84], a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
.asm_3ed8e
	ld a, [bc]
	inc bc
	ld [de], a
	inc de
	ldh a, [hff84]
	dec a
	ldh [hff84], a
	jr nz, .asm_3ed8e
	jr .loop
.asm_3ed9b
	ld hl, $ffe8
	add hl, de
	ld b, $17
	push hl
	ld a, [hli]
.asm_3eda3
	xor [hl]
	inc hl
	dec b
	jr nz, .asm_3eda3
	ld [hl], a
	pop hl
	ld b, $18
	ld a, [hli]
.asm_3edad
	add [hl]
	inc hl
	dec b
	jr nz, .asm_3edad
	ld [hl], a
	ret

CalculateFilesCompletion:
	ld a, NUM_FILES
	ldh [hff82], a
	ld hl, sFileSaveData
.loop_files
	push hl
	xor a
	ldh [hff80 + 0], a
	ldh [hff80 + 1], a
	ld de, FILESTRUCT_UNK03
	add hl, de

	ld b, $0a
	ld c, 2 ; %
	call .SumPercentages

	ld b, $02
	ld c, 1 ; %
	call .SumPercentages

	ld b, $01
	ld c, 3 ; %
	call .SumPercentages

	pop hl
	; hff80 = total percentage
	ldh a, [hff80 + 0]
	ld [hli], a
	ldh a, [hff80 + 1]
	ld [hld], a
	ld de, FILESTRUCT_STRUCT_SIZE
	add hl, de
	ldh a, [hff82]
	dec a
	ldh [hff82], a
	jr nz, .loop_files
	ret

; input:
; - b = how many byte flags to loop through
; - c = what percentage value to add for each flag
.SumPercentages:
.loop_flag_bytes
	ld e, [hl]
	inc hl
	ld d, 8 ; num bits
.loop_bits
	srl e
	call c, .AddPercentage
	dec d
	jr nz, .loop_bits
	dec b
	jr nz, .loop_flag_bytes
	ret

.AddPercentage:
	ldh a, [hff80 + 0]
	add c
	daa
	ldh [hff80 + 0], a
	ldh a, [hff80 + 1]
	adc $00
	daa
	ldh [hff80 + 1], a
	ret

InitFileSelectMenu:
	farcall InitObjects

	ld e, SGB_ATF_10
	farcall Func_7a011

	ld hl, $6e8c
	ld de, vTiles0
	call Decompress

	farcall Func_1150

	ld hl, $705d
	ld de, vTiles2
	call Decompress

	ld hl, $72a3
	debgcoord 0, 0, vBGMap0
	call Decompress

	call CheckFilesChecksums
	call CalculateFilesCompletion
	call PrintFileInfo
	call Func_1584

	ld a, $ff
	ld [wLYC], a
	ldh [rLYC], a

	ld a, KIRBY_FILE_SELECT
	lb hl, HIGH(sObjects), HIGH(sObjectsEnd)
	call CreateObject

	ld e, MUSIC_FILE_SELECT_MENU
	farcall PlayMusic

	ld hl, wFadePals3
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [hli], a ; wFadePals3BGP
	ldpal a, SHADE_WHITE, SHADE_WHITE, SHADE_LIGHT, SHADE_BLACK
	ld [hli], a ; wFadePals3OBP0
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [hl], a ; wFadePals3OBP1

	ld a, LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16 | LCDC_WIN_9C00
	ldh [rLCDC], a

	call TurnLCDOn

	ld a, $06
	ld [wGameMode], a
	call ReadJoypad

	lb de, SGB_PALSEQUENCE_01, 4
	farcall FadeIn
	ret
; 0x3ee8c

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
	call Func_647
	ld a, [wdf0a]
	cp $06
	jr z, .loop_selection
	lb de, $01, $04
	farcall Func_6827b
	call Func_437
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
	create_object $a9, HIGH(sObjects), HIGH(sObjectsEnd)
	set_oam $7370, $0f ; OAM_3f370
	set_draw_func Func_df6
	set_y 0
	set_field OBJSTRUCT_UNK39, FILE_SELECT_1
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
	create_object $aa, HIGH(sObjects), HIGH(sObjectsEnd)
	set_frame_wait 1, 32
	exec_asm EraseSelectedFile
	jump Script_3e939

Script_3e96e:
	set_field OBJSTRUCT_UNK3B, $01
	jump Script_3e98c

Script_3e974:
	exec_asm Func_3e9d9
	jump_if_unk27 .script_3e980
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
	ld e, $10
	jr Func_3e9c5
Func_3e9c3:
	ld e, $20
Func_3e9c5:
	push bc
	push de
	farcall Func_7a02e
	pop de
	pop bc
	ret

Func_3e9d2:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld [wdf0a], a
	ret

Func_3e9d9:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld hl, .FilePtrs
	add a ; *2
	add l
	ld l, a
	jr nc, .asm_3e9e5
	inc h
.asm_3e9e5
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld e, OBJSTRUCT_UNK27
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
	dw sFile1 ; FILE_SELECT_1
	dw sFile2 ; FILE_SELECT_2
	dw sFile3 ; FILE_SELECT_3

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
	jr nc, .asm_3ea12
	inc h
.asm_3ea12
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
	jr nc, .asm_3ea25
	inc h
.asm_3ea25
	ld a, [hl]
	ld e, OBJSTRUCT_Y_POS + 1
	ld [de], a
	ret

.YPositions:
	db  52 ; FILE_SELECT_1
	db  76 ; FILE_SELECT_2
	db 100 ; FILE_SELECT_3
	db 124 ; FILE_SELECT_ERASE

Func_3ea2e:
	ldh a, [hJoypad1Pressed]
	ld e, OBJSTRUCT_UNK39
	bit D_UP_F, a
	jr nz, .d_up
	bit D_DOWN_F, a
	jr nz, .d_down
	bit B_BUTTON_F, a
	jr nz, .b_btn
	and A_BUTTON | START
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
	cp FILE_SELECT_ERASE
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
	ld [wdf0a], a
	ret
.a_btn_or_start
	ld a, [de]
	cp $03
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
	bit D_RIGHT_F, a
	jr nz, .d_right
	bit D_LEFT_F, a
	jr nz, .d_left
	bit B_BUTTON_F, a
	jr nz, .b_btn
	and A_BUTTON | START
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
	ld [wdf0a], a
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
	bit D_RIGHT_F, a
	jr nz, .d_right
	bit D_LEFT_F, a
	jr nz, .d_left
	bit B_BUTTON_F, a
	jr nz, .b_btn
	and A_BUTTON | START
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
	ld [wdf0a], a
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
	jr nc, .asm_3eb58
	inc h
.asm_3eb58
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hff92]
	ld c, a
	ld b, HIGH(wc400)
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
	ldh [hff92], a
	pop de
	pop bc
	ret

Data_3eb83:
	dw .data_3eb89 ; FILE_SELECT_1
	dw .data_3eb9e ; FILE_SELECT_2
	dw .data_3ebb3 ; FILE_SELECT_3

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
	dw .data_3ebce ; FILE_SELECT_1
	dw .data_3ebde ; FILE_SELECT_2
	dw .data_3ebee ; FILE_SELECT_3

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
	dw .data_3ec04 ; FILE_SELECT_1
	dw .data_3ec0a ; FILE_SELECT_2
	dw .data_3ec10 ; FILE_SELECT_3

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

	script_end

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
; - a = which file to erase (FILE_* constant)
.Erase:
	ld a, e
	ld hl, sFile1
	cp FILE_2
	jr c, .got_file
	ld hl, sFile2
	jr z, .got_file
	ld hl, sFile3
.got_file
	ld e, FILE_STRUCT_SIZE
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
	ldh a, [hff92]
	ld l, a
	ld h, HIGH(wc400)
	ld de, $98cc
	ld bc, sFile1CurrentLevel
	call .PrintFileLevelAndCompletion
	ld de, $992c
	ld bc, sFile2CurrentLevel
	call .PrintFileLevelAndCompletion
	ld de, $998c
	ld bc, sFile3CurrentLevel
	call .PrintFileLevelAndCompletion
	ld a, l
	ldh [hff92], a
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
	ld de, FILE_STRUCT_SIZE
	ld hl, sFile1CurrentLevel
.loop_files
	ld b, FILE_CHECKSUM1 - FILE_UNK03
	push hl
	ld a, [hli]
.loop_xor
	xor [hl]
	inc hl
	dec b
	jr nz, .loop_xor
	cp [hl] ; FILE_CHECKSUM1
	jr nz, .checksum_fail
	pop hl
	ld b, FILE_CHECKSUM2 - FILE_UNK03
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
	ld b, FILE_STRUCT_SIZE - FILE_CURRENT_LEVEL
	xor a
.loop_clear
	ld [hli], a
	dec b
	jr nz, .loop_clear
	; no need to clear completion data since
	; that will be overwritten by CalculateFilesCompletion
	jr .next_file
; 0x3ed21

SECTION "CalculateFilesCompletion", ROMX[$6db4], BANK[$0f]

CalculateFilesCompletion:
	ld a, NUM_FILES
	ldh [hff82], a
	ld hl, sFileSaveData
.loop_files
	push hl
	xor a
	ldh [hff80 + 0], a
	ldh [hff80 + 1], a
	ld de, FILE_UNK03
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
	ld de, FILE_STRUCT_SIZE
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
	farcall Func_20000

	ld e, $10
	farcall Func_7a011

	ld hl, $6e8c
	ld de, vTiles0
	call Decompress

	farcall Func_1150

	ld hl, $705d
	ld de, vTiles2
	call Decompress

	ld hl, $72a3
	ld de, vBGMap0
	call Decompress

	call CheckFilesChecksums
	call CalculateFilesCompletion
	call PrintFileInfo
	call Func_1584

	ld a, $ff
	ld [wLYC], a
	ldh [rLYC], a

	ld a, $a8
	lb hl, HIGH(sObjects), HIGH(sObjectsEnd)
	call CreateObject

	ld e, MUSIC_FILE_SELECT_MENU
	farcall PlayMusic

	ld hl, wcd09
	ld a, $e4
	ld [hli], a ; wcd09
	ld a, $d0
	ld [hli], a ; wcd0a
	ld a, $e4
	ld [hl], a ; wcd0b

	ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d

	ld a, $06
	ld [wdf0a], a
	call ReadJoypad

	lb de, $01, $04
	farcall Func_68246
	ret
; 0x3ee8c

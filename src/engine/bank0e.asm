SECTION "_SoundTest", ROMX[$655f], BANK[$e]

_SoundTest:
	ld hl, $678f
	ld de, vTiles0
	call Decompress
	ld hl, vTiles0
	ld de, vTiles2
	ld bc, $80 tiles
	call CopyHLToDE

	ld hl, $6b91
	ld de, vBGMap0
	call Decompress

	ld hl, $6c3d
	ld de, vTiles0
	call Decompress

	; set palettes
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [wFadePals3BGP], a
	ldpal a, SHADE_WHITE, SHADE_WHITE, SHADE_LIGHT, SHADE_BLACK
	ld [wFadePals3OBP0], a
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [wFadePals3OBP1], a

	call StopSFXAndMusic

	farcall InitObjects

	ld a, UNK_OBJ_F6
	lb hl, HIGH(sObjects), HIGH(sObjectsEnd)
	call CreateObject

	call Func_1584

	ld a, LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16 | LCDC_WIN_9C00
	ldh [rLCDC], a

	call TurnLCDOn

	ld e, SGB_ATF_21
	farcall Func_7a011
	lb de, SGB_PALSEQUENCE_19, 4
	farcall FadeIn

	ld a, 32
.loop_cannot_exit
	push af
	call Func_496
	call UpdateObjects
	call Func_4ae
	call DoFrame
	call ReadJoypad
	pop af
	dec a
	jr nz, .loop_cannot_exit
.loop_can_exit
	call Func_496
	call UpdateObjects
	call Func_4ae
	call DoFrame
	call ReadJoypad
	ldh a, [hJoypad1Down]
	bit B_PAD_START, a
	jr z, .loop_can_exit

	; exit Sound Test
	ld e, SFX_2D
	farcall PlaySFX
	lb de, SGB_PALSEQUENCE_19, 4
	farcall FadeOut_ToBlack
	call StopSFXAndMusic
	jp TurnLCDOff

StopSFXAndMusic:
	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX
	ld e, MUSIC_NONE
	farcall PlayMusic
	ld e, SFX_NONE
	farcall PlaySFX
	ret

Script_3a62c:
	set_draw_func Func_df6
	set_oam $6c4b, $0e ; OAM_3ac4b
	exec_asm Func_3a653
	set_frame 0
	exec_asm Func_3a65a
Script_3a63b:
	exec_func_35e0 45, 116
	set_update_func1 ASM, Func_3a66a
	script_end
Script_3a647:
	exec_func_35e0 45, 132
	set_update_func1 ASM, Func_3a6cb
	script_end

Func_3a653:
	xor a
	ld hl, wSoundTestMusic
	ld [hli], a ; wSoundTestMusic
	ld [hl], a  ; wSoundTestSFX
	ret

Func_3a65a:
	push de
	push bc
	xor a
	ld e, a
	call Func_3a736
	xor a
	ld e, $1
	call Func_3a736
	pop bc
	pop de
	ret

Func_3a66a:
	ldh a, [hJoypad1Pressed]
	bit B_PAD_A, a
	jr nz, .a_btn
	bit B_PAD_B, a
	jr nz, .b_btn
	bit B_PAD_UP, a
	jr nz, .d_up_or_down
	bit B_PAD_DOWN, a
	jr nz, .d_up_or_down
	ldh a, [$ffa7]
	bit B_PAD_LEFT, a
	jr nz, .asm_3a695
	bit B_PAD_RIGHT, a
	ret z
	ld hl, wSoundTestMusic
	ld a, [hl]
	inc a
	cp NUM_MUSICS
	jr c, .asm_3a68f
	xor a ; wrap to start
.asm_3a68f
	ld [hli], a
	ld e, $0
	jp Func_3a736

.asm_3a695
	ld hl, wSoundTestMusic
	ld a, [hl]
	sub 1
	jr nc, .asm_3a69f
	ld a, NUM_MUSICS - 1 ; wrap to end
.asm_3a69f
	ld [hli], a
	ld e, $0
	jp Func_3a736

.d_up_or_down
	ld e, BANK(Script_3a647)
	ld bc, Script_3a647
	jp Func_846

.b_btn
	ld e, MUSIC_NONE
	farcall PlayMusic
	ldh a, [hff9a]
	ld d, a
	ret

.a_btn
	ld a, [wSoundTestMusic]
	ld e, a
	farcall ForcePlayMusic
	ldh a, [hff9a]
	ld d, a
	ret

Func_3a6cb:
	ldh a, [hJoypad1Pressed]
	bit B_PAD_A, a
	jr nz, .asm_3a71c
	bit B_PAD_B, a
	jr nz, .asm_3a70e
	bit B_PAD_UP, a
	jr nz, .asm_3a706
	bit B_PAD_DOWN, a
	jr nz, .asm_3a706
	ldh a, [$ffa7]
	bit B_PAD_LEFT, a
	jr nz, .asm_3a6f6
	bit B_PAD_RIGHT, a
	ret z
	ld hl, wSoundTestSFX
	ld a, [hl]
	inc a
	cp NUM_SFX
	jr c, .asm_3a6f0
	xor a ; wrap to start
.asm_3a6f0
	ld [hli], a
	ld e, $1
	jp Func_3a736

.asm_3a6f6
	ld hl, wSoundTestSFX
	ld a, [hl]
	sub 1
	jr nc, .asm_3a700
	ld a, NUM_SFX - 1 ; wrap to end
.asm_3a700
	ld [hli], a
	ld e, $1
	jp Func_3a736

.asm_3a706
	ld e, BANK(Script_3a63b)
	ld bc, Script_3a63b
	jp Func_846

.asm_3a70e
	ld e, SFX_NONE
	farcall PlaySFX
	ldh a, [hff9a]
	ld d, a
	ret

.asm_3a71c
	ld e, SFX_NONE
	farcall PlaySFX
	ld a, [wSoundTestSFX]
	ld e, a
	farcall PlaySFX
	ldh a, [hff9a]
	ld d, a
	ret

; input:
; - a = Music or SFX index
; - e = $0 for Music, $1 for SFX
Func_3a736:
	ld b, a
	ld a, $74
	swap e
	add e
	ld h, a
	ld a, b
	ld e, $68
	ld b, 10
	call .DivideAByB
	ld l, a
	ld a, c
	ldh [hff80], a
	ld a, h
	call .QueueDigitTile
	ld a, e
	add $08
	ld e, a
	ld a, l
	ldh [hff80], a
	ld a, h
	jp .QueueDigitTile

.DivideAByB:
	ld c, 0
.loop_divide
	sub b
	jr c, .got_digit
	inc c
	jr .loop_divide
.got_digit
	add b
	ret

.QueueDigitTile:
	push af
	push hl
	push de
	ld b, HIGH(vBGMap0) >> 2
	rlca
	rl b
	rlca
	rl b
	and $e0
	ld c, a
	ld a, e
	rra
	rra
	rra
	and $1f
	add c
	ld c, a
	ld h, HIGH(wBGMapQueue)
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], 1
	inc l
	ldh a, [hff80] ; tile index
	ld [hl], a
	inc l
	ld a, l
	ldh [hBGMapQueueSize], a
	pop de
	pop hl
	pop af
	ret
; 0x3a78f

SECTION "Func_3ac52", ROMX[$6c52], BANK[$e]

Func_3ac52:
	call StopSFXAndMusic

	ld hl, $6e42
	ld de, vTiles0
	call Decompress
	ld hl, vTiles0
	ld de, vTiles2
	ld bc, $80 tiles
	call CopyHLToDE

	ld hl, $6f3f
	ld de, vBGMap0
	call Decompress

	ld hl, $6f90
	ld de, vTiles0
	call Decompress

	; set palettes
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [wFadePals3BGP], a
	ldpal a, SHADE_WHITE, SHADE_WHITE, SHADE_LIGHT, SHADE_BLACK
	ld [wFadePals3OBP0], a
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [wFadePals3OBP1], a

	farcall InitObjects

	ld a, UNK_OBJ_F7
	lb hl, HIGH(sObjects), HIGH(sObjectsEnd)
	call CreateObject

	xor a
	ld [wSoundTestMusic], a

	xor a
	ld [wda01], a
	ld [wda00], a
	call Func_1584

	ld a, 127
	ldh [rLYC], a
	ld [wLYC], a
	ld a, LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16 | LCDC_WIN_9C00
	ldh [rLCDC], a
	call TurnLCDOn

	ld e, SGB_ATF_22
	farcall Func_7a011
	lb de, SGB_PALSEQUENCE_1A, 4
	farcall FadeIn

.asm_3accc
	call Func_496
	call UpdateObjects
	call Func_4ae
	call DoFrame
	call ReadJoypad
	ld a, [wSoundTestMusic]
	or a
	jr z, .asm_3accc
	ldh a, [hJoypad1Down]
	bit B_PAD_A, a
	jr nz, .asm_3aceb
	bit B_PAD_START, a
	jr z, .asm_3accc
.asm_3aceb
	ld e, SFX_2D
	farcall PlaySFX
	lb de, SGB_PALSEQUENCE_1A, 4
	farcall FadeOut_ToBlack
	jp TurnLCDOff

Script_3ad03:
	set_draw_func Func_df6
	set_oam $7453, $0e ; OAM_3b453
	set_frame 255
	wait 16
	set_field OBJSTRUCT_UNK3C, $00
	set_field OBJSTRUCT_UNK39, $00
	set_field OBJSTRUCT_UNK3A, $20

	repeat 6
	set_field OBJSTRUCT_VAR, $00
	set_field OBJSTRUCT_UNK3B, $20
	exec_asm Func_3ad4a
.loop
	exec_asm Func_3ad5f
	wait 8
	jump_if_not_var .loop
	repeat_end

	exec_asm Func_3ada9
	play_sfx SFX_2C
	wait 32
	exec_asm Func_3adc9
	play_sfx SFX_5B
	wait 32
	play_sfx SFX_NONE
	set_x 80
	set_y 72
	exec_asm Func_3adf5
	wait 240
	exec_asm Func_3ae3c
	script_end

Func_3ad4a:
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	ld hl, $df2c
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld e, OBJSTRUCT_UNK3D
	ld [de], a
	ld h, d
	ld l, OBJSTRUCT_UNK3C
	add [hl]
	ld [hl], a
	ret

Func_3ad5f:
	push bc
	ld a, $0b
	ldh [hff80], a
	ld hl, $df2c
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	add l
	ld l, a
	incc h
	ld a, [hl]
	or a
	jr z, .asm_3ad97
	ld e, OBJSTRUCT_UNK3B
	ld a, [de]
	ld h, a
	dec e
	ld a, [de]
	ld e, h
	call Func_3a736.QueueDigitTile
	ld e, SFX_41
	farcall PlaySFX
	ldh a, [hff9a]
	ld d, a
	ld e, OBJSTRUCT_UNK3B
	ld a, [de]
	add $08
	ld [de], a
	ld e, OBJSTRUCT_UNK3D
	ld a, [de]
	dec a
	ld [de], a
	jr nz, .asm_3ada7
.asm_3ad97
	ld e, OBJSTRUCT_VAR
	ld a, $01
	ld [de], a
	ld e, OBJSTRUCT_UNK3A
	ld a, [de]
	add $10
	ld [de], a
	ld e, OBJSTRUCT_UNK39
	ld a, [de]
	inc a
	ld [de], a
.asm_3ada7
	pop bc
	ret

Func_3ada9:
	push bc
	ld e, $28
	ld hl, .Tiles
.asm_3adaf
	ld a, [hli]
	cp $ff
	jr z, .asm_3adc1
	ldh [hff80], a
	ld a, $80
	call Func_3a736.QueueDigitTile
	ld a, $08
	add e
	ld e, a
	jr .asm_3adaf
.asm_3adc1
	pop bc
	ret

.Tiles:
	db $0d, $0e, $0d, $0f, $10
	db $ff

Func_3adc9:
	push bc
	ld e, OBJSTRUCT_UNK3C
	ld a, [de]
	ld b, 10
	call .DivideAByB
	ld l, a
	ld a, c
	ldh [hff80], a
	ld e, $70
	ld a, $80
	call Func_3a736.QueueDigitTile
	ld a, $08
	add e
	ld e, a
	ld a, l
	ldh [hff80], a
	ld a, $80
	call Func_3a736.QueueDigitTile
	pop bc
	ret

.DivideAByB:
	ld c, 0
.loop_divide
	sub b
	jr c, .got_digit
	inc c
	jr .loop_divide
.got_digit
	add b
	ret

Func_3adf5:
	push bc
	ld c, 0
	ld e, OBJSTRUCT_UNK3C
	ld a, [de]
	cp $46
	jr c, .got_frame
	inc c ; 1
	cp $4b
	jr c, .got_frame
	inc c ; 2
	cp $50
	jr c, .got_frame
	inc c ; 3
	cp $54
	jr c, .got_frame
	inc c ; 4
.got_frame
	ld a, c
	ld e, OBJSTRUCT_FRAME
	ld [de], a

	ld hl, .SFXAndMusicIDs
	add l
	ld l, a
	incc h
	ld e, [hl]
	ld a, c
	or a
	jr z, .play_sfx
	farcall PlayMusic
	jr .asm_3ae32
.play_sfx
	farcall PlaySFX
.asm_3ae32
	ldh a, [hff9a]
	ld d, a
	pop bc
	ret

.SFXAndMusicIDs:
	db SFX_5D
	db MUSIC_18
	db MUSIC_19
	db MUSIC_2D
	db MUSIC_2A

Func_3ae3c:
	ld a, $01
	ld [wSoundTestMusic], a
	ret
; 0x3ae42

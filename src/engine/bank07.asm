Func_1c000:
	ld a, 1
	ld [wDemoInputDuration], a
	ld a, $02
	ld [wDemoActive], a
	ld hl, wDemoInputPtr
	ld bc, sDemoInputs
	ld [hl], c
	inc hl
	ld [hl], b
	; set RNG to 0
	xor a
	ld hl, wRNG
	ld [hli], a
	ld [hl], a
	ld [wda0e], a
	ret

; fills some kind of look up table for Decompress
Func_1c01d:
	ld hl, wd900
.loop_entries
	ld b, 8
.loop_rotate
	rrc l
	rla
	dec b
	jr nz, .loop_rotate
	ld [hli], a
	inc a
	jr nz, .loop_entries
	ret

Data_1c02d::
	db $3b, $3d, $ff
	db $02, $ff

	db $70, $98
	db $48, $68
	db $b8, $ba

Data_1c038::
	db $3c, $3b, $ff
	db $02, $ff

	db $18, $60
	db $18, $38
	db $b9, $b8

Data_1c043::
	db $3b, $0c, $ff
	db $02, $07, $07, $07, $07, $05, $00, $ff

	db $60, $f8
	db $68, $a0
	db $d0, $30

	db $30, $b0, $f0, $00, $80, $d0, $a8
	db $f8, $30, $60, $b8, $58, $b8, $e8
	db $28, $58, $88, $18, $18, $b8, $b8

	db $80, $50, $50, $00, $00, $44, $98
	db $44, $38, $50, $50, $60, $50, $30
	db $70, $28, $70, $40, $60, $30, $48

	db $60, $58, $30, $38, $30, $68, $50
	db $50, $68, $50, $68, $38, $38, $68
	db $50, $38, $68, $40, $60, $64, $68

	db $3c, $b8, $bb, $bb, $bb, $bb, $bb
	db $bc, $bc, $bc, $bb, $bc, $bc, $bb
	db $bb, $bb, $bb, $bb, $bc, $bc, $bb

	db $bb, $bb, $bb, $bb, $bc
	db $bc, $bb, $bb, $bb, $bc
	db $bb, $bc, $bb, $bc, $bc

Data_1c0b7::
	db $3f, $3b, $ff
	db $02, $ff

	db $60, $60
	db $28, $38
	db $ce, $b8

Data_1c0c2::
	db $40, $3b, $ff
	db $03, $00, $00, $00, $00, $00, $00, $00, $ff

	db $98, $98, $60
	db $48, $58, $38
	db $cf, $d3, $b8

Data_1c0d7::
	db $41, $3b, $ff
	db $02, $ff

	db $88, $60
	db $68, $38
	db $d0, $b8

Func_1c0e2:
	ld hl, wcc00
	ld a, [wdb5f]
	inc a
	ld b, a
	jr .asm_1c0f3
.asm_1c0ec
	ld a, [hli]
	sub $bd
	cp $10
	jr c, .asm_1c0f9
.asm_1c0f3
	dec b
	jr nz, .asm_1c0ec
	ld a, [wLevel]
.asm_1c0f9
	add SGB_PALS_24
	ld e, a
	farcall SGBSetPalette_WithoutATF
	ret

Func_1c105:
	ld a, [wdb61]
	cp $08
	jr nz, .skip
	ld a, [wLevel]
	ld hl, .SGBSounds
	add l
	ld l, a
	incc h
	ld e, [hl]
	farcall SGBPlaySFX
.skip
	ret

.SGBSounds:
	table_width 1
	db SGB_SFX_WIND_HIGH    ; GRASS_LAND
	db SGB_SFX_STOP         ; BIG_FOREST
	db SGB_SFX_WAVE         ; RIPPLE_FIELD
	db SGB_SFX_THUNDERSTORM ; ICEBERG
	db SGB_SFX_STOP         ; RED_CANYON
	db SGB_SFX_STOP         ; CLOUDY_PARK
	db SGB_SFX_LIGHTNING    ; DARK_CASTLE
	assert_table_length NUM_LEVELS

Func_1c128:
	ld a, [wNextDemo]
	or a
	ret nz
	ld hl, wcc00
	ld a, [wdb5f]
	inc a
	ld b, a
	jr .asm_1c13c
.asm_1c137
	ld a, [hli]
	cp $b2
	jr z, .asm_1c141
.asm_1c13c
	dec b
	jr nz, .asm_1c137
	jr .asm_1c155
.asm_1c141
	ld a, [wLevel]
	call GetPowerOfTwo
	ld hl, wdd63
	and [hl]
	jr nz, .asm_1c155
	ld a, MUSIC_12
	ld [wdb6f], a
	ld e, a
	jr .play_music
.asm_1c155
	ld a, [wdb73]
	or a
	ld a, MUSIC_NONE
	jr nz, .asm_1c17b
	ld a, [wLevel]
	ld hl, .PtrTable
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wdb61]
	sub $08
	jr nc, .asm_1c175
	ld a, $02
.asm_1c175
	add l
	ld l, a
	incc h
	ld a, [hl]
.asm_1c17b
	ld [wdb6f], a
	ld a, [wdb38]
	or a
	jr z, .asm_1c18a
	xor a
	ld [wdb38], a
	jr .done
.asm_1c18a
	ld a, [wdb6f]
	ld e, a
	ld a, [wdb61]
	cp $08
	jr nc, .play_music
	ld a, [sa000Unk71]
	or a
	jr nz, .got_animal_friend
	ld a, [wCurMusic]
	inc a
	cp e
	jr z, .done
	jr .play_music

.got_animal_friend
	ld hl, .AnimalFriendMusicIDs
	add l
	ld l, a
	incc h
	ld e, [hl]
.play_music
	farcall PlayMusic
.done
	ret

.PtrTable:
	table_width 2
	dw .data_1c1c4 ; GRASS_LAND
	dw .data_1c1c7 ; BIG_FOREST
	dw .data_1c1ca ; RIPPLE_FIELD
	dw .data_1c1cd ; ICEBERG
	dw .data_1c1d0 ; RED_CANYON
	dw .data_1c1d3 ; CLOUDY_PARK
	dw .data_1c1d6 ; DARK_CASTLE
	assert_table_length NUM_LEVELS

.data_1c1c4
	db MUSIC_GRASS_LAND_HUB
	db MUSIC_13
	db MUSIC_05

.data_1c1c7
	db MUSIC_BIG_FOREST_HUB
	db MUSIC_13
	db MUSIC_08

.data_1c1ca
	db MUSIC_0C
	db MUSIC_13
	db MUSIC_1F

.data_1c1cd
	db MUSIC_22
	db MUSIC_13
	db MUSIC_21

.data_1c1d0
	db MUSIC_23
	db MUSIC_13
	db MUSIC_01

.data_1c1d3
	db MUSIC_24
	db MUSIC_13
	db MUSIC_26

.data_1c1d6
	db MUSIC_11
	db MUSIC_NONE

.AnimalFriendMusicIDs:
	db MUSIC_10   ; NONE
	db MUSIC_RICK ; RICK
	db MUSIC_KINE ; KINE
	db MUSIC_COO  ; COO

Func_1c1dc::
	ld hl, wdb51
	ld a, [hli]
	ld [wda01], a
	sub $10
	ld c, a
	ld a, [hli]
	ld b, a
	jr nc, .asm_1c1eb
	dec b
.asm_1c1eb
	ld a, [hli] ; wdb53
	ld [wda00], a
	sub $10
	ld e, a
	ld d, [hl]
	jr nc, .asm_1c1f6
	dec d
.asm_1c1f6
	call Func_15e3
	push hl
	call Func_15fc
	pop bc
	ld d, $0d
	ld e, $0b
	jr .asm_1c21e
.asm_1c204
	ld a, c
	add $10
	ld c, a
	jr c, .asm_1c213
	ld a, l
	add $40
	ld l, a
	jr nc, .asm_1c21e
	inc h
	jr .asm_1c21e
.asm_1c213
	ld a, [wdb3d]
	add b
	ld b, a
	ld h, $98
	ld a, l
	and $1f
	ld l, a
.asm_1c21e
	push bc
	push hl
	push de
	jr .asm_1c236
.asm_1c223
	inc c
	ld a, c
	and $0f
	jr z, .asm_1c22d
	inc l
	inc l
	jr .asm_1c236
.asm_1c22d
	ld a, c
	sub $10
	ld c, a
	inc b
	ld a, l
	and $e0
	ld l, a
.asm_1c236
	ld a, [bc]
	push bc
	ld c, a
	ld b, $c5
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hl], a
	inc b
	ld a, l
	add $1f
	ld l, a
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hl], a
	ld a, l
	sub $21
	ld l, a
	pop bc
	dec d
	jr nz, .asm_1c223
	pop de
	pop hl
	pop bc
	dec e
	jr nz, .asm_1c204
	ret

Func_1c259::
	ld hl, wdb51
	ld a, [hli]
	ld [wda01], a
	sub $10
	ld c, a
	ld a, [hli]
	ld b, a
	jr nc, .asm_1c268
	dec b
.asm_1c268
	ld a, [hli] ; wdb53
	ld [wda00], a
	sub $10
	ld e, a
	ld d, [hl]
	jr nc, .asm_1c273
	dec d
.asm_1c273
	ld a, e
	and $f0
	ld h, a
	ld a, [wdb56]
	sub h
	jr z, .asm_1c294
	push bc
	push de
	rla
	jr nc, .asm_1c289
	ld a, e
	add $a0
	ld e, a
	incc d
.asm_1c289
	ld a, h
	ld [wdb56], a
	ld a, $0d
	call Func_1c2bc
	pop de
	pop bc
.asm_1c294
	ld a, c
	and $f0
	ld h, a
	ld a, [wdb55]
	sub h
	jr z, .asm_1c2bb
	rla
	jr nc, .asm_1c2a8
	ld a, c
	add $b0
	ld c, a
	incc b
.asm_1c2a8
	ld a, h
	ld [wdb55], a
	push bc
	ld bc, $400
.asm_1c2b0
	dec bc
	ld a, b
	or c
	jr nz, .asm_1c2b0
	pop bc
	ld a, $0b
	call Func_1c318
.asm_1c2bb
	ret

Func_1c2bc:
	ldh [hff84], a
	ldh [hff80], a
	call Func_15fc
	push hl
	call Func_15e3
	ld b, h
	ld c, l
	pop de
	ld a, [wda22]
	ld l, a
	ld a, [wda28]
	ld h, a
	jr .asm_1c2e9
.asm_1c2d4
	ldh [hff84], a
	inc c
	ld a, c
	and $0f
	jr z, .asm_1c2e0
	inc e
	inc e
	jr .asm_1c2e9
.asm_1c2e0
	ld a, c
	sub $10
	ld c, a
	inc b
	ld a, e
	and $e0
	ld e, a
.asm_1c2e9
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld a, [bc]
	push bc
	ld c, a
	ld b, $c5
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	pop bc
	ldh a, [hff84]
	dec a
	jr nz, .asm_1c2d4
	ld a, l
	ld [wda22], a
	ld a, [wda28]
	ld hl, wda23
	rra
	jr nc, .asm_1c313
	ld hl, wda24
.asm_1c313
	ldh a, [hff80]
	add [hl]
	ld [hl], a
	ret

Func_1c318:
	ldh [hff84], a
	ldh [hff80], a
	call Func_15fc
	push hl
	call Func_15e3
	ld b, h
	ld c, l
	pop de
	ld a, [wda22]
	ld l, a
	ld a, [wda28]
	ld h, a
	jr .asm_1c34c
.asm_1c330
	ldh [hff84], a
	ld a, c
	add $10
	ld c, a
	jr c, .asm_1c341
	ld a, e
	add $40
	ld e, a
	jr nc, .asm_1c34c
	inc d
	jr .asm_1c34c
.asm_1c341
	ld a, [wdb3d]
	add b
	ld b, a
	ld d, $98
	ld a, e
	and $1f
	ld e, a
.asm_1c34c
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld a, [bc]
	push bc
	ld c, a
	ld b, $c5
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	pop bc
	ldh a, [hff84]
	dec a
	jr nz, .asm_1c330
	ld a, l
	ld [wda22], a
	ld a, [wda28]
	ld hl, wda23
	rra
	jr nc, .asm_1c376
	ld hl, wda24
.asm_1c376
	ldh a, [hff80]
	add [hl]
	ld [hl], a
	ret
; 0x1c37b

SECTION "Func_1c3a0", ROMX[$43a0], BANK[$7]

Func_1c3a0:
	ld hl, wdb51
	ld a, [hli]
	sub $10
	ld c, a
	ld a, [hli]
	ld b, a
	jr nc, .asm_1c3ac
	dec b
.asm_1c3ac
	ld a, [hli]
	sub $10
	ld e, a
	ld d, [hl]
	jr nc, .asm_1c3b4
	dec d
.asm_1c3b4
	ld a, $0b
.asm_1c3b6
	push af
	push bc
	push de
	ld a, $0d
	call Func_1c41e
	pop hl
	ld de, $10
	add hl, de
	ld d, h
	ld e, l
	pop bc
	pop af
	dec a
	jr nz, .asm_1c3b6
	ret

Func_1c3cb::
	ld hl, wdb51
	ld a, [hli]
	sub $10
	ld c, a
	ld a, [hli]
	ld b, a
	jr nc, .asm_1c3d7
	dec b
.asm_1c3d7
	ld a, [hli]
	sub $10
	ld e, a
	ld d, [hl]
	jr nc, .asm_1c3df
	dec d
.asm_1c3df
	ld a, e
	and $f0
	ld h, a
	ld a, [wdb7e]
	sub h
	jr z, .asm_1c400
	push bc
	push de
	rla
	jr nc, .asm_1c3f5
	ld a, e
	add $a0
	ld e, a
	incc d
.asm_1c3f5
	ld a, h
	ld [wdb7e], a
	ld a, $0d
	call Func_1c41e
	pop de
	pop bc
.asm_1c400
	ld a, c
	and $f0
	ld h, a
	ld a, [wdb7d]
	sub h
	jr z, .asm_1c41d
	rla
	jr nc, .asm_1c414
	ld a, c
	add $c0
	ld c, a
	incc b
.asm_1c414
	ld a, h
	ld [wdb7d], a
	ld a, $0b
	call Func_1c493
.asm_1c41d
	ret

Func_1c41e:
	swap a
	ldh [hff80], a
	ld a, [wdb3e]
	dec a
	cp d
	ret c
	ld a, d
	ldh [hff83], a
	ld a, e
	and $f0
	ld e, a
	ld a, c
	and $f0
	ld c, a
.asm_1c433
	ld a, [wdb3d]
	dec a
	cp b
	jr nc, .asm_1c445
	ldh a, [hff80]
	add c
	ret nc
	ldh [hff80], a
	inc b
	ld c, $00
	jr .asm_1c433
.asm_1c445
	ld a, b
	ldh [hff82], a
	ld hl, wcd35
	ld a, d
	add l
	ld l, a
	ld a, b
	rlca
	add [hl]
	ld l, a
	ld h, HIGH(wcd3d)
	ld a, [hli]
	ld d, a
	ld l, [hl]
	ldh a, [hff80]
	add c
	ld b, $ff
	jr c, .asm_1c461
	ld b, a
	dec b
	xor a
.asm_1c461
	ldh [hff80], a
	inc d
	jr .asm_1c480
.asm_1c466
	ld h, HIGH(wcb00)
	ld a, [hl]
	and $f0
	cp e
	jr nz, .asm_1c47f
	ld h, HIGH(wca00)
	ld a, [hl]
	cp c
	jr c, .asm_1c47f
	scf
	sbc b
	jr nc, .asm_1c47f
	ld h, $bb
	ld a, [hl]
	or a
	call z, Func_1c508
.asm_1c47f
	inc l
.asm_1c480
	dec d
	jr nz, .asm_1c466
	ldh a, [hff80]
	or a
	ret z
	ldh a, [hff83]
	ld d, a
	ldh a, [hff82]
	ld b, a
	inc b
	ld c, $00
	jp .asm_1c433

Func_1c493:
	swap a
	ldh [hff80], a
	ld a, [wdb3d]
	dec a
	cp b
	ret c
	ld a, b
	ldh [hff82], a
	ld a, c
	and $f0
	ld c, a
	ld a, e
	and $f0
	ld e, a
.asm_1c4a8
	ld a, [wdb3e]
	dec a
	cp d
	jr nc, .asm_1c4ba
	ldh a, [hff80]
	add e
	ret nc
	ldh [hff80], a
	inc d
	ld e, $00
	jr .asm_1c4a8
.asm_1c4ba
	ld a, d
	ldh [hff83], a
	ld hl, wcd35
	ld a, d
	add l
	ld l, a
	ld a, b
	rlca
	add [hl]
	ld l, a
	ld h, HIGH(wcd3d)
	ld a, [hli]
	ld b, a
	ld l, [hl]
	ldh a, [hff80]
	add e
	ld d, $ff
	jr c, .asm_1c4d6
	ld d, a
	dec d
	xor a
.asm_1c4d6
	ldh [hff80], a
	inc b
	jr .asm_1c4f5
.asm_1c4db
	ld h, HIGH(wca00)
	ld a, [hl]
	and $f0
	cp c
	jr nz, .asm_1c4f4
	ld h, HIGH(wcb00)
	ld a, [hl]
	cp e
	jr c, .asm_1c4f4
	scf
	sbc d
	jr nc, .asm_1c4f4
	ld h, $bb
	ld a, [hl]
	or a
	call z, Func_1c508
.asm_1c4f4
	inc l
.asm_1c4f5
	dec b
	jr nz, .asm_1c4db
	ldh a, [hff80]
	or a
	ret z
	ldh a, [hff82]
	ld b, a
	ldh a, [hff83]
	ld d, a
	inc d
	ld e, $00
	jp .asm_1c4a8

Func_1c508:
	push bc
	push de
	push hl
	ld h, HIGH(wca00)
	ld c, [hl]
	ld h, HIGH(wcb00)
	ld e, [hl]
	ldh a, [hff82]
	ld b, a
	ldh a, [hff83]
	ld d, a
	ld h, HIGH(wcc00)
	ld l, [hl]
	ld h, HIGH(Data_1fa00)
	push hl
	ld a, [hl]
	lb hl, HIGH(sObjectGroup3), HIGH(sObjectGroup3End)
	call CreateObject
	ld d, h
	pop hl
	ld a, d
	or a
	jr z, .asm_1c580
	inc h
	ld e, OBJSTRUCT_UNK5C
	ld a, [hl]
	swap a
	and $0f
	ld [de], a
	ld e, OBJSTRUCT_UNK5B
	ld a, [hl]
	and $0f
	ld [de], a
	inc h
	ld e, OBJSTRUCT_UNK4C
	ld a, [hl]
	ld [de], a
	inc h
	ld e, OBJSTRUCT_UNK4A
	ld a, [hl]
	ld [de], a
	inc h
	inc e
	ld a, [hl]
	ld [de], a
	ld e, OBJSTRUCT_UNK62
	ld a, $ff
	ld [de], a
	inc h
	ld a, [hl]
	ld bc, $5
	ld hl, wObjectOAMs
	jr .asm_1c557
.asm_1c556
	add hl, bc
.asm_1c557
	cp [hl]
	jr nz, .asm_1c556
	inc hl
	ld e, OBJSTRUCT_OAM_TILE_ID
	ld a, [hli]
	ld [de], a
	ld e, OBJSTRUCT_OAM_PTR + 1
	ld a, [hli]
	ld [de], a
	dec e
	ld a, [hli]
	ld [de], a
	dec e
	ld a, [hl]
	ld [de], a ; OBJSTRUCT_OAM_BANK
	ld e, OBJSTRUCT_UNK5E
	ld a, $08
	ld [de], a
	inc e
	ld [de], a
	ld e, OBJSTRUCT_UNK60
	xor a
	ld [de], a
	inc e
	ld [de], a
	pop hl
	ld [hl], $01
	ld e, OBJSTRUCT_UNK49
	ld a, l
	ld [de], a
	pop de
	pop bc
	ret
.asm_1c580
	pop hl
	pop de
	pop bc
	ret

Func_1c584:
	ld a, [wdb57]
	ld b, a
	ld hl, wdbd0 - 1
	ld d, $bb
.asm_1c58d
	inc hl
.asm_1c58e
	ld a, [hli]
	or a
	ret z
	ld a, [hli]
	cp b
	jr nz, .asm_1c58d
	ld a, [hli]
	ld e, a
	ld a, $01
	ld [de], a
	jr .asm_1c58e

; input:
; . e = ?
Func_1c59c:
	inc e
	ld hl, wdbd0
	ld b, h
	ld c, l
.asm_1c5a2
	ld a, [hli]
	or a
	jr z, .asm_1c5b7
	cp e
	jr nz, .asm_1c5ad
	inc hl
	inc hl
	jr .asm_1c5a2
.asm_1c5ad
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hli]
	ld [bc], a
	inc bc
	jr .asm_1c5a2
.asm_1c5b7
	xor a
	ld [bc], a
	ld a, c
	ld [wdcfd + 0], a
	ld a, b
	ld [wdcfd + 1], a
	ret
; 0x1c5c2

SECTION "Data_1d629", ROMX[$5629], BANK[$7]

MACRO data_1d629
	dwb \1, \2 ; OAM
	dwb \3, \4 ; gfx
ENDM

Data_1d629::
	data_1d629 $6b5a, $0c, $4000, $0c ; $00
	data_1d629 $6b70, $0c, $4074, $0c ; $01
	data_1d629 $6d05, $0c, $4265, $0c ; $02
	data_1d629 $6d57, $0c, $434d, $0c ; $03
	data_1d629 $6fac, $0c, $4ac8, $0c ; $04
	data_1d629 $6ef1, $0c, $45ef, $0c ; $05
	data_1d629 $6f6a, $0c, $46fb, $0c ; $06
	data_1d629 $6fcd, $0c, $4b18, $0c ; $07
	data_1d629 $7010, $0c, $4bdd, $0c ; $08
	data_1d629 $5486, $08, $47d1, $0c ; $09
	data_1d629 $707c, $0c, $492e, $0c ; $0a
	data_1d629 $70cc, $0c, $4a0f, $0c ; $0b
	data_1d629 $70f8, $0c, $4c74, $0c ; $0c
	data_1d629 $710e, $0c, $4c96, $0c ; $0d
	data_1d629 $7145, $0c, $4d6a, $0c ; $0e
	data_1d629 $7192, $0c, $4e22, $0c ; $0f
	data_1d629 $7253, $0c, $4fce, $0c ; $10
	data_1d629 $74d0, $0c, $55cc, $0c ; $11
	data_1d629 $7345, $0c, $52cb, $0c ; $12
	data_1d629 $7521, $0c, $57bb, $07 ; $13
	data_1d629 $7542, $0c, $57bb, $07 ; $14
	data_1d629 $7563, $0c, $57bb, $07 ; $15
	data_1d629 $7578, $0c, $57bb, $07 ; $16
	data_1d629 $7599, $0c, $568b, $0c ; $17
	data_1d629 $75de, $0c, $5784, $0c ; $18
	data_1d629 $778e, $0c, $59f3, $0c ; $19
	data_1d629 $78ca, $0c, $5c06, $0c ; $1a
	data_1d629 $7a0e, $0c, $5f63, $0c ; $1b
	data_1d629 $7b3f, $0c, $57bb, $07 ; $1c
	data_1d629 $7b7b, $0c, $636d, $0c ; $1d
	data_1d629 $7bdb, $0c, $6331, $0c ; $1e
	data_1d629 $6f52, $0b, $57bb, $07 ; $1f
	data_1d629 $7bee, $0c, $63f8, $0c ; $20
	data_1d629 $7d1a, $0c, $6744, $0c ; $21
	data_1d629 $7e23, $0c, $69f6, $0c ; $22
	data_1d629 $7e4f, $0c, $6aa1, $0c ; $23
	data_1d629 $729f, $0d, $4f84, $0d ; $24
	data_1d629 $72e1, $0d, $5007, $0d ; $25
	data_1d629 $647a, $0d, $4000, $0d ; $26
	data_1d629 $6886, $0d, $437c, $0d ; $27
	data_1d629 $6ae2, $0d, $4749, $0d ; $28
	data_1d629 $7002, $0d, $4ca7, $0d ; $29
	data_1d629 $730d, $0d, $50ab, $0d ; $2a
	data_1d629 $737b, $0d, $515a, $0d ; $2b
	data_1d629 $4725, $10, $5758, $0d ; $2c
	data_1d629 $51b4, $10, $5b6d, $0d ; $2d
	data_1d629 $5200, $10, $5c49, $0d ; $2e
	data_1d629 $522c, $10, $5ccc, $0d ; $2f
	data_1d629 $5306, $10, $5d42, $0d ; $30
	data_1d629 $5374, $10, $5e34, $0d ; $31
	data_1d629 $53f4, $10, $5ed9, $0d ; $32
	data_1d629 $547b, $10, $5f78, $0d ; $33
	data_1d629 $552c, $10, $6042, $0d ; $34
	data_1d629 $555f, $10, $60bb, $0d ; $35
	data_1d629 $5554, $10, $609d, $0d ; $36
	data_1d629 $556a, $10, $60f5, $0d ; $37
	data_1d629 $7779, $0d, $614c, $0d ; $38
	data_1d629 $58e0, $08, $6437, $0d ; $39
	data_1d629 $5761, $08, $644b, $0d ; $3a
	data_1d629 $75ee, $1a, $7028, $1a ; $3b
	data_1d629 $76ec, $1a, $71d3, $1a ; $3c
	data_1d629 $766d, $1a, $714e, $1a ; $3d
	data_1d629 $57bb, $07, $57bb, $07 ; $3e
	data_1d629 $770d, $1a, $727c, $1a ; $3f
	data_1d629 $7718, $1a, $72b6, $1a ; $40
	data_1d629 $7933, $1a, $74fd, $1a ; $41
	data_1d629 $55a3, $10, $4680, $10 ; $42
; 0x1d7bb

SECTION "Func_1d7bc", ROMX[$57bc], BANK[$7]

; fill in tables used by Multiply
Func_1d7bc:
	ld de, wd700
	ld hl, 0
	jr .start
.loop
	ld a, e
	add a ; *2
	ld c, a
	ld a, 0
	adc 0
	ld b, a
	inc bc ; +1
	add hl, bc
	inc e
.start
	ld a, h
	ld [de], a ; to wd700 table
	inc d
	ld a, l
	ld [de], a ; to wd800 table
	dec d
	ld a, e
	inc a
	jr nz, .loop
	ret
; 0x1d7da

SECTION "CopyAbilityIconsGfx", ROMX[$57dc], BANK[$7]

CopyAbilityIconsGfx:: INCBIN "gfx/copy_abilities.2bpp"
; 0x1da1c

SECTION "Func_1da7c", ROMX[$5a7c], BANK[$7]

Func_1da7c:
	; init score
	ld hl, wScore
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	; init copy ability
	ld hl, wCopyAbility
	ld [hl], a

	ld hl, wdee1
	ld [hl], a
	ld hl, wdee9
	ld [hl], a
	ld hl, wdeea
	ld [hl], a
	ld hl, wdee3
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $05
	ld hl, wdeeb
	ld [hl], a
	ld hl, wdeec
	ld [hl], a
	ret
; 0x1daa4

SECTION "Func_1dada", ROMX[$5ada], BANK[$7]

Func_1dada::
	xor a
	ld [wObjDisabled], a
	ld hl, wNextStatTrampoline
	ld a, LOW(Func_2aa)
	ld [hli], a
	ld [hl], HIGH(Func_2aa)
	ld hl, wStatTrampoline + $1
	ld a, LOW(Func_2aa)
	ld [hli], a
	ld [hl], HIGH(Func_2aa)

	ld a, $7f
	ldh [rLYC], a
	ld [wLYC], a

	xor a
	ld hl, rSCY
	ld [hli], a
	ld [hl], a ; rSCX
	ld [wda01], a
	ld [wda00], a

	ld a, LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_WIN9C00
	ldh [rLCDC], a
	ret

; input:
; - b = LYC value
Func_1db06:
	ld hl, wLYC
	ld a, b
	ld [hl], a
	ldh [rLYC], a

	ld hl, wNextStatTrampoline
	ld a, LOW(Func_30c)
	ld [hli], a
	ld [hl], HIGH(Func_30c)

	; switch on LYC==LY
	ld hl, rSTAT
	set STATB_LYC, [hl]
	ret
; 0x1db1b

SECTION "Func_1db28", ROMX[$5b28], BANK[$7]

Func_1db28::
	ld hl, wStatTrampoline + 1
	ld a, LOW(Func_2aa)
	ld [hli], a
	ld [hl], HIGH(Func_2aa)
	ld hl, wNextStatTrampoline
	ld a, LOW(Func_2aa)
	ld [hli], a
	ld [hl], HIGH(Func_2aa)

	ld a, $7f
	ldh [rLYC], a
	ld [wLYC], a

	ld c, 20
	ld de, $5b5d
	hlbgcoord 0, 0, vBGMap1
.loop_copy_1
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .loop_copy_1

	; c = $100
	hlbgcoord 0, 1, vBGMap1
.loop_copy_2
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .loop_copy_2

	ld hl, wHUDUpdateFlags
	xor a
	ld [hli], a ; wHUDUpdateFlags
	ld [hl], a  ; wdedf
	ret
; 0x1db5d

SECTION "UpdateHUD", ROMX[$5b85], BANK[$7]

UpdateHUD::
	ld hl, wHUDUpdateFlags
	ld b, [hl]
	bit 7, b
	jp nz, .asm_1dbba

	bit UPDATE_KIRBY_HP_F, b
	call nz, UpdateHUDKirbyHP
	bit UPDATE_LIVES_F, b
	call nz, UpdateHUDLives
	bit UPDATE_COPY_ABILITY_F, b
	call nz, UpdateHUDCopyAbilityIcon
	bit UPDATE_STARS_F, b
	call nz, UpdateHUDStars
	bit UPDATE_LEVEL_F, b
	call nz, UpdateHUDLevel

	ld hl, wdedf
	bit 0, [hl]
	jr nz, .boss_battle
	bit UPDATE_SCORE_F, b
	call nz, UpdateHUDScore
	ret
.boss_battle
	bit UPDATE_BOSS_HP_F, b
	call nz, UpdateHUDBossHP
	ret

.asm_1dbba
	ld hl, wdee9
	ld a, [hl]
	and a
	jr z, .do_call
	dec a
	ld [hl], a
	ret
.do_call
	ld de, wdee6
	ld a, [de]
	ld l, a
	inc e
	ld a, [de]
	ld h, a
	inc e
	ld a, [de]
	jp Farcall

	ret ; stray ret

Func_1dbd2::
	ld hl, wdedf
	bit 0, [hl]
	call nz, Func_1dc12
	ld hl, wdedf
	bit 1, [hl]
	jr nz, .asm_1dbe9
	ld de, sa000Unk4c
	ld hl, wdee3
	jr .asm_1dbef
.asm_1dbe9
	ld de, sa000Unk72
	ld hl, wdee5
.asm_1dbef
	ld a, [de]
	cp [hl]
	ret z
	jr nc, .asm_1dc01
	ld a, [de]
	ld [hl], a
	ld hl, wdeeb
	xor a
	ld [hl], a
	ld hl, wHUDUpdateFlags
	set UPDATE_KIRBY_HP_F, [hl]
	ret
.asm_1dc01
	ld hl, wdeeb
	ld a, [hl]
	and a
	jr z, .asm_1dc0b
	dec a
	ld [hl], a
	ret
.asm_1dc0b
	ld a, $05
	ld [hl], a
	call Func_1dd36
	ret

Func_1dc12:
	call Func_1dc39
	ld hl, wdee4
	cp [hl]
	ret z
	jr nc, .asm_1dc28
	ld [hl], a
	ld hl, wdeec
	xor a
	ld [hl], a
	ld hl, wHUDUpdateFlags
	set UPDATE_BOSS_HP_F, [hl]
	ret
.asm_1dc28
	ld hl, wdeec
	ld a, [hl]
	and a
	jr z, .asm_1dc32
	dec a
	ld [hl], a
	ret
.asm_1dc32
	ld a, $05
	ld [hl], a
	call Func_1ddbb
	ret

Func_1dc39:
	push bc
	push hl
	xor a
	ld b, a ; $00
	ld d, a ; $00
	ld hl, sa000Unk85
	ld a, [hl]
	add a
	incc b
	add a ; *4
	rl b
	ld l, a
	ld h, b
	add a
	rl b
	add l ; *5
	ld c, a
	ld a, b
	adc h
	ld b, a
	ld hl, sa000Unk86
	ld e, [hl]
	ld a, c
.asm_1dc58
	ld c, a
	sub e
	jr nc, .asm_1dc61
	dec b
	bit 7, b
	jr nz, .asm_1dc64
.asm_1dc61
	inc d
	jr .asm_1dc58
.asm_1dc64
	ld a, c
	and a
	ld a, d
	jr z, .asm_1dc6a
	inc a
.asm_1dc6a
	pop hl
	pop bc
	ret

UpdateHUDScore:
	ld a, $07
	call Func_675
	ret c

	push bc
	debgcoord 1, 1, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 7 ; number of digit tiles
	inc l
	ld c, $70
	ld de, wScore
	ld a, [de]
	ld b, a
	inc de
	ld b, a
	swap a
	and $0f
	add c
	ld [hl], a
	inc l
	ld a, b
	and $0f
	add c
	ld [hl], a
	inc l
	ld a, [de]
	inc de
	ld b, a
	swap a
	and $0f
	add c
	ld [hl], a
	inc l
	ld a, b
	and $0f
	add c
	ld [hl], a
	inc l
	ld a, [de]
	ld b, a
	swap a
	and $0f
	add c
	ld [hl], a
	inc l
	ld a, b
	and $0f
	add c
	ld [hl], a
	inc l
	ld a, c
	ld [hl], a
	inc l
	ld a, l
	ldh [hBGMapQueueSize], a
	pop bc
	ld hl, wHUDUpdateFlags
	res UPDATE_SCORE_F, b
	ld [hl], b
	ret

UpdateHUDKirbyHP:
	ld a, $07
	call Func_675
	ret c

	debgcoord 1, 0, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 7 ; number of digit tiles
	inc l
	ld [hl], $7b ; K
	inc l

	ld de, wdedf
	ld a, [de]
	bit 1, a
	jr nz, .asm_1dd13
	ld de, sa000Unk4c
	ld a, [de]
	ld d, 6
.asm_1dcec
	and a
	jr z, .asm_1dcff
	sub $02
	jr c, .asm_1dcfb
	ld [hl], $64
	inc l
	dec d
	jr nz, .asm_1dcec
	jr .asm_1dd09
.asm_1dcfb
	dec d
	ld [hl], $6e
	inc l
.asm_1dcff
	ld a, d
	and a
	jr z, .asm_1dd09
	ld [hl], $63
	inc l
	dec d
	jr nz, .asm_1dcff
.asm_1dd09
	ld a, l
	ldh [hBGMapQueueSize], a
	ld hl, wHUDUpdateFlags
	res UPDATE_KIRBY_HP_F, b
	ld [hl], b
	ret

.asm_1dd13
	ld a, [sa000Unk72]
	ld d, 6
	and a
	jr z, .asm_1dd22
.asm_1dd1b
	ld [hl], $64
	inc l
	dec d
	dec a
	jr nz, .asm_1dd1b
.asm_1dd22
	ld a, d
	and a
	jr z, .asm_1dd2c
.asm_1dd26
	ld [hl], $63
	inc l
	dec d
	jr nz, .asm_1dd26
.asm_1dd2c
	ld a, l
	ldh [hBGMapQueueSize], a
	ld hl, wHUDUpdateFlags
	res UPDATE_KIRBY_HP_F, b
	ld [hl], b
	ret

Func_1dd36:
	ld a, $07
	call Func_675
	jr nc, .asm_1dd43
	ld hl, wdeeb
	ld [hl], $00
	ret
.asm_1dd43
	debgcoord 1, 0, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 7
	inc l
	ld [hl], $7b
	inc l
	ld de, wdedf
	ld a, [de]
	bit 1, a
	jr nz, .asm_1dd91
	ld de, wdee3
	ld a, [de]
	inc a
	inc a
	ld [de], a
	ld d, $06
.asm_1dd66
	and a
	jr z, .asm_1dd79
	sub $02
	jr c, .asm_1dd75
	ld [hl], $64
	inc l
	dec d
	jr nz, .asm_1dd66
	jr .asm_1dd83
.asm_1dd75
	dec d
	ld [hl], $6e
	inc l
.asm_1dd79
	ld a, d
	and a
	jr z, .asm_1dd83
	ld [hl], $63
	inc l
	dec d
	jr nz, .asm_1dd79
.asm_1dd83
	ld a, l
	ldh [hBGMapQueueSize], a
	ld e, SFX_12
	farcall PlaySFX
	ret
.asm_1dd91
	ld de, wdee5
	ld a, [de]
	inc a
	ld [de], a
	ld d, $06
.asm_1dd99
	and a
	jr z, .asm_1dda3
	ld [hl], $64
	inc l
	dec a
	dec d
	jr nz, .asm_1dd99
.asm_1dda3
	ld a, d
	and a
	jr z, .asm_1ddad
	ld [hl], $63
	inc l
	dec d
	jr nz, .asm_1dda3
.asm_1ddad
	ld a, l
	ldh [hBGMapQueueSize], a
	ld e, SFX_12
	farcall PlaySFX
	ret

Func_1ddbb:
	ld a, $07
	call Func_675
	ret c

	debgcoord 1, 1, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 7
	inc l
	ld [hl], $7a
	inc l
	ld de, wdee4
	ld a, [de]
	inc a
	ld [de], a
	ld d, $06
.asm_1dddb
	and a
	jr z, .asm_1ddee
	sub $02
	jr c, .asm_1ddea
	ld [hl], $6f
	inc l
	dec d
	jr nz, .asm_1dddb
	jr .asm_1ddf8
.asm_1ddea
	dec d
	ld [hl], $6e
	inc l
.asm_1ddee
	ld a, d
	and a
	jr z, .asm_1ddf8
	ld [hl], $6d
	inc l
	dec d
	jr nz, .asm_1ddee
.asm_1ddf8
	ld a, l
	ldh [hBGMapQueueSize], a
	ld e, SFX_12
	farcall PlaySFX
	ret

UpdateHUDStars:
	ld a, $07
	call Func_675
	ret c

	debgcoord 9, 0, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 7
	inc l
	ld de, wdee1
	ld a, [de]
	and a
	jr z, .zero_stars
	ld [hl], $68
	inc l
	dec a
	jr z, .one_star
	ld [hl], $68
	inc l
	dec a
	jr z, .two_stars
	ld [hl], $68
	inc l
	dec a
	jr z, .three_stars
	ld [hl], $68
	inc l
	dec a
	jr z, .four_stars
	ld [hl], $68
	inc l
	dec a
	jr z, .five_stars
	ld [hl], $68
	inc l
	dec a
	jr z, .six_stars
	ld [hl], $68
	inc l
	jr .seven_stars
.zero_stars
	ld [hl], $67
	inc l
.one_star
	ld [hl], $67
	inc l
.two_stars
	ld [hl], $67
	inc l
.three_stars
	ld [hl], $67
	inc l
.four_stars
	ld [hl], $67
	inc l
.five_stars
	ld [hl], $67
	inc l
.six_stars
	ld [hl], $67
	inc l
.seven_stars
	ld a, l
	ldh [hBGMapQueueSize], a
	ld hl, wHUDUpdateFlags
	res UPDATE_STARS_F, b
	ld [hl], b
	ret

UpdateHUDLevel:
	ld a, $01
	call Func_675
	ret c

	debgcoord 15, 1, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 1
	inc l
	ld a, [wLevel]
	inc a ; +1
	ld e, $70
	add e
	ld [hl], a
	inc l
	ld a, l
	ldh [hBGMapQueueSize], a
	ld hl, wHUDUpdateFlags
	res UPDATE_LEVEL_F, b
	ld [hl], b
	ret

UpdateHUDLives:
	ld a, $03
	call Func_675
	ret c

	debgcoord 9, 1, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 3
	inc l
	ld [hl], $7c
	inc l
	ld de, sa000Unk84
	ld a, [de]
	ld d, $70
	ld e, a
	swap a
	and $0f
	add d
	ld [hl], a
	inc l
	ld a, e
	and $0f
	add d
	ld [hl], a
	inc l
	ld a, l
	ldh [hBGMapQueueSize], a
	ld hl, wHUDUpdateFlags
	res UPDATE_LIVES_F, b
	ld [hl], b
	ret

UpdateHUDCopyAbilityIcon:
	ld a, $40
	call Func_675
	ret c

	; load graphics for copy ability icons
	push bc
	ld de, vTiles2 tile $69
	ldh a, [hBGMapQueueSize]
	ld c, a
	ld b, HIGH(wBGMapQueue)
	ld a, e
	ld [bc], a
	inc c
	ld a, d
	ld [bc], a
	inc c
	ld a, 4 tiles
	ld [bc], a
	inc c
	ld de, wCopyAbility
	ld a, [de]
	swap a
	ld l, a
	and $0f
	ld h, a
	ld a, l
	and $f0
	ld l, a
	sla l
	rl h
	sla l
	rl h
	; hl = wCopyAbility * (4 tiles)

	; unnecessary bankswitch
	; will lead to bug if bank isn't $7
	ld a, BANK(CopyAbilityIconsGfx)
	call Bankswitch
	ld de, CopyAbilityIconsGfx
	add hl, de
	ld d, 4 tiles
.loop_copy
	ld a, [hli]
	ld [bc], a
	inc c
	dec d
	jr nz, .loop_copy
	ld a, c
	ldh [hBGMapQueueSize], a
	pop bc
	ld hl, wHUDUpdateFlags
	res UPDATE_COPY_ABILITY_F, b
	ld [hl], b
	ret

UpdateHUDBossHP:
	ld a, $07
	call Func_675
	ret c

	debgcoord 1, 1, vBGMap1
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], 7
	inc l
	ld [hl], $7a
	inc l
	call Func_1dc39
	ld d, $06
.asm_1df30
	and a
	jr z, .asm_1df43
	sub $02
	jr c, .asm_1df3f
	ld [hl], $6f
	inc l
	dec d
	jr nz, .asm_1df30
	jr .asm_1df4d
.asm_1df3f
	dec d
	ld [hl], $6e
	inc l
.asm_1df43
	ld a, d
	and a
	jr z, .asm_1df4d
	ld [hl], $6d
	inc l
	dec d
	jr nz, .asm_1df43
.asm_1df4d
	ld a, l
	ldh [hBGMapQueueSize], a
	ld hl, wHUDUpdateFlags
	res UPDATE_BOSS_HP_F, b
	ld [hl], b
	ret
; 0x1df57

SECTION "TitleScreen", ROMX[$5fee], BANK[$7]

TitleScreen:
	; set time to switch to Demo
	; after entering Title Screen
	ld hl, wTitleScreenDemoTimer
	ld a, LOW(DEMO_TIMER)
	ld [hli], a
	ld [hl], HIGH(DEMO_TIMER)

	ld hl, $6107
	ld de, vTiles0
	call Decompress
	ld hl, vTiles0
	ld de, vTiles2
	ld bc, $80 tiles
	call CopyHLToDE

	ld hl, $697d
	debgcoord 0, 0, vBGMap0
	call Decompress

	; load Kirby graphics
	ld a, $0b
	ld hl, $68a0
	ld de, vTiles0
	call FarDecompress

	ld a, BANK(Gfx_24000)
	ld hl, Gfx_24000
	ld de, vTiles0 tile $10
	ld bc, $28 tiles
	call FarCopyHLToDE

	ld a, BANK(Gfx_24280)
	ld hl, Gfx_24280
	ld de, vTiles0 tile $38
	ld bc, $22 tiles
	call FarCopyHLToDE

	farcall Func_20000

	ld a, $f8
	lb hl, HIGH(sObjects), HIGH(sObjectsEnd)
	call CreateObject

	xor a
	ld [wdf02], a
	ld hl, wcd09
	ld a, $e4
	ld [hli], a
	ld a, $d0
	ld [hli], a
	ld a, $e4
	ld [hl], a

	ld e, SFX_NONE
	farcall PlaySFX

	ld e, MUSIC_TITLE_SCREEN
	farcall PlayMusic

	call Func_1584

	ld a, LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d

	ld e, SGB_ATF_08
	farcall Func_7a011

	lb de, $00, $04
	farcall Func_68246

	ld e, SGB_SFX_APPLAUSE
	farcall SGBPlaySFX

	; short delay before accepting input
	ld a, 32
.wait_delay
	push af
	call Func_496
	farcall UpdateObjects
	call Func_4ae
	call DoFrame
	call ReadJoypad
	pop af
	dec a
	jr nz, .wait_delay

.wait_input_or_demo
	call Func_496
	farcall UpdateObjects
	call UpdateRNG
	call Func_4ae
	call DoFrame
	call ReadJoypad

	ld a, [wdf02]
	or a
	jr nz, .end_due_to_input

	; tick down wTitleScreenDemoTimer
	ld hl, wTitleScreenDemoTimer
	ld a, [hl]
	sub 1
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hld], a
	or [hl]
	jr nz, .wait_input_or_demo

	farcall Func_21e92
	jr .end_due_to_demo_timer

.end_due_to_input
	xor a ; NO_DEMO
	ld [wNextDemo], a
	jp Func_437

.end_due_to_demo_timer
	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX
	lb de, $00, $04
	farcall Func_6827b
	jp Func_437
; 0x1e107

SECTION "Data_1f700", ROMX[$7700], BANK[$7], ALIGN[8]

Data_1f700::
	dwb $4001, $01 ; $00
	dwb $45c2, $07 ; $01
	dwb $4c3a, $07 ; $02
	dwb $6ec0, $07 ; $03
	dwb $5409, $03 ; $04
	dwb $5437, $03 ; $05
	dwb $55e3, $03 ; $06
	dwb $4000, $03 ; $07
	dwb $4034, $03 ; $08
	dwb $6328, $03 ; $09
	dwb $659f, $03 ; $0a
	dwb $6609, $03 ; $0b
	dwb $44f1, $03 ; $0c
	dwb $480a, $03 ; $0d
	dwb $5be5, $03 ; $0e
	dwb $40ca, $04 ; $0f
	dwb $4239, $04 ; $10
	dwb $4000, $01 ; $11
	dwb $5f1b, $03 ; $12
	dwb $5fef, $03 ; $13
	dwb $6178, $0e ; $14
	dwb $6800, $03 ; $15
	dwb $687d, $03 ; $16
	dwb $7012, $03 ; $17
	dwb $7191, $03 ; $18
	dwb $4b2d, $05 ; $19
	dwb $4b8f, $05 ; $1a
	dwb $4d3c, $05 ; $1b
	dwb $73f1, $03 ; $1c
	dwb $7966, $03 ; $1d
	dwb $432c, $1a ; $1e
	dwb $45ac, $1a ; $1f
	dwb $45bf, $1a ; $20
	dwb $45c8, $1a ; $21
	dwb $4605, $1a ; $22
	dwb $4899, $07 ; $23
	dwb $46b1, $07 ; $24
	dwb $4926, $07 ; $25
	dwb $7c2d, $04 ; $26
	dwb $7d83, $04 ; $27
	dwb $7add, $03 ; $28
	dwb $7d31, $03 ; $29
	dwb $7d2b, $03 ; $2a
	dwb $7d2c, $03 ; $2b
	dwb $5333, $08 ; $2c
	dwb $5603, $08 ; $2d
	dwb $5782, $08 ; $2e
	dwb $461f, $1a ; $2f
	dwb $581c, $03 ; $30
	dwb $58b1, $03 ; $31
	dwb $409f, $05 ; $32
	dwb $42c2, $05 ; $33
	dwb $5083, $05 ; $34
	dwb $5753, $05 ; $35
	dwb $5b88, $05 ; $36
	dwb $5d8f, $05 ; $37
	dwb $5de5, $05 ; $38
	dwb $608e, $05 ; $39
	dwb $63bc, $05 ; $3a
	dwb $650d, $05 ; $3b
	dwb $668e, $05 ; $3c
	dwb $6694, $05 ; $3d
	dwb $6ae9, $05 ; $3e
	dwb $6c21, $05 ; $3f
	dwb $6e19, $05 ; $40
	dwb $6f41, $05 ; $41
	dwb $72f6, $05 ; $42
	dwb $7909, $05 ; $43
	dwb $6c86, $03 ; $44
	dwb $631e, $0e ; $45
	dwb $6399, $0e ; $46
	dwb $6e2e, $03 ; $47
	dwb $7554, $05 ; $48
	dwb $772b, $05 ; $49
	dwb $7773, $05 ; $4a
	dwb $77cd, $05 ; $4b
	dwb $7826, $05 ; $4c
	dwb $6798, $1c ; $4d
	dwb $6840, $1c ; $4e
	dwb $689c, $1c ; $4f
	dwb $68f9, $1c ; $50
	dwb $69f7, $1c ; $51
	dwb $6a1e, $1c ; $52
	dwb $6a4a, $1c ; $53
	dwb $6a67, $1c ; $54
	dwb $6ac5, $1c ; $55
	dwb $6bd2, $1c ; $56
	dwb $6beb, $1c ; $57
	dwb $6c50, $1c ; $58
	dwb $6c6b, $1c ; $59
	dwb $6c90, $1c ; $5a
	dwb $6cab, $1c ; $5b
	dwb $6cc6, $1c ; $5c
	dwb $6d69, $1c ; $5d
	dwb $6dce, $1c ; $5e
	dwb $6e24, $1c ; $5f
	dwb $6e5b, $1c ; $60
	dwb $6eb2, $1c ; $61
	dwb $6f23, $1c ; $62
	dwb $6f68, $1c ; $63
	dwb $6f83, $1c ; $64
	dwb $6fa1, $1c ; $65
	dwb $7115, $1c ; $66
	dwb $7186, $1c ; $67
	dwb $71ab, $1c ; $68
	dwb $720d, $1c ; $69
	dwb $722e, $1c ; $6a
	dwb $724f, $1c ; $6b
	dwb $7279, $1c ; $6c
	dwb $7296, $1c ; $6d
	dwb $742b, $1c ; $6e
	dwb $7463, $1c ; $6f
	dwb $7494, $1c ; $70
	dwb $74c5, $1c ; $71
	dwb $7530, $1c ; $72
	dwb $7555, $1c ; $73
	dwb $75b6, $1c ; $74
	dwb $762d, $1c ; $75
	dwb $76b4, $1c ; $76
	dwb $5bca, $0e ; $77
	dwb $5c11, $0e ; $78
	dwb $5c3d, $0e ; $79
	dwb $5c69, $0e ; $7a
	dwb $5fde, $0e ; $7b
	dwb $5c95, $0e ; $7c
	dwb $5cda, $0e ; $7d
	dwb $5cf8, $0e ; $7e
	dwb $5d16, $0e ; $7f
	dwb $5d6f, $0e ; $80
	dwb $5d99, $0e ; $81
	dwb $5dbd, $0e ; $82
	dwb $5de1, $0e ; $83
	dwb $5e05, $0e ; $84
	dwb $610c, $0e ; $85
	dwb $5e29, $0e ; $86
	dwb $5e94, $0e ; $87
	dwb $5edf, $0e ; $88
	dwb $5f28, $0e ; $89
	dwb $5fa9, $0e ; $8a
	dwb $6e04, $18 ; $8b
	dwb $74f7, $18 ; $8c
	dwb $751f, $18 ; $8d
	dwb $7543, $18 ; $8e
	dwb $756b, $18 ; $8f
	dwb $7593, $18 ; $90
	dwb $75e1, $18 ; $91
	dwb $768b, $18 ; $92
	dwb $6e87, $18 ; $93
	dwb $72f6, $18 ; $94
	dwb $70e3, $18 ; $95
	dwb $73e6, $18 ; $96
	dwb $7412, $18 ; $97
	dwb $7363, $18 ; $98
	dwb $71d6, $18 ; $99
	dab Script_3c4e6 ; $9a
	dwb $47e3, $0f ; $9b
	dwb $451d, $0f ; $9c
	dwb $4554, $0f ; $9d
	dwb $6c93, $08 ; $9e
	dwb $6cbe, $08 ; $9f
	dwb $5f84, $08 ; $a0
	dwb $4774, $1a ; $a1
	dwb $5ee0, $08 ; $a2
	dwb $60b5, $08 ; $a3
	dwb $4a62, $07 ; $a4
	dwb $4789, $1a ; $a5
	dwb $4807, $1a ; $a6
	dwb $676b, $0f ; $a7
	dab Script_3e920 ; $a8
	dab Script_3ec16 ; $a9
	dab Script_3ec47 ; $aa
	dwb $4eee, $1a ; $ab
	dwb $4f08, $1a ; $ac
	dwb $4f1d, $1a ; $ad
	dwb $4f37, $1a ; $ae
	dwb $4f4c, $1a ; $af
	dwb $4f66, $1a ; $b0
	dwb $4f7b, $1a ; $b1
	dwb $4f95, $1a ; $b2
	dwb $4fb4, $1a ; $b3
	dwb $5121, $1a ; $b4
	dwb $517e, $1a ; $b5
	dwb $51db, $1a ; $b6
	dwb $5238, $1a ; $b7
	dwb $5295, $1a ; $b8
	dwb $52ec, $1a ; $b9
	dwb $5343, $1a ; $ba
	dwb $535d, $1a ; $bb
	dwb $5377, $1a ; $bc
	dwb $5391, $1a ; $bd
	dwb $53ab, $1a ; $be
	dwb $602b, $1a ; $bf
	dwb $625c, $1a ; $c0
	dwb $69f6, $1a ; $c1
	dwb $6eeb, $1a ; $c2
	dwb $6267, $1a ; $c3
	dwb $6371, $1a ; $c4
	dwb $63af, $1a ; $c5
	dwb $64ec, $1a ; $c6
	dwb $68e8, $1a ; $c7
	dwb $6940, $1a ; $c8
	dwb $694e, $1a ; $c9
	dwb $4187, $06 ; $ca
	dwb $46c1, $06 ; $cb
	dwb $4124, $0e ; $cc
	dwb $492c, $0e ; $cd
	dwb $5d19, $0f ; $ce
	dwb $5d44, $0f ; $cf
	dwb $5dbe, $0f ; $d0
	dwb $5bd0, $06 ; $d1
	dwb $5c11, $06 ; $d2
	dwb $7230, $06 ; $d3
	dwb $40c8, $1d ; $d4
	dwb $4921, $1d ; $d5
	dwb $4d39, $1d ; $d6
	dwb $5c45, $1d ; $d7
	dwb $63c5, $1d ; $d8
	dwb $74bf, $1d ; $d9
	dwb $4379, $19 ; $da
	dwb $4409, $19 ; $db
	dwb $440d, $19 ; $dc
	dwb $447f, $19 ; $dd
	dwb $4437, $19 ; $de
	dwb $4513, $19 ; $df
	dwb $4548, $19 ; $e0
	dwb $4c50, $19 ; $e1
	dwb $4571, $19 ; $e2
	dwb $4c9d, $19 ; $e3
	dwb $4cb9, $19 ; $e4
	dwb $4cd5, $19 ; $e5
	dwb $4cf1, $19 ; $e6
	dwb $4d0d, $19 ; $e7
	dwb $4d29, $19 ; $e8
	dwb $4d45, $19 ; $e9
	dwb $4d61, $19 ; $ea
	dwb $4d7d, $19 ; $eb
	dwb $4d99, $19 ; $ec
	dwb $4db5, $19 ; $ed
	dwb $4dd1, $19 ; $ee
	dwb $4ded, $19 ; $ef
	dwb $4e09, $19 ; $f0
	dwb $4e25, $19 ; $f1
	dwb $4e41, $19 ; $f2
	dwb $4e5d, $19 ; $f3
	dwb $4e8b, $19 ; $f4
	dwb $7aed, $19 ; $f5
	dwb $662c, $0e ; $f6
	dwb $6d03, $0e ; $f7
	dab Script_218e7 ; $f8
; 0x1e9eb

SECTION "Func_1f458", ROMX[$7458], BANK[$7]

Func_1f458::
	ld a, [sa000Unk71]
	ld hl, .data
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld [wdf11], a
	ret

.data
	db $00, $09, $12, $1b
; 0x1f46c

SECTION "Data_1f472", ROMX[$7472], BANK[$7]

Func_1f472::
	ld a, [sa000Unk71]
	ld hl, .data
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld hl, sa000Unk5b
	add [hl]
	inc a
	ld [wdf11], a
	ret

.data
	db $01, $0a, $13, $1c
; 0x1f48b

SECTION "Data_1f4bb", ROMX[$74bb], BANK[$7]

MACRO data_1f4bb
	dw  \1       ; destination
	dab \2       ; source
	dw  \3 tiles ; number of tiles
ENDM

Data_1f4bb::
	data_1f4bb vTiles0 tile $10, Gfx_24000, $28 ; $00
	data_1f4bb vTiles0 tile $38, Gfx_24280, $22 ; $01
	data_1f4bb vTiles0 tile $38, Gfx_244a0, $1e ; $02
	data_1f4bb vTiles0 tile $38, Gfx_24680, $28 ; $03
	data_1f4bb vTiles0 tile $38, Gfx_24900, $16 ; $04
	data_1f4bb vTiles0 tile $38, Gfx_24a60, $1a ; $05
	data_1f4bb vTiles0 tile $38, Gfx_24c00, $26 ; $06
	data_1f4bb vTiles0 tile $38, Gfx_24e60, $16 ; $07
	data_1f4bb vTiles0 tile $38, Gfx_24fc0, $1a ; $08
	data_1f4bb vTiles0 tile $10, Gfx_25160, $2c ; $09
	data_1f4bb vTiles0 tile $3c, Gfx_25420, $24 ; $0a
	data_1f4bb vTiles0 tile $3c, Gfx_25660, $20 ; $0b
	data_1f4bb vTiles0 tile $3c, Gfx_25860, $24 ; $0c
	data_1f4bb vTiles0 tile $3c, Gfx_25aa0, $20 ; $0d
	data_1f4bb vTiles0 tile $3c, Gfx_25ce0, $24 ; $0e
	data_1f4bb vTiles0 tile $3c, Gfx_25f20, $1c ; $0f
	data_1f4bb vTiles0 tile $3c, Gfx_26160, $1a ; $10
	data_1f4bb vTiles0 tile $3c, Gfx_26300, $1e ; $11
	data_1f4bb vTiles0 tile $10, Gfx_264e0, $2c ; $12
	data_1f4bb vTiles0 tile $3c, Gfx_267a0, $24 ; $13
	data_1f4bb vTiles0 tile $3c, Gfx_269e0, $22 ; $14
	data_1f4bb vTiles0 tile $3c, Gfx_26c00, $22 ; $15
	data_1f4bb vTiles0 tile $3c, Gfx_26e40, $24 ; $16
	data_1f4bb vTiles0 tile $3c, Gfx_27080, $24 ; $17
	data_1f4bb vTiles0 tile $3c, Gfx_272c0, $18 ; $18
	data_1f4bb vTiles0 tile $3c, Gfx_27440, $24 ; $19
	data_1f4bb vTiles0 tile $3c, Gfx_27680, $1e ; $1a
	data_1f4bb vTiles0 tile $10, Gfx_27860, $30 ; $1b
	data_1f4bb vTiles0 tile $40, Gfx_28000, $20 ; $1c
	data_1f4bb vTiles0 tile $40, Gfx_28200, $1e ; $1d
	data_1f4bb vTiles0 tile $40, Gfx_28400, $20 ; $1e
	data_1f4bb vTiles0 tile $40, Gfx_28600, $1e ; $1f
	data_1f4bb vTiles0 tile $40, Gfx_28800, $1c ; $20
	data_1f4bb vTiles0 tile $40, Gfx_289c0, $18 ; $21
	data_1f4bb vTiles0 tile $40, Gfx_28bc0, $18 ; $22
	data_1f4bb vTiles0 tile $40, Gfx_28d40, $20 ; $23
	data_1f4bb vTiles0 tile $10, Gfx_2c000, $3a ; $24
	data_1f4bb vTiles1 tile $06, Gfx_2c3a0, $50 ; $25
	data_1f4bb vTiles1 tile $06, Gfx_2c8a0, $58 ; $26
	data_1f4bb vTiles1 tile $06, Gfx_2ce20, $54 ; $27
	data_1f4bb vTiles1 tile $24, Gfx_2c3a0, $50 ; $28
	data_1f4bb vTiles1 tile $24, Gfx_2c8a0, $58 ; $29
	data_1f4bb vTiles1 tile $24, Gfx_2ce20, $54 ; $2a
	data_1f4bb vTiles0 tile $10, Gfx_2c3a0, $50 ; $2b
	data_1f4bb vTiles0 tile $10, Gfx_2c8a0, $58 ; $2c
	data_1f4bb vTiles0 tile $10, Gfx_2ce20, $54 ; $2d
	data_1f4bb vTiles0 tile $00, Gfx_42571, $60 ; $2e
	data_1f4bb vTiles1 tile $06, Gfx_42b71, $6a ; $2f
	data_1f4bb vTiles0 tile $00, Gfx_6b9fd, $0c ; $30
	data_1f4bb vTiles0 tile $00, Gfx_6bacd, $10 ; $31
	data_1f4bb vTiles0 tile $00, Gfx_6bbcd, $0c ; $32
	data_1f4bb vTiles0 tile $38, Gfx_43211, $0c ; $33
	data_1f4bb vTiles0 tile $3c, Gfx_27680, $1e ; $34
	data_1f4bb vTiles0 tile $10, Gfx_27860, $30 ; $35
	data_1f4bb vTiles0 tile $40, Gfx_28000, $20 ; $36
	data_1f4bb vTiles0 tile $40, Gfx_28200, $1e ; $37
	data_1f4bb vTiles0 tile $40, Gfx_28400, $20 ; $38
	data_1f4bb vTiles0 tile $40, Gfx_28600, $1e ; $39
	data_1f4bb vTiles0 tile $40, Gfx_28800, $1c ; $3a
	data_1f4bb vTiles0 tile $40, Gfx_289c0, $18 ; $3b
	data_1f4bb vTiles0 tile $40, Gfx_28bc0, $18 ; $3c
	data_1f4bb vTiles0 tile $40, Gfx_28d40, $20 ; $3d
	data_1f4bb vTiles0 tile $10, Gfx_2c000, $3a ; $3e
	data_1f4bb vTiles1 tile $06, Gfx_2c3a0, $50 ; $3f
	data_1f4bb vTiles1 tile $06, Gfx_2c8a0, $58 ; $40
	data_1f4bb vTiles1 tile $06, Gfx_2ce20, $54 ; $41
	data_1f4bb vTiles1 tile $24, Gfx_2c3a0, $50 ; $42
	data_1f4bb vTiles1 tile $24, Gfx_2c8a0, $58 ; $43
	data_1f4bb vTiles1 tile $24, Gfx_2ce20, $54 ; $44
	data_1f4bb vTiles0 tile $10, Gfx_2c3a0, $50 ; $45
	data_1f4bb vTiles0 tile $10, Gfx_2c8a0, $58 ; $46
	data_1f4bb vTiles0 tile $10, Gfx_2ce20, $54 ; $47
	data_1f4bb vTiles0 tile $00, Gfx_42571, $60 ; $48
	data_1f4bb vTiles1 tile $06, Gfx_42b71, $6a ; $49
	data_1f4bb vTiles0 tile $00, Gfx_6b9fd, $0c ; $4a
	data_1f4bb vTiles0 tile $00, Gfx_6bacd, $10 ; $4b
	data_1f4bb vTiles0 tile $00, Gfx_6bbcd, $0c ; $4c
	data_1f4bb vTiles0 tile $38, Gfx_43211, $0c ; $4d
; 0x1f6dd

SECTION "Data_1fa00", ROMX[$7a00], BANK[$7]

Data_1fa00:
	db $04, $06, $06, $06, $06, $05, $05, $05, $05, $04, $08, $08, $0c, $0e, $0e, $0f
	db $0f, $11, $12, $12, $12, $12, $09, $09, $0a, $0a, $14, $14, $15, $15, $15, $15
	db $17, $17, $17, $17, $17, $17, $17, $17, $17, $17, $17, $17, $18, $18, $18, $18
	db $18, $18, $18, $18, $18, $18, $1c, $1c, $1c, $1c, $1c, $1c, $1e, $1e, $1e, $19
	db $19, $19, $19, $1b, $1b, $26, $26, $1b, $1b, $26, $26, $17, $28, $28, $28, $28
	db $30, $30, $26, $26, $26, $26, $26, $26, $32, $a1, $a2, $a5, $a5, $a5, $a5, $a5
	db $a5, $a5, $a5, $a6, $26, $26, $26, $26, $28, $28, $28, $28, $34, $34, $35, $35
	db $35, $35, $ca, $cc, $17, $d1, $d4, $36, $36, $36, $36, $37, $37, $39, $39, $d6
	db $d8, $22, $1e, $1e, $3a, $3a, $3b, $3b, $3d, $3d, $40, $40, $40, $40, $40, $40
	db $42, $42, $42, $42, $42, $42, $45, $45, $45, $45, $3e, $3e, $3e, $3e, $3f, $3f
	db $2c, $29, $2e, $2e, $05, $05, $05, $05, $1c, $1c, $1c, $1c, $1c, $1c, $44, $44
	db $44, $44, $2a, $47, $47, $47, $47, $2d, $bf, $c0, $c3, $c4, $c1, $11, $11, $11
	db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $2b, $c0, $c5
	db $c0, $09, $08, $c6, $2e, $15, $15, $15, $15, $15, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $80, $00, $00, $00

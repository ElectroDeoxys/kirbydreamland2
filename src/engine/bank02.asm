Script_8000:
	script_call .Script_8021
	set_field OBJSTRUCT_UNK3C, $00
	set_var_to_field OBJSTRUCT_UNK45
	set_field_to_var OBJSTRUCT_UNK3B
	set_oam $572c, $0a ; OAM_2972c
	exec_asm Func_b4a7
	var_jumptable 7
	dw Script_8025
	dw $40f5 ; .script_80f5
	dw $42bd ; .script_82bd
	dw $42bd ; .script_82bd
	dw $4a50 ; .script_8a50
	dw $4add ; .script_8add
	dw $4bb6 ; .script_8bb6

.Script_8021:
	set_field OBJSTRUCT_UNK51, $05
	script_ret

Script_8025:
	set_field OBJSTRUCT_UNK50, $00
	set_update_func1 ASM, Func_8040
	script_call Script_3a5c
	set_var_to_field OBJSTRUCT_UNK3C
	jump_if_not_var .loop
	script_call Script_80d7
.loop
	set_frame_wait 2, 30
	set_frame_wait 1, 15
	jump .loop

Func_8040:
	call Func_359a
	call Func_3602
	call Func_80c0
	jr nc, .asm_8053
	ld e, BANK(Script_8025)
	ld bc, Script_8025
	call Func_846
.asm_8053
	farcall Func_22e10
	call Func_b926
	call Func_391a
	call Func_b5a1
	jr nc, .asm_806e
	ld e, $02
	ld bc, $42bd
	jp Func_37f4
.asm_806e
	ldh a, [hJoypad1Pressed]
	and $01
	jr z, .asm_807c
	ld e, $02
	ld bc, $41ed
	jp Func_37f4
.asm_807c
	call Func_3650
	jr nc, .asm_8089
	ld e, $02
	ld bc, $4393
	jp Func_37f4
.asm_8089
	call Func_b663
	jr nc, .asm_8096
	ld e, $02
	ld bc, $40f5
	jp Func_37f4
.asm_8096
	call Func_369d
	jr nc, .asm_80a3
	ld e, $02
	ld bc, $4352
	jp Func_37f4
.asm_80a3
	call Func_36e6
	jr nc, .asm_80b0
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_80b0
	call Func_3724
	jr nc, .asm_80bd
	ld e, $01
	ld bc, $40f9
	jp Func_37f4
.asm_80bd
	jp Func_37f7

Func_80c0:
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	ld b, a
	ld e, OBJSTRUCT_UNK3B
	ld a, [de]
	xor b
	rla
	ret nc
	ld a, b
	ld [de], a ; OBJSTRUCT_UNK3B
	ld a, $07
	ld e, OBJSTRUCT_UNK3C
	ld [de], a
	ld a, $04
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	ret

Script_80d7:
.loop
	exec_asm Func_80e2
	wait 1
	set_var_to_field OBJSTRUCT_UNK3C
	jump_if_var .loop
	script_ret

Func_80e2:
	ld e, OBJSTRUCT_UNK3C
	ld a, [de]
	cp $04
	ld a, $4
	jr nc, .asm_80ec
	dec a
.asm_80ec
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	; tick down Unk3c
	ld e, OBJSTRUCT_UNK3C
	ld a, [de]
	dec a
	ld [de], a
	ret
; 0x80f5

SECTION "Func_9ccf", ROMX[$5ccf], BANK[$02]

Func_9ccf:
	ld a, [wdb76]
	or a
	ret z
	ld a, [wda36]
	or a
	ret nz
	ld hl, wBGP
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [hli], a
	ldpal a, SHADE_WHITE, SHADE_WHITE, SHADE_LIGHT, SHADE_BLACK
	ld [hli], a
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [hli], a
	ret
; 0x9ce6

SECTION "Func_b47d", ROMX[$747d], BANK[$02]

Func_b47d::
	ld a, [sa000Unk51]
	ld hl, .data
	add l
	ld l, a
	incc h
	ld a, [hl]
	or a
	jr z, .done
	ld [sa000Unk5b], a ; NO_COPY_ABILITY
	inc a
	ld [wCopyAbilityIcon], a ; NONE
	ld hl, wHUDUpdateFlags
	set UPDATE_COPY_ABILITY_F, [hl]
.done
	ret

.data
	db NO_COPY_ABILITY
	db NO_COPY_ABILITY
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db NO_COPY_ABILITY
	db NO_COPY_ABILITY
	db NO_COPY_ABILITY
	db 0
	db 0

Func_b4a7:
	push bc
	call Func_1ab3
	pop bc
	jr nz, .asm_b4e8
	ld a, $01
	ld [sa000Unk70], a
	push bc
	ld a, [sa000Unk71]
	ld hl, Data_b534 - $2
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call JumpHL
	call Func_b53a
	pop bc
	jr nc, .asm_b4d2
	ld e, OBJSTRUCT_VAR
	ld a, $06
	ld [de], a
	ret

.asm_b4d2
	ld h, d
	ld l, OBJSTRUCT_Y_VEL
	xor a
	ld [hli], a
	ld [hl], a
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	or [hl]
	ld e, OBJSTRUCT_VAR
	jr nz, .has_x_vel_1
	ld a, $04
	ld [de], a
	ret
.has_x_vel_1
	ld a, $05
	ld [de], a
	ret

.asm_b4e8
	xor a
	ld [sa000Unk70], a
	ld a, [sa000Unk50]
	cp $0d
	jr nz, .asm_b4f9
	ld e, OBJSTRUCT_VAR
	ld a, $03
	ld [de], a
	ret
.asm_b4f9
	ld e, OBJSTRUCT_Y_VEL + 1
	ld a, [de]
	rla
	jr c, .asm_b518
	push bc
	ld a, [sa000Unk71]
	ld hl, Data_b534 - $2
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call JumpHL
	call Func_b53a
	pop bc
	jr nc, .asm_b51e
.asm_b518
	ld e, OBJSTRUCT_VAR
	ld a, $02
	ld [de], a
	ret

.asm_b51e
	ld h, d
	ld l, OBJSTRUCT_Y_VEL
	xor a
	ld [hli], a
	ld [hl], a
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	or [hl]
	ld e, OBJSTRUCT_VAR
	jr nz, .has_x_vel_2
	ld a, $00
	ld [de], a
	ret
.has_x_vel_2
	ld a, $01
	ld [de], a
	ret

Data_b534:
	table_width 2
	dw Func_b926 ; RICK
	dw Func_b93c ; KINE
	dw Func_b952 ; COO
	assert_table_length NUM_ANIMAL_FRIENDS

Func_b53a:
	ld h, d
	ldh a, [hffaf]
	inc a
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	; bc = 0
	; de = hffaf
	call ApplyOffsetToObjectPosition

	call Func_184e
	jr c, .asm_b58f
	ldh a, [hffb1]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_b568
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, .asm_b58f
	ldh a, [hffb1]
	add l
	jr .asm_b58f
.asm_b568
	ldh a, [hffb3]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_b585
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, .asm_b58f
	ldh a, [hffb0]
	cpl
	scf
	adc l
	jr .asm_b58f
.asm_b585
	ldh a, [hff9a]
	ld d, a
	ld e, $4d
	ld a, $00
	ld [de], a
	scf
	ret

.asm_b58f
	inc a
	jr nz, .asm_b585
	ldh a, [hff9a]
	ld d, a
	ldh a, [hff9e]
	ld e, $4d
	ld [de], a
	ldh a, [hff9f]
	ld e, $4e
	ld [de], a
	and a
	ret

Func_b5a1:
	ld h, d
	ld e, OBJSTRUCT_UNK4D
	ld a, [de]
	ldh [hff84], a
	xor a
	ldh [hff85], a
	ldh a, [hffaf]
	inc a
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	call ApplyOffsetToObjectPosition
	call Func_184e
	jr c, .asm_b61e
	ldh a, [hff84]
	cp $05
	ldh a, [hffb0]
	jr z, .asm_b5e7
	ldh a, [hffb1]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_b5df
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, .asm_b610
	ldh a, [hffb1]
	add l
	jr .asm_b60c
.asm_b5df
	ldh a, [hff84]
	cp $04
	jr z, .asm_b602
	ldh a, [hffb3]
.asm_b5e7
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_b602
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, .asm_b610
	ldh a, [hffb0]
	cpl
	scf
	adc l
	jr .asm_b60c
.asm_b602
	ldh a, [hff9a]
	ld d, a
	ld e, OBJSTRUCT_UNK4D
	ld a, $00
	ld [de], a
	scf
	ret
.asm_b60c
	ld hl, hff85
	inc [hl]
.asm_b610
	ld b, a
	ldh a, [hff84]
	cp $04
	jr nc, .asm_b61d
	ldh a, [hff9e]
	cp $04
	jr nc, .asm_b602
.asm_b61d
	ld a, b
.asm_b61e
	inc a
	ld l, a
	rlca
	sbc a
	ld b, a
	ldh a, [hff9a]
	ld h, a
	ld a, l
	ld l, OBJSTRUCT_Y_POS
	ld [hl], $80
	inc l
	add [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
	ldh a, [hff9e]
	ld l, OBJSTRUCT_UNK4D
	ld [hl], a
	ldh a, [hff9f]
	ld l, OBJSTRUCT_UNK4E
	ld [hl], a
	ldh a, [hff85]
	or a
	jr z, .asm_b658
	xor a
	ldh [hff85], a
	ldh a, [hffaf]
	inc a
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	call ApplyOffsetToObjectPosition
	call Func_184e
	jr c, .asm_b61e
	ldh a, [hff9a]
	ld h, a
.asm_b658
	ld d, h
	ld e, OBJSTRUCT_UNK4E
	ld a, [de]
	cp $31
	call z, Func_3c63
	and a
	ret

Func_b663:
	ldh a, [hJoypad1Down]
	and PAD_RIGHT | PAD_LEFT
	jr z, .asm_b6c3
	ld h, d
	bit B_PAD_RIGHT, a
	ld de, $0
	jr z, .asm_b696
	ldh a, [hffb1]
	inc a
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_17a3
	jr nc, .asm_b683
	rla
	jr c, .asm_b6c0
.asm_b683
	ldh a, [hffae]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_17a3
	jr nc, .asm_b6bb
	rla
	jr nc, .asm_b6bb
	jr .asm_b6c0
.asm_b696
	ldh a, [hffb0]
	dec a
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_16ef
	jr nc, .asm_b6a9
	dec a
	rla
	jr nc, .asm_b6c0
.asm_b6a9
	ldh a, [hffae]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_16ef
	jr nc, .asm_b6bb
	dec a
	rla
	jr nc, .asm_b6c0
.asm_b6bb
	ldh a, [hff9a]
	ld d, a
	scf
	ret
.asm_b6c0
	ldh a, [hff9a]
	ld d, a
.asm_b6c3
	and a
	ret
; 0xb6c5

SECTION "Func_b6df", ROMX[$76df], BANK[$02]

Func_b6df::
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ld de, $0
	bit 7, [hl]
	jr nz, .asm_b726
	ldh a, [hffb1]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_17a3
	jr nc, .asm_b6fc
	ld l, a
	rlca
	jp c, Func_1e2a
.asm_b6fc
	ldh a, [hffae]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_17a3
	jr nc, .asm_b70f
	ld l, a
	rlca
	jp c, Func_1e2a
.asm_b70f
	ldh a, [hffb2]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_17a3
	jp nc, Func_1e6d
	ld l, a
	rlca
	jp c, Func_1e2a
	jp Func_1e6d

.asm_b726
	ldh a, [hffb0]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_16ef
	jr nc, .asm_b73a
	ld l, a
	dec a
	rlca
	jp nc, Func_1e4c
.asm_b73a
	ldh a, [hffae]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_16ef
	jr nc, .asm_b74e
	ld l, a
	dec a
	rlca
	jp nc, Func_1e4c
.asm_b74e
	ldh a, [hffb2]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_16ef
	jp nc, Func_1e6d
	ld l, a
	dec a
	rlca
	jp nc, Func_1e4c
	jp Func_1e6d
; 0xb766

SECTION "Func_b926", ROMX[$7926], BANK[$02]

Func_b926:
	ld hl, hffae
	ld a, $f3
	ld [hli], a ; hffae
	ld a, $0a
	ld [hli], a ; hffaf
	ld a, $f7
	ld [hli], a ; hffb0
	ld a, $08
	ld [hli], a ; hffb1
	ld a, $17
	ld [hli], a ; hffb2
	ld a, $ef
	ld [hli], a ; hffb3
	ret

Func_b93c:
	ld hl, hffae
	ld a, $f5
	ld [hli], a ; hffae
	ld a, $08
	ld [hli], a ; hffaf
	ld a, $f7
	ld [hli], a ; hffb0
	ld a, $08
	ld [hli], a ; hffb1
	ld a, $13
	ld [hli], a ; hffb2
	ld a, $ef
	ld [hli], a ; hffb3
	ret

Func_b952:
	ld hl, hffae
	ld a, $f4
	ld [hli], a ; hffae
	ld a, $0c
	ld [hli], a ; hffaf
	ld a, $f7
	ld [hli], a ; hffb0
	ld a, $08
	ld [hli], a ; hffb1
	ld a, $18
	ld [hli], a ; hffb2
	ld a, $ef
	ld [hli], a ; hffb3
	ret
; 0xb968

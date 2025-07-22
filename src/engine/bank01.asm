	script_stop

Script_4001:
	exec_asm Func_35a2
	set_var_to_field OBJSTRUCT_UNK7F
	var_jumptable 8
	dw Script_4030
	dw $4207 ; .script_4207
	dw $41b2 ; .script_41b2
	dw $4207 ; .script_4207
	dw $4213 ; .script_4213
	dw $41b9 ; .script_41b9
	dw $4207 ; .script_4207
	dw $4213 ; .script_4213
; 0x4018

SECTION "Script_4030", ROMX[$4030], BANK[$1]

Script_4030:
	set_field OBJSTRUCT_UNK45, $40
	exec_asm AdjustAnimalFriendYPosition
	set_draw_func Func_dce
	set_field OBJSTRUCT_UNK54, $00
	exec_asm Func_4083
	jump_if_not_var .skip_sfx
	play_sfx SFX_3C
.skip_sfx
	set_field OBJSTRUCT_UNK52, $00

	set_var_to_field OBJSTRUCT_UNK51
	var_jumptable 14
	dw Script_44bf
	dw $746a ; .script_746a
	dw $5631 ; .script_5631
	dw $5fd6 ; .script_5fd6
	dw $6154 ; .script_6154
	dw .script_4067
	dw .script_4073
	dw .script_407b
	dw $6d1b ; .script_6d1b
	dw .script_406b
	dw .script_4077
	dw .script_407f
	dw .script_406f
	dw $709a ; .script_709a

.script_4067
	far_jump Script_8000
.script_406b
	; far_jump Script_8d73
	db FAR_JUMP_CMD
	dwb $4d73, $2
.script_406f
	; far_jump Script_8649
	db FAR_JUMP_CMD
	dwb $4649, $2
.script_4073
	; far_jump Script_9303
	db FAR_JUMP_CMD
	dwb $5303, $2
.script_4077
	; far_jump Script_a2a5
	db FAR_JUMP_CMD
	dwb $62a5, $2
.script_407b
	; far_jump Script_a730
	db FAR_JUMP_CMD
	dwb $6730, $2
.script_407f
	; far_jump Script_b0ae
	db FAR_JUMP_CMD
	dwb $70ae, $2

Func_4083:
	ld a, [wdb73]
	dec a
	jr z, .asm_409e
	ld a, [sa000Unk71]
	or a
	ld e, OBJSTRUCT_UNK4C
	ld h, $04
	jr z, .no_animal_friend
	ld e, OBJSTRUCT_UNK72
	ld h, $02
.no_animal_friend
	ld a, [de]
	cp h
	ld a, FALSE
	incc a
.asm_409e
	; a = ([de] < h)
	ld e, OBJSTRUCT_VAR
	ld [de], a
	ret
; 0x40a2

SECTION "Script_44bf", ROMX[$44bf], BANK[$1]

Script_44bf:
	set_oam $4f40, $0a ; OAM_28f40
	script_call .Script_44d9
	exec_asm Func_7b40
	var_jumptable 7
	dw .Script_44e0
	dw $4583 ; .script_4583
	dw Script_4742
	dw $4aea ; .script_4aea
	dw $4c14 ; .script_4c14
	dw $4c81 ; .script_4c81
	dw $4d46 ; .script_4d46

.Script_44d9:
	set_field OBJSTRUCT_UNK51, $00
	set_field OBJSTRUCT_UNK5B, $ff
	script_ret

.Script_44e0:
	set_field OBJSTRUCT_UNK50, $00
	unk03_cmd Func_450e
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_4505
	jump_if_var_lt $03, .script_44f5
	set_frame 4
	jump .script_44fe
.script_44f5
	set_frame_with_orientation 8, 7
	unk03_cmd Func_4508
.script_44fe
	script_call Script_7b1f
	unk03_cmd Func_450e
.script_4505
	set_frame 0
	script_end

Func_4508:
	lb hl, 8, 7
	call Func_7baf
Func_450e:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_452f
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_452f
	ldh a, [hJoypad1Pressed]
	and A_BUTTON
	jr z, .no_a_btn
	ld e, $01
	ld bc, $4697
	jp Func_37f4
.no_a_btn
	call Func_7a55
	jr nc, .asm_454a
	ld e, $01
	ld bc, $4583
	jp Func_37f4
.asm_454a
	ldh a, [hJoypad1Down]
	and D_DOWN
	jr z, .no_d_down
	ld e, $01
	ld bc, $49fa
	jp Func_37f4
.no_d_down
	ldh a, [hffb4]
	and B_BUTTON
	jr z, .asm_4566
	ld e, $01
	ld bc, $729d
	jp Func_37f4
.asm_4566
	call Func_36e6
	jr nc, .asm_4573
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4573
	call Func_3619
	jr nc, .asm_4580
	ld e, $01
	ld bc, $4a48
	jp Func_37f4
.asm_4580
	jp Func_37f7
; 0x4583

SECTION "Script_4742", ROMX[$4742], BANK[$1]

Script_4742:
	set_field OBJSTRUCT_UNK39, $1d
	set_field OBJSTRUCT_UNK50, $05
	unk03_cmd Func_4792
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_4773
	jump_if_var_lt $03, .script_4763
	jump_if_var_lt $02, .script_475e
	set_frame 5
	jump .script_476c
.script_475e
	set_frame 4
	jump .script_476c
.script_4763
	set_frame_with_orientation 8, 7
	unk03_cmd Func_478c
.script_476c
	script_call Script_7b1f
	unk03_cmd Func_4792
.script_4773
	set_frame 31
.script_4775
	wait 1
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_4775
	set_var_to_field OBJSTRUCT_UNK39
	wait_var
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_4775
	jump_if_not_var .script_4775
	jump Script_480e

Func_478c:
	lb hl, 8, 7
	call Func_7baf
Func_4792:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_7a8c
	call Func_3992
	jr nc, .asm_47bb
	ld e, $01
	ld bc, $44c6
	jp Func_37f4
.asm_47bb
	call Func_39c1
	jr nc, .asm_47c8
	ld e, $01
	ld bc, $4742
	jp Func_37f4
.asm_47c8
	ld e, $52
	ld a, [de]
	or a
	jr z, .asm_47d6
	ld e, $01
	ld bc, $4742
	jp Func_37f4
.asm_47d6
	ldh a, [hffb4]
	and $02
	jr z, .asm_47e4
	ld e, $01
	ld bc, $729d
	jp Func_37f4
.asm_47e4
	call Func_3619
	jr nc, .asm_47f1
	ld e, $01
	ld bc, $4a48
	jp Func_37f4
.asm_47f1
	call Func_3765
	jr nc, .asm_47fe
	ld e, $01
	ld bc, $4c05
	jp Func_37f4
.asm_47fe
	call Func_36e6
	jr nc, .asm_480b
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_480b
	jp Func_37f7

Script_480e:
	set_field OBJSTRUCT_UNK50, $05
	exec_asm Func_481b
	unk03_cmd Func_4821
	set_frame 17
	script_end

Func_481b:
	ld hl, sa000Unk6c
	res 3, [hl]
	ret

Func_4821:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	ld hl, $48b6
	ld a, $01
	call Func_3aaa
	call Func_7d6e
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_4855
	ld e, $01
	ld bc, $494e
	jp Func_37f4
.asm_4855
	call Func_39c1
	jr nc, .asm_4862
	ld e, $01
	ld bc, $4742
	jp Func_37f4
.asm_4862
	ld hl, sa000Unk6c
	bit 3, [hl]
	jr z, .asm_4871
	ld e, $01
	ld bc, $48bb
	jp Func_37f4
.asm_4871
	ldh a, [hffb4]
	and $02
	jr z, .asm_487f
	ld e, $01
	ld bc, $729d
	jp Func_37f4
.asm_487f
	call Func_3619
	jr nc, .asm_488c
	ld e, $01
	ld bc, $4a48
	jp Func_37f4
.asm_488c
	call Func_3765
	jr nc, .asm_4899
	ld e, $01
	ld bc, $4c05
	jp Func_37f4
.asm_4899
	call Func_36e6
	jr nc, .asm_48a6
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_48a6
	call Func_3614
	jr nc, .asm_48b3
	ld e, $01
	ld bc, $4742
	jp Func_37f4
.asm_48b3
	jp Func_37f7
; 0x48b6

SECTION "Func_7a55", ROMX[$7a55], BANK[$1]

Func_7a55:
	ldh a, [hJoypad1Down]
	and D_RIGHT | D_LEFT
	jr z, .no_carry
	ld h, d
	ld de, $fff9
	bit D_RIGHT_F, a
	jr z, .d_left
	ld bc, 7
	call ApplyOffsetToObjectPosition
	call Func_17a3
	jr nc, .asm_7a82
	rla
	jr c, .asm_7a87
	jr .asm_7a82

.d_left
	ld bc, -8
	call ApplyOffsetToObjectPosition
	call Func_16ef
	jr nc, .asm_7a82
	dec a
	rla
	jr nc, .asm_7a87
.asm_7a82
	ldh a, [hff9a]
	ld d, a
	scf
	ret
.asm_7a87
	ldh a, [hff9a]
	ld d, a
.no_carry
	and a
	ret

Func_7a8c:
	call Func_1dc7
	jr nc, .asm_7a9c
	call Func_7abb
	ld e, OBJSTRUCT_X_VEL
	xor a
	ld [de], a
	inc e
	ld [de], a
	scf
	ret
.asm_7a9c
	and a
	ret
; 0x7a9e

SECTION "Func_7abb", ROMX[$7abb], BANK[$1]

Func_7abb:
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	ld a, [hli]
	ld e, OBJSTRUCT_UNK52
	jr c, .asm_7ad0
	sub LOW(0.7)
	ld a, [hl]
	sbc HIGH(0.7)
	jr c, .done
	ld a, $03
	jr .asm_7ad9
.asm_7ad0
	add LOW(0.7)
	ld a, [hl]
	adc HIGH(0.7)
	jr c, .done
	ld a, $04
.asm_7ad9
	ld [de], a ; OBJSTRUCT_UNK52
.done
	ret

Func_7adb:
	call Func_1b61
	ret c
	ldh a, [hff9e]
	cp $04
	jr c, .asm_7aff
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
	jr c, .asm_7afc
	ldh a, [hff9a]
	ld d, a
	jr .asm_7aff
.asm_7afc
	call Func_1bba
.asm_7aff
	ld e, OBJSTRUCT_UNK4E
	ld a, [de]
	cp $31
	call z, Func_3c63
	and a
	ret

Func_7b09:
	ld hl, hffae
	ld a, $f9
	ld [hli], a
	ld a, $06
	ld [hli], a
	ld a, $f9
	ld [hli], a
	ld a, $06
	ld [hli], a
	ld a, $0d
	ld [hli], a
	ld a, $f3
	ld [hli], a
	ret

Script_7b1f:
	set_field OBJSTRUCT_UNK52, $00
	play_sfx SFX_05
	exec_func_f77 $00
	wait 6
	script_ret

; sets object's frame to:
; - arg1 if (OBJSTRUCT_UNK45 bit 7) != (OBJSTRUCT_UNK52 bit 0)
; - arg2 if (OBJSTRUCT_UNK45 bit 7) == (OBJSTRUCT_UNK52 bit 0)
Func_7b2b:
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	rla
	ld e, OBJSTRUCT_UNK52
	ld a, [de]
	jr nc, .asm_7b35
	cpl ; flip bit
.asm_7b35
	rra ; check lower bit
	ld a, [bc] ; frame if bit is set
	inc bc
	jr c, .got_frame
	ld a, [bc] ; frame if bit is not set
.got_frame
	inc bc
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	ret

; sets object's var
Func_7b40:
	push bc
	call Func_1ab3
	pop bc
	jr nz, .asm_7b72
	ld a, $01
	ld [sa000Unk70], a
	push bc
	call Func_7b09
	call Func_1af6
	pop bc
	jr nc, .asm_7b5c
	ld e, OBJSTRUCT_VAR
	ld a, $06
	ld [de], a
	ret

.asm_7b5c
	; zero y velocity
	ld h, d
	ld l, OBJSTRUCT_Y_VEL
	xor a
	ld [hli], a
	ld [hl], a

	; is x velocity zero?
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	or [hl]
	ld e, OBJSTRUCT_VAR
	jr nz, .asm_7b6e
	; if zero, then set var to $4
	ld a, $04
	ld [de], a
	ret
.asm_7b6e
	; else, set var to $5
	ld a, $05
	ld [de], a
	ret

.asm_7b72
	xor a
	ld [sa000Unk70], a
	ld a, [sa000Unk50]
	cp $0d
	jr nz, .asm_7b83
	ld e, OBJSTRUCT_VAR
	ld a, $03
	ld [de], a
	ret
.asm_7b83
	; is moving downwards?
	ld e, OBJSTRUCT_Y_VEL + 1
	ld a, [de]
	rla
	jr c, .asm_7b93
	; if yes, then ?
	push bc
	call Func_7b09
	call Func_1af6
	pop bc
	jr nc, .asm_7b99
.asm_7b93
	ld e, OBJSTRUCT_VAR
	ld a, $02
	ld [de], a
	ret

.asm_7b99
	; zero y velocity
	ld h, d
	ld l, OBJSTRUCT_Y_VEL
	xor a
	ld [hli], a
	ld [hl], a

	; is x velocity zero?
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	or [hl]
	ld e, OBJSTRUCT_VAR
	jr nz, .asm_7bab
	; if zero, then set var to $0
	ld a, $00
	ld [de], a
	ret
.asm_7bab
	; else, set var to $1
	ld a, $01
	ld [de], a
	ret

Func_7baf:
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	rla
	ldh a, [hJoypad1Down]
	bit D_LEFT_F, a
	jr nc, .asm_7bbb
	bit D_RIGHT_F, a
.asm_7bbb
	jr z, .skip
	; alternate between input frame h
	; and input frame l
	ld e, OBJSTRUCT_FRAME
	ld a, [de]
	cp h
	ld a, l
	jr z, .got_frame
	ld a, h
.got_frame
	ld [de], a
.skip
	ret
; 0x7bc7

SECTION "Func_7cb8", ROMX[$7cb8], BANK[$1]

Func_7cb8:
	lb hl, 0.086, 0.055
	ld bc, 1.2
	jp Func_3894
; 0x7cc1

SECTION "Func_7d6e", ROMX[$7d6e], BANK[$1]

Func_7d6e:
	call Func_3ae9
	ret nc
	ld hl, sa000Unk6c
	set 3, [hl]
	ret
; 0x7d78

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
	dw Script_746a
	dw Script_5631
	dw Script_5fd6
	dw Script_6154
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

Script_40a2:
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_oam $4f40, $0a ; OAM_28f40
	set_frame 4
	set_field OBJSTRUCT_UNK51, $00
	script_call Script_40b4
	jump Script_44bf

Script_40b4:
	exec_asm Func_532a
	set_field OBJSTRUCT_UNK5B, NO_COPY_ABILITY
	exec_asm Func_1067
	exec_asm Func_40da
	set_copy_ability_icon NONE
	set_update_func1 ASM, Func_40d6
	exec_asm Func_357f
.loop
	wait 1
	set_var_to_field OBJSTRUCT_UNK64
	jump_if_var .loop
	exec_asm Func_1080
	script_ret

Func_40d6:
	call Func_34fd
	ret

Func_40da:
	push bc
	ld h, $a2
.loop_objs
	ld l, OBJSTRUCT_UNK00
	ld a, [hl]
	inc a
	jr z, .asm_40f1
	ld l, OBJSTRUCT_UNK4C
	ld a, [hl]
	or a
	jr z, .asm_40f1
	ld e, $03
	ld bc, $4e40
	call Func_849
.asm_40f1
	inc h
	ld a, h
	cp $a8
	jr c, .loop_objs
	pop bc
	ret
; 0x40f9

SECTION "Script_44bf", ROMX[$44bf], BANK[$1]

Script_44bf:
	set_oam $4f40, $0a ; OAM_28f40
	script_call Script_44d9
Script_44c6:
	exec_asm Func_7b40
	var_jumptable 7
	dw Script_44e0
	dw Script_4583
	dw Script_4742
	dw Script_4aea
	dw Script_4c14
	dw Script_4c81
	dw Script_4d46

Script_44d9:
	set_field OBJSTRUCT_UNK51, $00
	set_field OBJSTRUCT_UNK5B, NO_COPY_ABILITY
	script_ret

Script_44e0:
	set_field OBJSTRUCT_UNK50, $00
	set_update_func1 ASM, Func_450e
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_4505
	jump_if_var_lt $03, .script_44f5
	set_frame 4
	jump .script_44fe
.script_44f5
	set_frame_with_orientation 8, 7
	set_update_func1 ASM, Func_4508
.script_44fe
	script_call Script_7b1f
	set_update_func1 ASM, Func_450e
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
	and PAD_A
	jr z, .no_a_btn
	ld e, BANK(Script_4697)
	ld bc, Script_4697
	jp Func_37f4
.no_a_btn
	call Func_7a55
	jr nc, .asm_454a
	ld e, BANK(Script_4583)
	ld bc, Script_4583
	jp Func_37f4
.asm_454a
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .no_d_down
	ld e, BANK(Script_49fa)
	ld bc, Script_49fa
	jp Func_37f4
.no_d_down
	ldh a, [hffb4]
	and PAD_B
	jr z, .asm_4566
	ld e, BANK(Script_729d)
	ld bc, Script_729d
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
	ld e, BANK(Script_4a48)
	ld bc, Script_4a48
	jp Func_37f4
.asm_4580
	jp Func_37f7

Script_4583:
	set_field OBJSTRUCT_UNK50, $01
	set_update_func1 ASM, Func_45e4
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var Script_4594
	set_frame 4
	script_call Script_7b1f

Script_4594:
	exec_asm Func_383c
	var_jumptable 6
	dw .script_45a5
	dw .script_45b4
	dw .script_45c3
	dw .script_45c6
	dw .script_45d5
	dw .script_45c3
.script_45a5
	set_frame_wait 2, 8
	set_frame_wait 3, 10
	set_frame_wait 2, 8
	set_frame_wait 1, 10
	jump .script_45a5
.script_45b4
	set_frame_wait 2, 6
	set_frame_wait 3, 6
	set_frame_wait 2, 6
	set_frame_wait 1, 6
	jump .script_45b4
.script_45c3
	set_frame 31
	script_end
.script_45c6
	set_frame_wait 2, 3
	set_frame_wait 3, 4
	set_frame_wait 2, 3
	set_frame_wait 1, 4
	jump .script_45c6
.script_45d5
	set_frame_wait 2, 4
	set_frame_wait 3, 4
	set_frame_wait 2, 4
	set_frame_wait 1, 4
	jump .script_45b4

Func_45e4:
	call Func_359a
	call Func_7c45
Func_45ea:
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_4602
	ld e, BANK(Script_44e0)
	ld bc, Script_44e0
	jp Func_37f4
.asm_4602
	call Func_7adb
	jr nc, .asm_460f
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_460f
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_461d
	ld e, BANK(Script_4697)
	ld bc, Script_4697
	jp Func_37f4
.asm_461d
	ld h, d
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	or [hl]
	jr nz, .asm_462c
	ld e, BANK(Script_44e0)
	ld bc, Script_44e0
	jp Func_37f4
.asm_462c
	call Func_373b
	jr nc, .asm_4639
	ld e, BANK(Script_467f)
	ld bc, Script_467f
	jp Func_37f4
.asm_4639
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_4647
	ld e, BANK(Script_49fa)
	ld bc, Script_49fa
	jp Func_37f4
.asm_4647
	ldh a, [hffb4]
	and $02
	jr z, .asm_4655
	ld e, BANK(Script_729d)
	ld bc, Script_729d
	jp Func_37f4
.asm_4655
	call Func_36e6
	jr nc, .asm_4662
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4662
	call Func_3619
	jr nc, .asm_466f
	ld e, BANK(Script_4a48)
	ld bc, Script_4a48
	jp Func_37f4
.asm_466f
	call Func_374e
	jr nc, .asm_467c
	ld e, BANK(Script_4583)
	ld bc, Script_4583
	jp Func_37f4
.asm_467c
	jp Func_37f7

Script_467f:
	set_field OBJSTRUCT_UNK50, $03
	play_sfx SFX_0D
	set_update_func1 ASM, Func_468e
	exec_asm Func_37ff
	jump Script_4594

Func_468e:
	call Func_359a
	call Func_7c20
	jp Func_45ea

Script_4697:
	set_field OBJSTRUCT_UNK50, $04
	set_update_func1 ASM, Func_46bd
	set_y_vel -3.562
	play_sfx SFX_04
	jump Script_46ad

Script_46a6:
	set_y_vel -0.688
	set_update_func1 ASM, Func_46e1
Script_46ad:
	set_frame 32
.script_46af
	wait 1
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_46af
	set_field OBJSTRUCT_UNK39, $1d
	jump Script_4745

Func_46bd:
	call Func_359a
	ldh a, [hJoypad1Down]
	bit B_PAD_A, a
	jr nz, .asm_46ce
	ld e, BANK(Script_46a6)
	ld bc, Script_46a6
	jp Func_37f4
.asm_46ce
	ld bc, -0.688
	call Func_37eb
	jr nc, Func_46e1
	ld h, d
	ld l, OBJSTRUCT_UNK1F
	ld [hl], $41
	inc l
	ld [hl], HIGH(Func_46e1)
	inc l
	ld [hl], LOW(Func_46e1)
Func_46e1:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_470a
	ld e, BANK(Script_44c6)
	ld bc, Script_44c6
	jp Func_37f4
.asm_470a
	call Func_39c1
	jr nc, .asm_4717
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_4717
	ldh a, [hffb4]
	and $02
	jr z, .asm_4725
	ld e, BANK(Script_729d)
	ld bc, Script_729d
	jp Func_37f4
.asm_4725
	call Func_36e6
	jr nc, .asm_4732
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4732
	call Func_3614
	jr nc, .asm_473f
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_473f
	jp Func_37f7

Script_4742:
	set_field OBJSTRUCT_UNK39, $1d
Script_4745:
	set_field OBJSTRUCT_UNK50, $05
	set_update_func1 ASM, Func_4792
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
	set_update_func1 ASM, Func_478c
.script_476c
	script_call Script_7b1f
	set_update_func1 ASM, Func_4792
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
	ld e, BANK(Script_44c6)
	ld bc, Script_44c6
	jp Func_37f4
.asm_47bb
	call Func_39c1
	jr nc, .asm_47c8
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_47c8
	ld e, OBJSTRUCT_UNK52
	ld a, [de]
	or a
	jr z, .asm_47d6
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_47d6
	ldh a, [hffb4]
	and $02
	jr z, .asm_47e4
	ld e, BANK(Script_729d)
	ld bc, Script_729d
	jp Func_37f4
.asm_47e4
	call Func_3619
	jr nc, .asm_47f1
	ld e, BANK(Script_4a48)
	ld bc, Script_4a48
	jp Func_37f4
.asm_47f1
	call Func_3765
	jr nc, .asm_47fe
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
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
	set_update_func1 ASM, Func_4821
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
	ld e, BANK(Script_494e)
	ld bc, Script_494e
	jp Func_37f4
.asm_4855
	call Func_39c1
	jr nc, .asm_4862
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_4862
	ld hl, sa000Unk6c
	bit 3, [hl]
	jr z, .asm_4871
	ld e, BANK(Script_48bb)
	ld bc, Script_48bb
	jp Func_37f4
.asm_4871
	ldh a, [hffb4]
	and $02
	jr z, .asm_487f
	ld e, BANK(Script_729d)
	ld bc, Script_729d
	jp Func_37f4
.asm_487f
	call Func_3619
	jr nc, .asm_488c
	ld e, BANK(Script_4a48)
	ld bc, Script_4a48
	jp Func_37f4
.asm_488c
	call Func_3765
	jr nc, .asm_4899
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
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
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_48b3
	jp Func_37f7
; 0x48b6

SECTION "Func_48bb", ROMX[$48bb], BANK[$1]

Script_48bb:
	set_y_vel -2.75
	set_update_func1 ASM, Func_48c5
	set_frame 17
	script_end

Func_48c5:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_7a8c
	call Func_3992
	jr nc, .asm_48ee
	ld e, BANK(Script_44c6)
	ld bc, Script_44c6
	jp Func_37f4
.asm_48ee
	call Func_39c1
	jr nc, .asm_48fb
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_48fb
	ld e, $10
	ld a, [de]
	rla
	jr c, .asm_4909
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_4909
	ldh a, [hffb4]
	and $02
	jr z, .asm_4917
	ld e, BANK(Script_729d)
	ld bc, Script_729d
	jp Func_37f4
.asm_4917
	call Func_3619
	jr nc, .asm_4924
	ld e, BANK(Script_4a48)
	ld bc, Script_4a48
	jp Func_37f4
.asm_4924
	call Func_3765
	jr nc, .asm_4931
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
	jp Func_37f4
.asm_4931
	call Func_36e6
	jr nc, .asm_493e
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_493e
	call Func_3614
	jr nc, .asm_494b
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_494b
	jp Func_37f7

Script_494e:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $05
	set_field OBJSTRUCT_UNK52, $00
	play_sfx SFX_55
	set_update_func1 ASM, Func_4967
	create_particle PARTICLE_00
	set_frame 17
	set_y_vel -2.75
	script_end

Func_4967:
	ld e, $40
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_498a
	ld e, BANK(Script_44c6)
	ld bc, Script_44c6
	jp Func_37f4
.asm_498a
	call Func_39c1
	jr nc, .asm_4997
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_4997
	call Func_3619
	jr nc, .asm_49a4
	ld e, BANK(Script_4a48)
	ld bc, Script_4a48
	jp Func_37f4
.asm_49a4
	call Func_3765
	jr nc, .asm_49b1
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
	jp Func_37f4
.asm_49b1
	call Func_3614
	jr nc, .asm_49be
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_49be
	jp Func_37f7

Script_49c1:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $05
	set_update_func1 ASM, Func_49d4
	exec_asm IncrementObjectYPosition
	set_frame_wait 31, 1
	jump Script_44c6

Func_49d4:
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_49f7
	ld e, BANK(Script_44c6)
	ld bc, Script_44c6
	jp Func_37f4
.asm_49f7
	jp Func_37f7

Script_49fa:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $06
	play_sfx SFX_0D
	set_update_func1 ASM, Func_4a07
	script_end

Func_4a07:
	call Func_7c2e
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_4a25
	ld e, BANK(Script_4742)
	ld bc, Script_4742
	jp Func_37f4
.asm_4a25
	call Func_36a5
	jr nc, .asm_4a32
	ld e, BANK(Script_49c1)
	ld bc, Script_49c1
	jp Func_37f4
.asm_4a32
	ldh a, [hJoypad1Down]
	bit B_PAD_DOWN, a
	jr nz, .asm_4a40
	ld e, BANK(Script_44c6)
	ld bc, Script_44c6
	jp Func_37f4
.asm_4a40
	ld e, OBJSTRUCT_FRAME
	ld a, 4
	ld [de], a
	jp Func_37f7

Script_4a48:
	exec_asm Func_35a2
	play_sfx SFX_30
	set_update_func1 ASM, Func_4a5d
	set_frame_wait 13, 8
	set_frame_wait 27, 8
	set_frame_wait 25, 8
	jump Script_4aea

Func_4a5d:
	call Func_7cfd
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	call Func_36e6
	jr nc, .asm_4a84
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4a84
	jp Func_37f7

Script_4a87:
	set_field OBJSTRUCT_UNK50, $0d
	set_update_func1 ASM, Func_4a9d
.script_4a8e
	set_frame_wait 25, 10
	set_frame_wait 26, 10
	exec_asm Func_380e
	jump_if_var .script_4a8e
	jump Script_4aea

Func_4a9d:
	call Func_359a
	ld e, $50
	ld bc, $feb3
	call ApplyUpwardsAcceleration_WithDampening
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	ldh a, [hffb4]
	and $02
	jr z, .asm_4acd
	ld e, BANK(Script_4bb5)
	ld bc, Script_4bb5
	jp Func_37f4
.asm_4acd
	call Func_3765
	jr nc, .asm_4ada
	ld e, BANK(Script_4b55)
	ld bc, Script_4b55
	jp Func_37f4
.asm_4ada
	call Func_36e6
	jr nc, .asm_4ae7
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4ae7
	jp Func_37f7

Script_4aea:
	set_field OBJSTRUCT_UNK50, $0d
	set_update_func1 ASM, Func_4afa
.loop
	set_frame_wait 25, 20
	set_frame_wait 26, 20
	jump .loop

Func_4afa:
	call Func_359a
	ld e, $14
	ld bc, $100
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	ldh a, [hJoypad1Down]
	and PAD_A | PAD_UP
	jr z, .asm_4b2a
	ld e, BANK(Script_4a87)
	ld bc, Script_4a87
	jp Func_37f4
.asm_4b2a
	ldh a, [hffb4]
	and $02
	jr z, .asm_4b38
	ld e, BANK(Script_4bb5)
	ld bc, Script_4bb5
	jp Func_37f4
.asm_4b38
	call Func_3765
	jr nc, .asm_4b45
	ld e, $01
	ld bc, Script_4b55
	jp Func_37f4
.asm_4b45
	call Func_36e6
	jr nc, .asm_4b52
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4b52
	jp Func_37f7

Script_4b55:
	set_field OBJSTRUCT_UNK50, $0d
	exec_asm Func_3a51
	set_update_func1 ASM, Func_4b68
	set_frame 26
	script_end

Script_4b62:
	exec_asm Func_3a57
	jump Script_4aea

Func_4b68:
	call Func_359a
	ld e, $20
	ld bc, $fe80
	call ApplyUpwardsAcceleration_WithDampening
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	ldh a, [hffb4]
	and $02
	jr z, .asm_4b98
	ld e, BANK(Script_4bb5)
	ld bc, Script_4bb5
	jp Func_37f4
.asm_4b98
	call Func_377c
	jr nc, .asm_4ba5
	ld e, BANK(Script_4b62)
	ld bc, Script_4b62
	jp Func_37f4
.asm_4ba5
	call Func_36e6
	jr nc, .asm_4bb2
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4bb2
	jp Func_37f7

Script_4bb5:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $0a
	set_update_func1 ASM, Func_4bd6
	create_object_rel_2 $00, 8, 0
	play_sfx SFX_1A
	set_frame_wait 27, 12
	set_frame_wait 13, 12
	exec_asm Func_380e
	jump_if_var Script_4a48
	jump Script_44c6

Func_4bd6:
	ld e, $14
	ld bc, $100
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	call Func_3765
	jr nc, .asm_4c02
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
	jp Func_37f4
.asm_4c02
	jp Func_37f7

Script_4c05:
	script_call Script_44d9
	exec_asm Func_3a48
	create_object_rel_1 PARTICLE_07, 0, 0
	jump Script_44c6

Script_4c14:
	set_field OBJSTRUCT_UNK50, $00
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_4c28
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_frame 0
	script_end

Func_4c28:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_4c49
	ld e, BANK(Script_4d46)
	ld bc, Script_4d46
	jp Func_37f4
.asm_4c49
	call Func_37bd
	jr nc, .asm_4c56
	ld e, BANK(Script_4d46)
	ld bc, Script_4d46
	jp Func_37f4
.asm_4c56
	call Func_7a55
	jr nc, .asm_4c63
	ld e, BANK(Script_4c81)
	ld bc, Script_4c81
	jp Func_37f4
.asm_4c63
	ldh a, [hJoypad1Down]
	and PAD_B
	jr z, .asm_4c71
	ld e, BANK(Script_4de6)
	ld bc, Script_4de6
	jp Func_37f4
.asm_4c71
	call Func_36e6
	jr nc, .asm_4c7e
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4c7e
	jp Func_37f7

Script_4c81:
	set_field OBJSTRUCT_UNK50, $01
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_4cc4
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	exec_asm Func_383c
	var_jumptable 6
	dw .script_4ca3
	dw .script_4cb2
	dw .script_4cc1
	dw .script_4ca3
	dw .script_4cb2
	dw .script_4cc1
.script_4ca3
	set_frame_wait 2, 8
	set_frame_wait 3, 10
	set_frame_wait 2, 8
	set_frame_wait 1, 10
	jump .script_4ca3
.script_4cb2
	set_frame_wait 2, 6
	set_frame_wait 3, 6
	set_frame_wait 2, 6
	set_frame_wait 1, 6
	jump .script_4cb2
.script_4cc1
	set_frame 31
	script_end

Func_4cc4:
	call Func_359a
	call Func_3602
	call Func_7c8e
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_4ce5
	ld e, $01
	ld bc, Script_4c14
	jp Func_37f4
.asm_4ce5
	call Func_7adb
	jr nc, .asm_4cf2
	ld e, BANK(Script_4d46)
	ld bc, Script_4d46
	jp Func_37f4
.asm_4cf2
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_4d01
	ld e, $01
	ld bc, Script_4c14
	jp Func_37f4
.asm_4d01
	call Func_37bd
	jr nc, .asm_4d0e
	ld e, BANK(Script_4d46)
	ld bc, Script_4d46
	jp Func_37f4
.asm_4d0e
	call Func_36e6
	jr nc, .asm_4d1b
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4d1b
	call Func_374e
	jr nc, .asm_4d28
	ld e, $01
	ld bc, $4c81
	jp Func_37f4
.asm_4d28
	ldh a, [hJoypad1Down]
	and PAD_B
	jr z, .asm_4d36
	ld e, BANK(Script_4de6)
	ld bc, Script_4de6
	jp Func_37f4
.asm_4d36
	call Func_377c
	jr nc, .asm_4d43
	ld e, $01
	ld bc, $4eb6
	jp Func_37f4
.asm_4d43
	jp Func_37f7

Script_4d46:
	set_field OBJSTRUCT_UNK50, $05
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_4d87
	set_var_to_field OBJSTRUCT_UNK6F
	var_jumptable 3
	dw .script_4d5a
	dw .script_4d7d
	dw .script_4d64
.script_4d5a
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_frame 31
	script_end
.script_4d64
	set_oam $5486, $08 ; OAM_21486
	set_var_to_field OBJSTRUCT_UNK83
	set_field_to_var OBJSTRUCT_OAM_TILE_ID
.script_4d6c
	play_sfx SFX_48
	set_frame_wait 0, 10
	set_frame_wait 1, 10
	set_frame_wait 2, 10
	set_frame_wait 3, 10
	jump .script_4d6c
.script_4d7d
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_frame 17
	script_end

Func_4d87:
	call Func_359a
	call Func_7d16
	call Func_7cca
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_4dab
	ld e, $01
	ld bc, Script_44c6
	jp Func_37f4
.asm_4dab
	call Func_3943
	call Func_37cb
	jr nc, .asm_4dbb
	ld e, BANK(Script_4d46)
	ld bc, Script_4d46
	jp Func_37f4
.asm_4dbb
	ldh a, [hJoypad1Down]
	and PAD_B
	jr z, .asm_4dc9
	ld e, BANK(Script_4de6)
	ld bc, Script_4de6
	jp Func_37f4
.asm_4dc9
	call Func_377c
	jr nc, .asm_4dd6
	ld e, $01
	ld bc, $4eb6
	jp Func_37f4
.asm_4dd6
	call Func_36e6
	jr nc, .asm_4de3
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_4de3
	jp Func_37f7

Script_4de6:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $0c
	set_update_func1 ASM, Func_4e7a
	set_oam $5486, $08 ; OAM_21486
	set_var_to_field OBJSTRUCT_UNK83
	set_field_to_var OBJSTRUCT_OAM_TILE_ID
	exec_asm Func_7d78
	exec_asm Func_7d8b
	wait 6
	play_sfx SFX_15
	set_update_func1 ASM, Func_4e47
	var_jumptable 3
	dw .script_4e0e
	dw .script_4e2c
	dw .script_4e1d
.script_4e0e
	set_frame_wait 11, 4
	set_frame_wait 12, 4
	set_frame_wait 13, 4
	set_frame_wait 14, 4
	jump .script_4e0e
.script_4e1d
	set_frame_wait 7, 4
	set_frame_wait 8, 4
	set_frame_wait 9, 4
	set_frame_wait 10, 4
	jump .script_4e1d
.script_4e2c
	set_frame_wait 15, 4
	set_frame_wait 16, 4
	set_frame_wait 17, 4
	set_frame_wait 18, 4
	jump .script_4e2c
; 0x4e3b

SECTION "Func_4e47", ROMX[$4e47], BANK[$1]

Func_4e47:
	call Func_7a1b
	call Func_4e8d
	call Func_3ae9
	call Func_7d9c
	jr nc, .asm_4e5d
	ld e, $01
	ld bc, $4e00
	jp Func_37f4
.asm_4e5d
	call Func_375b
	jr nc, .asm_4e6a
	ld e, $01
	ld bc, $4e3b
	jp Func_37f4
.asm_4e6a
	call Func_377c
	jr nc, .asm_4e77
	ld e, $01
	ld bc, $4eb6
	jp Func_37f4
.asm_4e77
	jp Func_37f7

Func_4e7a:
	call Func_7a1b
	call Func_377c
	jr nc, .asm_4e8a
	ld e, $01
	ld bc, $4eb6
	jp Func_37f4
.asm_4e8a
	jp Func_37f7

Func_4e8d:
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	ld hl, $4ea1
	add a
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, $02
	jp Func_3aaa
; 0x4ea1

SECTION "Func_532a", ROMX[$532a], BANK[$1]

Func_532a:
.loop
	push bc
	ld bc, sb200Unkb3
	ld a, $2f
	ldh [hff84], a
	call Func_f67
	ldh a, [hff9a]
	ld d, a
	ld a, h
	or a
	jr z, .asm_5354
	ld l, OBJSTRUCT_PARENT_OBJ
	ld [hl], d
	ld l, OBJSTRUCT_UNK45
	ld e, l
	ld a, [de]
	xor $80
	ld [hl], a
	ld a, [sa000Unk74]
	ld l, OBJSTRUCT_UNK39
	ld [hl], a
	ld a, [sa000Unk5b]
	ld l, OBJSTRUCT_UNK3C
	ld [hl], a
	pop bc
	ret
.asm_5354
	ld h, $b2
	call Func_bba
	pop bc
	ldh a, [hff9a]
	ld d, a
	jr .loop
; 0x535f

SECTION "Func_5631", ROMX[$5631], BANK[$1]

Script_5631:
	script_call .Script_564b
	set_oam $4f40, $0a ; OAM_28f40
	exec_asm Func_7b40
	var_jumptable 7
	dw .script_564f
	dw Script_56fe
	dw Script_58c8
	dw Script_5c8b
	dw Script_5db5
	dw Script_5e2e
	dw Script_5eff

.Script_564b:
	set_field OBJSTRUCT_UNK51, $02
	script_ret

.script_564f
	set_field OBJSTRUCT_UNK50, $00
	set_update_func1 ASM, Func_567d
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_5674
	jump_if_var_lt $03, .script_5664
	set_frame 4
	jump .script_566d
.script_5664
	set_frame_with_orientation 8, 7
	set_update_func1 ASM, Func_5677
.script_566d
	script_call Script_7b1f
	set_update_func1 ASM, Func_567d
.script_5674
	set_frame 0
	script_end

Func_5677:
	ld hl, $807
	call Func_7baf
Func_567d:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_569e
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_569e
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_56ac
	ld e, $01
	ld bc, $581e
	jp Func_37f4
.asm_56ac
	call Func_3650
	jr nc, .asm_56b9
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_56b9
	call Func_7a55
	jr nc, .asm_56c6
	ld e, $01
	ld bc, $56fe
	jp Func_37f4
.asm_56c6
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_56d4
	ld e, $01
	ld bc, $5b9b
	jp Func_37f4
.asm_56d4
	call Func_36e6
	jr nc, .asm_56e1
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_56e1
	call Func_3619
	jr nc, .asm_56ee
	ld e, $01
	ld bc, $5be9
	jp Func_37f4
.asm_56ee
	call Func_3724
	jr nc, .asm_56fb
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_56fb
	jp Func_37f7

Script_56fe:
	set_field OBJSTRUCT_UNK50, $01
	set_update_func1 ASM, Func_575f
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_570f
	set_frame 4
	script_call Script_7b1f
.script_570f
	exec_asm Func_383c
	var_jumptable 6
	dw .script_5720
	dw .script_572f
	dw .script_573e
	dw .script_5741
	dw .script_5750
	dw .script_573e
.script_5720
	set_frame_wait 2, 8
	set_frame_wait 3, 10
	set_frame_wait 2, 8
	set_frame_wait 1, 10
	jump .script_5720
.script_572f
	set_frame_wait 2, 6
	set_frame_wait 3, 6
	set_frame_wait 2, 6
	set_frame_wait 1, 6
	jump .script_572f
.script_573e
	set_frame 31
	script_end
.script_5741
	set_frame_wait 2, 3
	set_frame_wait 3, 4
	set_frame_wait 2, 3
	set_frame_wait 1, 4
	jump .script_5741
.script_5750
	set_frame_wait 2, 4
	set_frame_wait 3, 4
	set_frame_wait 2, 4
	set_frame_wait 1, 4
	jump .script_572f

Func_575f:
	call Func_359a
	call Func_7c45
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_577d
	ld e, $01
	ld bc, $564f
	jp Func_37f4
.asm_577d
	call Func_7adb
	jr nc, .asm_578a
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_578a
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_5798
	ld e, $01
	ld bc, $581e
	jp Func_37f4
.asm_5798
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_57a7
	ld e, $01
	ld bc, $564f
	jp Func_37f4
.asm_57a7
	call Func_3650
	jr nc, .asm_57b4
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_57b4
	call Func_373b
	jr nc, .asm_57c1
	ld e, $01
	ld bc, $5806
	jp Func_37f4
.asm_57c1
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_57cf
	ld e, $01
	ld bc, $5b9b
	jp Func_37f4
.asm_57cf
	call Func_36e6
	jr nc, .asm_57dc
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_57dc
	call Func_3619
	jr nc, .asm_57e9
	ld e, $01
	ld bc, $5be9
	jp Func_37f4
.asm_57e9
	call Func_374e
	jr nc, .asm_57f6
	ld e, $01
	ld bc, $56fe
	jp Func_37f4
.asm_57f6
	call Func_3724
	jr nc, .asm_5803
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_5803
	jp Func_37f7
; 0x5806

SECTION "Func_58c8", ROMX[$58c8], BANK[$1]

Script_58c8:
	set_field OBJSTRUCT_UNK39, $1d
	set_field OBJSTRUCT_UNK50, $05
	set_update_func1 ASM, Func_5915
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_58f9
	jump_if_var_lt $03, .script_58e9
	jump_if_var_lt $02, .script_58e4
	set_frame 5
	jump .script_58f2
.script_58e4
	set_frame 4
	jump .script_58f2
.script_58e9
	set_frame_with_orientation 8, 7
	set_update_func1 ASM, Func_590f
.script_58f2
	script_call Script_7b1f
	set_update_func1 ASM, Func_5915
.script_58f9
	set_frame 31
.script_58fb
	wait 1
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_58fb
	set_var_to_field OBJSTRUCT_UNK39
	wait_var
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_58fb
	jump Script_59aa

Func_590f:
	ld hl, $807
	call Func_7baf
Func_5915:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_7a8c
	call Func_3992
	jr nc, .asm_593e
	ld e, $01
	ld bc, $5638
	jp Func_37f4
.asm_593e
	call Func_39c1
	jr nc, .asm_594b
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_594b
	ld e, $52
	ld a, [de]
	or a
	jr z, .asm_5959
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_5959
	call Func_3650
	jr nc, .asm_5966
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_5966
	call Func_3619
	jr nc, .asm_5973
	ld e, $01
	ld bc, $5be9
	jp Func_37f4
.asm_5973
	call Func_3765
	jr nc, .asm_5980
	ld e, $01
	ld bc, $5da6
	jp Func_37f4
.asm_5980
	call Func_36e6
	jr nc, .asm_598d
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_598d
	call Func_3724
	jr nc, .asm_599a
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_599a
	call Func_3614
	jr nc, .asm_59a7
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_59a7
	jp Func_37f7

Script_59aa:
	set_field OBJSTRUCT_UNK50, $05
	exec_asm Func_481b
	set_update_func1 ASM, Func_59b7
	set_frame 17
	script_end

Func_59b7:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	ld hl, $5a4b
	ld a, $01
	call Func_3aaa
	call Func_7d6e
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_59eb
	ld e, $01
	ld bc, $5aef
	jp Func_37f4
.asm_59eb
	call Func_39c1
	jr nc, .asm_59f8
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_59f8
	ld hl, sa000Unk6c
	bit 3, [hl]
	jr z, .asm_5a07
	ld e, $01
	ld bc, $5a50
	jp Func_37f4
.asm_5a07
	call Func_3650
	jr nc, .asm_5a14
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_5a14
	call Func_3619
	jr nc, .asm_5a21
	ld e, $01
	ld bc, $5be9
	jp Func_37f4
.asm_5a21
	call Func_3765
	jr nc, .asm_5a2e
	ld e, $01
	ld bc, $5da6
	jp Func_37f4
.asm_5a2e
	call Func_36e6
	jr nc, .asm_5a3b
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_5a3b
	call Func_3614
	jr nc, .asm_5a48
	ld e, $01
	ld bc, $58c8
	jp Func_37f4
.asm_5a48
	jp Func_37f7
; 0x5a4b

SECTION "Func_5c8b", ROMX[$5c8b], BANK[$1]

Script_5c8b:
	set_field OBJSTRUCT_UNK50, $0d
	set_update_func1 ASM, Func_5c9b
.loop
	set_frame_wait 25, 20
	set_frame_wait 26, 20
	jump .loop

Func_5c9b:
	call Func_359a
	ld e, $14
	ld bc, $100
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	ldh a, [hJoypad1Down]
	and PAD_A | PAD_UP
	jr z, .asm_5ccb
	ld e, $01
	ld bc, $5c28
	jp Func_37f4
.asm_5ccb
	ldh a, [hffb4]
	and $02
	jr z, .asm_5cd9
	ld e, $01
	ld bc, $5d56
	jp Func_37f4
.asm_5cd9
	call Func_3765
	jr nc, .asm_5ce6
	ld e, $01
	ld bc, $5cf6
	jp Func_37f4
.asm_5ce6
	call Func_36e6
	jr nc, .asm_5cf3
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_5cf3
	jp Func_37f7
; 0x5cf6

SECTION "Func_5db5", ROMX[$5db5], BANK[$1]

Script_5db5:
	set_field OBJSTRUCT_UNK50, $00
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_5dc9
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_frame 0
	script_end

Func_5dc9:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_5dea
	ld e, $01
	ld bc, $5eff
	jp Func_37f4
.asm_5dea
	call Func_37bd
	jr nc, .asm_5df7
	ld e, $01
	ld bc, $5eff
	jp Func_37f4
.asm_5df7
	call Func_7a55
	jr nc, .asm_5e04
	ld e, $01
	ld bc, $5e2e
	jp Func_37f4
.asm_5e04
	call Func_3650
	jr nc, .asm_5e11
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_5e11
	call Func_36e6
	jr nc, .asm_5e1e
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_5e1e
	call Func_3724
	jr nc, .asm_5e2b
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_5e2b
	jp Func_37f7

Script_5e2e:
	set_field OBJSTRUCT_UNK50, $01
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_5e71
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	exec_asm Func_383c
	var_jumptable 6
	dw .script_5e50
	dw .script_5e5f
	dw .script_5e6e
	dw .script_5e50
	dw .script_5e5f
	dw .script_5e6e
.script_5e50
	set_frame_wait 2, 8
	set_frame_wait 3, 10
	set_frame_wait 2, 8
	set_frame_wait 1, 10
	jump .script_5e50
.script_5e5f
	set_frame_wait 2, 6
	set_frame_wait 3, 6
	set_frame_wait 2, 6
	set_frame_wait 1, 6
	jump .script_5e5f
.script_5e6e
	set_frame 31
	script_end

Func_5e71:
	call Func_359a
	call Func_3602
	call Func_7c8e
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_5e92
	ld e, $01
	ld bc, $5db5
	jp Func_37f4
.asm_5e92
	call Func_7adb
	jr nc, .asm_5e9f
	ld e, $01
	ld bc, $5eff
	jp Func_37f4
.asm_5e9f
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_5eae
	ld e, $01
	ld bc, $5db5
	jp Func_37f4
.asm_5eae
	call Func_37bd
	jr nc, .asm_5ebb
	ld e, $01
	ld bc, $5eff
	jp Func_37f4
.asm_5ebb
	call Func_36e6
	jr nc, .asm_5ec8
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_5ec8
	call Func_374e
	jr nc, .asm_5ed5
	ld e, $01
	ld bc, $5e2e
	jp Func_37f4
.asm_5ed5
	call Func_3650
	jr nc, .asm_5ee2
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_5ee2
	call Func_377c
	jr nc, .asm_5eef
	ld e, $01
	ld bc, $5fab
	jp Func_37f4
.asm_5eef
	call Func_3724
	jr nc, .asm_5efc
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_5efc
	jp Func_37f7

Script_5eff:
	set_field OBJSTRUCT_UNK50, $05
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_5f40
	set_var_to_field OBJSTRUCT_UNK6F
	var_jumptable 3
	dw .script_5f13
	dw .script_5f36
	dw .script_5f1d
.script_5f13
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_frame 31
	script_end
.script_5f1d
	set_oam $5486, $08 ; OAM_21486
	set_var_to_field OBJSTRUCT_UNK83
	set_field_to_var OBJSTRUCT_OAM_TILE_ID
.script_5f25
	play_sfx SFX_48
	set_frame_wait 0, 10
	set_frame_wait 1, 10
	set_frame_wait 2, 10
	set_frame_wait 3, 10
	jump .script_5f25
.script_5f36
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_frame 17
	script_end

Func_5f40:
	call Func_359a
	call Func_7d16
	call Func_7cca
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_5f64
	ld e, $01
	ld bc, $5638
	jp Func_37f4
.asm_5f64
	call Func_3943
	call Func_37cb
	jr nc, .asm_5f74
	ld e, $01
	ld bc, $5eff
	jp Func_37f4
.asm_5f74
	call Func_3650
	jr nc, .asm_5f81
	ld e, $01
	ld bc, $5fbe
	jp Func_37f4
.asm_5f81
	call Func_377c
	jr nc, .asm_5f8e
	ld e, $01
	ld bc, $5fab
	jp Func_37f4
.asm_5f8e
	call Func_36e6
	jr nc, .asm_5f9b
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_5f9b
	call Func_3724
	jr nc, .asm_5fa8
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_5fa8
	jp Func_37f7
; 0x5fab

SECTION "Func_5fd6", ROMX[$5fd6], BANK[$1]

Script_5fd6:
	set_field OBJSTRUCT_OAM_TILE_ID, $00
	set_oam $4f40, $0a ; OAM_28f40
	set_field OBJSTRUCT_UNK51, $03
	set_field OBJSTRUCT_UNK50, $0c
	play_sfx SFX_3E
	set_update_func1 ASM, Func_6095
	set_x_vel_dir -2.0
	set_y_vel -1.0
	set_frame_wait 31, 1
	set_y_vel 0.0
	wait 2
	stop_movement
	set_oam $6f52, $0b ; OAM_2ef52
	set_frame_wait 4, 2
	set_oam $7717, $0b ; OAM_2f717
	set_frame_wait 0, 2
	set_frame_wait 1, 2
	set_frame_wait 2, 2
	set_frame_wait 3, 2
	set_field OBJSTRUCT_OAM_FLAGS, OAM_PAL1
	set_update_func1 ASM, Func_60b7
	exec_asm Func_1aa5
	jump_if_not_var .script_6022
	set_x_vel_dir 1.5
	jump .script_6025
.script_6022
	set_x_vel_dir 3.0
.script_6025
	set_oam $5214, $0a ; OAM_29214
	set_field OBJSTRUCT_OAM_FLAGS, OAM_PAL0

	repeat 3
	set_frame_wait 1, 2
	set_frame_wait 0, 2
	set_frame_wait 3, 2
	set_frame_wait 2, 2
	repeat_end

	set_update_func2 SCRIPT, Script_607e
	set_field OBJSTRUCT_UNK51, $02
	set_update_func1 ASM, Func_611f
	exec_asm Func_1aa5
	jump_if_not_var .script_6052
	set_x_vel_dir 0.75
	jump .script_6055
.script_6052
	set_x_vel_dir 1.5
.script_6055
	set_oam $4f40, $0a ; OAM_28f40
	set_frame 31

	repeat 2
	set_field OBJSTRUCT_OAM_FLAGS, OAM_PAL1
	wait 2
	set_field OBJSTRUCT_OAM_FLAGS, OAM_PAL0
	wait 2
	repeat_end

	jump Script_5631
; 0x606b

SECTION "Func_607e", ROMX[$607e], BANK[$1]

Script_607e:
	create_object_rel_1 PARTICLE_03, -6, 0
	wait 4
	create_object_rel_1 PARTICLE_03, -6, -4
	wait 4
	create_object_rel_1 PARTICLE_03, -6, 0
	script_end

Func_6095:
	ld a, $04
	ld [sa000Unk5d], a
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3957
	call Func_378b
	call Func_37a8
	jp Func_37f7
; 0x60b7

SECTION "Func_60b7", ROMX[$60b7], BANK[$1]

Func_60b7:
	ld a, [sa000Unk70]
	or a
	ld e, $45
	ld a, [de]
	ld e, $38
	jr nz, .asm_60d0
	rla
	ld bc, $300
	jr nc, .asm_60db
	ld bc, $fd00
.asm_60cb
	call ApplyLeftAcceleration_WithDampening
	jr .asm_60de
.asm_60d0
	rla
	ld bc, $180
	jr nc, .asm_60db
	ld bc, $fe80
	jr .asm_60cb
.asm_60db
	call ApplyRightAcceleration_WithDampening
.asm_60de
	farcall Func_22e10
	ld hl, $611a
	ld a, $04
	call Func_3aaa
	call Func_3ae4
	call Func_7b09
	call Func_7a8c
	jr nc, .asm_6101
	ld e, $01
	ld bc, $606b
	jp Func_37f4
.asm_6101
	call Func_3992
	jr nc, .asm_610e
	ld e, $01
	ld bc, $6078
	jp Func_37f4
.asm_610e
	call Func_3943
	call Func_378b
	call Func_37a8
	jp Func_37f7
; 0x611a

SECTION "Func_611f", ROMX[$611f], BANK[$1]

Func_611f:
	ld a, [sa000Unk70]
	or a
	ld e, $20
	ld bc, $280
	jr z, .asm_612f
	ld e, $08
	ld bc, $140
.asm_612f
	call ApplyDownwardsAcceleration_WithDampening
	ld e, $0e
	call DecelerateObjectX
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3957
	call Func_378b
	call Func_37a8
	jp Func_37f7

Script_6154:
	set_field OBJSTRUCT_UNK51, $04
	set_oam $5278, $0a ; OAM_29278
	exec_asm Func_7b40
	var_jumptable 7
	dw .script_616e
	dw Script_6221
	dw Script_63f0
	dw Script_691d
	dw Script_6a4d
	dw Script_6ac3
	dw Script_6b91
.script_616e
	set_field OBJSTRUCT_UNK50, $00
	set_update_func1 ASM, Func_619c
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_6193
	jump_if_var_lt $03, .script_6183
	set_frame 8
	jump .script_618c
.script_6183
	set_frame_with_orientation 27, 26
	set_update_func1 ASM, Func_6196
.script_618c
	script_call Script_7b1f
	set_update_func1 ASM, Func_619c
.script_6193
	set_frame 0
	script_end

Func_6196:
	ld hl, $1b1a
	call Func_7baf
Func_619c:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_61bd
	ld e, $01
	ld bc, $63f0
	jp Func_37f4
.asm_61bd
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_61cb
	ld e, $01
	ld bc, $6345
	jp Func_37f4
.asm_61cb
	call Func_7a55
	jr nc, .asm_61d8
	ld e, $01
	ld bc, $6221
	jp Func_37f4
.asm_61d8
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_61e6
	ld e, $01
	ld bc, $67b9
	jp Func_37f4
.asm_61e6
	ldh a, [hffb4]
	and $02
	jr z, .asm_61f4
	ld e, $01
	ld bc, $680a
	jp Func_37f4
.asm_61f4
	call Func_36e6
	jr nc, .asm_6201
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_6201
	call Func_3619
	jr nc, .asm_620e
	ld e, $01
	ld bc, $6875
	jp Func_37f4
.asm_620e
	call Func_3724
	jr nc, .asm_621b
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_621b
	call Func_6c37
	jp Func_37f7

Script_6221:
	set_field OBJSTRUCT_UNK50, $01
	set_update_func1 ASM, Func_6282
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_6232
	set_frame 8
	script_call Script_7b1f
.script_6232
	exec_asm Func_383c
	var_jumptable 6
	dw .script_6243
	dw .script_6252
	dw .script_6261
	dw .script_6264
	dw .script_6273
	dw .script_6261
.script_6243
	set_frame_wait 1, 10
	set_frame_wait 2, 8
	set_frame_wait 3, 10
	set_frame_wait 2, 8
	jump .script_6243
.script_6252
	set_frame_wait 1, 6
	set_frame_wait 2, 6
	set_frame_wait 3, 6
	set_frame_wait 2, 6
	jump .script_6252
.script_6261
	set_frame 7
	script_end
.script_6264
	set_frame_wait 1, 4
	set_frame_wait 2, 3
	set_frame_wait 3, 4
	set_frame_wait 2, 3
	jump .script_6264
.script_6273
	set_frame_wait 1, 4
	set_frame_wait 2, 4
	set_frame_wait 3, 4
	set_frame_wait 2, 4
	jump .script_6273

Func_6282:
	call Func_359a
	call Func_7c45
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_62a0
	ld e, $01
	ld bc, $616e
	jp Func_37f4
.asm_62a0
	call Func_7adb
	jr nc, .asm_62ad
	ld e, $01
	ld bc, $63f0
	jp Func_37f4
.asm_62ad
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_62bb
	ld e, $01
	ld bc, $6345
	jp Func_37f4
.asm_62bb
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_62ca
	ld e, $01
	ld bc, $616e
	jp Func_37f4
.asm_62ca
	call Func_373b
	jr nc, .asm_62d7
	ld e, $01
	ld bc, $632d
	jp Func_37f4
.asm_62d7
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_62e5
	ld e, $01
	ld bc, $67b9
	jp Func_37f4
.asm_62e5
	ldh a, [hffb4]
	and $02
	jr z, .asm_62f3
	ld e, $01
	ld bc, $680a
	jp Func_37f4
.asm_62f3
	call Func_36e6
	jr nc, .asm_6300
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_6300
	call Func_3619
	jr nc, .asm_630d
	ld e, $01
	ld bc, $6875
	jp Func_37f4
.asm_630d
	call Func_374e
	jr nc, .asm_631a
	ld e, $01
	ld bc, $6221
	jp Func_37f4
.asm_631a
	call Func_3724
	jr nc, .asm_6327
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_6327
	call Func_6c37
	jp Func_37f7
; 0x632d

SECTION "Func_63f0", ROMX[$63f0], BANK[$1]

Script_63f0:
	set_field OBJSTRUCT_UNK50, $05
	set_update_func1 ASM, Func_643b
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_641e
	jump_if_var_lt $03, .script_640e
	jump_if_var_lt $02, .script_6409
	set_frame 24
	jump .script_6417
.script_6409
	set_frame 8
	jump .script_6417
.script_640e
	set_frame_with_orientation 27, 26
	set_update_func1 ASM, Func_6435
.script_6417
	script_call Script_7b1f
	set_update_func1 ASM, Func_643b
.script_641e
	set_frame 4
.script_6420
	wait 1
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_6420
	set_var_to_field OBJSTRUCT_UNK39
	wait_var
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_6420
	jump_if_not_var .script_6420
	script_end

Func_6435:
	ld hl, $1b1a
	call Func_7baf
Func_643b:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_7a8c
	call Func_3992
	jr nc, .asm_6464
	ld e, $01
	ld bc, $615b
	jp Func_37f4
.asm_6464
	call Func_39c1
	jr nc, .asm_6471
	ld e, $01
	ld bc, $63f0
	jp Func_37f4
.asm_6471
	ld e, $52
	ld a, [de]
	or a
	jr z, .asm_647f
	ld e, $01
	ld bc, $63f0
	jp Func_37f4
.asm_647f
	call Func_64d4
	jr nc, .asm_648c
	ld e, $01
	ld bc, $64ec
	jp Func_37f4
.asm_648c
	ldh a, [hffb4]
	and $02
	jr z, .asm_649a
	ld e, $01
	ld bc, $680a
	jp Func_37f4
.asm_649a
	call Func_3619
	jr nc, .asm_64a7
	ld e, $01
	ld bc, $6875
	jp Func_37f4
.asm_64a7
	call Func_3765
	jr nc, .asm_64b4
	ld e, $01
	ld bc, $6a41
	jp Func_37f4
.asm_64b4
	call Func_36e6
	jr nc, .asm_64c1
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_64c1
	call Func_3724
	jr nc, .asm_64ce
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_64ce
	call Func_6c37
	jp Func_37f7

Func_64d4:
	ld a, [sa000Unk5b]
	cp PARASOL
	jr z, .parasol
.asm_64db
	and a
	ret
.parasol
	ld e, OBJSTRUCT_Y_VEL
	ld a, [de]
	sub $80
	inc e
	ld a, [de]
	bit 7, a
	jr nz, .asm_64db
	sbc $02
	ccf
	ret
; 0x64ec

SECTION "Func_691d", ROMX[$691d], BANK[$1]

Script_691d:
	set_field OBJSTRUCT_UNK50, $0d
	set_update_func1 ASM, Func_692d
.loop
	set_frame_wait 30, 20
	set_frame_wait 31, 20
	jump .loop

Func_692d:
	call Func_359a
	ld e, $14
	ld bc, $100
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cc1
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3943
	ldh a, [hJoypad1Down]
	and PAD_A | PAD_UP
	jr z, .asm_695d
	ld e, $01
	ld bc, $68b7
	jp Func_37f4
.asm_695d
	ldh a, [hffb4]
	and $02
	jr z, .asm_696b
	ld e, $01
	ld bc, $69ee
	jp Func_37f4
.asm_696b
	call Func_3765
	jr nc, .asm_6978
	ld e, $01
	ld bc, $698b
	jp Func_37f4
.asm_6978
	call Func_36e6
	jr nc, .asm_6985
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_6985
	call Func_6c37
	jp Func_37f7
; 0x698b

SECTION "Func_6a4d", ROMX[$6a4d], BANK[$1]

Script_6a4d:
	set_field OBJSTRUCT_UNK50, $00
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_6a5a
	set_frame 0
	script_end

Func_6a5a:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_6a7b
	ld e, $01
	ld bc, $6b91
	jp Func_37f4
.asm_6a7b
	ldh a, [hffb4]
	and $02
	jr z, .asm_6a89
	ld e, $01
	ld bc, $680a
	jp Func_37f4
.asm_6a89
	call Func_37bd
	jr nc, .asm_6a96
	ld e, $01
	ld bc, $6b91
	jp Func_37f4
.asm_6a96
	call Func_7a55
	jr nc, .asm_6aa3
	ld e, $01
	ld bc, $6ac3
	jp Func_37f4
.asm_6aa3
	call Func_3724
	jr nc, .asm_6ab0
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_6ab0
	call Func_36e6
	jr nc, .asm_6abd
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_6abd
	call Func_6c37
	jp Func_37f7

Script_6ac3:
	set_field OBJSTRUCT_UNK50, $01
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_6aff
	exec_asm Func_383c
	var_jumptable 6
	dw .script_6ade
	dw .script_6aed
	dw .script_6afc
	dw .script_6ade
	dw .script_6aed
	dw .script_6afc
.script_6ade
	set_frame_wait 1, 10
	set_frame_wait 2, 8
	set_frame_wait 3, 10
	set_frame_wait 2, 8
	jump .script_6ade
.script_6aed
	set_frame_wait 1, 6
	set_frame_wait 2, 6
	set_frame_wait 3, 6
	set_frame_wait 2, 6
	jump .script_6aed
.script_6afc
	set_frame 7
	script_end

Func_6aff:
	call Func_359a
	call Func_3602
	call Func_7c8e
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_6b20
	ld e, $01
	ld bc, $6a4d
	jp Func_37f4
.asm_6b20
	call Func_7adb
	jr nc, .asm_6b2d
	ld e, $01
	ld bc, $6b91
	jp Func_37f4
.asm_6b2d
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_6b3c
	ld e, $01
	ld bc, $6a4d
	jp Func_37f4
.asm_6b3c
	ldh a, [hffb4]
	and $02
	jr z, .asm_6b4a
	ld e, $01
	ld bc, $680a
	jp Func_37f4
.asm_6b4a
	call Func_37bd
	jr nc, .asm_6b57
	ld e, $01
	ld bc, $6b91
	jp Func_37f4
.asm_6b57
	call Func_36e6
	jr nc, .asm_6b64
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_6b64
	call Func_374e
	jr nc, .asm_6b71
	ld e, $01
	ld bc, $6ac3
	jp Func_37f4
.asm_6b71
	call Func_377c
	jr nc, .asm_6b7e
	ld e, $01
	ld bc, $6c2b
	jp Func_37f4
.asm_6b7e
	call Func_3724
	jr nc, .asm_6b8b
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_6b8b
	call Func_6c37
	jp Func_37f7

Script_6b91:
	set_field OBJSTRUCT_UNK50, $05
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_6bbc
	set_var_to_field OBJSTRUCT_UNK6F
	var_jumptable 3
	dw .script_6ba5
	dw .script_6bb9
	dw .script_6ba8
.script_6ba5
	set_frame 4
	script_end
.script_6ba8
	play_sfx SFX_48
	set_frame_wait 32, 10
	set_frame_wait 33, 10
	set_frame_wait 34, 10
	set_frame_wait 35, 10
	jump .script_6ba8
.script_6bb9
	set_frame 23
	script_end

Func_6bbc:
	call Func_359a
	call Func_7d16
	call Func_7cca
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_6be0
	ld e, $01
	ld bc, $615b
	jp Func_37f4
.asm_6be0
	call Func_3943
	ldh a, [hffb4]
	and $02
	jr z, .asm_6bf1
	ld e, $01
	ld bc, $680a
	jp Func_37f4
.asm_6bf1
	call Func_37cb
	jr nc, .asm_6bfe
	ld e, $01
	ld bc, $6b91
	jp Func_37f4
.asm_6bfe
	call Func_377c
	jr nc, .asm_6c0b
	ld e, $01
	ld bc, $6c2b
	jp Func_37f4
.asm_6c0b
	call Func_36e6
	jr nc, .asm_6c18
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_6c18
	call Func_3724
	jr nc, .asm_6c25
	ld e, BANK(Script_40a2)
	ld bc, Script_40a2
	jp Func_37f4
.asm_6c25
	call Func_6c37
	jp Func_37f7
; 0x6c2b

SECTION "Func_6c37", ROMX[$6c37], BANK[$1]

Func_6c37:
	call Func_6c40
	ret z
	ld a, $01
	jp Func_3aaa

Func_6c40:
	ld e, OBJSTRUCT_FRAME
	ld a, [de]
	ld hl, $6c51
	add a
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	ret
; 0x6c51

SECTION "Func_729d", ROMX[$729d], BANK[$1]

Script_729d:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $09
	exec_asm Func_72be
	set_field OBJSTRUCT_UNK80, $00
	set_field OBJSTRUCT_UNK81, $0a
	set_update_func1 ASM, Func_72e5
	set_field OBJSTRUCT_UNK39, $1e
	set_field OBJSTRUCT_UNK3D, $01
	play_sfx SFX_01
	set_frame_wait 13, 8
	set_frame 18
	script_end

Func_72be:
	xor a
	ld hl, sa100Unk53
	ld [hl], a
	inc h
	ld [hl], a
	inc h
	ld [hl], a
	ld [sa000Unk55], a
	ld [sa000Unk56], a
	ld [sa000Unk59], a
	ld [sa000Unk57], a
	dec a
	ld [sa000Unk58], a
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	rla
	ld a, $3c
	jr c, .asm_72e1
	cpl
	inc a
.asm_72e1
	ld [sa000Unk63], a
	ret

Func_72e5:
	call Func_7a1b
	ld a, [sa000Unk56]
	or a
	jr z, .asm_72fc
	ld a, [sa000Unk55]
	or a
	jr nz, .asm_72fc
	ld e, BANK(Script_741a)
	ld bc, Script_741a
	jp Func_37f4
.asm_72fc
	ld h, d
	ld l, OBJSTRUCT_UNK39
	ld a, [hl]
	or a
	jr z, .asm_7306
	dec [hl]
	jr .asm_7320
.asm_7306
	ldh a, [hJoypad1Down]
	bit B_PAD_B, a
	jr nz, .asm_7320
	ld a, [sa000Unk56]
	or a
	jr nz, .asm_7320
	ld a, [sa000Unk55]
	or a
	jr nz, .asm_7320
	ld e, BANK(Script_73fb)
	ld bc, Script_73fb
	jp Func_37f4
.asm_7320
	call Func_3a24
	jr nc, .asm_732d
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
	jp Func_37f4
.asm_732d
	ld e, OBJSTRUCT_UNK3D
	ld a, [de]
	or a
	jr z, .asm_7337
	dec a
	ld [de], a
	jr .asm_733a
.asm_7337
	call Func_7348
.asm_733a
	ld hl, $7343
	call Func_3aaa
	jp Func_37f7
; 0x7343

SECTION "Func_7348", ROMX[$7348], BANK[$1]

Func_7348:
	ld a, [sa000Unk57]
	rla
	jr c, .asm_7360
	ld a, [sa000Unk55]
	or a
	jr nz, .asm_7360
	ld a, [sa000Unk56]
	or a
	jr nz, .asm_7360
	ld a, [sa100Unk00]
	inc a
	jr z, .asm_7361
.asm_7360
	ret
.asm_7361
	ld a, [sa000Unk71]
	ld hl, Data_7f00
	add a ; *2
	add l
	ld l, a
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	rla
	jr c, .asm_7398
.asm_7373
	ld hl, sa000YPos + 1
	ld a, [bc]
	cp $80
	jr z, .asm_73be
	inc c
	add [hl]
	inc l
	ld e, a
	ld a, [bc]
	inc c
	adc [hl]
	ld d, a
	ld hl, sa000XPos + 1
	ld a, [bc]
	inc c
	push bc
	add [hl]
	inc l
	ld c, a
	ld a, [hl]
	adc $00
	ld b, a
	call Func_73c2
	pop bc
	jr c, .asm_73be
	jr .asm_7373
.asm_7398
	ld hl, sa000YPos + 1
	ld a, [bc]
	cp $80
	jr z, .asm_73be
	inc c
	add [hl]
	inc l
	ld e, a
	ld a, [bc]
	inc c
	adc [hl]
	ld d, a
	ld hl, sa000XPos + 1
	ld a, [bc]
	inc c
	push bc
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hl]
	sbc $00
	ld b, a
	call Func_73c2
	pop bc
	jr c, .asm_73be
	jr .asm_7398
.asm_73be
	ldh a, [hff9a]
	ld d, a
	ret

Func_73c2:
	call Func_1646
	cp $21
	jr z, .asm_73cb
	and a
	ret
.asm_73cb
	ld a, l
	ldh [hff80], a
	push bc
	push de
	ld a, e
	and $f0
	or $08
	ld e, a
	ld a, c
	and $f0
	or $08
	ld c, a
	lb hl, $a1, $a2
	ld a, UNK_OBJ_03
	call CreateObject
	ld l, OBJSTRUCT_UNK50
	ld [hl], $00
	ld hl, sa000Unk55
	inc [hl]
	ld hl, sa000Unk57
	set 6, [hl]
	pop de
	pop bc
	ldh a, [hff80]
	inc a
	call Func_15a8
	scf
	ret

Script_73fb:
	play_sfx SFX_NONE
	set_update_func1 ASM, Func_7407
	set_frame_wait 13, 8
	jump Script_44bf

Func_7407:
	call Func_7a1b
	call Func_3765
	jr nc, .asm_7417
	ld e, $01
	ld bc, Script_4c05
	jp Func_37f4
.asm_7417
	jp Func_37f7

Script_741a:
	play_sfx SFX_02
	set_update_func1 ASM, Func_743b
	set_frame_wait 24, 3
	set_frame_wait 33, 2
	set_frame_wait 34, 1
	set_frame_wait 24, 1
	set_frame_wait 34, 1
	set_frame_wait 19, 1
	set_frame_wait 35, 1
	set_frame_wait 19, 1
	jump Script_746a

Func_743b:
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7c45
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3957
	call Func_3765
	jr nc, .asm_7467
	ld e, $01
	ld bc, $7815
	jp Func_37f4
.asm_7467
	jp Func_37f7

Script_746a:
	set_oam $4f40, $0a ; OAM_28f40
	script_call Script_7484
Script_7471:
	exec_asm Func_7b40
	var_jumptable 7
	dw Script_7488
	dw Script_7525
	dw Script_76a8
	dw NULL
	dw Script_7824
	dw Script_78a6
	dw Script_7966

Script_7484:
	set_field OBJSTRUCT_UNK51, $01
	script_ret

Script_7488:
	set_field OBJSTRUCT_UNK50, $00
	set_update_func1 ASM, Func_74b0
	script_call Script_3a5c
	exec_asm $7496
	script_end

Func_7496:
	call Func_3847
	ld a, h
	ld e, OBJSTRUCT_UNK6D
	ld [de], a
	ld hl, .Frames
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	ret

.Frames:
	db 20, 28, 29, 20, 28, 29

Func_74b0:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_74d1
	ld e, BANK(Script_76a8)
	ld bc, Script_76a8
	jp Func_37f4
.asm_74d1
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_74df
	ld e, $01
	ld bc, $760d
	jp Func_37f4
.asm_74df
	call Func_7a55
	jr nc, .asm_74ec
	ld e, $01
	ld bc, $7525
	jp Func_37f4
.asm_74ec
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_74fa
	ld e, BANK(Script_777f)
	ld bc, Script_777f
	jp Func_37f4
.asm_74fa
	ldh a, [hffb4]
	and $02
	jr z, .asm_7508
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_7508
	call Func_36e6
	jr nc, .asm_7515
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_7515
	call Func_374e
	jr nc, .asm_7522
	ld e, $01
	ld bc, $7488
	jp Func_37f4
.asm_7522
	jp Func_37f7

Script_7525:
	set_field OBJSTRUCT_UNK50, $01
	set_update_func1 ASM, Func_7567
	script_call Script_3a5c
Script_752f:
	exec_asm $383c
	var_jumptable 6
	dw .script_7540
	dw .script_7549
	dw .script_7552
	dw .script_7555
	dw .script_755e
	dw .script_7552
.script_7540
	set_frame_wait 21, 12
	set_frame_wait 22, 6
	jump .script_7540
.script_7549
	set_frame_wait 21, 8
	set_frame_wait 22, 4
	jump .script_7549
.script_7552
	set_frame 29
	script_end
.script_7555
	set_frame_wait 21, 8
	set_frame_wait 22, 4
	jump .script_7555
.script_755e
	set_frame_wait 21, 6
	set_frame_wait 22, 3
	jump .script_755e

Func_7567:
	call Func_359a
	call Func_7c45
Func_756d:
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_7585
	ld e, $01
	ld bc, $7488
	jp Func_37f4
.asm_7585
	call Func_7adb
	jr nc, .asm_7592
	ld e, BANK(Script_76a8)
	ld bc, Script_76a8
	jp Func_37f4
.asm_7592
	ldh a, [hJoypad1Pressed]
	and PAD_A
	jr z, .asm_75a0
	ld e, $01
	ld bc, $760d
	jp Func_37f4
.asm_75a0
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_75af
	ld e, $01
	ld bc, $7488
	jp Func_37f4
.asm_75af
	call Func_373b
	jr nc, .asm_75bc
	ld e, $01
	ld bc, $75f5
	jp Func_37f4
.asm_75bc
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_75ca
	ld e, BANK(Script_777f)
	ld bc, Script_777f
	jp Func_37f4
.asm_75ca
	ldh a, [hffb4]
	and $02
	jr z, .asm_75d8
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_75d8
	call Func_374e
	jr nc, .asm_75e5
	ld e, $01
	ld bc, $7525
	jp Func_37f4
.asm_75e5
	call Func_36e6
	jr nc, .asm_75f2
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_75f2
	jp Func_37f7

Script_75f5:
	set_field OBJSTRUCT_UNK50, $03
	play_sfx SFX_0D
	set_update_func1 ASM, Func_7604
	exec_asm Func_37ff
	jump Script_752f

Func_7604:
	call Func_359a
	call Func_7c20
	jp Func_756d

Script_760d:
	set_field OBJSTRUCT_UNK50, $04
	set_update_func1 ASM, Func_7630
	set_y_vel -3.562
	play_sfx SFX_04
	jump Script_7623
; 0x761c

SECTION "Func_7623", ROMX[$7623], BANK[$1]

Script_7623:
	set_frame 21
.script_7625
	wait 1
	set_var_to_field OBJSTRUCT_Y_VEL + 1
	jump_if_var_lt $80, .script_7625
	jump Script_76a8

Func_7630:
	call Func_359a
	ldh a, [hJoypad1Down]
	bit B_PAD_A, a
	jr nz, .asm_7641
	ld e, $01
	ld bc, $761c
	jp Func_37f4
.asm_7641
	ld bc, $ff50
	call Func_37eb
	jr nc, .asm_7654
	ld h, d
	ld l, OBJSTRUCT_UNK1F
	ld [hl], $41
	inc l
	ld [hl], $76
	inc l
	ld [hl], $54
.asm_7654
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_767d
	ld e, $01
	ld bc, Script_7471
	jp Func_37f4
.asm_767d
	call Func_39c1
	jr nc, .asm_768a
	ld e, $01
	ld bc, Script_76a8
	jp Func_37f4
.asm_768a
	ldh a, [hffb4]
	and $02
	jr z, .asm_7698
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_7698
	call Func_36e6
	jr nc, .asm_76a5
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_76a5
	jp Func_37f7

Script_76a8:
	set_field OBJSTRUCT_UNK50, $05
	set_update_func1 ASM, Func_76b5
	script_call Script_3a5c
	set_frame 21
	script_end

Func_76b5:
	call Func_359a
	ld e, $20
	ld bc, $280
	call ApplyDownwardsAcceleration_WithDampening
	call Func_7cb8
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_76de
	ld e, $01
	ld bc, $7471
	jp Func_37f4
.asm_76de
	call Func_3957
	ldh a, [hffb4]
	and $02
	jr z, .asm_76ef
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_76ef
	call Func_3765
	jr nc, .asm_76fc
	ld e, $01
	ld bc, $7815
	jp Func_37f4
.asm_76fc
	call Func_36e6
	jr nc, .asm_7709
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_7709
	jp Func_37f7

Script_770c:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK51, $00
	set_field OBJSTRUCT_UNK50, $0a
	set_update_func1 ASM, Func_7741
	set_field OBJSTRUCT_UNK58, $ff
	exec_asm Func_3a18
	jump_if_var .script_772d
	create_object_rel_2 $01, 8, -4
	play_sfx SFX_1B
	jump .script_7735
.script_772d
	create_object_rel_2 $06, 8, -4
	play_sfx SFX_32
.script_7735
	set_frame_wait 24, 12
	set_frame_wait 18, 6
	set_frame_wait 13, 6
	jump Script_44bf

Func_7741:
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	rla
	ldh a, [hJoypad1Down]
	jr c, .asm_774f
	bit B_PAD_RIGHT, a
	jr z, .asm_7755
	jr .asm_7758
.asm_774f
	bit B_PAD_LEFT, a
	jr z, .asm_7755
	jr .asm_7758
.asm_7755
	call Func_7a35
.asm_7758
	call Func_7a42
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	call Func_3957
	call Func_3765
	jr nc, .asm_777c
	ld e, BANK(Script_4c05)
	ld bc, Script_4c05
	jp Func_37f4
.asm_777c
	jp Func_37f7

Script_777f:
	exec_asm Func_35a2
	set_field OBJSTRUCT_UNK50, $0b
	set_update_func1 ASM, Func_780b
	exec_asm Func_39f0
	var_jumptable 3
	dw Script_779f
	dw Script_77b9
	dw Script_77b9

Script_7794:
	exec_asm Func_77ed
	var_jumptable 3
	dw Script_44bf
	dw Script_5631
	dw Script_6154

Script_779f:
	set_field OBJSTRUCT_UNK58, $ff
	set_field OBJSTRUCT_UNK5B, NO_COPY_ABILITY
	set_field OBJSTRUCT_UNK5C, $00
	set_field OBJSTRUCT_UNK51, $00
	play_sfx SFX_03
	set_frame_wait 23, 4
	set_frame_wait 14, 4
	set_frame_wait 4, 4
	jump Script_7794

Script_77b9:
	play_sfx SFX_29
	exec_asm Func_3a07
	set_frame_wait 23, 4
	set_frame_wait 14, 4
	set_frame_wait 4, 4
	exec_asm Func_3c42
	exec_asm Func_1067
	stop_movement
	exec_asm Func_357f
	set_update_func1 ASM, Func_7811
	create_particle PARTICLE_01
	set_frame_wait 4, 8
.script_77dc
	wait 1
	set_var_to_field OBJSTRUCT_UNK64
	jump_if_var .script_77dc
	script_farcall Script_1eed7
	exec_asm Func_1080
	jump Script_7794

Func_77ed:
	ld a, [sa000Unk5b]
	bit 7, a
	jr z, .got_copy_ability
	; NO_COPY_ABILITY
	xor a
	jr .asm_7800
.got_copy_ability
	ld hl, .data
	add l
	ld l, a
	incc h
	ld a, [hl]
.asm_7800
	ld e, OBJSTRUCT_VAR
	ld [de], a
	ret

.data
	table_width 1
	db $01 ; FIRE
	db $02 ; PARASOL
	db $01 ; STONE
	db $01 ; CUTTER
	db $01 ; NEEDLE
	db $01 ; SPARK
	db $01 ; ICE
	assert_table_length NUM_COPY_ABILITIES

Func_780b:
	call Func_7a1b
	jp Func_37f7

Func_7811:
	call Func_34fd
	ret
; 0x7815

SECTION "Func_7815", ROMX[$7815], BANK[$1]

Script_7815:
	script_call Script_7484
	exec_asm Func_3a48
	create_object_rel_1 PARTICLE_07, 0, 0
	jump Script_7471

Script_7824:
	set_field OBJSTRUCT_UNK50, $00
	set_update_func1 ASM, Func_7832
	script_call Script_3a5c
	exec_asm Func_7496
	script_end

Func_7832:
	call Func_359a
	call Func_3602
	farcall Func_22e10
	call Func_7b09
	call Func_3924
	call Func_7adb
	jr nc, .asm_7853
	ld e, $01
	ld bc, $7966
	jp Func_37f4
.asm_7853
	call Func_37bd
	jr nc, .asm_7860
	ld e, $01
	ld bc, $7966
	jp Func_37f4
.asm_7860
	call Func_7a55
	jr nc, .asm_786d
	ld e, $01
	ld bc, $78a6
	jp Func_37f4
.asm_786d
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_787b
	ld e, BANK(Script_777f)
	ld bc, Script_777f
	jp Func_37f4
.asm_787b
	ldh a, [hffb4]
	and $02
	jr z, .asm_7889
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_7889
	call Func_36e6
	jr nc, .asm_7896
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_7896
	call Func_374e
	jr nc, .asm_78a3
	ld e, $01
	ld bc, $7824
	jp Func_37f4
.asm_78a3
	jp Func_37f7

Script_78a6:
	set_field OBJSTRUCT_UNK50, $01
	set_update_func1 ASM, Func_78d6
	script_call Script_3a5c
	exec_asm $383c
	var_jumptable 6
	dw .script_78c1
	dw .script_78ca
	dw .script_78d3
	dw .script_78c1
	dw .script_78ca
	dw .script_78d3
.script_78c1
	set_frame_wait 21, 12
	set_frame_wait 22, 6
	jump .script_78c1
.script_78ca
	set_frame_wait 21, 8
	set_frame_wait 22, 4
	jump .script_78ca
.script_78d3
	set_frame 29
	script_end

Func_78d6:
	call Func_359a
	call Func_3602
	call Func_7c8e
	farcall Func_22e10
	call Func_7b09
	call Func_7a9e
	jr nc, .asm_78f7
	ld e, $01
	ld bc, $7824
	jp Func_37f4
.asm_78f7
	call Func_7adb
	jr nc, .asm_7904
	ld e, $01
	ld bc, $7966
	jp Func_37f4
.asm_7904
	ld h, d
	ld l, $0d
	ld a, [hli]
	or [hl]
	jr nz, .asm_7913
	ld e, $01
	ld bc, $7824
	jp Func_37f4
.asm_7913
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_7921
	ld e, BANK(Script_777f)
	ld bc, Script_777f
	jp Func_37f4
.asm_7921
	ldh a, [hffb4]
	and $02
	jr z, .asm_792f
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_792f
	call Func_37bd
	jr nc, .asm_793c
	ld e, $01
	ld bc, $7966
	jp Func_37f4
.asm_793c
	call Func_374e
	jr nc, .asm_7949
	ld e, $01
	ld bc, $78a6
	jp Func_37f4
.asm_7949
	call Func_36e6
	jr nc, .asm_7956
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_7956
	call Func_377c
	jr nc, .asm_7963
	ld e, $01
	ld bc, $79e8
	jp Func_37f4
.asm_7963
	jp Func_37f7

Script_7966:
	set_field OBJSTRUCT_UNK50, $05
	set_field OBJSTRUCT_UNK52, $00
	set_update_func1 ASM, Func_7989
	set_var_to_field OBJSTRUCT_UNK6F
	var_jumptable 3
	dw .script_797a
	dw .script_7986
	dw .script_797d
.script_797a
	set_frame 19
	script_end
.script_797d
	set_frame_wait 21, 5
	set_frame_wait 22, 4
	jump .script_797d
.script_7986
	set_frame 19
	script_end

Func_7989:
	call Func_359a
	call Func_7d42
	call Func_7cca
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3992
	jr nc, .asm_79ad
	ld e, $01
	ld bc, $7471
	jp Func_37f4
.asm_79ad
	call Func_3943
	ldh a, [hffb4]
	and $02
	jr z, .asm_79be
	ld e, BANK(Script_770c)
	ld bc, Script_770c
	jp Func_37f4
.asm_79be
	call Func_37cb
	jr nc, .asm_79cb
	ld e, $01
	ld bc, $7966
	jp Func_37f4
.asm_79cb
	call Func_377c
	jr nc, .asm_79d8
	ld e, $01
	ld bc, $79e8
	jp Func_37f4
.asm_79d8
	call Func_36e6
	jr nc, .asm_79e5
	ld e, $08
	ld bc, $6282
	jp Func_37f4
.asm_79e5
	jp Func_37f7
; 0x79e8

SECTION "Func_7a1b", ROMX[$7a1b], BANK[$1]

Func_7a1b:
	call Func_7a35
	call Func_7a42
	farcall Func_22e10
	call Func_7b09
	call Func_391f
	call Func_3977
	jp Func_3957

Func_7a35:
	ld a, [sa000Unk70]
	or a
	ld e, $0e
	jr z, .asm_7a3f
	ld e, $09
.asm_7a3f
	jp DecelerateObjectX

Func_7a42:
	ld a, [sa000Unk70]
	or a
	ld e, $20
	ld bc, $280
	jr z, .asm_7a52
	ld e, $08
	ld bc, $e0
.asm_7a52
	jp ApplyDownwardsAcceleration_WithDampening

Func_7a55:
	ldh a, [hJoypad1Down]
	and PAD_RIGHT | PAD_LEFT
	jr z, .no_carry
	ld h, d
	ld de, $fff9
	bit B_PAD_RIGHT, a
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

Func_7a9e:
	call Func_1d8b
	jr nc, .asm_7ab9
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	ld b, a
	ld e, OBJSTRUCT_X_VEL + 1
	ld a, [de]
	xor b
	rla
	jr c, .asm_7ab9
	call Func_7abb
	ld e, OBJSTRUCT_X_VEL
	xor a
	ld [de], a
	inc e
	ld [de], a
	scf
	ret
.asm_7ab9
	and a
	ret

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
	create_particle PARTICLE_00
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
	bit B_PAD_LEFT, a
	jr nc, .asm_7bbb
	bit B_PAD_RIGHT, a
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

SECTION "Func_7c20", ROMX[$7c20], BANK[$1]

Func_7c20:
	ld e, OBJSTRUCT_UNK6D
	ld a, [de]
	cp $03
	ld e, 0.156
	jr c, .decelerate
	ld e, 0.031
.decelerate
	jp DecelerateObjectX

Func_7c2e:
	call Func_3847
	ld a, h
	ld hl, .DecelerationsVals
	add l
	ld l, a
	incc h
	ld a, [hl]
	ld e, a
	jp DecelerateObjectX

.DecelerationsVals:
	db 0.055
	db 0.055
	db 0.055
	db 0.016
	db 0.016
	db 0.016

Func_7c45:
	ld e, OBJSTRUCT_UNK6D
	ld a, [de]
	cp $03
	jr nc, .asm_7c6d
	cp $01
	jr z, .asm_7c5b
	jr nc, .asm_7c64
	lb hl, 0.125, 0.055
	ld bc, 1.2
	jp Func_386e
.asm_7c5b
	lb hl, 0.031, 0.055
	ld bc, 0.625
	jp Func_386e
.asm_7c64
	lb hl, 0.125, 0.055
	ld bc, 1.875
	jp Func_386e
.asm_7c6d
	cp $04
	jr z, .asm_7c7c
	jr nc, .asm_7c85
	lb hl, 0.094, 0.016
	ld bc, 1.2
	jp Func_386e
.asm_7c7c
	lb hl, 0.023, 0.016
	ld bc, 0.625
	jp Func_386e
.asm_7c85
	lb hl, 0.094, 0.016
	ld bc, 1.875
	jp Func_386e

Func_7c8e:
	ld e, OBJSTRUCT_UNK6D
	ld a, [de]
	cp $03
	jr c, .asm_7c97
	sub $03
.asm_7c97
	cp $01
	jr z, .asm_7ca6
	jr nc, .asm_7caf
	ld hl, $b05
	ld bc, $99
	jp Func_386e
.asm_7ca6
	ld hl, $305
	ld bc, $40
	jp Func_386e
.asm_7caf
	ld hl, $b05
	ld bc, $100
	jp Func_386e

Func_7cb8:
	lb hl, 0.086, 0.055
	ld bc, 1.2
	jp Func_3894

Func_7cc1:
	lb hl, $16, $09
	ld bc, 0.75
	jp Func_3894

Func_7cca:
	lb hl, $08, 09
	ld bc, $10c
	jp Func_3894
; 0x7cd3

SECTION "Func_7cfd", ROMX[$7cfd], BANK[$1]

Func_7cfd:
	ldh a, [hJoypad1Down]
	and PAD_A | PAD_UP
	jr z, .asm_7d0d
	ld e, $50
	ld bc, $feb3
	call ApplyUpwardsAcceleration_WithDampening
	jr .asm_7d15
.asm_7d0d
	ld e, $14
	ld bc, $100
	call ApplyDownwardsAcceleration_WithDampening
.asm_7d15
	ret

Func_7d16:
	ld h, d
	ld l, OBJSTRUCT_UNK6E
	ld a, [hl]
	or a
	jr z, .asm_7d20
	dec [hl]
	jr .asm_7d2f
.asm_7d20
	ldh a, [hJoypad1Down]
	and PAD_A | PAD_UP
	jr z, .asm_7d2f
	ld [hl], $0f
	ld l, $0f
	ld [hl], $00
	inc l
	ld [hl], $ff
.asm_7d2f
	ld e, $08
	ld bc, $e0
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_7d3f
	ld e, $10
	ld bc, $200
.asm_7d3f
	jp ApplyDownwardsAcceleration_WithDampening

Func_7d42:
	ld h, d
	ld l, OBJSTRUCT_UNK6E
	ld a, [hl]
	or a
	jr z, .asm_7d4c
	dec [hl]
	jr .asm_7d5b
.asm_7d4c
	ldh a, [hJoypad1Down]
	and PAD_A | PAD_UP
	jr z, .asm_7d5b
	ld [hl], $0f
	ld l, OBJSTRUCT_Y_VEL
	ld [hl], LOW(-0.75)
	inc l
	ld [hl], HIGH(-0.75)
.asm_7d5b
	ld e, $10
	ld bc, $180
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr z, .asm_7d6b
	ld e, $10
	ld bc, $200
.asm_7d6b
	jp ApplyDownwardsAcceleration_WithDampening

Func_7d6e:
	call Func_3ae9
	ret nc
	ld hl, sa000Unk6c
	set 3, [hl]
	ret

Func_7d78:
	ld h, $00
	ldh a, [hJoypad1Down]
	bit B_PAD_UP, a
	jr nz, .asm_7d86
	inc h
	bit B_PAD_DOWN, a
	jr nz, .asm_7d86
	inc h
.asm_7d86
	ld a, h
	ld e, OBJSTRUCT_VAR
	ld [de], a
	ret

Func_7d8b:
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	cp $02
	jr nc, .asm_7d96
	add $05
	jr .asm_7d98
.asm_7d96
	ld a, $04
.asm_7d98
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	ret

Func_7d9c:
	ldh a, [hJoypad1Down]
	and PAD_RIGHT | PAD_LEFT
	jr z, .asm_7dad
	bit B_PAD_RIGHT, a
	ld a, $40
	jr nz, .asm_7daa
	ld a, $c0
.asm_7daa
	ld e, OBJSTRUCT_UNK45
	ld [de], a
.asm_7dad
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	ld l, a
	ldh a, [hJoypad1Down]
	and PAD_CTRL_PAD
	ld h, l
	jr z, .asm_7dc4
	ld h, $00
	bit B_PAD_UP, a
	jr nz, .asm_7dc4
	inc h
	bit B_PAD_DOWN, a
	jr nz, .asm_7dc4
	inc h
.asm_7dc4
	ld a, h
	cp l
	jr nz, .asm_7dca
	and a
	ret
.asm_7dca
	ld [de], a
	scf
	ret
; 0x7dcd

SECTION "Data_7f00", ROMX[$7f00], BANK[$1]

Data_7f00:
	table_width 2
	dw $7f08 ; NONE
	dw $7f24 ; RICK
	dw $7f40 ; KINE
	dw $7f5c ; COO
	assert_table_length NUM_ANIMAL_FRIENDS + 1
; 0x7f08

SECTION "Script_cd9b", ROMX[$4d9b], BANK[$03]

Script_cd9b:
	set_field OBJSTRUCT_UNK4C, $00
	set_draw_func Func_e05
	exec_asm Func_cdaf
	unk03_cmd Func_cdd6
	script_end
; 0xcda9

SECTION "Func_cdaf", ROMX[$4daf], BANK[$03]

Func_cdaf:
	ld a, HIGH(sa000)
	ld h, a
	ld e, OBJSTRUCT_PARENT_OBJ
	ld [de], a
	ld e, OBJSTRUCT_Y_POS + 1
	ld l, e
	ld a, [de]
	sub [hl]
	ld [de], a
	inc l
	inc e
	ld a, [de]
	sbc [hl]
	ld [de], a
	ld e, OBJSTRUCT_X_POS + 1
	ld l, e
	ld a, [de]
	sub [hl]
	ld [de], a
	inc l
	inc e
	ld a, [de]
	sbc [hl]
	ld [de], a
	rla
	ld a, -0.164
	jr nc, .asm_cdd2
	cpl
	inc a
	; a = 0.164
.asm_cdd2
	ld e, OBJSTRUCT_X_ACC
	ld [de], a
	ret

Func_cdd6:
	call Func_cdfe
	ret nc
	ld e, OBJSTRUCT_BASE_SCORE
	ld a, [de]
	ld c, a
	inc e
	ld a, [de]
	ld b, a
	ld a, [sa000Unk56]
	inc a
	ld h, a
	call AddToScore
	ld hl, sa000Unk56
	inc [hl]
	ld hl, sa000Unk55
	dec [hl]
	ld h, d
	jp Func_bba
; 0xcdf5

SECTION "Func_cdfe", ROMX[$4dfe], BANK[$03]

Func_cdfe:
	ld a, [sa000Unk81]
	dec a
	ld b, a
	add a
	inc a
	ld c, a
	ld e, OBJSTRUCT_X_POS + 1
	ld a, [de]
	add b
	cp c
	ret c
	call ApplyObjectXAcceleration
	ld h, d
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [sa000Unk80]
	cpl
	inc a
	add [hl]
	cpl
	inc a
	ld b, a
	ld c, $00
	sra b
	rr c
	sra b
	rr c
	sra b
	rr c
	ld l, OBJSTRUCT_Y_VEL
	ld [hl], c
	inc l
	ld [hl], b
	call ApplyObjectVelocities
	and a
	ret
; 0xce33

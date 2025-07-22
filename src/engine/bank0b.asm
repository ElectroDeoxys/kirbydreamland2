SECTION "Func_2f85b", ROMX[$785b], BANK[$b]

Func_2f85b::
	xor a
	ldh [hff81], a
	ldh [hff83], a
	ld hl, hObjectOrientation
	ld [hli], a ; hObjectOrientation
	ld [hli], a ; hOAMBaseTileID
	ld [hl], a  ; hOAMFlags

	ld hl, sObjectGroup2 + OBJSTRUCT_UNK53
.loop_group_2
	push hl
	ld a, [hl] ; OBJSTRUCT_UNK53
	or a
	jr nz, .asm_2f89b
	ld l, OBJSTRUCT_UNK56
	ld [hli], a
	ld [hl], a

	; pick random entry in Data_2f914
	call Random
	and $0f
	ld bc, Data_2f914
	add c
	ld c, a
	incc b

	ld a, [sa000Unk80]
	ld e, a
	ld a, [bc]
	add e
	ld l, OBJSTRUCT_UNK55
	ld [hl], a

	; pick corresponding entry in Data_2f924
	ld a, c
	add $10
	ld c, a
	incc b
	ld a, [sa000Unk45]
	rla
	ld a, [bc]
	jr nc, .asm_2f898
	cpl
	inc a
.asm_2f898
	ld l, OBJSTRUCT_UNK53
	ld [hl], a
.asm_2f89b
	ld a, [sa000Unk81]
	ld b, a
	add a
	inc a
	ld c, a
	ld l, OBJSTRUCT_UNK53
	ld a, [hl]
	add b
	cp c
	jr nc, .asm_2f8ad
	ld [hl], $00
	jr .next_obj
.asm_2f8ad
	ld a, [sa000Unk63]
	ld l, OBJSTRUCT_UNK56
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

	ld l, OBJSTRUCT_UNK55
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
	rr c ; /8
	ld l, OBJSTRUCT_UNK58
	ld [hl], c
	inc l
	ld [hl], b
	ld l, OBJSTRUCT_UNK56
	ld d, h
	ld e, OBJSTRUCT_UNK52
	ld a, [de]
	add [hl]
	ld [de], a
	inc l
	inc e
	ld a, [de]
	adc [hl]
	ld [de], a
	ld b, a
	ld a, [sa000Unk09]
	add b
	ldh [hff80], a
	inc l
	inc e
	ld a, [de]
	add [hl]
	ld [de], a
	inc l
	inc e
	ld a, [de]
	adc [hl]
	ld [de], a
	ld b, a
	ld a, [sa000Unk0b]
	add b
	ldh [hff82], a
	ld de, hff83
	ld hl, $6f8a
	call LoadSprite
.next_obj
	pop hl
	inc h
	ld a, h
	cp HIGH(sObjectGroup2End)
	jp nz, .loop_group_2
	ldh a, [hff9a]
	ld d, a
	ret

Data_2f914:
	db -15
	db -15
	db -20
	db -20
	db -20
	db -20
	db -12
	db  -5
	db   5
	db  12
	db  20
	db  20
	db  20
	db  20
	db  15
	db  15

Data_2f924:
	db 15
	db 20
	db 25
	db 30
	db 35
	db 40
	db 44
	db 44
	db 44
	db 44
	db 40
	db 35
	db 30
	db 25
	db 20
	db 15
; 0x2f934

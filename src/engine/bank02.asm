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
	ld [sa000Unk5b], a ; -1
	inc a
	ld [wCopyAbility], a ; NONE
	ld hl, wHUDUpdateFlags
	set UPDATE_COPY_ABILITY_F, [hl]
.done
	ret

.data
	db -1
	db -1
	db  0
	db  0
	db  0
	db  0
	db  0
	db  0
	db  0
	db -1
	db -1
	db -1
	db  0
	db  0
; 0xb4a7

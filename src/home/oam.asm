Func_496::
	ld a, [wda28]
	; load wda23 if $c2
	; load wda24 if $c3
	ld de, wda23
	rra
	jr nc, .asm_4a0
	inc de ; wda24
.asm_4a0
	xor a
	ld [wVirtualOAMPtr + 1], a
	ld [wda22], a
	ld [de], a
	ld hl, wda06
	ld [hli], a
	ld [hl], a ; wda07
	ret

Func_4ae::
	ld a, [wVirtualOAMPtr + 0]
	ld c, a
	ld h, a
	; load wda0a if wVirtualOAM1
	; load wda0b if wVirtualOAM2
	ld de, wda0a
	rra
	jr nc, .asm_4ba
	inc de ; wda0b
.asm_4ba
	ld a, [de]
	ld b, a
	ld a, [wVirtualOAMPtr + 1]
	ld l, a
	ld [de], a
	sub b
	jr nc, .asm_4ca
	; old index > new index
	ld b, a ; diff between indices
	xor a
.loop_clear
	ld [hli], a
	inc b
	jr nz, .loop_clear

.asm_4ca
	srl h
	ld hl, wScroll1
	jr nc, .asm_4d4
	ld hl, wScroll2
.asm_4d4
	ld a, [wda00]
	ld b, a
	ld a, [wda06]
	add b
	ld [hli], a ; wda00 + wda06

	ld a, [wda01]
	ld b, a
	ld a, [wda07]
	add b
	ld [hli], a ; wda01 + wda07

	ld a, [wda28]
	ld b, a
	ld de, wda23
	rra
	jr nc, .asm_4f1
	inc de ; wda24
.asm_4f1
	ld a, [de]
	or a
	jr z, .select_oam_for_transfer
	bit 0, b
	ld hl, wda27
	di
	jr nz, .asm_503
	set 0, [hl]
	res 2, [hl]
	jr .enable_interrupt
.asm_503
	set 1, [hl]
	set 2, [hl]
.enable_interrupt
	ei
	ld a, b
	xor $1
	ld [wda28], a

.select_oam_for_transfer
	ld a, c
	and $1
	inc a
	; a = 1 for wVirtualOAM1
	; a = 2 for wVirtualOAM2
	ld [wVirtualOAMSelect], a

	; toggles OAM1/2
	ld a, c
	xor $1
	ld [wVirtualOAMPtr + 0], a
	ret

; input:
; - hl = OAM data
; - de = object position
LoadSprite::
	ld a, [wVirtualOAMPtr + 1]
	rrca
	rrca ; *4
	add [hl] ; num OAM
	cp OAM_COUNT + 1
	ret nc ; cannot fit in virtual OAM

	ld a, [de]
	dec e
	or a
	jr z, .asm_532
	inc a
	ret nz
	ld a, [de]
	cp 192
	ret c ; exit if y < 192
	jr .asm_536
.asm_532
	ld a, [de]
	cp 192
	ret nc ; exit if y >= 192
.asm_536
	add OAM_Y_OFS
	ld c, a ; y

	dec e
	ld a, [de]
	dec e
	or a
	jr z, .asm_547
	inc a
	ret nz
	ld a, [de]
	cp 204
	ret c ; exit if x < 204
	jr .asm_54b
.asm_547
	ld a, [de]
	cp 204
	ret nc ; exit if x >= 204
.asm_54b
	add OAM_X_OFS
	ld b, a ; x

	inc hl
	ld a, [wVirtualOAMPtr + 0]
	ld d, a
	ld a, [wVirtualOAMPtr + 1]
	ld e, a
	ldh a, [hObjectOrientation]
	rla
	jr c, .loop_oam_mirrored
.loop_oam
	ld a, [hli]
	add c
	cp SCREEN_HEIGHT_PX + OAM_Y_OFS
	jr nc, .y_out_of_range_1
	ld [de], a ; y
	inc e
	ld a, [hli]
	add b
	cp SCREEN_WIDTH_PX + OAM_X_OFS
	jr nc, .x_out_of_range_1
	ld [de], a ; x
	inc e
	ldh a, [hOAMBaseTileID]
	add [hl]
	inc hl
	ld [de], a ; tile ID
	inc e
	ldh a, [hOAMFlags]
	xor [hl]
	inc hl
	ld [de], a ; attributes
	inc e
.next_oam
	bit 0, a
	jr z, .loop_oam
	ld a, e
	ld [wVirtualOAMPtr + 1], a
	ret

.y_out_of_range_1
	inc hl
	inc hl
	ld a, [hli]
	jr .next_oam

.x_out_of_range_1
	dec e
	inc hl
	ld a, [hli]
	jr .next_oam

.loop_oam_mirrored
	ld a, [hli]
	add c
	cp SCREEN_HEIGHT_PX + OAM_Y_OFS
	jr nc, .y_out_of_range_2
	ld [de], a ; y
	inc e
	ld a, [hli]
	cpl
	sub 8 - 1
	add b
	cp SCREEN_WIDTH_PX + OAM_X_OFS
	jr nc, .x_out_of_range_2
	ld [de], a ; x
	inc e
	ldh a, [hOAMBaseTileID]
	add [hl]
	inc hl
	ld [de], a ; tile ID
	inc e
	ldh a, [hOAMFlags]
	xor [hl]
	xor OAM_XFLIP
	inc hl
	ld [de], a ; attributes
	inc e
.next_oam_mirrored
	bit 0, a
	jr z, .loop_oam_mirrored
	ld a, e
	ld [wVirtualOAMPtr + 1], a
	ret

.y_out_of_range_2
	inc hl
	inc hl
	ld a, [hli]
	jr .next_oam_mirrored

.x_out_of_range_2
	dec e
	inc hl
	ld a, [hli]
	jr .next_oam_mirrored

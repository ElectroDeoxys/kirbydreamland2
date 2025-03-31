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
	xor a
	ld hl, wda30
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
; 0x1c02d

SECTION "Func_1c1dc", ROMX[$41dc], BANK[$7]

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
	jr nc, .asm_1c289
	inc d
.asm_1c289
	ld a, h
	ld [wdb56], a
	ld a, $0d
	call $42bc ; Func_1c2bc
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
	jr nc, .asm_1c2a8
	inc b
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
	call $4318 ; Func_1c318
.asm_1c2bb
	ret
; 0x1c2bc

SECTION "Func_1dada", ROMX[$5ada], BANK[$7]

Func_1dada:
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

SECTION "TitleScreen", ROMX[$5fee], BANK[$7]

TitleScreen:
	; set time to switch to Demo
	; after entering Title Screen
	ld hl, wTitleScreenDemoTimer
	ld a, LOW(1598)
	ld [hli], a
	ld [hl], HIGH(1598)

	ld hl, $6107
	ld de, vTiles0
	call Decompress

	ld hl, vTiles0
	ld de, vTiles2
	ld bc, $800
	call CopyHLToDE

	ld hl, $697d
	ld de, vBGMap0
	call Decompress

	ld a, $0b
	ld hl, $68a0
	ld de, vTiles0
	call FarDecompress

	; load Kirby graphics
	ld a, $09
	ld hl, $4000
	ld de, vTiles0 tile $10
	ld bc, $28 tiles
	call FarCopyHLToDE

	ld a, $09
	ld hl, $4280
	ld de, vTiles0 tile $38
	ld bc, $22 tiles
	call FarCopyHLToDE

	farcall Func_20000

	ld a, $f8
	ld hl, sa0b3
	call Func_7c4

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

	ld e, $08
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
	farcall Func_86b
	call Func_4ae
	call Func_343
	call ReadJoypad
	pop af
	dec a
	jr nz, .wait_delay

.wait_input_or_demo
	call Func_496
	farcall Func_86b
	call Func_647
	call Func_4ae
	call Func_343
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

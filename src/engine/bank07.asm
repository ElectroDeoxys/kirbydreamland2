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
	call Func_647
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

SECTION "OAM_1e9fb", ROMX[$69fb], BANK[$7]

OAM_1e9fb:
	dw $6a21
	dw $6a2a
	dw $6a33
	dw $6a3c
	dw $6a45
	dw $6a4e
	dw $6a53
	dw $6a5c
	dw $6a65
	dw $6a6e
	dw $6a77
	dw $6a80
	dw $6a89
	dw $6a92
	dw $6a9b
	dw $6aa4
	dw $6aad
	dw $6ab6
	dw $6abf
; 0x1ea21

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
	dwb $44e6, $0f ; $9a
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

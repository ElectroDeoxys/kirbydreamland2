SECTION "FileSelectMenu", ROMX[$68d2], BANK[$0f]

FileSelectMenu:
	call InitFileSelectMenu

	ld a, 32
.asm_3e8d7
	push af
	xor a
	ldh [hJoypad1Pressed], a
	call .Func_3e8fe
	pop af
	dec a
	jr nz, .asm_3e8d7

.asm_3e8e2
	call .Func_3e8fe
	call Func_647
	ld a, [wdf0a]
	cp $06
	jr z, .asm_3e8e2
	lb de, $01, $04
	farcall Func_6827b
	call Func_437
	ret

.Func_3e8fe:
	call Func_496
	farcall Func_86b
	call Func_4ae
	call Func_343
	jp ReadJoypad
; 0x3e912

SECTION "Func_3ec97", ROMX[$6c97], BANK[$0f]

Func_3ec97:
	ld a, $0f
	call Func_675
	ret c

	ldh a, [hff92]
	ld l, a
	ld h, HIGH(wc400)
	ld de, $98cc
	ld bc, $bf02
	call .Func_3ecc1
	ld de, $992c
	ld bc, $bf1e
	call .Func_3ecc1
	ld de, $998c
	ld bc, $bf3a
	call .Func_3ecc1
	ld a, l
	ldh [hff92], a
	ret

; input:
; - hl = ?
; - de = ?
.Func_3ecc1:
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], $05
	inc l
	ld a, [bc]
	inc a
	ld [hl], a
	inc l
	ld e, $0a
	ld [hl], e
	inc l
	dec bc
	ld a, [bc]
	and $0f
	call .Func_3ece5
	dec bc
	ld a, [bc]
	swap a
	and $0f
	call .Func_3ece5
	ld e, $00
	ld a, [bc]
	and $0f
.Func_3ece5:
	jr nz, .asm_3ecea
	ld a, e
	jr .asm_3ecec
.asm_3ecea
	ld e, $00
.asm_3ecec
	ld [hl], a
	inc l
	ret

Func_3ecef:
	ld c, $03
	ld de, $1c
	ld hl, $bf02
.asm_3ecf7
	ld b, $17
	push hl
	ld a, [hli]
.asm_3ecfb
	xor [hl]
	inc hl
	dec b
	jr nz, .asm_3ecfb
	cp [hl]
	jr nz, .asm_3ed16
	pop hl
	ld b, $18
	push hl
	ld a, [hli]
.asm_3ed08
	add [hl]
	inc hl
	dec b
	jr nz, .asm_3ed08
	cp [hl]
	jr nz, .asm_3ed16
.asm_3ed10
	pop hl
	add hl, de
	dec c
	jr nz, .asm_3ecf7
	ret
.asm_3ed16
	pop hl
	push hl
	ld b, $1a
	xor a
.asm_3ed1b
	ld [hli], a
	dec b
	jr nz, .asm_3ed1b
	jr .asm_3ed10
; 0x3ed21

SECTION "Func_3edb4", ROMX[$6db4], BANK[$0f]

Func_3edb4:
	ld a, $03
	ldh [hff82], a
	ld hl, $bf00
.asm_3edbb
	push hl
	xor a
	ldh [hff80 + 0], a
	ldh [hff80 + 1], a
	ld de, $3
	add hl, de
	ld b, $0a
	ld c, $02
	call .Func_3eded
	ld b, $02
	ld c, $01
	call .Func_3eded
	ld b, $01
	ld c, $03
	call .Func_3eded
	pop hl
	ldh a, [hff80 + 0]
	ld [hli], a
	ldh a, [hff80 + 1]
	ld [hld], a
	ld de, $1c
	add hl, de
	ldh a, [hff82]
	dec a
	ldh [hff82], a
	jr nz, .asm_3edbb
	ret

.Func_3eded:
.asm_3eded
	ld e, [hl]
	inc hl
	ld d, $08
.asm_3edf1
	srl e
	call c, .Func_3edfd
	dec d
	jr nz, .asm_3edf1
	dec b
	jr nz, .asm_3eded
	ret

.Func_3edfd:
	ldh a, [hff80 + 0]
	add c
	daa
	ldh [hff80 + 0], a
	ldh a, [hff80 + 1]
	adc $00
	daa
	ldh [hff80 + 1], a
	ret

InitFileSelectMenu:
	farcall Func_20000

	ld e, $10
	farcall Func_7a011

	ld hl, $6e8c
	ld de, vTiles0
	call Decompress

	farcall Func_1150

	ld hl, $705d
	ld de, vTiles2
	call Decompress

	ld hl, $72a3
	ld de, vBGMap0
	call Decompress

	call Func_3ecef
	call Func_3edb4
	call Func_3ec97
	call Func_1584

	ld a, $ff
	ld [wLYC], a
	ldh [rLYC], a

	ld a, $a8
	ld hl, sa0b3
	call Func_7c4

	ld e, MUSIC_FILE_SELECT_MENU
	farcall PlayMusic

	ld hl, wcd09
	ld a, $e4
	ld [hli], a ; wcd09
	ld a, $d0
	ld [hli], a ; wcd0a
	ld a, $e4
	ld [hl], a ; wcd0b

	ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d

	ld a, $06
	ld [wdf0a], a
	call ReadJoypad

	lb de, $01, $04
	farcall Func_68246
	ret
; 0x3ee8c

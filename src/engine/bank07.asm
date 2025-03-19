SECTION "Func_1c01d", ROMX[$401d], BANK[$7]

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

SECTION "Func_1dfee", ROMX[$5fee], BANK[$7]

Func_1dfee:
	ld hl, $df00
	ld a, $3e
	ld [hli], a
	ld [hl], $06

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

	ld a, $09
	ld hl, $4000
	ld de, $8100
	ld bc, $280
	call FarCopyHLToDE

	ld a, $09
	ld hl, $4280
	ld de, $8380
	ld bc, $220
	call FarCopyHLToDE

	ld hl, $4000
	ld a, $08
	call Farcall

	ld a, $f8
	ld hl, $a0b3
	call Func_7c4

	xor a
	ld [$df02], a
	ld hl, $cd09
	ld a, $e4
	ld [hli], a
	ld a, $d0
	ld [hli], a
	ld a, $e4
	ld [hl], a

	ld e, SFX_NONE
	farcall PlaySFX

	ld e, MUSIC_06
	farcall PlayMusic

	call Func_1584

	ld a, LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d

	ld e, $08
	ld hl, $6011
	ld a, $1e
	call Farcall

	ld de, $4
	farcall Func_68246

	ld e, $06
	ld hl, $606d
	ld a, $1e
	call Farcall

	ld a, $20
.asm_1e09a
	push af
	call Func_496
	ld hl, $86b
	ld a, $00
	call Farcall
	call Func_4ae
	call Func_343
	call ReadJoypad
	pop af
	dec a
	jr nz, .asm_1e09a
.asm_1e0b3
	call Func_496
	ld hl, $86b
	ld a, $00
	call Farcall
	call Func_647
	call Func_4ae
	call Func_343
	call ReadJoypad
	ld a, [$df02]
	or a
	jr nz, .asm_1e0e8
	ld hl, $df00
	ld a, [hl]
	sub $01
	ld [hli], a
	ld a, [hl]
	sbc $00
	ld [hld], a
	or [hl]
	jr nz, .asm_1e0b3
	ld hl, $5e92
	ld a, $08
	call Farcall
	jr .asm_1e0ef
.asm_1e0e8
	xor a
	ld [$deff], a
	jp Func_437
.asm_1e0ef
	ld e, $00
	ld hl, $606d
	ld a, $1e
	call Farcall
	ld de, $4
	ld hl, $427b
	ld a, $1a
	call Farcall
	jp Func_437
; 0x1e107

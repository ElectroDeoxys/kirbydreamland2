SECTION "StartIntro", ROMX[$7a2d], BANK[$10]

StartIntro:
	call Func_2af8

	xor a
	ld [wdf32], a
	ld [wScreenSectionSCX], a
	ld a, $e4
	ld [wcd09], a
	ld a, $d0
	ld [wcd0a], a
	ld a, $e4
	ld [wcd0b], a

	; clear BG maps
	ld hl, vBGMap0
	ld bc, SCRN_VX_B * SCRN_VY_B
	ld a, $00
	call FillHL

	ld hl, vBGMap1
	ld bc, SCRN_VX_B * SCRN_VY_B
	ld a, $00
	call FillHL

	; clear any music and SFX
	ld e, MUSIC_NONE
	farcall PlayMusic
	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX

	ld hl, $72d1
	ld de, vTiles0
	call Decompress

	; copy vTiles0 to vTiles2
	ld hl, vTiles0
	ld de, vTiles2
	ld bc, $800
	call CopyHLToDE

	; fill tile $ff with black
	ld hl, vTiles1 tile $7f
	ld bc, TILE_SIZE
	ld a, $ff
	call FillHL

	ld hl, $7944
	ld de, wcf00
	call Decompress

	call DrawStartIntroLineSeparators

	; enable LCD
	ld a, LCDCF_BGON | LCDCF_OBJ16 | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d

	ld e, $1f
	farcall Func_7a011

	lb de, $02, $01
	farcall Func_68246
	ld b, $00
	farcall Func_1db06

	ld a, $a8
	ld [wScreenSectionSCX], a
	ld a, $14
	ld [wdf33], a

	ld e, SFX_47
	farcall PlaySFX

.loop_scroll_rick
	call Func_43b84

	; scroll left
	ld a, [wScreenSectionSCX]
	sub 4
	ld [wScreenSectionSCX], a

	call Func_496
	call Func_4ae
	call Func_343
	ld a, [wScreenSectionSCX]
	and a
	jr nz, .loop_scroll_rick

	ld hl, wLYC
	ld a, $2f
	ld [hl], a
	ldh [rLYC], a
	ld a, $58
	ld [wScreenSectionSCX], a
	ld a, $ff
	ld [wdf33], a

	ld e, SFX_47
	farcall PlaySFX

.loop_scroll_coo
	call Func_43bcc

	; scroll right
	ld a, [wScreenSectionSCX]
	add 4
	ld [wScreenSectionSCX], a

	call Func_496
	call Func_4ae
	call Func_343
	ld a, [wScreenSectionSCX]
	and a
	jr nz, .loop_scroll_coo

	ld hl, wLYC
	ld a, $5f
	ld [hl], a
	ldh [rLYC], a
	ld a, $a8
	ld [wScreenSectionSCX], a
	ld a, $14
	ld [wdf33], a

	ld e, SFX_47
	farcall PlaySFX

.loop_scroll_kine
	call Func_43c15

	; scroll left
	ld a, [wScreenSectionSCX]
	sub 4
	ld [wScreenSectionSCX], a

	call Func_496
	call Func_4ae
	call Func_343
	ld a, [wScreenSectionSCX]
	and a
	jr nz, .loop_scroll_kine

	; small delay before intro end
	ld a, 64
.loop_wait
	dec a
	push af
	call Func_496
	call Func_4ae
	call Func_343
	pop af
	and a
	jr nz, .loop_wait

	lb de, $02, $04
	farcall Func_6827b

	call Func_437

	farcall Func_1dada
	ret

Func_43b84:
	ld a, [wScreenSectionSCX]
	and %111
	ret nz

	ld bc, vBGMap0
	ld a, [wdf33]
	and a
	ret z ; is 0
	dec a
	ld [wdf33], a
	add c
	ld c, a
	ldh a, [hff92]
	ld l, a
	ld h, HIGH(wc400)
	ld a, $06
	ldh [hff81], a
	ld de, wcf00
	ld a, [wdf33]
	add e
	ld e, a
.loop
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], $01
	inc l
	ld a, [de]
	ld [hl], a
	inc l
	ld a, e
	add SCRN_VX_B
	ld e, a
	jr nc, .asm_43bba
	inc d
.asm_43bba
	ld a, c
	add SCRN_VX_B
	ld c, a
	jr nc, .asm_43bc1
	inc b
.asm_43bc1
	ldh a, [hff81]
	dec a
	ldh [hff81], a
	jr nz, .loop
	ld a, l
	ldh [hff92], a
	ret

Func_43bcc:
	ld a, [wScreenSectionSCX]
	and $07
	ret nz

	ld bc, $98c0
	ld a, [wdf33]
	cp $14
	ret z
	inc a
	ld [wdf33], a
	add c
	ld c, a
	ldh a, [hff92]
	ld l, a
	ld h, HIGH(wc400)
	ld a, $06
	ldh [hff81], a
	ld de, $cfc0
	ld a, [wdf33]
	add e
	ld e, a
.loop
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], $01
	inc l
	ld a, [de]
	ld [hl], a
	inc l
	ld a, e
	add SCRN_VX_B
	ld e, a
	jr nc, .asm_43c03
	inc d
.asm_43c03
	ld a, c
	add SCRN_VX_B
	ld c, a
	jr nc, .asm_43c0a
	inc b
.asm_43c0a
	ldh a, [hff81]
	dec a
	ldh [hff81], a
	jr nz, .loop
	ld a, l
	ldh [hff92], a
	ret

Func_43c15:
	ld a, [wScreenSectionSCX]
	and $07
	ret nz

	ld bc, $9980
	ld a, [wdf33]
	and a
	ret z
	dec a
	ld [wdf33], a
	add c
	ld c, a
	ldh a, [hff92]
	ld l, a
	ld h, HIGH(wc400)
	ld a, $06
	ldh [hff81], a
	ld de, wd080
	ld a, [wdf33]
	add e
	ld e, a
.loop
	ld [hl], c
	inc l
	ld [hl], b
	inc l
	ld [hl], $01
	inc l
	ld a, [de]
	ld [hl], a
	inc l
	ld a, e
	add SCRN_VX_B
	ld e, a
	jr nc, .asm_43c4b
	inc d
.asm_43c4b
	ld a, c
	add SCRN_VX_B
	ld c, a
	jr nc, .asm_43c52
	inc b
.asm_43c52
	ldh a, [hff81]
	dec a
	ldh [hff81], a
	jr nz, .loop
	ld a, l
	ldh [hff92], a
	ret
; 0x43c5d

SECTION "DrawStartIntroLineSeparators", ROMX[$7c90], BANK[$10]

; draws the 2 line separators from intro screen
; each line is 2 tiles thick
DrawStartIntroLineSeparators:
	ld hl, wcf00 + $a0
	ld a, [hl]
	ld hl, $98a0
	ld b, SCRN_VX_B
.loop_line_upper_1
	ld [hli], a
	dec b
	jr nz, .loop_line_upper_1
	ld hl, wcf00 + $c0
	ld a, [hl]
	ld hl, $98c0
	ld b, SCRN_VX_B
.loop_line_bottom_1
	ld [hli], a
	dec b
	jr nz, .loop_line_bottom_1

	ld hl, wd060
	ld a, [hl]
	ld hl, $9960
	ld b, SCRN_VX_B
.loop_line_upper_2
	ld [hli], a
	dec b
	jr nz, .loop_line_upper_2
	ld hl, wd080
	ld a, [hl]
	ld hl, $9980
	ld b, SCRN_VX_B
.loop_line_bottom_2
	ld [hli], a
	dec b
	jr nz, .loop_line_bottom_2
	ret
; 0x43cc5

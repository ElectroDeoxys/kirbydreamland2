SECTION "Bank 10 GFX", ROMX[$6211], BANK[$10]

Gfx_42211: INCBIN "gfx/gfx_42211.2bpp"
Gfx_42571: INCBIN "gfx/gfx_42571.2bpp"
Gfx_42b71: INCBIN "gfx/gfx_42b71.2bpp"
Gfx_43211: INCBIN "gfx/gfx_43211.2bpp"


SECTION "StartIntro", ROMX[$7a2d], BANK[$10]

StartIntro:
	call Func_2af8

	xor a
	ld [wdf32], a
	ld [wScreenSectionSCX], a

	; set palettes
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [wFadePals3BGP], a
	ldpal a, SHADE_WHITE, SHADE_WHITE, SHADE_LIGHT, SHADE_BLACK
	ld [wFadePals3OBP0], a
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ld [wFadePals3OBP1], a

	; clear BG maps
	hlbgcoord 0, 0
	ld bc, TILEMAP_AREA
	ld a, $00
	call FillHL

	hlbgcoord 0, 0, vBGMap1
	ld bc, TILEMAP_AREA
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
	ld a, LCDC_BG_ON | LCDC_OBJ_16 | LCDC_WIN_9C00
	ldh [rLCDC], a

	call Func_46d

	ld e, SGB_ATF_1F
	farcall Func_7a011

	lb de, $02, 1
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
	call DoFrame
	ld a, [wScreenSectionSCX]
	and a
	jr nz, .loop_scroll_rick

	ld hl, wLYC
	ld a, 47
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
	call DoFrame
	ld a, [wScreenSectionSCX]
	and a
	jr nz, .loop_scroll_coo

	ld hl, wLYC
	ld a, 95
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
	call DoFrame
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
	call DoFrame
	pop af
	and a
	jr nz, .loop_wait

	lb de, SGB_PALSEQUENCE_02, 4
	farcall Func_6827b

	call Func_437

	farcall Func_1dada
	ret

Func_43b84:
	ld a, [wScreenSectionSCX]
	and %111
	ret nz

	bcbgcoord 0, 0, vBGMap0
	ld a, [wdf33]
	and a
	ret z ; is 0
	dec a
	ld [wdf33], a
	add c
	ld c, a
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
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
	add TILEMAP_WIDTH
	ld e, a
	incc d
	ld a, c
	add TILEMAP_WIDTH
	ld c, a
	incc b
	ldh a, [hff81]
	dec a
	ldh [hff81], a
	jr nz, .loop
	ld a, l
	ldh [hBGMapQueueSize], a
	ret

Func_43bcc:
	ld a, [wScreenSectionSCX]
	and $07
	ret nz

	bcbgcoord 0, 6
	ld a, [wdf33]
	cp $14
	ret z
	inc a
	ld [wdf33], a
	add c
	ld c, a
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
	ld a, $06
	ldh [hff81], a
	ld de, wcf00 + $c0
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
	add TILEMAP_WIDTH
	ld e, a
	incc d
	ld a, c
	add TILEMAP_WIDTH
	ld c, a
	incc b
	ldh a, [hff81]
	dec a
	ldh [hff81], a
	jr nz, .loop
	ld a, l
	ldh [hBGMapQueueSize], a
	ret

Func_43c15:
	ld a, [wScreenSectionSCX]
	and $07
	ret nz

	bcbgcoord 0, 12
	ld a, [wdf33]
	and a
	ret z
	dec a
	ld [wdf33], a
	add c
	ld c, a
	ldh a, [hBGMapQueueSize]
	ld l, a
	ld h, HIGH(wBGMapQueue)
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
	add TILEMAP_WIDTH
	ld e, a
	incc d
	ld a, c
	add TILEMAP_WIDTH
	ld c, a
	incc b
	ldh a, [hff81]
	dec a
	ldh [hff81], a
	jr nz, .loop
	ld a, l
	ldh [hBGMapQueueSize], a
	ret
; 0x43c5d

SECTION "DrawStartIntroLineSeparators", ROMX[$7c90], BANK[$10]

; draws the 2 line separators from intro screen
; each line is 2 tiles thick
DrawStartIntroLineSeparators:
	ld hl, wcf00 + $a0
	ld a, [hl]
	hlbgcoord 0, 5
	ld b, TILEMAP_WIDTH
.loop_line_upper_1
	ld [hli], a
	dec b
	jr nz, .loop_line_upper_1
	ld hl, wcf00 + $c0
	ld a, [hl]
	hlbgcoord 0, 6
	ld b, TILEMAP_WIDTH
.loop_line_bottom_1
	ld [hli], a
	dec b
	jr nz, .loop_line_bottom_1

	ld hl, wd060
	ld a, [hl]
	hlbgcoord 0, 11
	ld b, TILEMAP_WIDTH
.loop_line_upper_2
	ld [hli], a
	dec b
	jr nz, .loop_line_upper_2
	ld hl, wd080
	ld a, [hl]
	hlbgcoord 0, 12
	ld b, TILEMAP_WIDTH
.loop_line_bottom_2
	ld [hli], a
	dec b
	jr nz, .loop_line_bottom_2
	ret
; 0x43cc5

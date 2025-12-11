; if window is on, then disable Objs on scanlines
; that belong to the window (when LYC is triggered)
StatHandler_DisableWindowObjs::
	push af
	push hl
	push bc
	push de
	ld hl, rLCDC
	bit B_LCDC_WINDOW, [hl]
	jr z, InterruptRet

	; window is on
	ld b, 15
.loop_wait
	nop
	dec b
	jr nz, .loop_wait

	; disable obj and set default BGP
	res B_LCDC_OBJS, [hl]
	ldpal a, SHADE_WHITE, SHADE_LIGHT, SHADE_DARK, SHADE_BLACK
	ldh [rBGP], a
	jp InterruptRet
; 0x2c4

SECTION "StatHandler_ScreenSectionXScroll", ROM0[$30c]

; waits some cycles then applies wScreenSectionSCX
StatHandler_ScreenSectionXScroll::
	push af
	push hl
	push bc
	push de
	ld a, [wScreenSectionSCX]
	ld hl, rSCX
	ld b, 15
.wait
	nop
	dec b
	jr nz, .wait
	ld [hl], a
	jp InterruptRet
; 0x320

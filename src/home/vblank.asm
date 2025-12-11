_VBlank:
	ldh a, [hRequestLCDOff]
	or a
	jr z, .continue_lcd_on

; LCD was requested to be turned off
; we can only do it safely during V-Blank

.wait_vblank
	ldh a, [rLY]
	cp LY_VBLANK + 1
	jr nz, .wait_vblank

	; disable LCD
	ld hl, rLCDC
	res B_LCDC_ENABLE, [hl]

	xor a
	ldh [hRequestLCDOff], a
	jp InterruptRet

.continue_lcd_on
	; if wVirtualOAMSelect is 0, skip loading OAM and scroll update;
	; if wVirtualOAMSelect is 1,  load wVirtualOAM1
	; if wVirtualOAMSelect is >1, load wVirtualOAM2
	ld a, [wVirtualOAMSelect]
	cp $01
	jp c, .skip_dma_and_scroll ; can be jr
	ld a, HIGH(wVirtualOAM1)
	jr z, .got_virtual_oam ; wVirtualOAMSelect == 1
	inc a ; HIGH(wVirtualOAM2)
.got_virtual_oam
	ldh [hTransferVirtualOAM + $1], a
	call hTransferVirtualOAM

	ld a, [wVirtualOAMSelect]
	dec a
	ld hl, wScroll1
	jr z, .asm_18d ; wVirtualOAMSelect == 1
	ld hl, wScroll2
.asm_18d
	ld a, [hli]
	ldh [rSCY], a
	ld a, [hl]
	ldh [rSCX], a

.skip_dma_and_scroll
	ld hl, wBGOBPals
	ld c, LOW(rBGP)
	ld a, [hli]     ; wBGP
	ld [$ff00+c], a ; rBGP
	inc c
	ld a, [hli]     ; wOBP0
	ld [$ff00+c], a ; rOBP0
	inc c
	ld a, [hl]      ; wOBP1
	ld [$ff00+c], a ; rOBP1

	ld a, [wda27]
	or a
	jp z, .asm_210

	ld [wVBlankCachedSP1], sp
	ld de, TILEMAP_WIDTH - 1
	bit 2, a
	jr z, .asm_1dd
	bit 0, a
	jr z, .asm_1c8
	; wda27 bit 0 and 2 set
	ld a, [wda23]
	ld sp, wc200
.asm_1bb
	pop hl
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	add hl, de ; next row
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	dec a
	jr nz, .asm_1bb

.asm_1c8
	ld a, [wda24]
	ld sp, wc300
.asm_1ce
	pop hl
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	add hl, de ; next row
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	dec a
	jr nz, .asm_1ce
	jr .asm_207

.asm_1dd
	bit 1, a
	jr z, .asm_1f4
	; wda27 bit 1 set, 2 unset
	ld a, [wda24]
	ld sp, wc300
.asm_1e7
	pop hl
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	add hl, de
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	dec a
	jr nz, .asm_1e7

.asm_1f4
	ld a, [wda23]
	ld sp, wc200
.asm_1fa
	pop hl
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	add hl, de
	pop bc
	ld [hl], c
	inc l
	ld [hl], b
	dec a
	jr nz, .asm_1fa

.asm_207
	; restore cached stack pointer
	ld sp, wVBlankCachedSP1
	pop hl
	ld sp, hl
	xor a
	ld [wda27], a

.asm_210
	xor a
	ldh [rLYC], a
	ld hl, wStatTrampoline + $1
	ld a, LOW(Func_2a4)
	ld [hli], a
	ld [hl], HIGH(Func_2a4)
	ld [wVBlankCachedSP2], sp
	ld sp, wda1a
	pop de ; wda1a
	pop hl ; wBGMapQueueIndex
	ld c, h ; wda1d
	ld h, HIGH(wBGMapQueue)
	ldh a, [hBGMapQueueSize]
	ld b, a
	pop af ; wda1e
	reti ; jumps to wProcessBGMapQueueFunc

ProcessBGMapQueue::
.next_entry
	ld a, l ; wBGMapQueueIndex
	cp b
	jr z, .at_queue_end
.start_copy
	ld e, [hl]
	inc l
	ld d, [hl]
	inc l
	ld c, [hl]
	inc l
.loop_copy
	ld a, [hl]
	ld [de], a
	inc l
	inc de
	dec c
	jr nz, .loop_copy
	jr .next_entry

.at_queue_end
	di
	cp b
	jr z, .asm_245
	ei
	jr .start_copy
.asm_245
	ld h, c
	ld bc, ProcessBGMapQueue
	push bc
	push af
	push hl
	push de
;	fallthrough

Func_24d:
	; restore regular stack pointer
	ld sp, wVBlankCachedSP2
	pop hl
	ld sp, hl

	; overwrite wStatTrampoline with wNextStatTrampoline
	ld a, [wLYC]
	ldh [rLYC], a
	ld hl, wStatTrampoline + $1
	ld a, [wNextStatTrampoline + 0]
	ld [hli], a
	ld a, [wNextStatTrampoline + 1]
	ld [hl], a

	ld hl, rLCDC
	ld a, [wObjDisabled]
	or a
	jr z, .set_obj_on
; set obj off
	res B_LCDC_OBJS, [hl]
	jr .asm_271
.set_obj_on
	set B_LCDC_OBJS, [hl]

.asm_271
	; switch off Stat interrupt flag
	ldh a, [rIF]
	and $ff ^ IF_STAT
	ldh [rIF], a
	; switch off V-blank interrupts
	ldh a, [rIE]
	and $ff ^ IE_VBLANK
	ldh [rIE], a
	ei

	; execute wVBlankTrampoline
	call wVBlankTrampoline

	xor a
	ld [wVirtualOAMSelect], a
	ld a, TRUE
	ld [wVBlankExecuted], a
;	fallthrough

UpdateAudio:
	ldh a, [hROMBank]
	push af
	ld a, BANK(_UpdateAudio) ; useless bankswitch to $0
	call UnsafeBankswitch
	call _UpdateAudio
	pop af
	call UnsafeBankswitch
	ldh a, [rIE]
	or IE_VBLANK
	ldh [rIE], a
;	fallthrough

; returns from an interrupt handler
InterruptRet:
	pop de
	pop bc
	pop hl
	pop af
	reti

Func_2a4:
	ld h, c
	push af
	push hl
	push de
	jr Func_24d

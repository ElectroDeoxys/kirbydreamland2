_Start:
	di
	ld a, BANK(Init)
	ld [rROMB0 + $100], a
	jp Init

_VBlank:
	ldh a, [hRequestLCDOff]
	or a
	jr z, .continue_lcd_on

; LCD was requested to be turned off
; we can only do it safely during V-Blank

.wait_vblank
	ldh a, [rLY]
	cp $91
	jr nz, .wait_vblank

	; disable LCD
	ld hl, rLCDC
	res B_LCDC_ENABLE, [hl]

	xor a
	ldh [hRequestLCDOff], a
	jp InterruptRet

.continue_lcd_on
	ld a, [wda0f]
	cp $01
	jp c, .skip_dma_and_scroll ; can be jr
	ld a, HIGH(wVirtualOAM1)
	jr z, .got_virtual_oam ; wda0f == 1
	inc a ; $c1
.got_virtual_oam
	ldh [hTransferVirtualOAM + $1], a
	call hTransferVirtualOAM

	ld a, [wda0f]
	dec a
	ld hl, wScroll1
	jr z, .asm_18d ; wda0f == 1
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
	ld de, $1f
	bit 2, a
	jr z, .asm_1dd
	bit 0, a
	jr z, .asm_1c8
	ld a, [wda23]
	ld sp, wc200
.asm_1bb
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
	add hl, de
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
	pop hl ; wda1c
	ld c, h
	ld h, HIGH(wBGMapQueue)
	ldh a, [hBGMapQueueSize]
	ld b, a
	pop af ; wda1e
	reti ; jumps to wProcessBGMapQueueFunc

ProcessBGMapQueue::
.next_entry
	ld a, l ; wda1c
	cp b
	jr z, .asm_23e
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
.asm_23e
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
	ld [wda0f], a
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
; 0x2aa

SECTION "Func_2aa", ROM0[$2aa]

Func_2aa::
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
	ld a, $e4
	ldh [rBGP], a
	jp InterruptRet
; 0x2c4

SECTION "Func_30c", ROM0[$30c]

; waits some cycles then applies wScreenSectionSCX
Func_30c::
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

SECTION "_Timer", ROM0[$333]

_Timer:
	ld a, TRUE
	ld [wTimerExecuted], a
	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a
	jp z, UpdateAudio ; lcd off
	jp InterruptRet

VBlankHandler_Default::
StatHandler_Default::
Func_342:
	ret

DoFrame::
	ld hl, wVBlankExecuted
.loop_wait_vblank
	di
	bit 0, [hl]
	jr nz, .vblank_executed
	halt
	ei
	jr .loop_wait_vblank
.vblank_executed
	ei
	ld [hl], FALSE ; wVBlankExecuted
	ld hl, wda0e
	inc [hl]
	ret

ReadJoypad::
	ld a, [wJoypad1Down]
	ldh [hff84], a
	ld a, [wSGBEnabled]
	or a
	jr nz, .read_sgb_input
; only read GB input
	ld b, 1
	ld hl, wJoypad1
	jr .got_joypad_struct
.read_sgb_input
	ld a, [wda38]
	or a
	ret nz
	ld b, 2 ; number of joypads
	ldh a, [rJOYP]
	ld c, a
	jr .start_read_inputs
.loop_read_joypads
	ldh a, [rJOYP]
	cp c
	jr z, .no_change
.start_read_inputs
	cpl
	and %11
	; a = which joypad ID
	add a
	add a ; *4
	ld e, a
	ld d, $00
	ld hl, wJoypad1
	add hl, de
.got_joypad_struct
	ld e, [hl]

; can only get four inputs at a time
; take d-pad first
	ld a, JOYP_GET_CTRL_PAD
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	swap a
	and %11110000
	ld d, a

; take the buttons values next
	ld a, JOYP_GET_BUTTONS
	ldh [rJOYP], a
REPT 6
	ldh a, [rJOYP]
ENDR
	and %1111
	or d
	cpl
	; button bits on lower nybble, d-pad on higher nybble
	call .WriteInput

	ld a, JOYP_GET_NONE
	ldh [rJOYP], a
	dec b
	jr nz, .loop_read_joypads

.no_change
	ld a, [wDemoActive]
	or a
	jp z, .not_in_demo

	; we are reading input from sDemoInputs
	ld hl, wDemoInputPtr
	ld a, [hli]
	ld b, [hl]
	ld c, a
	cp LOW(sDemoInputsEnd - $2)
	jr nz, .asm_3ca
	ld a, b
	cp HIGH(sDemoInputsEnd - $2)
	jr nz, .asm_3ca
	; bc = sDemoInputsEnd - $2
	dec bc
	dec bc
.asm_3ca
	; useless comparison
	ld a, [wDemoActive]
	cp $02
	jr z, .asm_3d1
.asm_3d1
	ld a, [wDemoInputDuration]
	dec a
	jr nz, .got_demo_input
	inc bc
	inc bc
	inc bc
	ld a, [bc] ; duration
	dec bc
	ld hl, wDemoInputPtr
	ld [hl], c
	inc hl
	ld [hl], b
.got_demo_input
	ld [wDemoInputDuration], a
	ldh a, [hJoypad1Down]
	ld e, a
	ld a, [bc] ; key input
	ld hl, hJoypad1
	call .WriteInput
	ld b, $4
	ld hl, wJoypad2
	ld c, LOW(hJoypad2)
	jr .loop_copy_to_hram

.not_in_demo
	ld b, $8
	ld hl, wJoypad1
	ld c, LOW(hJoypad1)
.loop_copy_to_hram
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	dec b
	jr nz, .loop_copy_to_hram

	; if all buttons are down
	ldh a, [hJoypad1Down]
	cp PAD_A | PAD_B | PAD_SELECT | PAD_START
	ret nz ; no reset
	; ...and they weren't pressed at the same time
	ldh a, [hJoypad1Pressed]
	cp PAD_A | PAD_B | PAD_SELECT | PAD_START
	ret z ; no reset
	; ...and at least one of them was pressed now
	or a
	ret z ; no reset
	; ...do reset
	ld e, SGB_PALS_34
	farcall SGBSetPalette_WithoutATF
	jp _Start

; input:
; - a = input bits
; - hl = joypad struct
; - e = last input down
.WriteInput:
	ld d, a
	ld [hli], a ; down
	xor e
	and d
	ld [hli], a ; pressed
	jr z, .none_pressed
; something pressed
	ld [hli], a ; ?
	ld [hl], 20 ; ?
	ret
.none_pressed
	inc hl
	or [hl]
	jr z, .asm_432
	dec [hl]
	dec hl
	ld [hl], 0
	ret
.asm_432
	ld [hl], 3
	dec hl
	ld [hl], d ; down
	ret

Func_437::
	call Func_496
	call Func_4ae
	call DoFrame

	ld d, MASK_EN_FREEZE
	farcall SGB_MaskEn
	farcall SGBWait_Short
;	fallthrough

Func_452::
	ld a, TRUE
	ldh [hRequestLCDOff], a
.wait_lcd_off
	ldh a, [hRequestLCDOff]
	or a
	jr nz, .wait_lcd_off

	di
	ld hl, rIF
	res B_IF_VBLANK, [hl]
	res B_IF_STAT, [hl]

	; set Timer to be executed as soon as possible
	ld a, -1
	ldh [rTIMA], a
	; start Timer
	ld a, TAC_START | TAC_4KHZ
	ldh [rTAC], a
	ei
	ret

Func_46d::
	call StopTimerAndTurnLCDOn
	farcall SGBWait_Short
	ld d, MASK_EN_CANCEL
	farcall SGB_MaskEn
	ret

StopTimerAndTurnLCDOn::
	ld hl, wTimerExecuted
	ld [hl], FALSE

	; stay in low power mode
	; until timer is executed
.wait_timer
	halt
	bit 0, [hl]
	jr z, .wait_timer

	xor a ; TAC_STOP
	ldh [rTAC], a
	ld hl, rLCDC
	set B_LCDC_ENABLE, [hl]
	ret

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
	ld b, a
	xor a
.asm_4c6
	ld [hli], a
	inc b
	jr nz, .asm_4c6
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
	ld [hli], a
	ld a, [wda01]
	ld b, a
	ld a, [wda07]
	add b
	ld [hli], a
	ld a, [wda28]
	ld b, a
	ld de, wda23
	rra
	jr nc, .asm_4f1
	inc de ; wda24
.asm_4f1
	ld a, [de]
	or a
	jr z, .asm_50e
	bit 0, b
	ld hl, wda27
	di
	jr nz, .asm_503
	set 0, [hl]
	res 2, [hl]
	jr .asm_507
.asm_503
	set 1, [hl]
	set 2, [hl]
.asm_507
	ei
	ld a, b
	xor $01
	ld [wda28], a
.asm_50e
	ld a, c
	and $01
	inc a
	ld [wda0f], a
	ld a, c
	xor $01
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

; input:
; - a:hl = source
; - de = destination
; - bc = number of bytes
FarCopyHLToDE::
	ldh [hTempROMBank], a
	ldh a, [hROMBank]
	push af
	ldh a, [hTempROMBank]
	call Bankswitch
	call CopyHLToDE
	pop af
	jr Bankswitch

; input:
; - a:hl = bank/address to call
Farcall::
	ldh [hTempROMBank], a
	ldh a, [hROMBank]
	push af
	ldh a, [hTempROMBank]
	call Bankswitch
	call JumpHL
	pop af
;	fallthrough

; same as UnsafeBankswitch but disables interrupts
; to avoid an interrupt between UnsafeBankswitch
; and write to hROMBank
Bankswitch::
	di
	ld [rROMB0 + $100], a
	ldh [hROMBank], a
	ei
	ret

; input:
; - a:hl = bank/address to call
UnsafeFarcall::
	ldh [hTempROMBank], a
	ldh a, [hROMBank]
	push af
	ldh a, [hTempROMBank]
	call UnsafeBankswitch
	call JumpHL
	pop af
;	fallthrough

UnsafeBankswitch::
	ld [rROMB0 + $100], a
	ldh [hROMBank], a
	ret

; sets wVBlankTrampoline function to hl
; same as UnsafeSetVBlankTrampoline, but does it
; with interrupts disabled
SetVBlankTrampoline::
	di
	ld a, l
	ld [wVBlankTrampoline + 1], a
	ld a, h
	ld [wVBlankTrampoline + 2], a
	ei
	ret

; sets wVBlankTrampoline function to hl
UnsafeSetVBlankTrampoline::
	ld a, l
	ld [wVBlankTrampoline + 1], a
	ld a, h
	ld [wVBlankTrampoline + 2], a
	ret

; input:
; - c = bank
; - hl = source address
; - de = destination address
FarDecompress::
	ldh [hTempROMBank], a
	ldh a, [hROMBank]
	push af
	ldh a, [hTempROMBank]
	call Bankswitch
	call Decompress
	pop af
	jr Bankswitch
; 0x61d

SECTION "JumpHL", ROM0[$620]

JumpHL::
	jp hl

; input:
; - hl = source
; - de = destination
; - bc = number of bytes to copy
CopyHLToDE::
	inc b
	inc c
	jr .start
.loop
	ld a, [hli]
	ld [de], a
	inc de
.start
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

; input:
; - a = fill byte
; - hl = address to fill
; - bc = fill size
FillHL::
	inc b
	inc c
	jr .start
.loop
	ld [hli], a
.start
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret
; 0x63b

SECTION "Random", ROM0[$647]

; advances RNG, and outputs in a
; a random number between 0 and 255
Random::
	push de
	push hl
	ld hl, wRNG
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, de ; *5
	ld de, $3711 ; seed
	add hl, de
	ld a, l
	ld [wRNG + 0], a
	ld a, h
	ld [wRNG + 1], a
	pop hl
	pop de
	ret

; output:
; - a = 2^a
GetPowerOfTwo::
	ld hl, PowersOfTwo
	add l
	ld l, a
	incc h
	ld a, [hl]
	ret

PowersOfTwo:
	db 1 << 0
	db 1 << 1
	db 1 << 2
	db 1 << 3
	db 1 << 4
	db 1 << 5
	db 1 << 6
	db 1 << 7

; input:
; - a = ?
; output:
; - carry set if ?
Func_675::
	push de
	add $03
	ld e, a
	ldh a, [hBGMapQueueSize]
	ld d, a
	ld a, [wda1c]
	sub d
	dec a
	cp e
	pop de
	ret

Func_684::
	ld a, [wda0f]
	or a
	jr nz, .asm_693
	ld a, [wda39]
	or a
	ret z
	xor a
	ld [wda39], a
.asm_693
	ld hl, wda33
	dec [hl]
	ret nz
	ld a, [wda34]
	cp LOW(wcd0c)
	jr z, .asm_6bf
	ld e, a
	ld d, HIGH(wcd0c)
	ld a, [wda38]
	or a
	jr nz, .asm_6c9
	ld hl, wBGOBPals
	ld a, [de]
	inc e
	ld [hli], a
	ld a, [de]
	inc e
	ld [hli], a
	ld a, [de]
	inc e
	ld [hl], a
	ld a, e
	ld [wda34], a
.asm_6b8
	ld a, [wda32]
	ld [wda33], a
	ret
.asm_6bf
	xor a
.asm_6c0
	ld [wda36], a
	ld hl, StatHandler_Default
	jp UnsafeSetVBlankTrampoline
.asm_6c9
	ld a, [wcd0c]
	or a
	jr nz, .asm_6d5
	xor a
	ld [wda38], a
	jr .asm_6c0
.asm_6d5
	dec a
	ld [wcd0c], a
	jr nz, .asm_6ef
	ld a, [wda37]
	cp $ff
	jr z, .asm_6ef
	cp $01
	ld a, $ff
	jr z, .asm_6e9
	xor a
.asm_6e9
	ld hl, wBGOBPals
	ld [hli], a ; wBGP
	ld [hli], a ; wOBP0
	ld [hl], a  ; wOBP1
.asm_6ef
	ld a, [de]
	ld h, a
	inc e
	ld a, e
	ld [wda34], a
	ldh a, [hROMBank]
	push af
	ld a, $1e
	call UnsafeBankswitch
	ld e, h
	call SGBSetPalette_WithoutATF_NoWait
	pop af
	call UnsafeBankswitch
	jr .asm_6b8

; input:
; - hl = source address
; - de = destination address
Decompress::
	ld a, e
	ldh [hff97 + 0], a
	ld a, d
	ldh [hff97 + 1], a

.loop_compressed_data
	ld a, [hl]
	cp $ff
	ret z ; done
	and $e0
	cp $e0
	jr nz, .short_length

; long length
	ld a, [hl]
	add a
	add a
	add a ; *8
	and $e0
	push af
	ld a, [hli]
	and $03
	ld b, a
	ld a, [hli]
	ld c, a
	inc bc
	jr .got_length

.short_length
	push af
	ld a, [hli]
	and $1f
	ld c, a
	ld b, $00
	inc c
.got_length
	inc b
	inc c
	pop af
	bit 7, a
	jr nz, .is_lookback
	cp $20
	jr z, .repeat_byte
	cp $40
	jr z, .loop_repeat_bytes
	cp $60
	jr z, .increasing_sequence
.loop_literal_copy
	dec c
	jr nz, .continue_literal_copy
	dec b
	jp z, .loop_compressed_data
.continue_literal_copy
	ld a, [hli]
	ld [de], a
	inc de
	jr .loop_literal_copy

.repeat_byte
	ld a, [hli]
.loop_repeat_byte
	dec c
	jr nz, .continue_repeat_byte
	dec b
	jp z, .loop_compressed_data
.continue_repeat_byte
	ld [de], a
	inc de
	jr .loop_repeat_byte

.loop_repeat_bytes
	dec c
	jr nz, .continue_repeat_bytes
	dec b
	jp z, .done_repeat_bytes
.continue_repeat_bytes
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hld]
	ld [de], a
	inc de
	jr .loop_repeat_bytes
.done_repeat_bytes
	inc hl
	inc hl
	jr .loop_compressed_data

.increasing_sequence
	ld a, [hli]
.loop_increasing_sequence
	dec c
	jr nz, .continue_increasing_sequence
	dec b
	jp z, .loop_compressed_data
.continue_increasing_sequence
	ld [de], a
	inc de
	inc a
	jr .loop_increasing_sequence

.is_lookback
	push hl
	push af
	ld a, [hli]
	ld l, [hl]
	ld h, a
	ldh a, [hff97 + 0]
	add l
	ld l, a
	ldh a, [hff97 + 1]
	adc h
	ld h, a
	pop af
	cp $80
	jr z, .loop_lookback
	cp $a0
	jr z, .loop_lookback_inverted
	cp $c0
	jr z, .loop_reverse_lookback

.loop_lookback
	dec c
	jr nz, .continue_lookback
	dec b
	jr z, .done_lookback
.continue_lookback
	ld a, [hli]
	ld [de], a
	inc de
	jr .loop_lookback

.loop_lookback_inverted
	dec c
	jr nz, .continue_lookback_inverted
	dec b
	jp z, .done_lookback
.continue_lookback_inverted
	ld a, [hli]
	push hl
	ld h, HIGH(wd900)
	ld l, a
	ld a, [hl]
	pop hl
	ld [de], a
	inc de
	jr .loop_lookback_inverted

.loop_reverse_lookback
	dec c
	jr nz, .continue_reverse_lookback
	dec b
	jp z, .done_lookback
.continue_reverse_lookback
	ld a, [hld]
	ld [de], a
	inc de
	jr .loop_reverse_lookback

.done_lookback
	pop hl
	inc hl
	inc hl
	jp .loop_compressed_data

; input:
; - a = ?
; - h = ?
; - l = ?
; - OBJSTRUCT_X_POS + 1 <- bc
; - OBJSTRUCT_Y_POS + 1 <- de
CreateObject::
	ldh [hff84], a
	push de
	push bc
	ld b, h
	ld c, l
Func_7ca:
	call Func_b94
	jr nc, .asm_7d8
	pop hl
	pop de
	ld h, $00
	ld a, h
	ld [wda4a], a
	ret
.asm_7d8
	ld a, h
	ld [wda4a], a
	ld l, OBJSTRUCT_DRAW_FUNC
	ld [hl], LOW(Func_342)
	inc l
	ld [hl], HIGH(Func_342)
	ld a, 0.5
	ld l, OBJSTRUCT_X_POS
	ld [hl], a
	ld l, OBJSTRUCT_Y_POS
	ld [hl], a
	pop bc
	ld l, OBJSTRUCT_X_POS + 1
	ld [hl], c
	inc l
	ld [hl], b
	pop bc
	ld l, OBJSTRUCT_Y_POS + 1
	ld [hl], c
	inc l
	ld [hl], b
	call Func_c06

	ldh a, [hff84]
	ld l, OBJSTRUCT_UNK00
	ld [hl], a
	ld e, a
	ld d, $00
	sla a
	rl d
	add e ; *3
	ld e, a
	ld a, HIGH(Data_1f700)
	adc d
	ld d, a

	xor a
	ld l, OBJSTRUCT_X_VEL
	ld [hli], a
	ld [hl], a
	ld l, OBJSTRUCT_Y_VEL
	ld [hli], a
	ld [hl], a
	ld l, OBJSTRUCT_X_ACC
	ld [hli], a
	ld [hl], a ; OBJSTRUCT_Y_ACC
	ld l, OBJSTRUCT_UNK45
	ld [hli], a
	ld [hl], a ; OBJSTRUCT_OAM_TILE_ID
	ld l, OBJSTRUCT_UNK4A
	ld [hli], a
	ld [hl], a
	ld a, $ff
	ld l, OBJSTRUCT_FRAME
	ld [hl], a
	ld l, OBJSTRUCT_UNK49
	ld [hl], a
	ld l, OBJSTRUCT_PARENT_OBJ
	ld [hl], a

	ldh a, [hROMBank]
	ldh [hff84], a
	ld a, BANK(Data_1f700)
	call Bankswitch
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld e, a
	ldh a, [hff84]
	call Bankswitch
	call Func_855
	ret

Func_846::
	ldh a, [hff9a]
	ld h, a
	ld a, h
	cp HIGH(sObjects)
	ret c
	cp HIGH(sObjectsEnd)
	ret nc
	ld l, OBJSTRUCT_UNK00
	ld a, [hl]
	inc a
	ret z
;	fallthrough

; input:
; - hl = ?
; - e:bc = ?
Func_855:
	call Func_c2a
	ld l, OBJSTRUCT_UNK19
	ld [hl], e ; OBJSTRUCT_UNK19
	inc l
	ld [hl], b ; OBJSTRUCT_UNK1A
	inc l
	ld [hl], c
	xor a
	ld l, OBJSTRUCT_UNK24
	ld [hl], a
	ld l, OBJSTRUCT_OAM_FLAGS
	ld [hl], a
	ld l, OBJSTRUCT_STACK_PTR
	ld [hl], OBJSTRUCT_UNK38 + 1
	ret

UpdateObjects::
	ld a, [wda46]
	jr .start_loop
.loop_objs
	ldh [hff9a], a
	ld h, a
	ld l, OBJSTRUCT_NEXT_OBJ
	ld a, [hl]
	ld [wda49], a
	call Func_8a1
	ld a, [wda49]
.start_loop
	or a
	jr nz, .loop_objs
	ld a, [wda46]
	jr .asm_89d

.asm_887
	ldh [hff9a], a
	ld d, a
	ld e, OBJSTRUCT_NEXT_OBJ
	ld a, [de]
	ld [wda49], a
	ld e, OBJSTRUCT_DRAW_FUNC
	ld a, [de]
	ld l, a
	inc e
	ld a, [de]
	ld h, a
	call JumpHL
	ld a, [wda49]
.asm_89d
	or a
	jr nz, .asm_887
	ret

Func_8a1:
	ld l, OBJSTRUCT_UNK19
	ld a, OBJSTRUCT_UNK24
	ldh [hff9b], a
	ld e, a
.asm_8a8
	ld a, [hli]
	ld b, a
	and $a0
	jr nz, .asm_8b9
	bit 6, b
	jr nz, .asm_8de
	ld d, h
	ld a, [de]
	or a
	jr z, .asm_8c6
	dec a
	ld [de], a
.asm_8b9
	inc l
	inc l
.asm_8bb
	ldh a, [hff9b]
	cp OBJSTRUCT_UNK25 + 1
	ret nc
	inc a
	ldh [hff9b], a
	ld e, a
	jr .asm_8a8

.asm_8c6
	ld a, b
	call Bankswitch
	ld a, [hli]
	ld b, a
	ld c, [hl]
	push hl
.asm_8ce
	ld a, [bc]
	inc bc
	add a ; *2
	ld h, HIGH(Data_3f00)
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.asm_8d8
	pop hl
	ld [hl], c
	dec l
	ld [hl], b
	jr .asm_8b9

.asm_8de
	ld a, b
	and $1f
	call Bankswitch
	ld a, [hli]
	ld b, a
	ld a, [hli]
	push hl
	ld d, h
	ld l, a
	ld h, b
	call JumpHL
	pop hl
	jr .asm_8bb

Func_8f1:
	ld h, d
	push de
	call Func_bba
	pop de
	jp Func_8a1.asm_8d8

Func_8fa:
	ldh a, [hff9b]
	sub OBJSTRUCT_UNK24
	ld l, a
	add a
	add l ; *3
	add OBJSTRUCT_UNK19
	; a = OBJSTRUCT_UNK19 if hff9b == OBJSTRUCT_UNK24
	; a = OBJSTRUCT_UNK1C if hff9b == OBJSTRUCT_UNK25
	ld l, a
	ld h, d
	set 7, [hl]
	jp Func_8a1.asm_8d8

Func_90a:
	ldh a, [hff9b]
	ld e, a
	ld a, [bc]
	inc bc
	dec a
	ld [de], a
	jp Func_8a1.asm_8d8

Func_914:
	ld h, d
	ldh a, [hff9b]
	ld l, a
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	dec a
	ld [hl], a
	jp Func_8a1.asm_8d8

; set OBJSTRUCT_FRAME to arg
Func_920:
	ld a, [bc]
	inc bc
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	jp Func_8a1.asm_8ce

Func_928:
	ld a, [bc]
	inc bc
	ld e, OBJSTRUCT_FRAME
	ld [de], a
	ldh a, [hff9b]
	ld e, a
	ld a, [bc]
	inc bc
	dec a
	ld [de], a
	jp Func_8a1.asm_8d8

; sets obj struct attribute arg0
; to value arg1
Func_937:
	ld a, [bc]
	inc bc
	ld e, a
	ld a, [bc]
	inc bc
	ld [de], a
	jp Func_8a1.asm_8ce

Func_940:
	ld a, [bc]
	inc bc
	ld e, a
	ld a, [de]
	ld e, OBJSTRUCT_VAR
	ld [de], a
	jp Func_8a1.asm_8ce

Func_94a:
	ld a, [bc]
	inc bc
	ld e, a
	ld h, d
	ld l, OBJSTRUCT_VAR
	ld a, [hl]
	ld [de], a
	jp Func_8a1.asm_8ce
; 0x955

SECTION "Func_96c", ROM0[$96c]

Func_96c:
	ld h, d
	ld h, d ; repeated
	ld l, OBJSTRUCT_UNK20 + 1
	ld a, [bc]
	inc bc
	ld [hld], a ; OBJSTRUCT_UNK21
	ld a, [bc]
	inc bc
	ld [hld], a ; OBJSTRUCT_UNK20
	ld a, [bc]
	inc bc
	ld [hl], a ; OBJSTRUCT_UNK1F
	jp Func_8a1.asm_8ce

; sets OBJSTRUCT_DRAW_FUNC to arg
Func_97c:
	ld e, OBJSTRUCT_DRAW_FUNC
	ld a, [bc]
	inc bc
	ld [de], a
	inc e
	ld a, [bc]
	inc bc
	ld [de], a
	jp Func_8a1.asm_8ce

; sets OBJSTRUCT_OAM_BANK:OBJSTRUCT_OAM_PTR to arg
Func_988:
	ld h, d
	ld l, OBJSTRUCT_OAM_PTR + 1
	ld a, [bc]
	inc bc
	ld [hld], a
	ld a, [bc]
	inc bc
	ld [hld], a
	ld a, [bc]
	inc bc
	ld [hl], a ; OBJSTRUCT_OAM_BANK
	jp Func_8a1.asm_8ce

Func_997:
	ld a, [bc]
	inc bc
	ld e, a
	ld a, [bc]
	ld b, a
	ld c, e
	jp Func_8a1.asm_8ce

Func_9a0:
	; load arg to hl
	ld a, [bc]
	inc bc
	ld l, a
	ld a, [bc]
	inc bc
	ld h, a

	ldh a, [hff9b]
	sub OBJSTRUCT_UNK24
	ld e, a
	add a
	add e
	add OBJSTRUCT_UNK19
	ld e, a
	; e == OBJSTRUCT_UNK19 if [hff9b] == OBJSTRUCT_UNK24
	; e == OBJSTRUCT_UNK1C if [hff9b] == OBJSTRUCT_UNK25

	ld a, [bc]
	ld [de], a
	call Bankswitch
	ld b, h
	ld c, l
	jp Func_8a1.asm_8ce

; branches to argument address
; if OBJSTRUCT_VAR is 0
Func_9ba:
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	or a
	jr nz, .asm_9c9
	ld a, [bc]
	inc bc
	ld e, a
	ld a, [bc]
	ld b, a
	ld c, e
	jp Func_8a1.asm_8ce
.asm_9c9
	inc bc
	inc bc
	jp Func_8a1.asm_8ce

; branches to argument address
; if OBJSTRUCT_VAR is non-0
Func_9ce:
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	or a
	jr z, .asm_9dd
	ld a, [bc]
	inc bc
	ld e, a
	ld a, [bc]
	ld b, a
	ld c, e
	jp Func_8a1.asm_8ce
.asm_9dd
	inc bc
	inc bc
	jp Func_8a1.asm_8ce
; 0x9e2

SECTION "Func_9f7", ROM0[$9f7]

Func_9f7:
	ld h, b
	ld l, c
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	cp [hl]
	jr c, .asm_a06
	inc hl
	ld a, [hli]
	ld c, a
	ld b, [hl]
	jp Func_8a1.asm_8ce
.asm_a06
	inc bc
	inc bc
	inc bc
	jp Func_8a1.asm_8ce

Func_a0c:
	ld e, OBJSTRUCT_X_VEL
	ld a, [bc]
	inc bc
	ld [de], a ; OBJSTRUCT_X_VEL
	inc e
	ld a, [bc]
	inc bc
	ld [de], a
	jp Func_8a1.asm_8ce

Func_a18:
	ld e, OBJSTRUCT_Y_VEL
	ld a, [bc]
	inc bc
	ld [de], a
	inc e
	ld a, [bc]
	inc bc
	ld [de], a
	jp Func_8a1.asm_8ce
; 0xa24

SECTION "Func_a39", ROM0[$a39]

; set OBJSTRUCT_Y_ACC to arg
Func_a39:
	ld a, [bc]
	inc bc
	ld e, OBJSTRUCT_Y_ACC
	ld [de], a
	jp Func_8a1.asm_8ce

Func_a41:
	ld a, [bc]
	ld e, a
	inc bc
	ld h, d
	ld l, OBJSTRUCT_STACK_PTR
	ld a, [hl]
	dec a
	ld l, a
	ld [hl], b
	dec l
	ld [hl], c
	dec l
	ld [hl], e ; number of repetitions
	ld e, OBJSTRUCT_STACK_PTR
	ld a, l
	ld [de], a
	jp Func_8a1.asm_8ce

Func_a56:
	ld h, d
	ld l, OBJSTRUCT_STACK_PTR
	ld a, [hl]
	ld l, a
	dec [hl] ; number of repetitions
	jr z, .end_repeats
	inc l
	ld c, [hl]
	inc l
	ld b, [hl]
	jp Func_8a1.asm_8ce
.end_repeats
	; update new stack position
	inc l
	inc l
	inc l
	ld e, OBJSTRUCT_STACK_PTR
	ld a, l
	ld [de], a
	jp Func_8a1.asm_8ce

Func_a6f:
	ld h, d
	ld l, OBJSTRUCT_STACK_PTR
	ld a, [hl]
	dec a
	ld l, a
	ld a, [bc]
	inc bc
	ld e, a
	ld a, [bc]
	inc bc
	ld [hl], b
	dec l
	ld [hl], c
	ld b, a
	ld c, e
	ld e, OBJSTRUCT_STACK_PTR
	ld a, l
	ld [de], a
	jp Func_8a1.asm_8ce
; 0xa86

SECTION "Func_ab4", ROM0[$ab4]

Func_ab4:
	ld h, d
	ld l, OBJSTRUCT_STACK_PTR
	ld a, [hl]
	ld l, a
	ld c, [hl]
	inc l
	ld b, [hl]
	inc l
	ld e, OBJSTRUCT_STACK_PTR
	ld a, l
	ld [de], a
	jp Func_8a1.asm_8ce
; 0xac4

SECTION "Func_ae3", ROM0[$ae3]

Func_ae3:
	ld a, [bc]
	inc bc
	ld l, a
	ld a, [bc]
	inc bc
	ld h, a
	call JumpHL
	jp Func_8a1.asm_8ce
; 0xaef

SECTION "Func_b01", ROM0[$b01]

; plays arg as SFX
Func_b01:
	call Func_1099
	jp Func_8a1.asm_8ce
; 0xb07

SECTION "Func_b1f", ROM0[$b1f]

Func_b1f:
	ld h, b
	ld l, c
	ld e, OBJSTRUCT_VAR
	ld a, [de]
	cp [hl]
	jr nc, .skip_table
	inc hl
	rlca ; *2
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld c, a
	ld b, [hl]
	jp Func_8a1.asm_8ce
.skip_table
	ld a, [hli]
	rlca
	ld c, a
	ld b, $00
	add hl, bc
	ld b, h
	ld c, l
	jp Func_8a1.asm_8ce
; 0xb3e

SECTION "Func_b74", ROM0[$b74]

Func_b74:
	ld e, OBJSTRUCT_X_POS
	ld a, 0.5
	ld [de], a ; OBJSTRUCT_X_POS
	inc e
	ld a, [bc]
	inc bc
	ld [de], a ; OBJSTRUCT_X_POS + 1
	inc e
	ld a, [bc]
	inc bc
	ld [de], a
	jp Func_8a1.asm_8ce

Func_b84:
	ld e, OBJSTRUCT_Y_POS
	ld a, 0.5
	ld [de], a ; OBJSTRUCT_Y_POS
	inc e
	ld a, [bc]
	inc bc
	ld [de], a ; OBJSTRUCT_Y_POS + 1
	inc e
	ld a, [bc]
	inc bc
	ld [de], a
	jp Func_8a1.asm_8ce

; input:
; - [wda48] = ?
; - b = ?
; - c = ?
; output:
; - carry set if ?
Func_b94:
	ld a, [wda48]
	or a
	jr z, .set_carry
	ld h, a
	ld l, OBJSTRUCT_NEXT_OBJ
.loop_find
	cp b
	jr c, .asm_ba3
	cp c
	jr c, .found
.asm_ba3
	; h < b or h >= c
	ld h, a
	ld a, [hl] ; OBJSTRUCT_NEXT_OBJ
	or a
	jr nz, .loop_find
.set_carry
	scf
	ret

.found
	; b <= h < c
	cp h
	jr nz, .asm_bb3
	ld a, [hl] ; OBJSTRUCT_NEXT_OBJ
	ld [wda48], a
	and a
	ret ; no carry
.asm_bb3
	ld d, h
	ld e, l
	ld h, a
	ld a, [hl]
	ld [de], a
	and a
	ret ; no carry

Func_bba:
	ld a, h
	cp HIGH(sObjects)
	ret c
	cp HIGH(sObjectsEnd)
	ret nc
	ld l, OBJSTRUCT_UNK00
	ld a, [hl]
	inc a
	ret z
	ld [hl], $ff ; OBJSTRUCT_UNK00
	call Func_c2a
	ld l, OBJSTRUCT_NEXT_OBJ
	ld a, [hl]
	or a
	ld l, OBJSTRUCT_PREV_OBJ
	jr nz, .has_prev_obj
	ld de, wda47
	jr .asm_bda
.has_prev_obj
	ld d, a
	ld e, l ; OBJSTRUCT_PREV_OBJ
.asm_bda
	ld a, [hl]
	ld [de], a
	or a
	ld l, OBJSTRUCT_NEXT_OBJ
	jr nz, .asm_be6
	ld de, wda46
	jr .asm_be8
.asm_be6
	ld d, a
	ld e, l ; OBJSTRUCT_NEXT_OBJ
.asm_be8
	ld a, [hl]
	ld [de], a
	ld a, [wda49]
	cp h
	jr nz, .asm_bf4
	ld a, [hl]
	ld [wda49], a
.asm_bf4
	ld de, wda48
	ld a, [de]
	ld l, OBJSTRUCT_NEXT_OBJ
	ld [hl], a
	ld a, h
	ld [de], a
	ld l, OBJSTRUCT_UNK49
	ld e, [hl]
	ld d, HIGH(sbb00)
	xor a
	ld [de], a
	ld d, h
	ret

Func_c06:
	ld de, wda47
	ld a, [de]
	ld l, OBJSTRUCT_PREV_OBJ
	ld [hl], a
	ld l, OBJSTRUCT_NEXT_OBJ
	ld [hl], $00
	or a
	jr nz, .not_first_obj
	ld a, h
	ld [de], a ; wda47
	ld [wda46], a
	ret
.not_first_obj
	ld b, h
	ld h, a
	ld [hl], b ; OBJSTRUCT_NEXT_OBJ
	ld a, b
	ld [de], a ; wda47
	ld h, a
	ld a, [wda49]
	or a
	ret nz
	ld a, h
	ld [wda49], a
	ret

Func_c2a:
	ld l, OBJSTRUCT_UNK1C
	ld [hl], $80
	ld l, OBJSTRUCT_UNK1F
	ld [hl], $80
	ld l, OBJSTRUCT_UNK25
	ld [hl], $00 ; OBJSTRUCT_UNK25
	inc l
	ld [hl], $00 ; OBJSTRUCT_UNK26
	ret
; 0xc3a

SECTION "ApplyObjectXAcceleration", ROM0[$c80]

; does OBJSTRUCT_X_VEL += OBJSTRUCT_X_ACC
ApplyObjectXAcceleration::
	ld e, OBJSTRUCT_X_ACC
	ld a, [de]
	ld e, OBJSTRUCT_X_VEL
	ld c, a
	rla
	sbc a ; 0 if no carry, -1 if carry
	ld b, a
	ld a, [de] ; OBJSTRUCT_X_VEL
	add c
	ld [de], a
	inc e
	ld a, [de]
	adc b
	ld [de], a
	ret

; does OBJSTRUCT_Y_VEL += OBJSTRUCT_Y_ACC
ApplyObjectYAcceleration::
	ld e, OBJSTRUCT_Y_ACC
	ld a, [de]
	ld e, OBJSTRUCT_Y_VEL
	ld c, a
	rla
	sbc a ; 0 if no carry, -1 if carry
	ld b, a
	ld a, [de] ; OBJSTRUCT_Y_VEL
	add c
	ld [de], a
	inc e
	ld a, [de]
	adc b
	ld [de], a
	ret

; input
; - e = right acceleration
; - bc = maximum velocity
ApplyRightAcceleration_WithDampening::
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	jr c, _ApplyRightAcceleration ; moving left
	; moving right
	; is velocity larget than bc?
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	jr c, _ApplyRightAcceleration
	; if so, decelerate it
	ld e, 0.047
	jp DecelerateObjectX

; input
; - e = right acceleration
; - bc = maximum velocity
ApplyRightAcceleration::
	ld h, d
	ld l, OBJSTRUCT_X_VEL
;	fallthrough

; input
; - e = right acceleration
; - bc = maximum velocity
_ApplyRightAcceleration:
	; add e from velocity
	ld a, [hl]
	add e
	ld [hli], a
	ld a, [hl]
	adc 0
	ld [hld], a
	rla
	ret c
	; positive velocity
	; is velocity larger than bc?
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	ret c ; return if not
	; yes, set velocity to bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret
; 0xcc9

SECTION "ApplyLeftAcceleration_WithDampening", ROM0[$cd3]

; input
; - e = left acceleration
; - bc = maximum velocity
ApplyLeftAcceleration_WithDampening::
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	jr nc, _ApplyLeftAcceleration ; moving right
	; moving left
	; is velocity smaller than bc?
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	jr nc, _ApplyLeftAcceleration
	; if so, decelerate it
	ld e, 0.047
	jp DecelerateObjectX

	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
	adc $00
	ld b, a

; input
; - e = left acceleration
; - bc = maximum velocity
ApplyLeftAcceleration::
	ld h, d
	ld l, OBJSTRUCT_X_VEL
;	fallthrough

; input:
; - e = left acceleration
; - bc = maximum velocity
_ApplyLeftAcceleration:
	; subtract e from velocity
	ld a, [hl]
	sub e
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hld], a
	rla
	ret nc
	; negative velocity
	; is velocity smaller than bc?
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	ret nc ; return if not
	; yes, set velocity to bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret

; applies deceleration to object's x velocity
; given by input register e
; input:
; - e = x deceleration
DecelerateObjectX::
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ld a, [hld]
	rla
	jr c, .neg_x_vel
	; subtracting e reduces velocity
	ld a, [hl]
	sub e
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hl], a
	ret nc
	; reduce to 0 x velocity
	xor a
	ld [hld], a
	ld [hl], a
	ret

.neg_x_vel
	; adding e reduces velocity
	ld a, [hl]
	add e
	ld [hli], a
	ld a, [hl]
	adc 0
	ld [hl], a
	ret nc
	; reduce to 0 x velocity
	xor a
	ld [hld], a
	ld [hl], a
	ret

; input
; - e = downwards acceleration
; - bc = maximum velocity
ApplyDownwardsAcceleration_WithDampening::
	ld h, d
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr c, _ApplyDownwardsAcceleration ; moving upwards
	; moving downwards
	; is velocity larger than bc?
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	jr c, _ApplyDownwardsAcceleration
	; if so, decelerate it
	ld e, 0.047
	jp DecelerateObjectY

; input:
; - e = downwards acceleration
; - bc = maximum velocity
ApplyDownwardsAcceleration::
	ld h, d
	ld l, OBJSTRUCT_Y_VEL
;	fallthrough

; input:
; - e = downwards acceleration
; - bc = maximum velocity
_ApplyDownwardsAcceleration:
	; add e from velocity
	ld a, [hl]
	add e
	ld [hli], a
	ld a, [hl]
	adc 0
	ld [hld], a
	rla
	ret c
	; positive velocity
	; is velocity larger than bc?
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	ret c ; return if not
	; yes, set velocity to bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret
; 0xd4a

SECTION "ApplyUpwardsAcceleration_WithDampening", ROM0[$d54]

; input
; - e = upwards acceleration
; - bc = maximum velocity
ApplyUpwardsAcceleration_WithDampening::
	ld h, d
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr nc, _ApplyUpwardsAcceleration ; moving downwards
	; moving upwards
	; is velocity smaller than bc?
	ld a, [hli]
	sub c
	ld a, [hld]
	sbc b
	jr nc, _ApplyUpwardsAcceleration
	; if so, decelerate it
	ld e, 0.047
	jp DecelerateObjectY

	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
	adc $00
	ld b, a
;	fallthrough

; input:
; - e = upwards acceleration
; - bc = maximum velocity
ApplyUpwardsAcceleration::
	ld h, d
	ld l, OBJSTRUCT_Y_VEL
;	fallthrough

; input:
; - e = upwards acceleration
; - bc = maximum velocity
_ApplyUpwardsAcceleration:
	; subtract e from velocity
	ld a, [hl]
	sub e
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hld], a
	rla
	ret nc
	; negative velocity
	; is velocity smaller than bc?
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	ret nc ; return if not
	; yes, set velocity to bc
	ld a, b
	ld [hld], a
	ld [hl], c
	ret

; applies deceleration to object's y velocity
; given by input register e
; input:
; - e = y deceleration
DecelerateObjectY::
	ld h, d
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr c, .neg_y_vel
	; subtracting e reduces velocity
	ld a, [hl]
	sub e
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hl], a
	ret nc
	; reduce to 0 y velocity
	xor a
	ld [hld], a
	ld [hl], a
	ret

.neg_y_vel
	; adding e reduces velocity
	ld a, [hl]
	add e
	ld [hli], a
	ld a, [hl]
	adc 0
	ld [hl], a
	ret nc
	; reduce to 0 y velocity
	xor a
	ld [hld], a
	ld [hl], a
	ret

ApplyObjectVelocities::
	ld e, OBJSTRUCT_X_VEL
	ld h, d
	ld l, OBJSTRUCT_X_POS
	ld a, [de]
	add [hl]
	ld [hli], a
	inc e
	ld a, [de]
	ld b, 0
	bit 7, a
	jr z, .positive_x_vel
	dec b ; -1
.positive_x_vel
	adc [hl]
	ld [hli], a
	inc e
	ld a, b
	adc [hl]
	ld [hli], a
	; OBJSTRUCT_X_POS += OBJSTRUCT_X_VEL

	ld a, [de]
	add [hl]
	ld [hli], a
	inc e
	ld a, [de]
	ld b, 0
	bit 7, a
	jr z, .positive_y_vel
	dec b ; -1
.positive_y_vel
	adc [hl]
	ld [hli], a
	inc e
	ld a, b
	adc [hl]
	ld [hl], a
	; OBJSTRUCT_Y_POS += OBJSTRUCT_Y_VEL

	ret

Func_dce::
	ld a, [sa000Unk6c]
	rra
	jr nc, .asm_dde
	homecall Func_1f40a
	jr .asm_df0
.asm_dde
	call Func_e2c
	ld a, [sa000Unk5d]
	cp $00
	jr nz, .asm_df0
	homecall Func_2f85b
.asm_df0
	jp LoadObjectSprite

Func_df3::
	call Func_3467
Func_df6::
	call Func_e2c
	jp LoadObjectSprite
; 0xdfc

SECTION "Func_e2c", ROM0[$e2c]

; does OBJSTRUCT_UNK09 = OBJSTRUCT_X_POS + 1 - wdb51
; and  OBJSTRUCT_UNK0B = OBJSTRUCT_Y_POS + 1 - wdb53
Func_e2c::
	ld e, OBJSTRUCT_X_POS + 1
	ld hl, wdb51
	ld b, d
	ld c, OBJSTRUCT_UNK09
	ld a, [de]
	sub [hl]
	ld [bc], a
	inc e
	inc hl
	inc c
	ld a, [de] ; OBJSTRUCT_X_POS + 2
	sbc [hl]
	ld [bc], a ; OBJSTRUCT_UNK09 + 1
	inc e
	inc e
	inc hl
	inc c
	ld a, [de] ; OBJSTRUCT_Y_POS + 1
	sub [hl]
	ld [bc], a ; OBJSTRUCT_UNK0B
	inc e
	inc hl
	inc c
	ld a, [de] ; OBJSTRUCT_Y_POS + 2
	sbc [hl]
	ld [bc], a ; OBJSTRUCT_UNK0B + 1
	ret
; 0xe4b

SECTION "LoadObjectSprite", ROM0[$f22]

LoadObjectSprite:
	ld e, OBJSTRUCT_FRAME
	ld a, [de]
	cp -1
	ret z ; no sprite
	add a ; *2
	ld c, a
	ld h, d
	ld l, OBJSTRUCT_OAM_BANK
	ld a, [hli]
	call Bankswitch
	ld a, [hli]
	ld l, [hl]
	ld h, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, LOW(hObjectOrientation)
	ld e, OBJSTRUCT_UNK45
	ld a, [de] ; OBJSTRUCT_UNK45
	ld [$ff00+c], a ; hObjectOrientation
	inc e
	inc c
	ld a, [de] ; OBJSTRUCT_OAM_TILE_ID
	ld [$ff00+c], a ; hOAMBaseTileID
	inc e
	inc c
	ld a, [de] ; OBJSTRUCT_OAM_FLAGS
	ld [$ff00+c], a ; hOAMFlags
	ld e, OBJSTRUCT_UNK0B + 1
	push de
	call LoadSprite
	pop de
	ret

Func_f50::
	push de
	ld h, b
	ld l, c
	ld a, [hli]
	ldh [hff84], a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	push hl
	call Func_f67
	pop bc
	pop de
	ld a, h
	or a
	ret z
	ld l, OBJSTRUCT_PARENT_OBJ
	ld [hl], d
	ret

Func_f67:
	ld h, d
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hli]
	ld e, a
	ld d, [hl]
	push de
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	ld e, a
	ld d, [hl]
	push de
	jp Func_7ca

Func_f77::
	ld a, [bc]
	inc bc
	ld e, a
Func_f7a::
	push de
	push bc
	ld a, $01
	ldh [hff84], a
	lb bc, HIGH(sa200), HIGH(sa500)
	call Func_f67
	pop bc
	pop de
	ld a, h
	or a
	ret z
	ld l, OBJSTRUCT_PARENT_OBJ
	ld [hl], d
	ld l, OBJSTRUCT_UNK51
	ld [hl], e
	ret
; 0xf92

SECTION "Func_1067", ROM0[$1067]

Func_1067:
	ld h, HIGH(sObjects)
	ld a, h
.loop_objs
	cp d
	jr z, .next_obj
	ld l, OBJSTRUCT_UNK19
	set 5, [hl]
	ld l, OBJSTRUCT_UNK1C
	set 5, [hl]
	ld l, OBJSTRUCT_UNK1F
	set 5, [hl]
.next_obj
	inc h
	ld a, h
	cp HIGH(sObjectsEnd)
	jr nz, .loop_objs
	ret
; 0x1080

SECTION "Func_1099", ROM0[$1099]

Func_1099:
	ld a, [bc]
	ld e, a
	inc bc
	push bc
	farcall PlaySFX
	pop bc
	ldh a, [hff9a]
	ld d, a
	ret

; input:
; - e = SFX_* constant
Func_10aa::
	farcall PlaySFX
	ldh a, [hff9a]
	ld d, a
	ret
; 0x10b6

SECTION "GameLoop", ROM0[$10de]

GameLoop::
	ld a, BANK(_GameLoop)
	call Bankswitch
	jp _GameLoop

Func_10e6::
	ld e, SGB_PALS_09 ; SGB_ATF_09
	farcall SGBPaletteSet_WithATF

	call Func_1126
	call Func_1134

	farcall Func_1db28

	ld hl, wHUDUpdateFlags
	set UPDATE_LIVES_F, [hl]
	set UPDATE_KIRBY_HP_F, [hl]
	set UPDATE_COPY_ABILITY_F, [hl]
	set UPDATE_STARS_F, [hl]
	set UPDATE_LEVEL_F, [hl]

	ld a, [sa000Unk5b]
	inc a
	ld [wCopyAbility], a
	ld a, [sa000Unk71]
	or a
	jr z, .asm_111d
	ld hl, wdedf
	set 1, [hl]
.asm_111d
	ld a, $07
	ldh [rWX], a
	ld a, $80
	ldh [rWY], a
	ret

Func_1126:
	ld a, $0b
	call Bankswitch
	ld hl, $68a0
	ld de, vTiles0
	jp Decompress

Func_1134:
	ld a, $0b
	call Bankswitch
	ld hl, $7122
	ld de, vTiles2 tile $63
	call Decompress
	ld a, $0b
	call Bankswitch
	ld hl, $720f
	ld de, vTiles1
	call Decompress
;	fallthrough

Func_1150::
	ld a, $0b
	call Bankswitch
	ld hl, $6d87
	ld de, vTiles0 tile $60
	call Decompress
	ret
; 0x115f

SECTION "Func_1166", ROM0[$1166]

Func_1166::
	farcall Func_b47d
	ld a, [sa000Unk51]
	cp $0d
	jr nz, .asm_1183
	ld a, $0b
	call Bankswitch
	ld hl, $6980
	ld de, vTiles0
	jp Decompress
.asm_1183
	homecall Func_1f458
	call .Func_1196

	homecall Func_1f472
.Func_1196:
	ld a, [wdf11]
	ld h, $00
	ld l, a
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc
	add hl, hl
	add hl, bc ; *7
	ld bc, Data_1f4bb
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ldh [hff84], a
	push bc
	ld a, [hli]
	ld c, a
	ld b, [hl]
	pop hl
	ldh a, [hff84]
	call Bankswitch
	jp CopyHLToDE

; main level loop
; only breaks when sa000Unk82 is non-zero
LevelLoop::
	xor a
	ld [sa000Unk82], a
	ldh [hJoypad1Down], a
	ldh [hJoypad1Pressed], a
.loop
	call Func_496
	ld a, [sa000Unk6c]
	rra
	jr c, .asm_11d4
	ld a, $ff
	ld [sa000Unk5d], a
.asm_11d4
	call UpdateObjects

	homecall Func_1c259
	homecall Func_1c3cb

	call Func_4ae
	farcall UpdateHUD
	farcall Func_1dbd2

	call DoFrame
	call ReadJoypad

	ld a, [sa000Unk82]
	or a
	jr nz, .check_break
	ld a, [wDemoActive]
	cp $02
	jr nz, .check_break
	ld a, [wJoypad1Pressed]
	and PAD_A | PAD_B | PAD_START
	jr z, .check_break
	ld a, $09
	ld [sa000Unk82], a
.check_break
	ld a, [sa000Unk82]
	or a
	jr z, .loop
	ret

Func_1220::
	call Func_1564
	ld bc, $e
	add hl, bc
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch
	ld de, sa000XPos + $1
	ld a, [de]
	and $f0
	swap a
	ld b, a
	inc e
	ld a, [de]
	swap a
	or b
	ld b, a
	ld e, OBJSTRUCT_Y_POS + $1
	ld a, [de]
	and $f0
	swap a
	ld c, a
	inc e
	ld a, [de]
	swap a
	or c
	ld c, a
	; b = Kirby's block X coordinate
	; c = Kirby's block Y coordinate

	ld de, $3
.asm_1250
	ld a, [hli]
	cp b
	jr nz, .asm_125a
	ld a, [hli]
	cp c
	jr nz, .asm_125b
	jr .asm_1267
.asm_125a
	inc hl
.asm_125b
	ld a, [hli]
	cp $20
	jr nc, .asm_125b
	cp $01
	jr z, .asm_1250
	add hl, de
	jr .asm_1250
.asm_1267
	push hl
	ld a, [hli]
	cp $60
	ld e, $04
	jr nz, .asm_1279
	farcall Func_68276
	jr .asm_1281
.asm_1279
	farcall Func_68280
.asm_1281
	call Func_437
	pop hl
	ret

Func_1286::
	call Func_1564
Func_1289:
	ld a, [hli]
	ld [wdb3d], a
	ld c, a
	ld a, [hli]
	ld [wdb3e], a

	push hl
	ld b, a
	ld hl, wcd2d
	ld a, $b3
	jr .asm_129c
.asm_129b
	add c
.asm_129c
	ld [hli], a
	dec b
	jr nz, .asm_129b
	sla c
	ld a, [wdb3e]
	ld b, a
	ld hl, wcd35
	ld a, LOW(wcd3d)
	jr .asm_12ae
.asm_12ad
	add c
.asm_12ae
	ld [hli], a
	dec b
	jr nz, .asm_12ad
	pop hl

	ld c, $04
	ld de, wdb45
.asm_12b8
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	ld [de], a
	inc de
	ld a, b
	and $0f
	ld [de], a
	inc de
	dec c
	jr nz, .asm_12b8

	push hl
	ld hl, wdb45
	ld de, wdb3f
	ld a, [hli]
	add $08
	ld [de], a
	inc de
	ld a, [hli]
	adc $00
	ld [de], a
	inc de
	ld a, [hli]
	add $08
	ld [de], a
	inc de
	ld a, [hli]
	adc $00
	ld [de], a
	inc de
	ld a, [hli]
	add $98
	ld [de], a
	inc de
	ld a, [hl]
	adc $00
	ld [de], a
	pop hl

	push hl
	ld bc, $a
	add hl, bc
	ld de, sb300
	call Decompress
	pop hl

	inc hl
	inc hl
	push hl
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch
	ld bc, $3
	add hl, bc
	push hl
	ld a, [hli]
	ld [wdb5c], a
	ld de, wcf00
	call Decompress

	ld c, $05
	ld hl, wcf00
	ld de, wc500
.asm_131c
	ld a, [wdb5c]
	ld b, a
.asm_1320
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, .asm_1320
	ld e, $00
	inc d
	dec c
	jr nz, .asm_131c
	pop hl
	dec hl
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	ld [wdb5a], a
	call Bankswitch
	ld a, [hli]
	cpl
	inc a
	swap a
	ld d, a
	and $f0
	ld e, a
	ld a, d
	or $f0
	ld d, a
	ld a, e
	add $30
	ld e, a
	ld a, d
	adc $96
	ld d, a
	and $0f
	or e
	swap a
	ld [wdb59], a
	ld a, l
	ld [wdb5b], a
	ld a, h
	ld [wdb5c], a
	call Decompress
	ld a, [wdb58]
	call Bankswitch
	pop hl

	push hl
	ld bc, $7
	add hl, bc
	bit 0, [hl]
	ld a, $86
	jr z, .asm_1388
	ld a, $0c
	call Bankswitch
	ld hl, $47d1
	ld de, vTiles1 tile $06
	call Decompress
	ld a, d
	and $0f
	or e
	swap a
.asm_1388
	ld [wdb5e], a
	ld a, [wdb73]
	or a
	jr z, .asm_13a3
	pop hl

	ld a, [wLevel]
	ld hl, PtrTable_14d0
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jr .asm_13ae
.asm_13a3
	ld a, [wdb58]
	call Bankswitch
	pop hl
	ld bc, $3
	add hl, bc
.asm_13ae
	ld a, [hld]
	ld b, a
	ld [wdb5d], a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch

	ld de, wObjectOAMs
.asm_13bd
	ld a, [hli]
	cp $ff
	jp z, .asm_1445
	ldh [hff84], a
	push hl
	ld l, a
	ld h, $00
	ld [de], a ; object ID
	inc de
	ld a, [wdb5e]
	ld [de], a ; base tile index
	inc de
	add hl, hl
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc ; *6
	ld bc, Data_1d629
	add hl, bc
	ld a, BANK(Data_1d629)
	call Bankswitch
	ld a, [hli] ; OAM ptr
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli] ; OAM bank
	ld [de], a
	inc de
	ldh a, [hff84]
	cp $13
	jr z, .asm_143b
	cp $14
	jr z, .asm_143b
	cp $15
	jr z, .asm_143b
	cp $16
	jr z, .asm_143b
	cp $1c
	jr z, .asm_143b
	cp $1f
	jr z, .asm_143b
	cp $3e
	jr z, .asm_143b
	push de
	inc hl
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch
	ldh a, [hff84]
	cp $11
	jr nz, .asm_141f
	ld de, vTiles1 tile $58
	call Decompress
	jr .asm_143a
.asm_141f
	ld a, [wdb5e]
	swap a
	ld d, a
	and $f0
	ld e, a
	ld a, d
	and $0f
	add $80
	ld d, a
	call Decompress
	ld a, d
	and $0f
	or e
	swap a
	ld [wdb5e], a
.asm_143a
	pop de
.asm_143b
	pop hl
	ld a, [wdb5d]
	call Bankswitch
	jp .asm_13bd
.asm_1445
	ld a, $ff
	ld [de], a

	ld b, $00
	ld de, wcd3d
.asm_144d
	ld a, [hli]
	cp $ff
	jr z, .asm_145c
	ld [de], a
	ld c, a
	inc e
	ld a, b
	ld [de], a
	inc e
	add c
	ld b, a
	jr .asm_144d
.asm_145c
	ld a, b
	ld [wdb5f], a

	ld c, $03
	ld de, wca00
.asm_1465
	ld a, [wdb5f]
	ld b, a
.asm_1469
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, .asm_1469
	ld e, $00
	inc d
	dec c
	jr nz, .asm_1465

	ld hl, sbb00
	ld bc, $100
	ld a, $00
	call FillHL

	xor a
	ld hl, wdb4f
	ld [hli], a ; wdb4f
	ld [hli], a ; wdb50

	ld de, sa000XPos + 1
	ld a, [de]
	inc e
	sub $50
	ld [hli], a ; wdb51
	ld a, [de]
	inc e
	sbc $00
	ld [hli], a
	inc e
	ld a, [de] ; sa000YPos + 1
	inc e
	sub $40
	ld [hli], a ; wdb53
	ld a, [de]
	sbc $00
	ld [hl], a
	call Func_1513

	ld hl, wdb51
	ld a, [hli] ; wdb51
	and $f0
	sub $10
	ld [wdb55], a
	ld [wdb7d], a
	inc hl
	ld a, [hl] ; wdb53
	and $f0
	sub $10
	ld [wdb56], a
	ld [wdb7e], a

	ld hl, wcd56
	ld bc, $18
	ld a, $00
	call FillHL

	xor a
	ld [wdb72], a
	ld [wdb70], a
	ld [wdb71], a
	ret

PtrTable_14d0:
	table_width 2
	dw .grass_land   + $2 ; GRASS_LAND
	dw .big_forest   + $2 ; BIG_FOREST
	dw .ripple_field + $2 ; RIPPLE_FIELD
	dw .iceberg      + $2 ; ICEBERG
	dw .red_canyon   + $2 ; RED_CANYON
	dw .cloudy_park  + $2 ; CLOUDY_PARK
	assert_table_length NUM_LEVELS - 1

.grass_land
	dab Data_1c02d
.big_forest
	dab Data_1c038
.ripple_field
	dab Data_1c043
.iceberg
	dab Data_1c0b7
.red_canyon
	dab Data_1c0c2
.cloudy_park
	dab Data_1c0d7
; 0x14fe

SECTION "Func_1513", ROM0[$1513]

Func_1513:
	ld hl, wdb45
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb51
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_1526
	bit 7, [hl]
	jr z, .asm_1529
.asm_1526
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_1529
	ld hl, wdb49
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb51
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_153b
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_153b
	ld hl, wdb47
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_154e
	bit 7, [hl]
	jr z, .asm_1551
.asm_154e
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_1551
	ld hl, wdb4b
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld hl, wdb53
	ld a, [hli]
	sub c
	ld a, [hl]
	sbc b
	jr c, .asm_1563
	ld a, b
	ld [hld], a
	ld [hl], c
.asm_1563
	ret

Func_1564::
	ld a, BANK(PtrTable_2111d)
	call Bankswitch
	ld a, [wdb57]
	ld l, a
	ld h, $00
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc ; *3
	ld bc, PtrTable_2111d + $2
	add hl, bc
	ld a, [hld]
	ld b, a
	ld [wdb58], a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch
	ret

Func_1584::
	; clear scroll
	xor a
	ld hl, rSCY
	ld [hli], a
	ld [hl], a ; rSCX

	ld hl, wda00
	ld [hli], a
	ld [hl], a ; wda01

	ld hl, wdb51
	ld [hli], a
	ld [hli], a
	ld [hli], a ; wdb53
	ld [hl], a
	ret
; 0x1597

SECTION "Func_15a8", ROM0[$15a8]

Func_15a8:
	ldh [hff84], a
	call Func_15e3
	ldh a, [hff84]
	ld [hl], a
Func_15b0:
	call Func_15fc
	ld d, h
	ld e, l
	ld a, [wda22]
	ld l, a
	ld a, [wda28]
	ld h, a
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ldh a, [hff84]
	ld c, a
	ld b, HIGH(wc500)
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	inc b
	ld a, [bc]
	ld [hli], a
	ld a, l
	ld [wda22], a
	ld a, [wda28]
	ld hl, wda23
	rra
	jr nc, .asm_15e1
	ld hl, wda24
.asm_15e1
	inc [hl]
	ret

; input:
; - bc = x position
; - de = y position
; output:
; - [hl] = ?
Func_15e3::
	ld hl, wcd2d
	ld a, d
	add l
	ld l, a
	ld a, [hl]
	add b
	ld h, a
	ldh [hff9d], a
	ld a, e
	and $f0
	ld l, a
	ld a, c
	swap a
	and $0f
	add l
	ld l, a
	ldh [hff9c], a
	ret

Func_15fc::
	ld a, e
	ld h, $26
	rla
	rl h
	rla
	rl h
	and $c0
	ld l, a
	ld a, c
	rra
	rra
	rra
	and $1e
	add l
	ld l, a
	ret

; input:
; - a = level
Func_1611::
	ldh [hff84], a
	ld hl, wdb62
	add l
	ld l, a
	incc h
	ld e, [hl]
	ldh a, [hff84]
	ld hl, Data_163e
	add l
	ld l, a
	incc h
	ld a, [hl]
	or e
	inc a
	ret

Func_162a::
	ldh [hff84], a
	ld a, e
	call GetPowerOfTwo
	ld e, a
	ldh a, [hff84]
	ld hl, wdb62
	add l
	ld l, a
	incc h
	ld a, [hl]
	and e
	ret

Data_163e:
	table_width 1
	db   -8 ; GRASS_LAND
	db   -8 ; BIG_FOREST
	db   -8 ; RIPPLE_FIELD
	db  -16 ; ICEBERG
	db  -32 ; RED_CANYON
	db  -64 ; CLOUDY_PARK
	db -128 ; DARK_CASTLE
	db $ff
	assert_table_length NUM_LEVELS + 1

; input:
; - bc = x position
; - de = y position
; output:
; - a = ?
Func_1646::
	ld a, [wdb3d]
	dec a
	cp b
	jr c, .asm_165c
	ld a, [wdb3e]
	dec a
	cp d
	jr c, .asm_165c
	; (wdb3d > x pos) && (wdb3e > y pos)
	call Func_15e3
	ld l, [hl]
	ld h, HIGH(wc900)
	ld a, [hl]
	ret
.asm_165c
	; (wdb3d <= x pos) || (wdb3e <= y pos)
	xor a
	ld hl, hff9c
	ld [hli], a
	ld [hl], a
	ld a, $00
	ret

; input:
; - [hff9c] = ?
; output:
; - a = ?
Func_1665:
	ld hl, hff9c
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_1684
	ld a, l
	sub $10
	ld l, a
	jr nc, .asm_167f
	ld a, d
	or a
	jr z, .asm_1684
	ld a, [wdb3d]
	cpl
	inc a
	add h
	ld h, a
.asm_167f
	ld l, [hl]
	ld h, HIGH(wc900)
	ld a, [hl]
	ret
.asm_1684
	ld a, $00
	ret

Func_1687:
	ld hl, hff9c
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_16a7
	ld a, l
	add $10
	ld l, a
	jr nc, .asm_16a2
	ld a, [wdb3e]
	dec a
	cp d
	jr z, .asm_16a7
	ld a, [wdb3d]
	add h
	ld h, a
.asm_16a2
	ld l, [hl]
	ld h, HIGH(wc900)
	ld a, [hl]
	ret
.asm_16a7
	ld a, $00
	ret

Func_16aa:
	ld hl, hff9c
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_16ca
	inc l
	ld a, l
	and $0f
	jr nz, .asm_16c5
	ld a, [wdb3d]
	dec a
	cp b
	jr z, .asm_16ca
	ld a, l
	sub $10
	ld l, a
	inc h
.asm_16c5
	ld l, [hl]
	ld h, HIGH(wc900)
	ld a, [hl]
	ret
.asm_16ca
	ld a, $00
	ret

Func_16cd:
	ld hl, hff9c
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_16ec
	dec l
	ld a, l
	and $0f
	cp $0f
	jr nz, .asm_16e7
	ld a, b
	or a
	jr z, .asm_16ec
	ld a, l
	add $10
	ld l, a
	dec h
.asm_16e7
	ld l, [hl]
	ld h, HIGH(wc900)
	ld a, [hl]
	ret
.asm_16ec
	ld a, $00
	ret

; input:
; - bc = x position
; - de = y position
Func_16ef::
	call Func_1646
	and $07
	ldh [hff9e], a
	cp $01
	jr z, .asm_16fc
	and a
	ret
.asm_16fc
	call Func_16aa
	and $07
	cp $01
	jr c, .asm_170b
	jr z, .asm_1714
	cp $04
	jr nc, .asm_1714
.asm_170b
	ld a, c
	and $0f
	ld l, a
	ld a, $10
	sub l
	scf
	ret
.asm_1714
	and a
	ret
; 0x1716

SECTION "Func_17a3", ROM0[$17a3]

; input:
; - bc = x position
; - de = y position
Func_17a3::
	call Func_1646
	and $07
	ldh [hff9e], a
	cp $01
	jr z, .asm_17b0
	and a
	ret
.asm_17b0
	call Func_16cd
	and $07
	cp $01
	jr c, .asm_17bf
	jr z, .asm_17c5
	cp $04
	jr nc, .asm_17c5
.asm_17bf
	ld a, c
	and $0f
	cpl
	scf
	ret
.asm_17c5
	and a
	ret
; 0x17c7

SECTION "Func_184e", ROM0[$184e]

; input:
; - bc = x position
; - de = y position
Func_184e::
	call Func_1646
	ldh [hff9f], a
	and $07
	ldh [hff9e], a
	ld hl, .PtrTable
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.PtrTable:
	dw .Func_188c ; $0
	dw .Func_188e ; $1
	dw .Func_188e ; $2
	dw .Func_188e ; $3
	dw .Func_1874 ; $4
	dw .Func_1882 ; $5
	dw .Func_188e ; $6
	dw .Func_188e ; $7

.Func_1874:
	ld a, c
	and $0f
	ld l, a
	ld a, e
	and $0f
	ld h, a
	ld a, $0f
	sub l
	sub h
	scf
	ret

.Func_1882:
	ld a, e
	and $0f
	ld h, a
	ld a, c
	and $0f
	sub h
	scf
	ret

.Func_188c:
	and a
	ret

.Func_188e:
	call Func_1665
	and $07
	ld hl, $18a0
	add a
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl
; 0x18a0

SECTION "Func_18d7", ROM0[$18d7]

Func_18d7:
	call Func_1646
	and $07
	ldh [hff9e], a
	ld hl, $18eb
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.PtrTable:
	dw .Func_1913
	dw .Func_1915
	dw .Func_1913
	dw .Func_1913
	dw .Func_1913
	dw .Func_1913
	dw .Func_18fb
	dw .Func_1905

.Func_18fb:
	ld a, e
	and $0f
	ld h, a
	ld a, c
	and $0f
	sub h
	scf
	ret

.Func_1905:
	ld a, c
	and $0f
	ld l, a
	ld a, e
	and $0f
	ld h, a
	ld a, $0f
	sub l
	sub h
	scf
	ret

.Func_1913:
	and a
	ret

.Func_1915:
	call Func_1687
	and $07
	ld hl, $1927
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl
; 0x1927

SECTION "Func_1ab3", ROM0[$1ab3]

Func_1ab3::
	call GetObjectPosition
	call Func_1646
	and $c0
	cp $80
	ldh a, [hff9a]
	ld d, a
	ret
; 0x1ac1

SECTION "ApplyOffsetToObjectPosition", ROM0[$1ad9]

; adds bc to object's x position
; and de to object's y position
ApplyOffsetToObjectPosition::
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	add c
	ld c, a
	ld a, [hl]
	adc b
	ld b, a
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hli]
	add e
	ld e, a
	ld a, [hl]
	adc d
	ld d, a
	ret

; outputs object's positions
; output:
; - bc = x position
; - de = y position
GetObjectPosition::
	ld h, d
	ld l, OBJSTRUCT_X_POS + 1
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ret

Func_1af6::
	ld h, d
	ldh a, [hffaf]
	inc a
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	call ApplyOffsetToObjectPosition
	call Func_184e
	jr c, .asm_1b4f
	bit 3, c
	jr z, .asm_1b28
	ldh a, [hffb1]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_1b45
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, .asm_1b4f
	ldh a, [hffb1]
	add l
	jr .asm_1b4f
.asm_1b28
	ldh a, [hffb0]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_1b45
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, .asm_1b4f
	ldh a, [hffb0]
	cpl
	scf
	adc l
	jr .asm_1b4f
.asm_1b45
	ldh a, [hff9a]
	ld d, a
	ld e, OBJSTRUCT_UNK4D
	ld a, $00
	ld [de], a
	scf
	ret
.asm_1b4f
	inc a
	jr nz, .asm_1b45
	ldh a, [hff9a]
	ld d, a
	ldh a, [hff9e]
	ld e, OBJSTRUCT_UNK4D
	ld [de], a
	ldh a, [hff9f]
	ld e, OBJSTRUCT_UNK4E
	ld [de], a
	and a
	ret
; 0x1b61

SECTION "Func_1b61", ROM0[$1b61]

Func_1b61::
	ld h, d
	ldh a, [hffaf]
	inc a
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	call ApplyOffsetToObjectPosition
	call Func_184e
	jr c, Func_1bba
	bit 3, c
	jr z, .asm_1b93
	ldh a, [hffb1]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_1bb0
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, Func_1bba
	ldh a, [hffb1]
	add l
	jr Func_1bba
.asm_1b93
	ldh a, [hffb0]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_1bb0
	ld l, a
	ldh a, [hff9e]
	cp $04
	ld a, l
	jr c, Func_1bba
	ldh a, [hffb0]
	cpl
	scf
	adc l
	jr Func_1bba
.asm_1bb0
	ldh a, [hff9a]
	ld d, a
	ld e, OBJSTRUCT_UNK4D
	ld a, $00
	ld [de], a
	scf
	ret

Func_1bba::
	inc a
	ld l, a
	rlca
	sbc a
	ld b, a
	ldh a, [hff9a]
	ld h, a
	ld a, l
	ld l, OBJSTRUCT_Y_POS
	ld [hl], $80
	inc l
	add [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a
	ldh a, [hff9e]
	ld l, OBJSTRUCT_UNK4D
	ld [hl], a
	ldh a, [hff9f]
	ld l, OBJSTRUCT_UNK4E
	ld [hl], a
	ld d, h
	and a
	ret
; 0x1bda

SECTION "Func_1c0a", ROM0[$1c0a]

Func_1c0a:
	ld h, d
	ldh a, [hffae]
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	call ApplyOffsetToObjectPosition
	call Func_18d7
	jr nc, .asm_1c24
	ld l, a
	dec a
	rlca
	jr nc, .asm_1c76
	jp Func_1e6d
.asm_1c24
	bit 3, c
	jr z, .asm_1c51
	ldh a, [hffb1]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_18d7
	jp nc, Func_1e6d
	ld l, a
	ldh a, [hff9e]
	cp $07
	jp z, Func_1e6d
	cp $06
	ld a, l
	jr nz, .asm_1c4a
	ldh a, [hffb1]
	cpl
	scf
	adc l
	ld l, a
.asm_1c4a
	dec a
	rlca
	jr nc, .asm_1c76
	jp Func_1e6d
.asm_1c51
	ldh a, [hffb0]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_18d7
	jp nc, Func_1e6d
	ld l, a
	ldh a, [hff9e]
	cp $06
	jp z, Func_1e6d
	cp $07
	ld a, l
	jr nz, .asm_1c71
	ldh a, [hffb0]
	add l
	ld l, a
.asm_1c71
	dec a
	rlca
	jp c, Func_1e6d
.asm_1c76
	ldh a, [hff9a]
	ld h, a
	ld a, l
	ld l, OBJSTRUCT_Y_POS
	ld [hl], $80
	inc l
	add [hl]
	ld [hli], a
	ld a, $00
	adc [hl]
	ld [hl], a
	ld d, h
	scf
	ret

Func_1c88::
	xor a
	ld [wdb7c], a
	ld h, d
	ldh a, [hffaf]
	ld e, a
	rla
	sbc a
	ld d, a
	ld b, $00
	ld c, b
	call ApplyOffsetToObjectPosition
	call Func_184e
	jr nc, .asm_1cac
	ld l, a
	rlca
	jr c, .asm_1d06
	ldh a, [hff9a]
	ld d, a
	ld e, OBJSTRUCT_UNK4D
	ldh a, [hff9e]
	ld [de], a
	jr .asm_1cfe
.asm_1cac
	bit 3, c
	jr z, .asm_1cd3
	ldh a, [hffb1]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_1cf6
	ld l, a
	ldh a, [hff9e]
	cp $05
	jr z, .asm_1cf6
	cp $04
	ld a, l
	jr nz, .asm_1cce
	ldh a, [hffb1]
	add l
	ld l, a
.asm_1cce
	rlca
	jr c, .asm_1d38
	jr .asm_1cf6
.asm_1cd3
	ldh a, [hffb0]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_1cf6
	ld l, a
	ldh a, [hff9e]
	cp $04
	jr z, .asm_1cf6
	cp $05
	ld a, l
	jr nz, .asm_1cf3
	ldh a, [hffb0]
	cpl
	scf
	adc l
	ld l, a
.asm_1cf3
	rlca
	jr c, .asm_1d38
.asm_1cf6
	ldh a, [hff9a]
	ld h, a
	ld d, a
	ld l, OBJSTRUCT_UNK4D
	ld [hl], $00
.asm_1cfe
	ld e, OBJSTRUCT_UNK4F
	ld a, [wdb7c]
	ld [de], a
	and a
	ret
.asm_1d06
	ld a, $01
	ld [wdb7c], a
	ldh a, [hff9a]
	ld h, a
	ld c, l
	ld l, OBJSTRUCT_UNK4D
	ld a, [hl]
	cp $04
	jr nc, .asm_1d6e
	ldh a, [hff9e]
	ld e, $00
	cp $04
	jr c, .asm_1d5a
	ld l, OBJSTRUCT_UNK4F
	bit 0, [hl]
	jr nz, .asm_1d3c
	ld l, OBJSTRUCT_Y_POS
	ld b, [hl]
	ld l, OBJSTRUCT_Y_VEL
	ld a, [hli]
	scf
	sbc b
	ld a, [hl]
	sbc $ff
	bit 7, a
	jr nz, .asm_1d3c
	add c
	jr nc, .asm_1d3c
	jr .asm_1d6e
.asm_1d38
	ldh a, [hff9a]
	ld h, a
	ld c, l
.asm_1d3c
	ldh a, [hff9e]
	cp $04
	ld e, $00
	jr c, .asm_1d5a
	ld l, OBJSTRUCT_X_POS
	ld b, [hl]
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	jr z, .asm_1d54
	scf
	sbc b
	ld a, [hl]
	sbc $00
	cpl
	jr .asm_1d59
.asm_1d54
	scf
	sbc b
	ld a, [hl]
	sbc $ff
.asm_1d59
	ld e, a
.asm_1d5a
	ld l, OBJSTRUCT_Y_POS
	ld b, [hl]
	ld l, OBJSTRUCT_Y_VEL
	ld a, [hli]
	scf
	sbc b
	ld a, [hl]
	sbc $ff
	add e
	bit 7, a
	jr nz, .asm_1cf6
	add c
	jp nc, .asm_1cf6
.asm_1d6e
	ld l, OBJSTRUCT_Y_POS
	ld [hl], $80
	inc l
	ld a, c
	add [hl]
	ld [hli], a
	ld a, $ff
	adc [hl]
	ld [hl], a
	ldh a, [hff9e]
	ld l, OBJSTRUCT_UNK4D
	ld [hl], a
	ldh a, [hff9f]
	ld l, OBJSTRUCT_UNK4E
	ld [hl], a
	ld l, OBJSTRUCT_UNK4F
	ld [hl], $00
	ld d, h
	scf
	ret

Func_1d8b:
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ldh a, [hffae]
	ld e, a
	rla
	sbc a
	ld d, a
	bit 7, [hl]
	jr nz, .moving_left

; moving right
	ldh a, [hffb1]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_17a3
	jp nc, Func_1e6d
	ld l, a
	rlca
	jp c, Func_1e2a
	jp Func_1e6d
.moving_left
	ldh a, [hffb0]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_16ef
	jp nc, Func_1e6d
	ld l, a
	dec a
	rlca
	jp nc, Func_1e4c
	jp Func_1e6d

Func_1dc7::
	ld h, d
	ld l, OBJSTRUCT_X_VEL + 1
	ldh a, [hffae]
	ld e, a
	rla
	sbc a
	ld d, a
	bit 7, [hl]
	jr nz, .asm_1dfe
	ldh a, [hffb1]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_17a3
	jr nc, .asm_1de7
	ld l, a
	rlca
	jp c, Func_1e2a
.asm_1de7
	ldh a, [hffb2]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_17a3
	jp nc, Func_1e6d
	ld l, a
	rlca
	jp c, Func_1e2a
	jp Func_1e6d
.asm_1dfe
	ldh a, [hffb0]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_16ef
	jr nc, .asm_1e12
	ld l, a
	dec a
	rlca
	jp nc, Func_1e4c
.asm_1e12
	ldh a, [hffb2]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	call Func_16ef
	jp nc, Func_1e6d
	ld l, a
	dec a
	rlca
	jp nc, Func_1e4c
	jp Func_1e6d

Func_1e2a::
	ld c, l
	ldh a, [hff9a]
	ld h, a
	ld l, OBJSTRUCT_X_POS
	ld b, [hl]
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	scf
	sbc b
	ld a, [hl]
	sbc $ff
	add c
	jp nc, Func_1e6d
	ld l, OBJSTRUCT_X_POS
	ld [hl], $80
	inc l
	ld a, c
	add [hl]
	ld [hli], a
	ld a, $ff
	adc [hl]
	ld [hl], a
	ld d, h
	scf
	ret

Func_1e4c::
	ld c, l
	ldh a, [hff9a]
	ld h, a
	ld l, OBJSTRUCT_X_POS
	ld b, [hl]
	ld l, OBJSTRUCT_X_VEL
	ld a, [hli]
	scf
	sbc b
	ld a, [hl]
	sbc $00
	add c
	jr c, Func_1e6d
	ld l, OBJSTRUCT_X_POS
	ld [hl], $80
	inc l
	ld a, c
	add [hl]
	ld [hli], a
	ld a, $00
	adc [hl]
	ld [hl], a
	ld d, h
	scf
	ret

Func_1e6d::
	ldh a, [hff9a]
	ld d, a
	and a
	ret
; 0x1e72

SECTION "Func_2871", ROM0[$2871]

Func_2871:
	ld hl, sa000Unk6c
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld hl, sa000Unk76
	ld [hl], $00
	ret
; 0x287f

SECTION "Multiply", ROM0[$293e]

; output:
; - bc = b * c
Multiply:
	push af
	xor a
	ldh [hff87], a
	push de
	push hl
	ld a, b
	cp c
	jr nc, .b_is_larger
	; swap b and c
	ld b, c
	ld c, a
.b_is_larger
	ld h, HIGH(wd700)
	ld l, c
	ld d, [hl]
	inc h
	ld e, [hl]
	dec h
	ld l, b
	ld a, [hl]
	inc h
	ld l, [hl]
	ld h, a
	add hl, de
	push af
	ld d, HIGH(wd800)
	ld a, b
	sub c
	ld e, a
	ld a, [de]
	ld c, a
	dec d
	ld a, [de]
	ld b, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr nc, .asm_296e
	pop af
	ccf
	jr .asm_296f
.asm_296e
	pop af
.asm_296f
	rr h
	rr l
	ld b, h
	ld c, l
	ldh a, [hff87]
	rlca
	jr nc, .done
	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
	adc $00
	ld b, a
.done
	pop hl
	pop de
	pop af
	ret
; 0x2988

SECTION "Data_29c9", ROM0[$29c9]

MACRO data_29c9
	db \1 ; music ID
	db \2 ; ATF ID
	dbw \3, \4 ; bank:address
	dbw \5, \6 ; bank:address
	dbw \7, \8 ; bank:address
	db \9 ; ?
ENDM

Data_29c9:
	data_29c9 MUSIC_04, $0b, $1b, $5934, $1b, $4000, $1b, $4191, $4d
	data_29c9 MUSIC_07, $0e, $1b, $6b50, $1b, $43d1, $1b, $4804, $54
	data_29c9 MUSIC_1E, $11, $1b, $61e3, $1b, $423b, $1b, $432e, $4f
	data_29c9 MUSIC_20, $13, $1b, $7667, $1b, $48d0, $1b, $4c06, $5c
	data_29c9 MUSIC_00, $12, $1c, $4000, $1b, $4ca5, $1b, $51ea, $65
	data_29c9 MUSIC_25, $14, $1c, $4e90, $1b, $5295, $1b, $53cb, $6d
	data_29c9 MUSIC_0F, $15, $1c, $5b60, $1b, $5478, $1b, $58a0, $73
	data_29c9 MUSIC_1D, $0a, $0e, $4cc3, $0e, $595a, $0e, $5b4c, $77

Func_2a29::
	ld e, $07
;	fallthrough

; input:
; - e = ?
Func_2a2b::
	ld a, e
	ld [wdd2e], a
	add a
	add a
	ld b, a
	add a
	add b ; *12
	ld bc, Data_29c9
	add c
	incc b
	ld c, a
	call Func_2af8

	ld a, [bc]
	inc bc
	ld e, a
	push bc
	farcall PlayMusic
	pop bc

	ld a, [bc]
	inc bc
	ld e, a

	push de
	ld a, [bc]
	inc bc
	push bc
	call Bankswitch
	pop bc
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
	ld de, vTiles0
	push bc
	call Decompress
	pop bc

	ld a, [bc]
	inc bc
	push bc
	call Bankswitch
	pop bc
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
	ld de, vTiles2
	push bc
	call Decompress
	pop bc

	ld a, [bc]
	inc bc
	push bc
	call Bankswitch
	pop bc
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
	debgcoord 0, 0, vBGMap0
	push bc
	call Decompress

	ld a, LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16 | LCDC_WIN_9C00
	ldh [rLCDC], a

	call Func_46d
	homecall Func_20000
	pop bc
	ld a, [bc]
	ld h, HIGH(sObjects)
	ld l, HIGH(sObjectsEnd)
	ld b, $00
	ld c, b ; $00
	ld d, c ; $00
	ld e, d ; $00
	call CreateObject
	pop de
	farcall Func_7a011

	ld a, [wdd2e]
	add $03
	ld d, a
	ld e, $04
	farcall Func_68246

.asm_2ac4
	call Func_496
	call UpdateObjects
	call Func_4ae
	call DoFrame
	ld a, [wdd2d]
	and a
	jr nz, .asm_2adc
	ld a, [wda46]
	and a
	jr nz, .asm_2ac4
.asm_2adc
	ld a, [wdd2e]
	add $03
	ld d, a
	ld e, $04
	farcall Func_6827b
	call Func_437
	farcall Func_1dada
	ret

Func_2af8::
	call Func_1584

	ld hl, wdd2d
	ld [hl], a ; $00

	; clear any player input
	ld hl, hJoypad1Down
	ld [hl], a ; $00

	ld a, $e4
	ld [wcd09], a
	ld a, $d0
	ld [wcd0a], a
	ld a, $e4
	ld [wcd0b], a
	ret
; 0x2b13

SECTION "Func_2b91", ROM0[$2b91]

Func_2b91::
	ld hl, wdd2d
	ld [hl], $01
	ret

; input:
; - [de] = audio commands
; - bc = channel
InitChannel::
	ld hl, wChannelBaseNotes
	add hl, bc
	ld [hl], C_3

	xor a
	ld hl, wInstrumentSustainLength
	add hl, bc
	ld [hl], a ; $00
	ld hl, wChannelVolumes
	add hl, bc
	ld [hl], a ; $00
	ld hl, wChannelInstruments
	add hl, bc
	ld [hl], a ; $00
	ld hl, wChannelTempoModes
	add hl, bc
	ld [hl], a ; $00
	ld hl, wNoteFrequencyTables
	add hl, bc
	ld [hl], a ; $00

	ld hl, ChannelAudioStackOffsets
	add hl, bc
	ld a, [hl]
	ld hl, wAudioStackPointers
	add hl, bc
	ld [hl], a

	; set command pointer for this channel
	inc de
	ld a, [de]
	ld hl, wAudioCommandPointersLo
	add hl, bc
	ld [hl], a
	inc de
	ld a, [de]
	ld hl, wAudioCommandPointersHi
	add hl, bc
	ld [hl], a

	inc de
	ld a, [de]
	sra a
	sra a ; /4
	add LOW(ChannelSelectorOffsets)
	ld l, a
	ld h, HIGH(ChannelSelectorOffsets)
	incc h
	ld a, [hl]
	ld hl, wChannelSelectorOffsets
	add hl, bc
	ld [hl], a

	; set this channel active
	ld hl, wAudioCommandDurations
	add hl, bc
	ld [hl], 1
	ld hl, wInstrumentSustain
	add hl, bc
	ld [hl], $01
	ret

ChannelSelectorOffsets:
	db CHANNEL1_LENGTH - 1
	db CHANNEL2_LENGTH - 1
	db $ff
	db CHANNEL4_LENGTH - 1
	db CHANNEL3_LENGTH - 1

; offsets in wAudioStack reserved for each channel
; holds stack for general audio commands
ChannelAudioStackOffsets:
	db wChannel1StackAudioBottom - wAudioStack ; CHANNEL1
	db wChannel2StackAudioBottom - wAudioStack ; CHANNEL2
	db wChannel3StackAudioBottom - wAudioStack ; CHANNEL3
	db wChannel4StackAudioBottom - wAudioStack ; CHANNEL4
	db wChannel5StackAudioBottom - wAudioStack ; CHANNEL5
	db wChannel6StackAudioBottom - wAudioStack ; CHANNEL6
	db wChannel7StackAudioBottom - wAudioStack ; CHANNEL7
	db wChannel8StackAudioBottom - wAudioStack ; CHANNEL8

_UpdateAudio:
	ld a, $1f
	call UnsafeBankswitch

	ld b, CHANNEL8
.loop_channels
	ld h, HIGH(wAudioCommandDurations)
	ld a, LOW(wAudioCommandDurations)
	add b
	ld l, a
	ld a, [hl]
	and a
	jr z, .next_channel ; inactive
	ld a, b
	cp CHANNEL4 + 1
	ld a, LOW(wSFXChannels) ; sfx
	jr c, .got_channel_config_ptr
	ld a, LOW(wMusicChannels) ; music
.got_channel_config_ptr
	ldh [wChannelConfigLowByte], a

	ld h, HIGH(wAudioCommandPointersLo)
	ld a, LOW(wAudioCommandPointersLo)
	add b
	ld l, a
	push hl
	ld e, [hl]
	add wAudioCommandPointersHi - wAudioCommandPointersLo
	ld l, a ; wAudioCommandPointersHi
	push hl
	ld d, [hl]
	push bc
	call ExecuteAudioCommands
	pop bc
	pop hl
	ld [hl], d ; wAudioCommandPointersHi
	pop hl
	ld [hl], e ; wAudioCommandPointersLo

	call UpdateInstrumentSustain
	ld h, HIGH(wInstrumentAudioCommandPointersLo)
	ld a, LOW(wInstrumentAudioCommandPointersLo)
	add b
	ld l, a
	push hl
	ld e, [hl]
	add wInstrumentAudioCommandPointersHi - wInstrumentAudioCommandPointersLo
	ld l, a
	push hl
	ld d, [hl]
	push bc
	call ExecuteInstrumentCommands
	pop bc
	pop hl
	ld [hl], d
	pop hl
	ld [hl], e
.next_channel
	; switch to different bank for SFX channels
	ld a, CHANNEL4 + 1
	cp b
	jr nz, .skip_bankswitch
	ld a, BANK(UpdateSFX)
	call UnsafeBankswitch
.skip_bankswitch
	dec b
	bit 7, b
	jr z, .loop_channels
	jp UpdateSFX

; input:
; - [de] = audio commands
; - b = channel
ExecuteAudioCommands:
	ld h, HIGH(wAudioCommandDurations)
	ld a, LOW(wAudioCommandDurations)
	add b
	ld l, a
	dec [hl]
	jr z, .do_cmds
	ret ; still waiting delay
.next_cmd
	inc de
.do_cmds
	ld h, $ce
	ld a, [de]
	ld c, a ; command byte
	and $e0
	cp AUDIO_COMMANDS_BEGIN
	jp z, .audio_command
	ld a, LOW(wChannelSelectorOffsets)
	add b
	ld l, a
	ld a, [hl]
	cp CHANNEL4_LENGTH - 1
	jr nz, .not_noise_channel
	; noise channel
	bit 4, c
	jp nz, .asm_14fcd
	ld a, c
	and $0f
	cp $0f
	jr z, .asm_14fb6
	add LOW(NoiseChannelPolynomialCounters)
	ld l, a
	ld h, HIGH(NoiseChannelPolynomialCounters)
	incc h
	ld c, [hl]
	ld a, CHANNEL4_FREQUENCY
	call GetPointerToChannelConfig
	ld [hl], c
	jp .asm_14fcd
.not_noise_channel
	ld a, c
	and $1f
	cp $10
	jr z, .asm_14fb6
	bit 4, a
	jr z, .asm_14fa7
	; is negative
	or $e0
.asm_14fa7
	ld c, a
	ld a, LOW(wChannelBaseNotes)
	add b
	ld l, a
	ld a, [hl]
	add c ; + fundamental note
	push de
	call SetChannelNoteFrequency
	pop de
	jp .asm_14fcd

.asm_14fb6
	call .Func_15038
	ld c, a
	ld h, HIGH(wInstrumentSustain)
	ld a, LOW(wInstrumentSustain)
	add b
	ld l, a
	ld a, [hl]
	and a
	jr z, .asm_14fc6
	ld [hl], 1
.asm_14fc6
	ld a, c
	and a
	jp z, .next_cmd
	inc de
	ret

.asm_14fcd
	call .Func_15038
	ld c, a
	ld h, HIGH(wInstrumentSustain)
	ld a, LOW(wInstrumentSustain)
	add b
	ld l, a
	ld [hl], -1
	add wInstrumentSustainLength - wInstrumentSustain
	ld l, a
	ld a, [hl]
	and a
	jr z, .asm_14ff3
	push bc
	push de
	ld e, a ; value from wInstrumentSustainLength
	ld h, HIGH(wInstrumentSustain)
	ld a, LOW(wInstrumentSustain)
	add b
	ld l, a
	push hl
	ld b, e
	call Multiply
	; hl = c * wInstrumentSustainLength
	pop hl
	ld [hl], b ; wInstrumentSustain
	pop de
	pop bc
.asm_14ff3
	push bc
	call .Func_14ffb
	pop bc
	jp .asm_14fc6

.Func_14ffb:
	ld h, HIGH(wChannelInstruments)
	ld a, LOW(wChannelInstruments)
	add b
	ld l, a
	ld a, [hl]
	bit 7, a
	jr nz, .asm_15037
;	fallthrough

; input:
; - a = INSTRUMENT_* constant
.SetChannelInstrument_Attack:
	add a
	add a ; *4
.SetChannelInstrument_Release
	push de
	add LOW(Instruments)
	ld e, a
	ld d, HIGH(Instruments)
	incc d
	ld h, HIGH(wInstrumentAudioCommandPointersLo)
	ld a, LOW(wInstrumentAudioCommandPointersLo)
	add b
	ld l, a
	ld a, [de]
	ld [hl], a
	ld a, LOW(wInstrumentAudioCommandPointersHi)
	add b
	ld l, a
	inc de
	ld a, [de]
	ld [hl], a

	; reset instrument stack for this channel
	ld h, HIGH(ChannelInstrumentStackOffsets)
	ld a, LOW(ChannelInstrumentStackOffsets)
	add b
	ld l, a
	incc h
	ld c, [hl]
	ld h, HIGH(wInstrumentStackPointers)
	ld a, LOW(wInstrumentStackPointers)
	add b
	ld l, a
	ld [hl], c
	add wInstrumentCommandDurations - wInstrumentStackPointers
	ld l, a
	ld [hl], 1
	pop de
.asm_15037
	ret

.Func_15038:
	ld a, [de]
	and $e0
	cp AUDIOCMD_WAIT
	jr nz, .rest
	inc de
	ld a, [de]
	jr .got_duration

.rest
	ld h, HIGH(wChannelTempoModes)
	ld a, LOW(wChannelTempoModes)
	add b
	ld l, a
	ld a, [de]
	and $e0
	swap a
	srl a
	add [hl] ; wChannelTempoModes
	add LOW(wTempoModeDurations)
	ld l, a
	ld a, $00
	adc HIGH(wTempoModeDurations)
	ld h, a
	ld a, [hl]
.got_duration
	ld c, a
	ld h, HIGH(wAudioCommandDurations)
	ld a, LOW(wAudioCommandDurations)
	add b
	ld l, a
	ld a, c
	ld [hl], a
	ret

.audio_command
	ld a, c
	cp AUDIOCMD_VOLUME
	jr nz, .volumn_shift_cmd
	inc de
	ld h, HIGH(wChannelVolumes)
	ld a, LOW(wChannelVolumes)
	add b
	ld l, a
	ld a, [de]
.set_channel_base_volume
	; set high nybble of wChannelVolumes to
	; the command argument
	swap a
	and $f0
	ld c, a
	ld a, [hl] ; wChannelVolumes + CHANNEL
	and $0f
	or c
	ld [hl], a
	call UpdateChannelVolume
	jp .next_cmd

.volumn_shift_cmd
	cp AUDIOCMD_VOLUME_SHIFT
	jr nz, .tempo_mode_cmd
	inc de
	ld a, [de]
	ld c, a
	ld h, HIGH(wChannelVolumes)
	ld a, LOW(wChannelVolumes)
	add b
	ld l, a
	ld a, [hl]
	swap a
	and $0f
	add c
	bit 7, c
	jr nz, .negative_volume_shift
	cp $10
	jr c, .got_volume_shift
	ld a, 15 ; cap it to max 15
	jr .got_volume_shift
.negative_volume_shift
	jr c, .got_volume_shift
	xor a ; cap it to min 0
.got_volume_shift
	jr .set_channel_base_volume

.tempo_mode_cmd
	cp AUDIOCMD_SET_TEMPO_MODE
	jr nz, .sustain_cmd
	inc de
	ld a, [de]
	add a
	ld c, a
	add a
	add c ; *6
	ld hl, wChannelTempoModes
.set_channel_value
	ld c, a
	ld a, l
	add b
	ld l, a
	ld [hl], c
	jp .next_cmd

.sustain_cmd
	cp AUDIOCMD_SUSTAIN
	jr nz, .sustain_length_cmd
	inc de
	ld h, HIGH(wAudioCommandDurations)
	ld a, LOW(wAudioCommandDurations)
	add b
	ld l, a
	ld a, [de]
	ld [hl], a
	ld a, LOW(wInstrumentSustain)
	add b
	ld l, a
	ld [hl], -1
	inc de
	ret

.sustain_length_cmd
	cp AUDIOCMD_SUSTAIN_LENGTH
	jr nz, .base_note_cmd
	inc de
	ld a, [de]
	ld hl, wInstrumentSustainLength
	jp .set_channel_value

.base_note_cmd
	cp AUDIOCMD_SET_BASE_NOTE
	jr nz, .instrument_cmd
	inc de
	ld a, [de]
	ld hl, wChannelBaseNotes
	jp .set_channel_value

.instrument_cmd
	cp AUDIOCMD_SET_INSTRUMENT
	jr nz, .note_frequencies_cmd
	inc de
	ld h, HIGH(wChannelInstruments)
	ld a, LOW(wChannelInstruments)
	add b
	ld l, a
	ld a, [de]
	ld [hl], a
	bit 7, a
	call nz, .SetChannelInstrument_Attack ; bug? should be call z
	jp .next_cmd

.note_frequencies_cmd
	cp AUDIOCMD_NOTE_FREQUENCIES
	jr nz, .set_frequency_cmd
	inc de
	ld a, [de]
	ld hl, wNoteFrequencyTables
	jp .set_channel_value

.set_frequency_cmd
	cp AUDIOCMD_SET_FREQUENCY
	jr nz, .pitch_cmd
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	push de
	ld d, a
	ld e, c
	call SetChannelFrequency
	call .Func_14ffb
	pop de
	jp .next_cmd

.pitch_cmd
	cp AUDIOCMD_PITCH
	jr nz, .pan_cmd
	inc de
	ld a, [de]
	push de
	cpl
	inc a
	ld e, a
	ld d, 0
	rla
	jr nc, .got_pitch_val
	dec d ; -1
.got_pitch_val
	call AddToChannelFrequency
	pop de
	jp .next_cmd

.pan_cmd
	cp AUDIOCMD_SET_PAN
	jr nz, .audio_e1_cmd
	inc de
	ld a, [de]
	ld c, a
	push de
	ld h, HIGH(wChannelSelectorOffsets)
	ld a, LOW(wChannelSelectorOffsets)
	add b
	ld l, a
	ld e, [hl]
	srl e
	srl e
	ld d, $00
	ld hl, wChannelPans
	add hl, de
	ld a, c
	rra
	jr nc, .no_left_output
	set 4, d ; left
.no_left_output
	rra
	jr nc, .no_right_output
	inc d ; right
.no_right_output
	inc e
	dec e
	jr z, .got_final_pan ; is channel 1
	; not channel 1, then need to shift
	; left to get correct channel sound output
.loop_pan_shift
	rlc d
	dec e
	jr nz, .loop_pan_shift
.got_final_pan
	ld a, b
	cp CHANNEL4 + 1
	jr c, .sfx_panning
REPT NUM_SFX_CHANNELS
	inc l
ENDR
.sfx_panning
	ld [hl], d
	pop de
	jp .next_cmd

.audio_e1_cmd
	cp AUDIOCMD_E1
	jr nz, .audio_end_cmd
	inc de
	ld a, [de]
	ld [wce00], a
	jp .next_cmd

.audio_end_cmd
	cp AUDIOCMD_END
	jr nz, .stack_commands
	ld h, HIGH(wAudioCommandDurations)
	ld a, LOW(wAudioCommandDurations)
	add b
	ld l, a
	ld [hl], 0
	add wInstrumentCommandDurations - wAudioCommandDurations
	ld l, a
	xor a
	ld [hl], a
	jp SetChannelNoteVolume

.stack_commands
	ld hl, wAudioStackPointers
	call ExecuteStackAudioCommands
	jp .do_cmds

; input:
; - hl = ?
ExecuteStackAudioCommands:
	ld a, l
	add b
	ld l, a
	push hl
	ld a, LOW(wAudioStack)
	add [hl]
	ld l, a
	ld a, HIGH(wAudioStack)
	adc 0
	ld h, a
	call .ExecuteCommand
	ld a, l
	sub LOW(wAudioStack)
	pop hl
	ld [hl], a
	ret

.ExecuteCommand:
	ld a, [de]
	cp AUDIOCMD_JUMP
	jr nz, .call_cmd
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld d, a
	ld e, c
	ret

.call_cmd
	cp AUDIOCMD_CALL
	jr nz, .ret_cmd
	inc de
	inc de
	inc de
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e
	dec de
	ld a, [de]
	ld c, a
	dec de
	ld a, [de]
	ld e, a
	ld d, c
	ret

.ret_cmd
	cp AUDIOCMD_RET
	jr nz, .repeat_cmd
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ret

.repeat_cmd
	cp AUDIOCMD_REPEAT
	jr nz, .repeat_end_cmd
	inc de
	ld a, [de]
	ld c, a
	inc de
	dec hl
	ld [hl], d
	dec hl
	ld [hl], e
	dec hl
	ld [hl], c
	ret

.repeat_end_cmd
	cp AUDIOCMD_REPEAT_END
	jr nz, .asm_151f8
	dec [hl]
	jr z, .asm_151f4
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	dec hl
	dec hl
	ret
.asm_151f4
	inc hl
	inc hl
	inc hl
	inc de
.asm_151f8
	ret

; input:
; - a = note constant
SetChannelNoteFrequency:
	ld e, a
	ld a, LOW(wNoteFrequencyTables)
	add b
	ld l, a
	ld a, [hl]
	add a ; *2
	add LOW(NoteFrequencyTable)
	ld l, a
	ld a, $00
	adc HIGH(NoteFrequencyTable)
	ld h, a
	ld a, [hli]
	rlc e ; *2
	add e
	ld e, a
	ld a, [hl]
	adc $00
	ld h, a
	ld l, e
	ld a, [hli]
	ld d, a
	ld e, [hl]
;	fallthrough

; input:
; - b = channel
; - de = frequency
SetChannelFrequency:
	ld h, HIGH(wChannelSelectorOffsets)
	ld a, LOW(wChannelSelectorOffsets)
	add b
	ld l, a
	ld a, [hl]
	cp CHANNEL3_LENGTH - 1
	jr z, .channel_3
	ld a, CHANNEL_SELECTOR_FREQUENCY
	call GetPointerToChannelProperty_GotOffset
	jr .set_frequency
.channel_3
	; channel 3 needs to be enabled as well
	ld a, CHANNEL_SELECTOR_ENABLED
	call GetPointerToChannelProperty_GotOffset
	ld [hl], AUD3ENA_ON
	inc l
	inc l
	inc l
.set_frequency
	ld a, e
	ld [hli], a
	ld [hl], d
	ret

; tick down sustain counter for instrument
; if it reaches 0, then do release audio scripts
; if sustain is -1, then don't release note
UpdateInstrumentSustain:
	ld h, HIGH(wInstrumentSustain)
	ld a, LOW(wInstrumentSustain)
	add b
	ld l, a
	ld a, [hl]
	and a
	ret z ; not playing
	cp -1
	ret z ; no releasing
	dec [hl]
	ret nz ; still waiting delay
	ld a, LOW(wChannelInstruments)
	add b
	ld l, a
	ld a, [hl]
	add a
	add a
	add $2 ; a = a*4 + 2
	jp ExecuteAudioCommands.SetChannelInstrument_Release

ExecuteInstrumentCommands:
	ld h, HIGH(wInstrumentCommandDurations)
	ld a, LOW(wInstrumentCommandDurations)
	add b
	ld l, a
	dec [hl]
	jr z, .do_cmds
	ret ; still waiting delay
.next_cmd
	inc de
.do_cmds
	ld h, $ce
	ld a, [de]
	ld c, a ; command byte
	and $e0
	jr nz, .check_change_pitch
	ld a, c
	and $1f
	ld c, a
	ld a, LOW(wInstrumentCommandDurations)
	add b
	ld l, a
	ld [hl], c
	inc de
	ret

.check_change_pitch
	cp AUDIOCMD_PITCH_SHIFT
	jr nz, .volume_cmd
	push bc
	push de
	call ConvertTo16BitFrequency
	call AddToChannelFrequency
	pop de
	pop bc
.asm_1527b
	ld a, [de]
	and AUDIOCMD_BREAK
	jr z, .next_cmd
	ld h, HIGH(wInstrumentCommandDurations)
	ld a, LOW(wInstrumentCommandDurations)
	add b
	ld l, a
	ld [hl], 1
	inc de
	ret

.volume_cmd
	cp AUDIOCMD_NOTE_VOLUME
	jr nz, .asm_15294
	ld a, c
	and $0f
	jp .asm_152b2

.asm_15294
	cp AUDIOCMD_NOTE_VOLUME_SHIFT
	jr nz, .wave_cmd
	push de
	call ConvertTo16BitFrequency
	ld h, HIGH(wChannelVolumes)
	ld a, LOW(wChannelVolumes)
	add b
	ld l, a
	ld a, [hl]
	and $0f
	add e
	bit 7, a
	jr z, .asm_152ab
	xor a ; cap to min 0
.asm_152ab
	cp 15 + 1
	jr c, .asm_152b1
	ld a, 15 ; cap to max 15
.asm_152b1
	pop de
.asm_152b2
	push de
	call SetChannelNoteVolume
	pop de
	jp .asm_1527b

.wave_cmd
	cp AUDIOCMD_WAVE
	jr nz, .asm_15311
	ld h, HIGH(wChannelSelectorOffsets)
	ld a, LOW(wChannelSelectorOffsets)
	add b
	ld l, a
	ld a, [hl]
	cp CHANNEL3_LENGTH - 1
	jr z, .change_wave_sample
	ld a, CHANNEL_SELECTOR_LENGTH
	call GetPointerToChannelProperty_GotOffset
	ld a, c
	rrca
	rrca
	and $c0 ; wave duty cycle mask
	ld c, a
	ld a, [hl]
	and $3f
	or c
	ld [hl], a
	jp .asm_1527b
.change_wave_sample
	ld a, c
	and $0f
	ld hl, wWaveSample
	cp [hl]
	jr z, .skip_load_wave_sample
	push de
	ld [hl], a
	swap a ; *$10
	ld e, a
	ld d, $00
	ld hl, wWaveSamples
	add hl, de
	xor a ; AUD3ENA_OFF
	ldh [rAUD3ENA], a
	call .LoadWaveSample
	ld a, AUD3ENA_ON
	ldh [rAUD3ENA], a
	ld a, [wChannel3FreqHi]
	set 7, a
	ldh [rAUD3HIGH], a
	pop de
.skip_load_wave_sample
	jp .asm_1527b

; input:
; - hl = wave sample data
.LoadWaveSample::
	ld de, _AUD3WAVERAM
	ld c, $10
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop
	ret

.asm_15311
	cp $e0
	jr nz, .done
	ld a, c
	cp $f0
	jr nz, .audio_end_cmd
	inc de
	ld a, [de]
	ld c, a
	ld a, CHANNEL_SELECTOR_ENABLED
	call GetPointerToChannelProperty
	ld [hl], c
	jp .next_cmd
.audio_end_cmd
	cp AUDIOCMD_END
	jr nz, .stack_commands
	ld a, LOW(wInstrumentCommandDurations)
	add b
	ld l, a
	ld [hl], 0
	ret

.stack_commands
	ld hl, wInstrumentStackPointers
	call ExecuteStackAudioCommands
	jp .do_cmds

.done
	ret

; input:
; - a = volume value (between 0 and 15)
SetChannelNoteVolume:
	; set low nybble of wChannelVolumes to input
	ld c, a
	ld h, HIGH(wChannelVolumes)
	ld a, LOW(wChannelVolumes)
	add b
	ld l, a
	ld a, [hl]
	and $f0
	or c
	ld [hl], a
;	fallthrough

; input:
; - hl = channel volume
UpdateChannelVolume:
	push de
	ld a, -1
	sub [hl]
	swap a
	and $0f
	ld e, a
	ld a, [hl]
	and $0f
	sub e
	ld e, a
	; e = noteVolume - (15 - channelVolume)
	jr nc, .no_underflow
	ld e, 0 ; minimum of 0
.no_underflow
	push hl
	ld hl, wce01
	ld a, b
	cp CHANNEL4 + 1
	jr c, .is_sfx
	inc l ; wce02
.is_sfx
	ld a, -1
	sub [hl]
	swap a
	and $0f
	ld d, a
	pop hl
	ld a, e
	sub d
	jr nc, .set_envelope_or_level
	xor a ; minimum of 0
.set_envelope_or_level
	ld e, a
	ld a, LOW(wChannelSelectorOffsets)
	add b
	ld l, a
	ld a, [hl]
	cp CHANNEL3_LENGTH - 1
	jr z, .channel_3
; set envelope initial volume
	ld a, CHANNEL_SELECTOR_ENVELOPE
	call GetPointerToChannelProperty_GotOffset
	swap e
	ld a, [hl]
	and $0f
	or e
	ld [hl], a
	pop de
	ret
.channel_3
	srl e
	srl e ; /4
	ld d, $00
	ld hl, Channel3OutputLevels
	add hl, de
	ld e, [hl]
	ld a, CHANNEL_SELECTOR_ENVELOPE
	call GetPointerToChannelProperty
	ld [hl], e
	pop de
	ret

Channel3OutputLevels:
	db AUD3LEVEL_MUTE ;   0 ~  3
	db AUD3LEVEL_25   ;   4 ~  7
	db AUD3LEVEL_50   ;   8 ~ 11
	db AUD3LEVEL_100  ;  12 ~ 15

; input:
; - c = 4-bit two's compliment frequency
; output:
; - de = frequency
ConvertTo16BitFrequency:
	ld a, c
	and $0f
	ld d, $00
	bit 3, a
	jr z, .positive
; negative
	or $f0
	dec d ; $ff
.positive
	ld e, a
	ret

; input:
; - de = channel frequency to add
AddToChannelFrequency:
	ld a, CHANNEL_SELECTOR_FREQUENCY
	call GetPointerToChannelProperty
	ld a, e
	add [hl]
	ld [hli], a
	ld a, d
	adc [hl]
	ld [hl], a
	ret

; selects a property of the current channel
; and gets its pointer in hl
; input:
; - a = CHANNEL_SELECTOR_* constant
GetPointerToChannelProperty:
	push af
	ld h, HIGH(wChannelSelectorOffsets)
	ld a, LOW(wChannelSelectorOffsets)
	add b
	ld l, a
	pop af
;	fallthrough

; same as GetPointerToChannelProperty but
; expects hl to already point to the channel specific offset
; input:
; - a = CHANNEL_SELECTOR_* constant
; - hl = wChannelSelectorOffsets + channel
GetPointerToChannelProperty_GotOffset:
	add [hl]
;	fallthrough

; input:
; - a = CHANNEL_SELECTOR_* constant
GetPointerToChannelConfig:
	ld hl, wChannelConfigLowByte
	add [hl]
	ld l, a
	ld h, HIGH(wSFXChannels) ; aka HIGH(wMusicChannels)
	ret

; offsets in wAudioStack reserved for each channel
; holds stack for instrument audio commands
ChannelInstrumentStackOffsets:
	db wChannel1StackInstrumentBottom - wAudioStack ; CHANNEL1
	db wChannel2StackInstrumentBottom - wAudioStack ; CHANNEL2
	db wChannel3StackInstrumentBottom - wAudioStack ; CHANNEL3
	db wChannel4StackInstrumentBottom - wAudioStack ; CHANNEL4
	db wChannel5StackInstrumentBottom - wAudioStack ; CHANNEL5
	db wChannel6StackInstrumentBottom - wAudioStack ; CHANNEL6
	db wChannel7StackInstrumentBottom - wAudioStack ; CHANNEL7
	db wChannel8StackInstrumentBottom - wAudioStack ; CHANNEL8

NoteFrequencyTable:
	dw NoteFrequencies - 6

NoiseChannelPolynomialCounters:
	db %000 | AUD4POLY_15STEP | (0 << 4)
	db %000 | AUD4POLY_15STEP | (1 << 4)
	db %000 | AUD4POLY_15STEP | (2 << 4)
	db %000 | AUD4POLY_15STEP | (3 << 4)
	db %111 | AUD4POLY_15STEP | (0 << 4)
	db %011 | AUD4POLY_15STEP | (2 << 4)
	db %000 | AUD4POLY_15STEP | (5 << 4)
	db %011 | AUD4POLY_15STEP | (3 << 4)
	db %000 | AUD4POLY_15STEP | (6 << 4)
	db %011 | AUD4POLY_15STEP | (4 << 4)
	db %000 | AUD4POLY_15STEP | (7 << 4)
	db %101 | AUD4POLY_15STEP | (4 << 4)
	db %111 | AUD4POLY_15STEP | (4 << 4)
	db %101 | AUD4POLY_15STEP | (5 << 4)
	db %101 | AUD4POLY_15STEP | (6 << 4)

; loaded to channel3 wave RAM in InitAudio
InitialWaveform::
	dn 13,  5,  6,  9,  5,  0,  1, 14,  0,  0,  1,  8,  0, 13,  7,  9,  8,  5,  2,  7,  4, 15,  7,  8,  8, 10,  2,  7,  4,  7,  7, 11

SECTION "Func_3131", ROM0[$3131]

Func_3131::
	xor a
	ld [wHUDUpdateFlags], a

	hlbgcoord 1, 1, vBGMap1
	ld c, $70
	ld de, wScore
	ld a, [de]
	ld b, a
	inc de
	ld b, a
	swap a
	and $0f
	add c
	ld [hli], a
	ld a, b
	and $0f
	add c
	ld [hli], a
	ld a, [de]
	inc de
	ld b, a
	swap a
	and $0f
	add c
	ld [hli], a
	ld a, b
	and $0f
	add c
	ld [hli], a
	ld a, [de]
	ld b, a
	swap a
	and $0f
	add c
	ld [hli], a
	ld a, b
	and $0f
	add c
	ld [hli], a
	ld a, c
	ld [hl], a

	hlbgcoord 2, 0, vBGMap1
	ld a, [sa000Unk71]
	and a
	jr nz, .asm_3178
	ld a, [wdee3]
	rra
	jr .asm_317b
.asm_3178
	ld a, [wdee5]
.asm_317b
	ld d, $06
	and a
	jr z, .asm_3187
.asm_3180
	ld [hl], $64
	inc hl
	dec d
	dec a
	jr nz, .asm_3180
.asm_3187
	ld a, d
	and a
	jr z, .asm_3191
.asm_318b
	ld [hl], $63
	inc hl
	dec d
	jr nz, .asm_318b
.asm_3191
	hlbgcoord 9, 0, vBGMap1
	ld de, wdee1
	ld a, [de]
	and a
	ld b, a
	ld c, $07
	ld a, $68
.asm_319e
	jr z, .asm_31a7
	ld [hli], a
	dec c
	dec b
	jr nz, .asm_319e
	jr .asm_31ad
.asm_31a7
	ld a, $67
.asm_31a9
	ld [hli], a
	dec c
	jr nz, .asm_31a9
.asm_31ad
	hlbgcoord 10, 1, vBGMap1
	ld de, sa000Unk84
	ld a, [de]
	ld d, $70
	ld e, a
	swap a
	and $0f
	add d
	ld [hli], a
	ld a, e
	and $0f
	add d
	ld [hl], a

	hlbgcoord 15, 1, vBGMap1
	ld a, [wLevel]
	inc a ; +1
	ld e, $70
	add e
	ld [hl], a

	ld bc, vTiles2 tile $69
	ld de, wCopyAbility
	ld a, [de]
	swap a
	ld l, a
	and $0f
	ld h, a
	ld a, l
	and $f0
	ld l, a
	sla l
	rl h
	sla l
	rl h
	; hl = wCopyAbility * (4 tiles)
	ldh a, [hROMBank]
	push af
	ld a, BANK(CopyAbilityIconsGfx)
	call Bankswitch
	ld de, CopyAbilityIconsGfx
	add hl, de
	ld d, 4 tiles
.loop_copy
	ld a, [hli]
	ld [bc], a
	inc c
	dec d
	jr nz, .loop_copy
	pop af
	jp Bankswitch

MACRO data_31fe
	dbw \1, \2
	dw \3
ENDM

Data_31fe:
	data_31fe $0f, $4a64, $ff
	data_31fe $0f, $4ca9, $4ee9
	data_31fe $0f, $50b5, $531c
	data_31fe $0f, $55a7, $58b1

Func_3212::
	ld a, $01
	ld [wdf03], a
	ld a, $e4
	ld [wcd09], a
	ld a, $d0
	ld [wcd0a], a
	ld a, $90
	ld [wcd0b], a
	call Func_33cb

	ld e, MUSIC_15
	farcall PlayMusic

	ld a, $0f
	call Bankswitch
	ld hl, $4983
	ld de, vTiles0
	call Decompress

	ld bc, Data_31fe
	ld a, [sa000Unk71]
	ld d, a
	add a
	add a
	add d ; *5
	add c
	ld c, a
	incc b
	ld a, [bc]
	inc bc
	push bc
	call Bankswitch
	pop bc
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
	push bc
	ld de, vTiles0 tile $20
	call Decompress

	ld a, [sa000Unk71]
	and a
	pop bc
	jr z, .asm_3276
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	ld de, vTiles1 tile $60
	call Decompress
.asm_3276
	homecall Func_20000

	ld a, $92
	ld [wdb5e], a

	ld bc, 96
	ld de, 576
	ld a, UNK_OBJ_CE
	lb hl, HIGH(sObjectGroup1), HIGH(sObjectGroup1End)
	call CreateObject

	ld a, $0a
	ld [wdb58], a
	call Bankswitch
	ld hl, $781c
	call Func_1289

	homecall Func_1c1dc

	ld a, LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16 | LCDC_WIN_ON | LCDC_WIN_9C00
	ldh [rLCDC], a

	call Func_46d
	ld e, $04
	farcall Func_6824e
.asm_32b8
	call Func_496
	call UpdateObjects

	homecall Func_1c259

	homecall Func_1c3cb

	call Func_4ae
	farcall UpdateHUD
	farcall Func_1dbd2
	call DoFrame
	ld hl, wdd2d
	ld a, [hl]
	and a
	jr nz, .asm_32f1
	ld a, [wda46]
	and a
	jr nz, .asm_32b8
.asm_32f1
	ld e, $04
	farcall Func_68280
	call Func_437
	ret

Func_32ff::
	ld a, $ff
	ldh [rLYC], a
	ld [wLYC], a

	ld a, $00
	ld [wdf03], a
	ld a, $e4
	ld [wcd09], a
	ld a, $e0
	ld [wcd0a], a
	ld a, $e4
	ld [wcd0b], a
	call Func_33cb

	ld e, MUSIC_LEVEL_SELECT
	farcall PlayMusic

	ld a, LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16 | LCDC_WIN_9C00
	ldh [rLCDC], a

	ld a, $0f
	call Bankswitch
	ld hl, $4000
	ld de, vTiles0
	call Decompress

	homecall Func_20000

	ld a, BANK(LevelSelectionCoordinates)
	call Bankswitch
	ld hl, LevelSelectionCoordinates
	ld a, [wLevel]
	add a
	add a ; *4
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld a, UNK_OBJ_9A
	lb hl, HIGH(sObjectGroup1), HIGH(sObjectGroup1End)
	call CreateObject
	call Func_34cc
	call Func_33d5
	call Func_3467
	call Func_3492

	homecall Func_1c1dc

	call Func_46d

	ld a, [wLevel]
	ld e, a
	farcall Func_7a011

	ld a, [wLevel]
	add $1b
	ld d, a
	ld e, $04
	farcall Func_68246

.asm_3396
	call Func_496
	call UpdateObjects

	homecall Func_1c259

	call Func_4ae
	call DoFrame
	ld hl, wdd2d
	ld a, [hl]
	and a
	jr nz, .asm_33b7
	ld a, [wda46]
	and a
	jr nz, .asm_3396
.asm_33b7
	ld a, [wLevel]
	add $1b
	ld d, a
	ld e, $04
	farcall Func_6827b
	call Func_437
	ret

Func_33cb:
	ld hl, wdd2d
	xor a
	ld [hl], a
	ld hl, hJoypad1Down
	ld [hl], a
	ret

Func_33d5:
	call Func_34a3
	ld a, [hli]
	ld [wdb3d], a
	ld c, a
	ld a, [hli]
	ld [wdb3e], a

	push hl
	ld b, a
	ld hl, wcd2d
	ld a, $b3
	jr .asm_33eb
.asm_33ea
	add c
.asm_33eb
	ld [hli], a
	dec b
	jr nz, .asm_33ea
	pop hl
	ld c, $04
	ld de, wdb45
.asm_33f5
	ld a, [hli]
	swap a
	ld b, a
	and $f0
	ld [de], a
	inc de
	ld a, b
	and $0f
	ld [de], a
	inc de
	dec c
	jr nz, .asm_33f5
	push hl
	ld bc, $a
	add hl, bc
	ld de, sb300
	call Decompress
	pop hl
	inc hl
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch
	ld bc, $3
	add hl, bc
	push hl
	ld a, [hli]
	ld [wdb5c], a
	ld de, wcf00
	call Decompress
	ld c, $05
	ld hl, wcf00
	ld de, wc500
.asm_3433
	ld a, [wdb5c]
	ld b, a
.asm_3437
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, .asm_3437
	ld e, $00
	inc d
	dec c
	jr nz, .asm_3433
	pop hl
	dec hl
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, b
	call Bankswitch
	inc hl
	xor a
	ld [wdb59], a
	ld a, [wdf03]
	and a
	jr nz, .asm_3460
	ld de, vTiles1
	call Decompress
	ret
.asm_3460
	ld de, vTiles2
	call Decompress
	ret

Func_3467:
	ld de, sa000XPos + 1
	ld hl, wdb51
	ld a, [de]
	inc e
	sub $50
	ld [hli], a
	ld a, [de]
	inc e
	sbc $00
	ld [hli], a
	xor a
	ld [hli], a
	ld [hl], a
	jp Func_1513
; 0x347d

SECTION "Func_3492", ROM0[$3492]

Func_3492:
	ld hl, wdb51
	ld a, [hli]
	and $f0
	ld [wdb55], a
	inc hl
	ld a, [hl]
	and $f0
	ld [wdb56], a
	ret

Func_34a3:
	ld a, $0f
	call Bankswitch
	ld a, [wdb6a]
	and $7f
	ld b, $00
.asm_34af
	srl a
	jr nc, .asm_34b6
	inc b
	jr .asm_34af
.asm_34b6
	ld a, b
	add a
	add b
	ld hl, $612d
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld h, b
	ld l, c
	call Bankswitch
	ret

Func_34cc:
	ld a, [wdd63]
	ld b, a
	ld a, $00
.asm_34d2
	ld hl, LevelSelectionCoordinates
	rr b
	call c, .Func_34e0
	inc a
	cp $07
	ret z
	jr .asm_34d2

.Func_34e0:
	push bc
	push af
	add a
	add a
	add l
	ld l, a
	incc h
	ld a, [hli] ; x pos
	ld c, a     ;
	ld a, [hli] ;
	ld b, a     ;
	ld a, [hli] ; y pos
	ld e, a     ;
	ld a, [hl]  ;
	ld d, a     ;
	ld a, UNK_OBJ_9D
	ld h, HIGH(sObjectGroup4)
	ld l, HIGH(sObjectGroup4End)
	call CreateObject
	pop af
	pop bc
	ret
; 0x34fd

SECTION "Data_359a", ROM0[$359a]

Func_359a::
	ld hl, hffb4
	ldh a, [hJoypad1Pressed]
	or [hl]
	ld [hl], a
	ret

Func_35a2::
	xor a
	ldh [hffb4], a
	ret
; 0x35a6

SECTION "Func_3602", ROM0[$3602]

Func_3602::
	ldh a, [hJoypad1Down]
	and PAD_RIGHT | PAD_LEFT
	jr z, .skip
	bit B_PAD_RIGHT, a
	ld a, $40 ; for d-right
	jr nz, .got_val
	ld a, $c0 ; for d-left
.got_val
	ld e, OBJSTRUCT_UNK45
	ld [de], a
.skip
	ret

Func_3614::
	ld e, OBJSTRUCT_UNK7D
	ld a, [de]
	rra
	ret

Func_3619::
	ld a, [wda36]
	or a
	jr nz, .no_carry
	ldh a, [hJoypad1Down]
	and PAD_UP
	jr z, .no_carry
	scf
	ret
.no_carry
	and a
	ret
; 0x3629

SECTION "Script_3650", ROM0[$3650]

Func_3650::
	ldh a, [hffb4]
	and PAD_B
	jr z, .asm_3664
	ld hl, sa500 + OBJSTRUCT_UNK00
.loop_objs
	ld a, [hl]
	cp $ff
	jr z, .set_carry
	inc h
	ld a, h
	cp HIGH(sObjectGroup3End)
	jr nz, .loop_objs
.asm_3664
	call Func_35a2
	and a
	ret
.set_carry
	scf
	ret
; 0x366b

SECTION "Script_369d", ROM0[$369d]

Func_369d::
	ldh a, [hJoypad1Down]
	and PAD_DOWN
	jr nz, .asm_36a5
	and a
	ret
.asm_36a5
	ld h, d
	ld e, $4d
	ld a, [de]
	cp $02
	jr nz, .asm_36e4
	ldh a, [hffaf]
	inc a
	ld e, a
	rla
	sbc a
	ld d, a
	ldh a, [hffb1]
	ld c, a
	rla
	sbc a
	ld b, a
	call ApplyOffsetToObjectPosition
	call Func_184e
	jr nc, .asm_36c8
	ldh a, [hff9e]
	cp $02
	jr nz, .asm_36e1
.asm_36c8
	ldh a, [hffb3]
	ld l, a
	rla
	sbc a
	ld h, a
	add hl, bc
	ld b, h
	ld c, l
	call Func_184e
	jr nc, .asm_36dc
	ldh a, [hff9e]
	cp $02
	jr nz, .asm_36e1
.asm_36dc
	ldh a, [hff9a]
	ld d, a
	scf
	ret
.asm_36e1
	ldh a, [hff9a]
	ld d, a
.asm_36e4
	and a
	ret

Func_36e6::
	ldh a, [hJoypad1Down]
	and PAD_UP
	jr nz, .asm_36ee
	and a
	ret
.asm_36ee
	ld h, d
	ld l, OBJSTRUCT_X_POS + 1
	ld c, [hl]
	inc l
	ld b, [hl]
	ld l, OBJSTRUCT_Y_POS + 1
	ld e, [hl]
	inc l
	ld d, [hl]
	call Func_1646
	cp $10
	jr z, .asm_3716
	cp $90
	jr z, .asm_3716
	cp $18
	jr z, .asm_370d
.asm_3708
	and a
	ldh a, [hff9a]
	ld d, a
	ret
.asm_370d
	ld a, [wLevel]
	call Func_1611
	or a
	jr nz, .asm_3708
.asm_3716
	ld a, [wcd4d]
	or a
	jr nz, .asm_3708
	call Func_1067
	scf
	ldh a, [hff9a]
	ld d, a
	ret

Func_3724::
	ldh a, [hJoypad1Pressed]
	and PAD_SELECT
	jr nz, .asm_372c
	and a
	ret
.asm_372c
	ld e, SFX_28
	farcall PlaySFX
	ldh a, [hff9a]
	ld d, a
	scf
	ret
; 0x373b

SECTION "Script_3765", ROM0[$3765]

Func_3765::
	ld a, [sa000Unk70]
	or a
	jr nz, .no_carry
	call Func_1ab3
	jr nz, .no_carry
	ld e, 0.0
	ld bc, 1.25
	call ApplyDownwardsAcceleration
	scf
	ret
.no_carry
	and a
	ret
; 0x377c

SECTION "Script_37f4", ROM0[$37f4]

Func_37f4::
	call Func_846
Func_37f7::
	ld a, $08
	call Bankswitch
	jp $7358 ; Func_23358
; 0x37ff

SECTION "Func_3894", ROM0[$3894]

; input:
; - h  = acceleration
; - l  = deceleration
; - bc = max velocity
Func_3894::
	ldh a, [hJoypad1Down]
	and PAD_RIGHT | PAD_LEFT
	jr z, .decelerate
	bit B_PAD_RIGHT, a
	ld e, OBJSTRUCT_UNK45
	jr z, .d_left
; d-right
	ld a, $40
	ld [de], a ; OBJSTRUCT_UNK45
	ld e, h ; acceleration
	jp ApplyRightAcceleration_WithDampening
.d_left
	ld a, $c0
	ld [de], a ; OBJSTRUCT_UNK45
	ld e, h ; acceleration
	ld a, c
	cpl
	add 1
	ld c, a
	ld a, b
	cpl
	adc 0
	ld b, a
	; bc = -bc
	jp ApplyLeftAcceleration_WithDampening

.decelerate
	ld e, l
	jp DecelerateObjectX
; 0x38bc

SECTION "Script_391a", ROM0[$391a]

Func_391a::
	call Func_b6df
	jr Func_3927
Func_391f::
	call Func_1dc7
	jr Func_3927
Func_3924::
	call Func_1d8b
Func_3927:
	jr nc, .no_carry
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	ld b, a
	ld e, OBJSTRUCT_X_VEL + 1
	ld a, [de]
	xor b
	rla
	jr c, .set_carry
	; zero x velocity
	ld e, OBJSTRUCT_X_VEL
	xor a
	ld [de], a
	inc e
	ld [de], a
.set_carry
	scf
	ret
.no_carry
	and a
	ret
; 0x393e

SECTION "Script_3992", ROM0[$3992]

Func_3992::
	call Func_1c88
	jr nc, .no_carry
	ldh a, [hff9f]
	cp $31
	call z, Func_3c63
	ld h, d
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr c, .set_y_vel_zero ; moving upwards
	ld a, [hli]
	sub LOW(0.7)
	ld a, [hl]
	sbc HIGH(0.7)
	jr c, .set_y_vel_zero ; y vel < 0.7
	; y vel >= 0.7
	ld e, OBJSTRUCT_UNK52
	ld a, $02
	ld [de], a
.set_y_vel_zero
	ld e, OBJSTRUCT_Y_VEL
	xor a
	ld [de], a
	inc e
	ld [de], a
	scf
	ret
.no_carry
	and a
	ret
; 0x39bc

SECTION "Func_39c1", ROM0[$39c1]

Func_39c1::
	call Func_1c0a
	jr nc, .no_carry
	ld h, d
	ld l, OBJSTRUCT_Y_VEL + 1
	ld a, [hld]
	rla
	jr nc, .asm_39da ; moving downwards
	ld a, [hli]
	sub LOW(-0.75)
	ld a, [hl]
	sbc HIGH(-0.75)
	jr nc, .asm_39da ; y vel >= -0.75
	; ; y vel < -0.75
	ld a, $01
	ld e, OBJSTRUCT_UNK52
	ld [de], a
.asm_39da
	ldh a, [hff9e]
	cp $01
	jr z, .set_y_vel_zero
	ld e, OBJSTRUCT_X_VEL
	xor a
	ld [de], a
	inc e
	ld [de], a
.set_y_vel_zero
	xor a
	ld e, OBJSTRUCT_Y_VEL
	ld [de], a
	inc e
	ld [de], a
	scf
	ret
.no_carry
	and a
	ret
; 0x39f0

SECTION "Script_3a5c", ROM0[$3a5c]

Script_3a5c::
	set_var_to_field OBJSTRUCT_UNK52
	jump_if_not_var .script_3a6a
	set_field OBJSTRUCT_UNK52, $00
	play_sfx SFX_05
	exec_func_f77 $00
.script_3a6a
	script_ret

; each animal friend has its own y positioning
AdjustAnimalFriendYPosition::
	push bc
	ld a, [sa000Unk71]
	ld hl, .YOffsets
	add l
	ld l, a
	incc h
	ld a, [hl] ; y offset
	ld c, a
	rla
	sbc a
	ld b, a
	ld h, d
	ld l, OBJSTRUCT_Y_POS + 1
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	pop bc
	ret

.YOffsets:
	db  0 ; NONE
	db -4 ; RICK
	db -2 ; KINE
	db -6 ; COO
; 0x3a8b

SECTION "Func_3aaa", ROM0[$3aaa]

; input:
; - a = ?
; - hl = ?
Func_3aaa::
	ld [sa000Unk62], a
	ld a, [hli]
	ld [sa000Unk5d], a
	ld e, OBJSTRUCT_UNK45
	ld a, [de]
	rla
	ld a, [hli]
	jr nc, .asm_3aba
	cpl
	inc a
.asm_3aba
	ld c, a
	rla
	sbc a
	ld b, a
	ld e, OBJSTRUCT_X_POS + 1
	ld a, [de]
	inc e
	add c
	ld [sa000Unk5e], a
	ld a, [de]
	adc b
	ld [sa000Unk5f], a
	ld a, [hli]
	ld c, a
	rla
	sbc a
	ld b, a
	ld e, OBJSTRUCT_Y_POS + 1
	ld a, [de]
	inc e
	add c
	ld [sa000Unk60], a
	ld a, [de]
	adc b
	ld [sa000Unk61], a
	ld a, [hli]
	ldh [hffa2], a
	ld a, [hl]
	ldh [hffa3], a
	ret
; 0x3ae4

SECTION "Func_3ae9", ROM0[$3ae9]

Func_3ae9::
	ld a, $ff
	ld [wdf15], a
	ld a, [sa000Unk5d]
	inc a
	jr nz, .asm_3af6
	and a
	ret
.asm_3af6
	xor a
	ld [wdf0b], a
	ld hl, hffa3
	ld e, $60
	ld a, [de]
	sub [hl]
	ld c, a
	inc e
	ld a, [de]
	sbc $00
	ld b, a
	ld a, c
	and $f0
	ld c, a
	push bc
	dec e
	ld a, [de]
	add [hl]
	sub c
	swap a
	and $0f
	inc a
	ld [wdf0e], a
	dec l
	ld e, $5e
	ld a, [de]
	sub [hl]
	ld [wdf0f], a
	ld c, a
	inc e
	ld a, [de]
	sbc $00
	ld [wdf10], a
	ld b, a
	ld a, c
	and $f0
	ld c, a
	dec e
	ld a, [de]
	add [hl]
	sub c
	swap a
	and $0f
	inc a
	ld [wdf0c], a
	ld [wdf0d], a
	pop de
	jr .asm_3b5b
.asm_3b3f
	ld hl, wdf0f
	ld a, [hli]
	ld c, a
	ld b, [hl]
	ld a, [wdf0c]
	ld [wdf0d], a
	ld a, e
	add $10
	ld e, a
	incc d
	jr .asm_3b5b
.asm_3b54
	ld a, c
	add $10
	ld c, a
	incc b
.asm_3b5b
	call Func_3b8f
	jr nc, .asm_3b65
	ld a, $01
	ld [wdf0b], a
.asm_3b65
	ld a, [wdf0d]
	dec a
	ld [wdf0d], a
	jr nz, .asm_3b54
	ld a, [wdf0e]
	dec a
	ld [wdf0e], a
	jr nz, .asm_3b3f
	ld a, [wdf0b]
	or a
	jr nz, .asm_3b82
	ldh a, [hff9a]
	ld d, a
	and a
	ret
.asm_3b82
	ldh a, [hff9a]
	ld d, a
	call Func_2871
	ld e, $0f
	call Func_f7a
	scf
	ret

Func_3b8f:
	call Func_1646
	ld [wdf13], a
	ld h, a
	and $07
	cp $01
	jr nz, .asm_3bf2
	ld a, h
	cp $21
	jr z, .asm_3bcd
	cp $29
	jr nz, .asm_3bad
	ld a, [wdf15]
	inc a
	jr z, .asm_3bf2
	jr .asm_3bcd
.asm_3bad
	cp $41
	jr c, .asm_3bf2
	cp $79
	jr nc, .asm_3bf2
	rra
	rra
	rra
	and $1f
	sub $08
	push hl
	ld hl, $3bf4
	add l
	ld l, a
	incc h
	ld h, [hl]
	ld a, [wdf15]
	cp h
	pop hl
	jr nz, .asm_3bf2
.asm_3bcd
	push bc
	push de
	ld a, l
	ldh [hff80], a
	call Func_3c02
	ldh a, [hff80]
	inc a
	call Func_15a8
	ld a, [wdf13]
	cp $71
	ld e, SFX_19
	jr nz, .asm_3be6
	ld e, SFX_53
.asm_3be6
	farcall PlaySFX
	pop de
	pop bc
	scf
	ret
.asm_3bf2
	and a
	ret
; 0x3bf4

SECTION "Func_3c02", ROM0[$3c02]

Func_3c02:
	call Func_3c0e
	ret z
	ld [hl], $05
	ret
; 0x3c09

SECTION "Func_3c0e", ROM0[$3c0e]

Func_3c0e:
	ld hl, sa200Unka5
	push bc
	push de
	ld a, e
	and $f0
	or $08
	ld e, a
	ld a, c
	and $f0
	or $08
	ld c, a
	ld a, UNK_OBJ_01
	call CreateObject
	ld a, h
	or a
	ld l, OBJSTRUCT_UNK51
	pop de
	pop bc
	ret
; 0x3c2b

SECTION "Func_3c63", ROM0[$3c63]

Func_3c63::
	ld b, $08
	ld hl, wcd56
.asm_3c68
	ld a, [hli]
	or a
	jr z, .asm_3c72
	inc l
	inc l
	dec b
	jr nz, .asm_3c68
	ret
.asm_3c72
	dec l
	ld [hl], $20
	inc l
	ldh a, [hff9c]
	ld c, a
	ld [hli], a
	ldh a, [hff9d]
	ld b, a
	ld [hl], a
	ld a, [bc]
	inc a
	ld [bc], a
	ldh [hff84], a
	ld e, c
	swap c
	call Func_15b0
	ld hl, wdf12
	inc [hl]
	ldh a, [hff9a]
	ld d, a
	and a
	ret
; 0x3c92

SECTION "Data_3f00", ROM0[$3f00], ALIGN[8]

Data_3f00::
	table_width 2
	dw Func_8fa ; SCRIPT_END_CMD
	dw Func_920 ; SET_FRAME_CMD
	dw $959 ; UNK02_CMD
	dw Func_96c ; UNK03_CMD
	dw Func_988 ; SET_OAM_CMD
	dw Func_90a ; WAIT_CMD
	dw Func_997 ; JUMP_CMD
	dw Func_a0c ; SET_X_VEL_CMD
	dw Func_a18 ; SET_Y_VEL_CMD
	dw Func_a41 ; REPEAT_CMD
	dw Func_a56 ; REPEAT_END_CMD
	dw Func_a6f ; CALL_CMD
	dw Func_ab4 ; RET_CMD
	dw Func_ae3 ; EXEC_ASM_CMD
	dw Func_b1f ; VAR_JUMPTABLE_CMD
	dw Func_937 ; SET_FIELD_CMD
	dw Func_940 ; SET_VAR_TO_FIELD_CMD
	dw Func_9ba ; JUMP_IF_NOT_VAR_CMD
	dw Func_9ce ; JUMP_IF_VAR_CMD
	dw $9e2 ; UNK13_CMD
	dw Func_9f7 ; JUMP_IF_VAR_LT_CMD
	dw Func_914 ; WAIT_VAR_CMD
	dw Func_8f1 ; SCRIPT_STOP_CMD
	dw Func_97c ; SET_DRAW_FUNC_CMD
	dw $a24 ; UNK18_CMD
	dw Func_928 ; SET_FRAME_WAIT_CMD
	dw Func_94a ; SET_FIELD_TO_VAR_CMD
	dw Func_9a0 ; FAR_JUMP_CMD
	dw $a86 ; UNK1C_CMD
	dw $ac4 ; UNK1D_CMD
	dw $b3e ; UNK1E_CMD
	dw $aef ; UNK1F_CMD
	dw Func_b74 ; SET_X_CMD
	dw Func_b84 ; SET_Y_CMD
	dw $955 ; UNK22_CMD
	dw $968 ; UNK23_CMD
	dw Func_b01 ; PLAY_SFX_CMD
	dw $b07 ; UNK25_CMD
	dw $b0d ; UNK26_CMD
	dw $b13 ; UNK27_CMD
	dw $b19 ; UNK28_CMD
	dw $a31 ; UNK29_CMD
	dw Func_a39 ; SET_Y_ACC_CMD
	assert_table_length NUM_CMDS

NoteFrequencies:
	bigdw  $3b ;   65.9 Hz ; C_0
	bigdw  $aa ;   69.8 Hz ; C#0
	bigdw $112 ;   73.9 Hz ; D_0
	bigdw $175 ;   78.3 Hz ; D#0
	bigdw $1d3 ;   82.9 Hz ; E_0
	bigdw $22b ;   87.8 Hz ; F_0
	bigdw $27e ;   93.0 Hz ; F#0
	bigdw $2cd ;   98.5 Hz ; G_0
	bigdw $317 ;  104.3 Hz ; G#0
	bigdw $35d ;  110.4 Hz ; A_0
	bigdw $3a0 ;  117.0 Hz ; A#0
	bigdw $3de ;  123.9 Hz ; B_0
	bigdw $419 ;  131.2 Hz ; C_1
	bigdw $451 ;  139.0 Hz ; C#1
	bigdw $486 ;  147.3 Hz ; D_1
	bigdw $4b8 ;  156.0 Hz ; D#1
	bigdw $4e7 ;  165.3 Hz ; E_1
	bigdw $513 ;  175.0 Hz ; F_1
	bigdw $53d ;  185.4 Hz ; F#1
	bigdw $564 ;  196.2 Hz ; G_1
	bigdw $58a ;  208.1 Hz ; G#1
	bigdw $5ad ;  220.3 Hz ; A_1
	bigdw $5ce ;  233.2 Hz ; A#1
	bigdw $5ee ;  247.3 Hz ; B_1
	bigdw $60b ;  261.6 Hz ; C_2
	bigdw $627 ;  277.1 Hz ; C#2
	bigdw $642 ;  293.9 Hz ; D_2
	bigdw $65b ;  311.3 Hz ; D#2
	bigdw $672 ;  329.3 Hz ; E_2
	bigdw $689 ;  349.5 Hz ; F_2
	bigdw $69e ;  370.3 Hz ; F#2
	bigdw $6b2 ;  392.4 Hz ; G_2
	bigdw $6c4 ;  414.8 Hz ; G#2
	bigdw $6d6 ;  439.8 Hz ; A_2
	bigdw $6e7 ;  466.4 Hz ; A#2
	bigdw $6f6 ;  492.8 Hz ; B_2
	bigdw $705 ;  522.2 Hz ; C_3
	bigdw $713 ;  553.0 Hz ; C#3
	bigdw $721 ;  587.8 Hz ; D_3
	bigdw $72d ;  621.2 Hz ; D#3
	bigdw $739 ;  658.7 Hz ; E_3
	bigdw $744 ;  697.2 Hz ; F_3
	bigdw $74e ;  736.4 Hz ; F#3
	bigdw $758 ;  780.2 Hz ; G_3
	bigdw $762 ;  829.6 Hz ; G#3
	bigdw $76b ;  879.7 Hz ; A_3
	bigdw $773 ;  929.6 Hz ; A#3
	bigdw $77b ;  985.5 Hz ; B_3
	bigdw $782 ; 1040.3 Hz ; C_4
	bigdw $789 ; 1101.4 Hz ; C#4
	bigdw $790 ; 1170.3 Hz ; D_4
	bigdw $796 ; 1236.5 Hz ; D#4
	bigdw $79c ; 1310.7 Hz ; E_4
	bigdw $7a2 ; 1394.4 Hz ; F_4
	bigdw $7a7 ; 1472.7 Hz ; F#4
	bigdw $7ac ; 1560.4 Hz ; G_4
	bigdw $7b1 ; 1659.1 Hz ; G#4
	bigdw $7b5 ; 1747.6 Hz ; A_4
	bigdw $7b9 ; 1846.1 Hz ; A#4
	bigdw $7bd ; 1956.3 Hz ; B_4
	bigdw $7c1 ; 2080.5 Hz ; C_5
	bigdw $7c4 ; 2184.5 Hz ; C#5
	bigdw $7c8 ; 2340.6 Hz ; D_5
	bigdw $7cb ; 2473.1 Hz ; D#5
	bigdw $7ce ; 2621.4 Hz ; E_5
	bigdw $7d1 ; 2788.8 Hz ; F_5
	bigdw $7d3 ; 2912.7 Hz ; F#5
	bigdw $7d6 ; 3120.8 Hz ; G_5
	bigdw $7d8 ; 3276.8 Hz ; G#5
	bigdw $7da ; 3449.3 Hz ; A_5
	bigdw $7dc ; 3640.9 Hz ; A#5
	bigdw $7de ; 3855.1 Hz ; B_5

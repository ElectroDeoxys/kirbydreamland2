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
	res LCDCB_ON, [hl]

	xor a
	ldh [hRequestLCDOff], a
	jp InterruptRet

.continue_lcd_on
	ld a, [wda0f]
	cp $01
	jp c, .skip_dma_and_scroll ; can be jr
	ld a, HIGH(wVirtualOAM)
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
	ld h, HIGH(wc400)
	ldh a, [hff92]
	ld b, a
	pop af ; wda1e
	reti ; return to wda20

Func_22b::
.asm_22b
	ld a, l
	cp b
	jr z, .asm_23e
.asm_22f
	ld e, [hl]
	inc l
	ld d, [hl]
	inc l
	ld c, [hl]
	inc l
.asm_235
	ld a, [hl]
	ld [de], a
	inc l
	inc de
	dec c
	jr nz, .asm_235
	jr .asm_22b
.asm_23e
	di
	cp b
	jr z, .asm_245
	ei
	jr .asm_22f
.asm_245
	ld h, c
	ld bc, .asm_22b
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
	res LCDCB_OBJON, [hl]
	jr .asm_271
.set_obj_on
	set LCDCB_OBJON, [hl]

.asm_271
	; switch off Stat interrupt flag
	ldh a, [rIF]
	and $ff ^ IEF_STAT
	ldh [rIF], a
	; switch off V-blank interrupts
	ldh a, [rIE]
	and $ff ^ IEF_VBLANK
	ldh [rIE], a
	ei

	; execute wVBlankTrampoline
	call wVBlankTrampoline

	xor a
	ld [wda0f], a
	ld a, $01
	ld [wda0c], a
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
	or IEF_VBLANK
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
	bit LCDCB_WINON, [hl]
	jr z, InterruptRet

	; window is on
	ld b, 15
.loop_wait
	nop
	dec b
	jr nz, .loop_wait

	; disable obj and set default BGP
	res LCDCB_OBJON, [hl]
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
	bit LCDCB_ON, a
	jp z, UpdateAudio ; lcd off
	jp InterruptRet

VBlankHandler_Default::
StatHandler_Default::
	ret

Func_343::
	ld hl, wda0c
.asm_346
	di
	bit 0, [hl]
	jr nz, .asm_34f
	halt
	ei
	jr .asm_346
.asm_34f
	ei
	ld [hl], $00 ; wda0c
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
	ldh a, [rP1]
	ld c, a
	jr .start_read_inputs
.loop_read_joypads
	ldh a, [rP1]
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
	ld a, P1F_GET_DPAD
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	swap a
	and %11110000
	ld d, a

; take the buttons values next
	ld a, P1F_GET_BTN
	ldh [rP1], a
REPT 6
	ldh a, [rP1]
ENDR
	and %1111
	or d
	cpl
	; button bits on lower nybble, d-pad on higher nybble
	call .WriteInput

	ld a, P1F_GET_NONE
	ldh [rP1], a
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
	cp LOW($befe)
	jr nz, .asm_3ca
	ld a, b
	cp HIGH($befe)
	jr nz, .asm_3ca
	; bc = $befe
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
	cp A_BUTTON | B_BUTTON | SELECT | START
	ret nz ; no reset
	; ...and they weren't pressed at the same time
	ldh a, [hJoypad1Pressed]
	cp A_BUTTON | B_BUTTON | SELECT | START
	ret z ; no reset
	; ...and at least one of them was pressed now
	or a
	ret z ; no reset
	; ...do reset
	ld e, $34
	ld hl, $6002
	ld a, $1e
	call Farcall
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
	call Func_343

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
	res IEB_VBLANK, [hl]
	res IEB_STAT, [hl]

	; set Timer to be executed as soon as possible
	ld a, -1
	ldh [rTIMA], a
	; start Timer
	ld a, TACF_START | TACF_4KHZ
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

	xor a ; TACF_STOP
	ldh [rTAC], a
	ld hl, rLCDC
	set LCDCB_ON, [hl]
	ret

Func_496::
	ld a, [wda28]
	ld de, wda23
	rra
	jr nc, .asm_4a0
	inc de ; wda23
.asm_4a0
	xor a
	ld [wda09], a
	ld [wda22], a
	ld [de], a
	ld hl, wda06
	ld [hli], a
	ld [hl], a ; wda07
	ret

Func_4ae::
	ld a, [wda08]
	ld c, a
	ld h, a
	ld de, wda0a
	rra
	jr nc, .asm_4ba
	inc de ; wda0b
.asm_4ba
	ld a, [de]
	ld b, a
	ld a, [wda09]
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
	ld [wda08], a
	ret
; 0x51c

SECTION "FarCopyHLToDE", ROM0[$5bf]

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
Bankswitch:
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

JumpHL:
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

SECTION "Func_647", ROM0[$647]

Func_647::
	push de
	push hl
	ld hl, wda30
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, de ; *5
	ld de, $3711
	add hl, de
	ld a, l
	ld [wda30 + 0], a
	ld a, h
	ld [wda30 + 1], a
	pop hl
	pop de
	ret
; 0x663

SECTION "Func_675", ROM0[$675]

; input:
; - a = ?
; output:
; - carry set if ?
Func_675::
	push de
	add $03
	ld e, a
	ldh a, [hff92]
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
	call $600c
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
; - hl = ?
Func_7c4::
	ldh [hff84], a
	push de
	push bc
	ld b, h
	ld c, l
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
	ld l, $22
	ld [hl], $42
	inc l
	ld [hl], $03
	ld a, $80
	ld l, $03
	ld [hl], a
	ld l, $06
	ld [hl], a
	pop bc
	ld l, $04
	ld [hl], c
	inc l
	ld [hl], b
	pop bc
	ld l, $07
	ld [hl], c
	inc l
	ld [hl], b
	call Func_c06
	ldh a, [hff84]
	ld l, $00
	ld [hl], a
	ld e, a
	ld d, $00
	sla a
	rl d
	add e
	ld e, a
	ld a, $77
	adc d
	ld d, a
	xor a
	ld l, $0d
	ld [hli], a
	ld [hl], a
	ld l, $0f
	ld [hli], a
	ld [hl], a
	ld l, $11
	ld [hli], a
	ld [hl], a
	ld l, $45
	ld [hli], a
	ld [hl], a
	ld l, $4a
	ld [hli], a
	ld [hl], a
	ld a, $ff
	ld l, $15
	ld [hl], a
	ld l, $49
	ld [hl], a
	ld l, $48
	ld [hl], a
	ldh a, [hROMBank]
	ldh [hff84], a
	ld a, $07
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
; 0x846

SECTION "Func_855", ROM0[$855]

; input:
; - hl = ?
Func_855:
	call Func_c2a
	ld l, $19
	ld [hl], e
	inc l
	ld [hl], b
	inc l
	ld [hl], c
	xor a
	ld l, $24
	ld [hl], a
	ld l, $47
	ld [hl], a
	ld l, $28
	ld [hl], $39
	ret

Func_86b::
	ld a, [wda46]
	jr .asm_87f
.asm_870
	ldh [hff9a], a
	ld h, a
	ld l, $01
	ld a, [hl]
	ld [wda49], a
	call .Func_8a1
	ld a, [wda49]
.asm_87f
	or a
	jr nz, .asm_870
	ld a, [wda46]
	jr .asm_89d
.asm_887
	ldh [hff9a], a
	ld d, a
	ld e, $01
	ld a, [de]
	ld [wda49], a
	ld e, $22
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

.Func_8a1:
	ld l, $19
	ld a, $24
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
	cp $26
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
	ld a, [bc]
	inc bc
	add a
	ld h, $3f
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl
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
; 0x8f1

SECTION "Func_b94", ROM0[$b94]

; input:
; - [wda48] = ?
; - bc = ?
; output:
; - carry set if ?
Func_b94:
	ld a, [wda48]
	or a
	jr z, .set_carry
	ld h, a
	ld l, $01
.asm_b9d
	cp b
	jr c, .asm_ba3
	cp c
	jr c, .asm_baa
.asm_ba3
	ld h, a
	ld a, [hl]
	or a
	jr nz, .asm_b9d
.set_carry
	scf
	ret
.asm_baa
	cp h
	jr nz, .asm_bb3
	ld a, [hl]
	ld [wda48], a
	and a
	ret
.asm_bb3
	ld d, h
	ld e, l
	ld h, a
	ld a, [hl]
	ld [de], a
	and a
	ret ; no carry
; 0xbba

SECTION "Func_c06", ROM0[$c06]

Func_c06:
	ld de, wda47
	ld a, [de]
	ld l, $02
	ld [hl], a
	ld l, $01
	ld [hl], $00
	or a
	jr nz, .asm_c1a
	ld a, h
	ld [de], a
	ld [wda46], a
	ret
.asm_c1a
	ld b, h
	ld h, a
	ld [hl], b
	ld a, b
	ld [de], a
	ld h, a
	ld a, [wda49]
	or a
	ret nz
	ld a, h
	ld [wda49], a
	ret

Func_c2a:
	ld l, $1c
	ld [hl], $80
	ld l, $1f
	ld [hl], $80
	ld l, $25
	ld [hl], $00
	inc l
	ld [hl], $00
	ret
; 0xc3a

SECTION "GameLoop", ROM0[$10de]

GameLoop::
	ld a, BANK(_GameLoop)
	call Bankswitch
	jp _GameLoop

Func_10e6::
	ld e, $09
	ld hl, $602e
	ld a, $1e
	call Farcall

	call Func_1126
	call Func_1134

	ld hl, $5b28
	ld a, $07
	call Farcall

	ld hl, wdede
	set 2, [hl]
	set 1, [hl]
	set 3, [hl]
	set 5, [hl]
	set 6, [hl]

	ld a, [sa05b]
	inc a
	ld [wdee0], a
	ld a, [sa071]
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
	ld de, $9630
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
	ld de, $8600
	call Decompress
	ret
; 0x115f

SECTION "Func_1166", ROM0[$1166]

Func_1166::
	ld hl, $747d
	ld a, $02
	call Farcall
	ld a, [sa051]
	cp $0d
	jr nz, .asm_1183
	ld a, $0b
	call Bankswitch
	ld hl, $6980
	ld de, vTiles0
	jp Decompress
.asm_1183
	ld a, $07
	call Bankswitch
	call $7458
	call .Func_1196

	ld a, $07
	call Bankswitch
	call $7472

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
	ld bc, $74bb
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
; 0x11be

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
; 0x1564

SECTION "Func_1584", ROM0[$1584]

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

SECTION "Func_15e3", ROM0[$15e3]

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
; 0x1611

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

	db $1e, $07

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
	ld de, vBGMap0
	push bc
	call Decompress

	ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
	ldh [rLCDC], a

	call Func_46d
	ld a, BANK(Func_20000)
	call Bankswitch
	call Func_20000
	pop bc
	ld a, [bc]
	ld h, $a0
	ld l, $b3
	ld b, $00
	ld c, b
	ld d, c
	ld e, d
	call Func_7c4
	pop de
	farcall Func_7a011

	ld a, [wdd2e]
	add $03
	ld d, a
	ld e, $04
	ld hl, $4246
	ld a, $1a
	call Farcall

.asm_2ac4
	call Func_496
	call Func_86b
	call Func_4ae
	call Func_343
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
	ld hl, $427b
	ld a, $1a
	call Farcall
	call Func_437
	ld hl, $5ada
	ld a, $07
	call Farcall
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

SECTION "_UpdateAudio", ROM0[$2b97]

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

SECTION "Func_32ff", ROM0[$32ff]

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

	ld a, LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WIN9C00
	ldh [rLCDC], a

	ld a, $0f
	call Bankswitch
	ld hl, $4000
	ld de, vTiles0
	call Decompress

	ld a, BANK(Func_20000)
	call Bankswitch
	call Func_20000

	ld a, $0f
	call Bankswitch
	ld hl, $6111
	ld a, [wdb60]
	add a
	add a
	add l
	ld l, a
	jr nc, .asm_3353
	inc h
.asm_3353
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld a, $9a
	ld hl, sa0a1
	call Func_7c4
	call Func_34cc
	call Func_33d5
	call Func_3467
	call Func_3492

	ld a, BANK(Func_1c1dc)
	call Bankswitch
	call Func_1c1dc

	call Func_46d

	ld a, [wdb60]
	ld e, a
	farcall Func_7a011

	ld a, [wdb60]
	add $1b
	ld d, a
	ld e, $04
	farcall Func_68246

.asm_3396
	call Func_496
	call Func_86b

	ld a, BANK(Func_1c259)
	call Bankswitch
	call Func_1c259

	call Func_4ae
	call Func_343
	ld hl, wdd2d
	ld a, [hl]
	and a
	jr nz, .asm_33b7
	ld a, [wda46]
	and a
	jr nz, .asm_3396
.asm_33b7
	ld a, [wdb60]
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
	ld de, sa004
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
	jr nc, .asm_34c1
	inc h
.asm_34c1
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
	ld hl, $6111
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
	jr nc, .asm_34e9
	inc h
.asm_34e9
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld a, $9d
	ld h, $a8
	ld l, $b2
	call Func_7c4
	pop af
	pop bc
	ret
; 0x34fd

SECTION "NoteFrequencies", ROM0[$3f56]

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

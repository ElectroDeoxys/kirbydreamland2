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
	ld a, [$da0f]
	cp $01
	jp c, .skip_dma_and_scroll ; can be jr
	ld a, HIGH(wVirtualOAM)
	jr z, .got_virtual_oam
	inc a ; $c1
.got_virtual_oam
	ldh [hTransferVirtualOAM + $1], a
	call hTransferVirtualOAM

	ld a, [$da0f]
	dec a
	ld hl, $da02
	jr z, .asm_18d
	ld hl, $da04
.asm_18d
	ld a, [hli]
	ldh [rSCY], a
	ld a, [hl]
	ldh [rSCX], a

.skip_dma_and_scroll
	ld hl, wBGP
	ld c, LOW(rBGP)
	ld a, [hli]     ; wBGP
	ld [$ff00+c], a ; rBGP
	inc c
	ld a, [hli]     ; wOBP0
	ld [$ff00+c], a ; rOBP0
	inc c
	ld a, [hl]      ; wOBP1
	ld [$ff00+c], a ; rOBP1

	ld a, [$da27]
	or a
	jp z, .asm_210
	ld [$da25], sp
	ld de, $1f
	bit 2, a
	jr z, .asm_1dd
	bit 0, a
	jr z, .asm_1c8
	ld a, [$da23]
	ld sp, $c200
.asm_1bb
	pop hl ; $c200
	pop bc ; $c202
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
	ld a, [$da24]
	ld sp, $c300
.asm_1ce
	pop hl ; $c300
	pop bc ; $c302
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
	ld a, [$da24]
	ld sp, $c300
.asm_1e7
	pop hl ; $c300
	pop bc ; $c302
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
	ld a, [$da23]
	ld sp, $c200
.asm_1fa
	pop hl ; $c200
	pop bc ; $c202
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
	ld sp, $da25
	pop hl
	ld sp, hl
	xor a
	ld [$da27], a

.asm_210
	xor a
	ldh [rLYC], a
	ld hl, $da14
	ld a, $a4
	ld [hli], a
	ld [hl], $02
	ld [$da18], sp
	ld sp, $da1a
	pop de ; $da1a
	pop hl ; wda1c
	ld c, h
	ld h, $c4
	ldh a, [$ff92]
	ld b, a
	pop af
	reti
; 0x22b

SECTION "UpdateAudio", ROM0[$28a]

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
; 0x2a4

SECTION "_Timer", ROM0[$333]

_Timer:
	ld a, TRUE
	ld [wTimerExecuted], a
	ldh a, [rLCDC]
	bit LCDCB_ON, a
	jp z, UpdateAudio ; lcd off
	jp InterruptRet

StatHandler_Default::
	ret

Func_343::
	ld hl, $da0c
.asm_346
	di
	bit 0, [hl]
	jr nz, .asm_34f
	halt
	ei
	jr .asm_346
.asm_34f
	ei
	ld [hl], $00
	ld hl, $da0e
	inc [hl]
	ret

ReadJoypad::
	ld a, [wJoypad1Down]
	ldh [$ff84], a
	ld a, [wSGBEnabled]
	or a
	jr nz, .read_sgb_input
; only read GB input
	ld b, 1
	ld hl, wJoypad1
	jr .got_joypad_struct
.read_sgb_input
	ld a, [$da38]
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
	ld a, [wda3a]
	or a
	jp z, .asm_3f8
	ld hl, wda3c
	ld a, [hli]
	ld b, [hl]
	ld c, a
	cp $fe
	jr nz, .asm_3ca
	ld a, b
	cp $be
	jr nz, .asm_3ca
	dec bc
	dec bc
.asm_3ca
	; useless comparison
	ld a, [wda3a]
	cp $02
	jr z, .asm_3d1
.asm_3d1
	ld a, [wda3b]
	dec a
	jr nz, .asm_3e2
	inc bc
	inc bc
	inc bc
	ld a, [bc]
	dec bc
	ld hl, wda3c
	ld [hl], c
	inc hl
	ld [hl], b
.asm_3e2
	ld [wda3b], a
	ldh a, [hJoypad1Down]
	ld e, a
	ld a, [bc]
	ld hl, $ffa5
	call .WriteInput
	ld b, $04
	ld hl, wJoypad2
	ld c, LOW(hJoypad2)
	jr .asm_3ff

.asm_3f8
	ld b, $08
	ld hl, wJoypad1
	ld c, LOW(hJoypad1)
.asm_3ff
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	dec b
	jr nz, .asm_3ff

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

	ld d, $01
	ld hl, $5feb
	ld a, $1e
	call Farcall

	ld hl, $5dff
	ld a, $1e
	call Farcall
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
	ld a, $ff
	ldh [rTIMA], a
	ld a, TACF_START
	ldh [rTAC], a
	ei
	ret

Func_46d::
	call StopTimerAndTurnLCDOn
	ld hl, $5dff
	ld a, $1e
	call Farcall
	ld d, $00
	ld hl, $5feb
	ld a, $1e
	call Farcall
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
	ld a, [$da28]
	ld de, $da23
	rra
	jr nc, .asm_4a0
	inc de
.asm_4a0
	xor a
	ld [$da09], a
	ld [$da22], a
	ld [de], a
	ld hl, $da06
	ld [hli], a
	ld [hl], a
	ret

Func_4ae::
	ld a, [$da08]
	ld c, a
	ld h, a
	ld de, $da0a
	rra
	jr nc, .asm_4ba
	inc de
.asm_4ba
	ld a, [de]
	ld b, a
	ld a, [$da09]
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
	ld hl, $da02
	jr nc, .asm_4d4
	ld hl, $da04
.asm_4d4
	ld a, [$da00]
	ld b, a
	ld a, [$da06]
	add b
	ld [hli], a
	ld a, [$da01]
	ld b, a
	ld a, [$da07]
	add b
	ld [hli], a
	ld a, [$da28]
	ld b, a
	ld de, $da23
	rra
	jr nc, .asm_4f1
	inc de
.asm_4f1
	ld a, [de]
	or a
	jr z, .asm_50e
	bit 0, b
	ld hl, $da27
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
	ld [$da28], a
.asm_50e
	ld a, c
	and $01
	inc a
	ld [$da0f], a
	ld a, c
	xor $01
	ld [$da08], a
	ret
; 0x51c

SECTION "FarCopyHLToDE", ROM0[$5bf]

; input:
; - a:hl = source
; - de = destination
; - bc = number of bytes
FarCopyHLToDE::
	ldh [$ff96], a
	ldh a, [hROMBank]
	push af
	ldh a, [$ff96]
	call Bankswitch
	call CopyHLToDE
	pop af
	jr Bankswitch

; input:
; - a:hl = bank/address to call
Farcall::
	ldh [$ff96], a
	ldh a, [hROMBank]
	push af
	ldh a, [$ff96]
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
	ldh [$ff96], a
	ldh a, [hROMBank]
	push af
	ldh a, [$ff96]
	call UnsafeBankswitch
	call JumpHL
	pop af
;	fallthrough

UnsafeBankswitch::
	ld [rROMB0 + $100], a
	ldh [hROMBank], a
	ret

Func_5f9::
	di
	ld a, l
	ld [$da11], a
	ld a, h
	ld [$da12], a
	ei
	ret

Func_604::
	ld a, l
	ld [$da11], a
	ld a, h
	ld [$da12], a
	ret

; input:
; - c = bank
; - hl = source address
; - de = destination address
FarDecompress::
	ldh [$ff96], a
	ldh a, [hROMBank]
	push af
	ldh a, [$ff96]
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

SECTION "Decompress", ROM0[$708]

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

Func_7c4::
	ldh [$ff84], a
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
	ld [$da4a], a
	ret
.asm_7d8
	ld a, h
	ld [$da4a], a
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
	ldh a, [$ff84]
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
	ldh [$ff84], a
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
	ldh a, [$ff84]
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
; 0x86b

SECTION "Func_b94", ROM0[$b94]

Func_b94:
	ld a, [$da48]
	or a
	jr z, .asm_ba8
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
.asm_ba8
	scf
	ret
.asm_baa
	cp h
	jr nz, .asm_bb3
	ld a, [hl]
	ld [$da48], a
	and a
	ret
.asm_bb3
	ld d, h
	ld e, l
	ld h, a
	ld a, [hl]
	ld [de], a
	and a
	ret
; 0xbba

SECTION "Func_c06", ROM0[$c06]

Func_c06:
	ld de, $da47
	ld a, [de]
	ld l, $02
	ld [hl], a
	ld l, $01
	ld [hl], $00
	or a
	jr nz, .asm_c1a
	ld a, h
	ld [de], a
	ld [$da46], a
	ret
.asm_c1a
	ld b, h
	ld h, a
	ld [hl], b
	ld a, b
	ld [de], a
	ld h, a
	ld a, [$da49]
	or a
	ret nz
	ld a, h
	ld [$da49], a
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
; 0x10e6

SECTION "Func_1584", ROM0[$1584]

Func_1584::
	xor a
	ld hl, rSCY
	ld [hli], a
	ld [hl], a ; rSCX
	ld hl, $da00
	ld [hli], a
	ld [hl], a
	ld hl, $db51
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret
; 0x1597

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

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
	pop hl ; $da1c
	ld c, h
	ld h, $c4
	ldh a, [$ff92]
	ld b, a
	pop af
	reti
; 0x22b

SECTION "Func_28a", ROM0[$28a]

Func_28a:
	ldh a, [hROMBank]
	push af
	ld a, $0 ; BANK(Func_2bfd) ; useless bankswitch to $0
	call UnsafeBankswitch
	call Func_2bfd
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
	ld a, $01
	ld [$da0d], a
	ldh a, [rLCDC]
	bit LCDCB_ON, a
	jp z, Func_28a ; lcd off
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
	ld a, [$deed]
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
	call Func_483
	ld hl, $5dff
	ld a, $1e
	call Farcall
	ld d, $00
	ld hl, $5feb
	ld a, $1e
	call Farcall
	ret

Func_483:
	ld hl, $da0d
	ld [hl], $00
.wait_timer
	halt
	bit 0, [hl]
	jr z, .wait_timer
	xor a
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
	ld h, $d9
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

SECTION "Func_293e", ROM0[$293e]

Func_293e:
	push af
	xor a
	ldh [$ff87], a
	push de
	push hl
	ld a, b
	cp c
	jr nc, .asm_294a
	ld b, c
	ld c, a
.asm_294a
	ld h, $d7
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
	ld d, $d8
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
	ldh a, [$ff87]
	rlca
	jr nc, .asm_2984
	ld a, c
	cpl
	add $01
	ld c, a
	ld a, b
	cpl
	adc $00
	ld b, a
.asm_2984
	pop hl
	pop de
	pop af
	ret
; 0x2988

SECTION "Func_2bfd", ROM0[$2bfd]

Func_2bfd:
	ld a, $1f
	call UnsafeBankswitch
	ld b, $07
.loop
	ld h, $ce
	ld a, $52
	add b
	ld l, a
	ld a, [hl]
	and a
	jr z, .asm_2c48
	ld a, b
	cp $04
	ld a, $1a
	jr c, .asm_2c17
	ld a, $2e
.asm_2c17
	ldh [$ff99], a
	ld h, $ce
	ld a, $5a
	add b
	ld l, a
	push hl
	ld e, [hl]
	add $08
	ld l, a
	push hl
	ld d, [hl]
	push bc
	call Func_2c5a
	pop bc
	pop hl
	ld [hl], d
	pop hl
	ld [hl], e
	call Func_2f31
	ld h, $ce
	ld a, $72
	add b
	ld l, a
	push hl
	ld e, [hl]
	add $08
	ld l, a
	push hl
	ld d, [hl]
	push bc
	call Func_2f4b
	pop bc
	pop hl
	ld [hl], d
	pop hl
	ld [hl], e
.asm_2c48
	ld a, $04
	cp b
	jr nz, .asm_2c52
	ld a, $1e
	call UnsafeBankswitch
.asm_2c52
	dec b
	bit 7, b
	jr z, .loop
	jp $4368

Func_2c5a:
	ld h, $ce
	ld a, $52
	add b
	ld l, a
	dec [hl]
	jr z, .asm_2c65
	ret

.asm_2c64
	inc de
.asm_2c65
	ld h, $ce
	ld a, [de]
	ld c, a
	and $e0
	cp $e0
	jp z, .asm_2d60
	ld a, $4a
	add b
	ld l, a
	ld a, [hl]
	cp $0f
	jr nz, .asm_2c97
	bit 4, c
	jp nz, .asm_2cca
	ld a, c
	and $0f
	cp $0f
	jr z, .asm_2cb3
	add $d1
	ld l, a
	ld h, $30
	jr nc, .asm_2c8d
	inc h
.asm_2c8d
	ld c, [hl]
	ld a, $12
	call Func_30bf
	ld [hl], c
	jp .asm_2cca
.asm_2c97
	ld a, c
	and $1f
	cp $10
	jr z, .asm_2cb3
	bit 4, a
	jr z, .asm_2ca4
	or $e0
.asm_2ca4
	ld c, a
	ld a, $8a
	add b
	ld l, a
	ld a, [hl]
	add c
	push de
	call Func_2ef5
	pop de
	jp .asm_2cca
.asm_2cb3
	call .Func_2d34
	ld c, a
	ld h, $ce
	ld a, $82
	add b
	ld l, a
	ld a, [hl]
	and a
	jr z, .asm_2cc3
	ld [hl], $01
.asm_2cc3
	ld a, c
	and a
	jp z, .asm_2c64
	inc de
	ret

.asm_2cca
	call .Func_2d34
	ld c, a
	ld h, $ce
	ld a, $82
	add b
	ld l, a
	ld [hl], $ff
	add $10
	ld l, a
	ld a, [hl]
	and a
	jr z, .asm_2cef
	push bc
	push de
	ld e, a
	ld h, $ce
	ld a, $82
	add b
	ld l, a
	push hl
	ld b, e
	call Func_293e
	pop hl
	ld [hl], b
	pop de
	pop bc
.asm_2cef
	push bc
	call .Func_2cf7
	pop bc
	jp .asm_2cc3

.Func_2cf7:
	ld h, $ce
	ld a, $a2
	add b
	ld l, a
	ld a, [hl]
	bit 7, a
	jr nz, .asm_2d33
.Func_2d02:
	add a
	add a
.asm_2d04
	push de
	add $00
	ld e, a
	ld d, $40
	jr nc, .asm_2d0d
	inc d
.asm_2d0d
	ld h, $ce
	ld a, $72
	add b
	ld l, a
	ld a, [de]
	ld [hl], a
	ld a, $7a
	add b
	ld l, a
	inc de
	ld a, [de]
	ld [hl], a
	ld h, $30
	ld a, $c7
	add b
	ld l, a
	jr nc, .asm_2d25
	inc h
.asm_2d25
	ld c, [hl]
	ld h, $ce
	ld a, $c2
	add b
	ld l, a
	ld [hl], c
	add $a8
	ld l, a
	ld [hl], $01
	pop de
.asm_2d33
	ret

.Func_2d34:
	ld a, [de]
	and $e0
	cp $c0
	jr nz, .asm_2d3f
	inc de
	ld a, [de]
	jr .asm_2d56
.asm_2d3f
	ld h, $ce
	ld a, $aa
	add b
	ld l, a
	ld a, [de]
	and $e0
	swap a
	srl a
	add [hl]
	add $15
	ld l, a
	ld a, $00
	adc $de
	ld h, a
	ld a, [hl]
.asm_2d56
	ld c, a
	ld h, $ce
	ld a, $52
	add b
	ld l, a
	ld a, c
	ld [hl], a
	ret

.asm_2d60
	ld a, c
	cp $f0
	jr nz, .asm_2d7d
	inc de
	ld h, $ce
	ld a, $9a
	add b
	ld l, a
	ld a, [de]
.asm_2d6d
	swap a
	and $f0
	ld c, a
	ld a, [hl]
	and $0f
	or c
	ld [hl], a
	call Func_3043
	jp .asm_2c64
.asm_2d7d
	cp $f1
	jr nz, .asm_2da1
	inc de
	ld a, [de]
	ld c, a
	ld h, $ce
	ld a, $9a
	add b
	ld l, a
	ld a, [hl]
	swap a
	and $0f
	add c
	bit 7, c
	jr nz, .asm_2d9c
	cp $10
	jr c, .asm_2d9f
	ld a, $0f
	jr .asm_2d9f
.asm_2d9c
	jr c, .asm_2d9f
	xor a
.asm_2d9f
	jr .asm_2d6d
.asm_2da1
	cp $f2
	jr nz, .asm_2db6
	inc de
	ld a, [de]
	add a
	ld c, a
	add a
	add c
	ld hl, $ceaa
.asm_2dae
	ld c, a
	ld a, l
	add b
	ld l, a
	ld [hl], c
	jp .asm_2c64
.asm_2db6
	cp $f3
	jr nz, .asm_2dcb
	inc de
	ld h, $ce
	ld a, $52
	add b
	ld l, a
	ld a, [de]
	ld [hl], a
	ld a, $82
	add b
	ld l, a
	ld [hl], $ff
	inc de
	ret
.asm_2dcb
	cp $f4
	jr nz, .asm_2dd7
	inc de
	ld a, [de]
	ld hl, $ce92
	jp .asm_2dae
.asm_2dd7
	cp $f5
	jr nz, .asm_2de3
	inc de
	ld a, [de]
	ld hl, $ce8a
	jp .asm_2dae
.asm_2de3
	cp $f6
	jr nz, .asm_2df8
	inc de
	ld h, $ce
	ld a, $a2
	add b
	ld l, a
	ld a, [de]
	ld [hl], a
	bit 7, a
	call nz, .Func_2d02
	jp .asm_2c64
.asm_2df8
	cp $f7
	jr nz, .asm_2e04
	inc de
	ld a, [de]
	ld hl, $ceb2
	jp .asm_2dae
.asm_2e04
	cp $e2
	jr nz, .asm_2e1a
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	push de
	ld d, a
	ld e, c
	call Func_2f11
	call .Func_2cf7
	pop de
	jp .asm_2c64
.asm_2e1a
	cp $e3
	jr nz, .asm_2e31
	inc de
	ld a, [de]
	push de
	cpl
	inc a
	ld e, a
	ld d, $00
	rla
	jr nc, .asm_2e2a
	dec d
.asm_2e2a
	call Func_30aa
	pop de
	jp .asm_2c64
.asm_2e31
	cp $fe
	jr nz, .asm_2e6b
	inc de
	ld a, [de]
	ld c, a
	push de
	ld h, $ce
	ld a, $4a
	add b
	ld l, a
	ld e, [hl]
	srl e
	srl e
	ld d, $00
	ld hl, $ce42
	add hl, de
	ld a, c
	rra
	jr nc, .asm_2e50
	set 4, d
.asm_2e50
	rra
	jr nc, .asm_2e54
	inc d
.asm_2e54
	inc e
	dec e
	jr z, .asm_2e5d
.asm_2e58
	rlc d
	dec e
	jr nz, .asm_2e58
.asm_2e5d
	ld a, b
	cp $04
	jr c, .asm_2e66
	inc l
	inc l
	inc l
	inc l
.asm_2e66
	ld [hl], d
	pop de
	jp .asm_2c64
.asm_2e6b
	cp $e1
	jr nz, .asm_2e77
	inc de
	ld a, [de]
	ld [$ce00], a
	jp .asm_2c64
.asm_2e77
	cp $ff
	jr nz, .asm_2e8b
	ld h, $ce
	ld a, $52
	add b
	ld l, a
	ld [hl], $00
	add $18
	ld l, a
	xor a
	ld [hl], a
	jp Func_3037
.asm_2e8b
	ld hl, $ceba
	call Func_2e94
	jp .asm_2c65

Func_2e94:
	ld a, l
	add b
	ld l, a
	push hl
	ld a, $64
	add [hl]
	ld l, a
	ld a, $dd
	adc $00
	ld h, a
	call Func_2eaa
	ld a, l
	sub $64
	pop hl
	ld [hl], a
	ret

Func_2eaa:
	ld a, [de]
	cp $f8
	jr nz, .asm_2eb7
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld d, a
	ld e, c
	ret
.asm_2eb7
	cp $fa
	jr nz, .asm_2eca
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
.asm_2eca
	cp $fb
	jr nz, .asm_2ed3
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ret
.asm_2ed3
	cp $fc
	jr nz, .asm_2ee2
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
.asm_2ee2
	cp $fd
	jr nz, .asm_2ef4
	dec [hl]
	jr z, .asm_2ef0
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	dec hl
	dec hl
	ret
.asm_2ef0
	inc hl
	inc hl
	inc hl
	inc de
.asm_2ef4
	ret

Func_2ef5:
	ld e, a
	ld a, $b2
	add b
	ld l, a
	ld a, [hl]
	add a
	add $cf
	ld l, a
	ld a, $00
	adc $30
	ld h, a
	ld a, [hli]
	rlc e
	add e
	ld e, a
	ld a, [hl]
	adc $00
	ld h, a
	ld l, e
	ld a, [hli]
	ld d, a
	ld e, [hl]
Func_2f11:
	ld h, $ce
	ld a, $4a
	add b
	ld l, a
	ld a, [hl]
	cp $0a
	jr z, .asm_2f23
	ld a, $03
	call Func_30be
	jr .asm_2f2d
.asm_2f23
	ld a, $00
	call Func_30be
	ld [hl], $80
	inc l
	inc l
	inc l
.asm_2f2d
	ld a, e
	ld [hli], a
	ld [hl], d
	ret

Func_2f31:
	ld h, $ce
	ld a, $82
	add b
	ld l, a
	ld a, [hl]
	and a
	ret z
	cp $ff
	ret z
	dec [hl]
	ret nz
	ld a, $a2
	add b
	ld l, a
	ld a, [hl]
	add a
	add a
	add $02
	jp Func_2c5a.asm_2d04

Func_2f4b:
	ld h, $ce
	ld a, $6a
	add b
	ld l, a
	dec [hl]
	jr z, .asm_2f56
	ret
.asm_2f55
	inc de
.asm_2f56
	ld h, $ce
	ld a, [de]
	ld c, a
	and $e0
	jr nz, .asm_2f69
	ld a, c
	and $1f
	ld c, a
	ld a, $6a
	add b
	ld l, a
	ld [hl], c
	inc de
	ret
.asm_2f69
	cp $20
	jr nz, .asm_2f86
	push bc
	push de
	call Func_309c
	call Func_30aa
	pop de
	pop bc
.asm_2f77
	ld a, [de]
	and $10
	jr z, .asm_2f55
	ld h, $ce
	ld a, $6a
	add b
	ld l, a
	ld [hl], $01
	inc de
	ret
.asm_2f86
	cp $40
	jr nz, .asm_2f90
	ld a, c
	and $0f
	jp .asm_2fae
.asm_2f90
	cp $60
	jr nz, .asm_2fb6
	push de
	call Func_309c
	ld h, $ce
	ld a, $9a
	add b
	ld l, a
	ld a, [hl]
	and $0f
	add e
	bit 7, a
	jr z, .asm_2fa7
	xor a
.asm_2fa7
	cp $10
	jr c, .asm_2fad
	ld a, $0f
.asm_2fad
	pop de
.asm_2fae
	push de
	call Func_3037
	pop de
	jp .asm_2f77
.asm_2fb6
	cp $80
	jr nz, .asm_300d
	ld h, $ce
	ld a, $4a
	add b
	ld l, a
	ld a, [hl]
	cp $0a
	jr z, .asm_2fd8
	ld a, $01
	call Func_30be
	ld a, c
	rrca
	rrca
	and $c0
	ld c, a
	ld a, [hl]
	and $3f
	or c
	ld [hl], a
	jp .asm_2f77
.asm_2fd8
	ld a, c
	and $0f
	ld hl, $ced2
	cp [hl]
	jr z, .asm_2ffe
	push de
	ld [hl], a
	swap a
	ld e, a
	ld d, $00
	ld hl, $dde5
	add hl, de
	xor a
	ldh [rAUD3ENA], a
	call .Func_3001
	ld a, $80
	ldh [rAUD3ENA], a
	ld a, [$ce14]
	set 7, a
	ldh [rAUD3HIGH], a
	pop de
.asm_2ffe
	jp .asm_2f77

.Func_3001:
	ld de, _AUD3WAVERAM
	ld c, $10
.asm_3006
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .asm_3006
	ret

.asm_300d
	cp $e0
	jr nz, .asm_3036
	ld a, c
	cp $f0
	jr nz, .asm_3022
	inc de
	ld a, [de]
	ld c, a
	ld a, $00
	call Func_30b6
	ld [hl], c
	jp .asm_2f55
.asm_3022
	cp $ff
	jr nz, .asm_302d
	ld a, $6a
	add b
	ld l, a
	ld [hl], $00
	ret
.asm_302d
	ld hl, $cec2
	call Func_2e94
	jp .asm_2f56
.asm_3036
	ret

Func_3037:
	ld c, a
	ld h, $ce
	ld a, $9a
	add b
	ld l, a
	ld a, [hl]
	and $f0
	or c
	ld [hl], a
;	fallthrough
Func_3043:
	push de
	ld a, $ff
	sub [hl]
	swap a
	and $0f
	ld e, a
	ld a, [hl]
	and $0f
	sub e
	ld e, a
	jr nc, .asm_3055
	ld e, $00
.asm_3055
	push hl
	ld hl, $ce01
	ld a, b
	cp $04
	jr c, .asm_305f
	inc l
.asm_305f
	ld a, $ff
	sub [hl]
	swap a
	and $0f
	ld d, a
	pop hl
	ld a, e
	sub d
	jr nc, .asm_306d
	xor a
.asm_306d
	ld e, a
	ld a, $4a
	add b
	ld l, a
	ld a, [hl]
	cp $0a
	jr z, .asm_3085
	ld a, $02
	call Func_30be
	swap e
	ld a, [hl]
	and $0f
	or e
	ld [hl], a
	pop de
	ret
.asm_3085
	srl e
	srl e
	ld d, $00
	ld hl, .data
	add hl, de
	ld e, [hl]
	ld a, $02
	call Func_30b6
	ld [hl], e
	pop de
	ret

.data
	db $00, $60, $40, $20

Func_309c:
	ld a, c
	and $0f
	ld d, $00
	bit 3, a
	jr z, .asm_30a8
	or $f0
	dec d
.asm_30a8
	ld e, a
	ret

Func_30aa:
	ld a, $03
	call Func_30b6
	ld a, e
	add [hl]
	ld [hli], a
	ld a, d
	adc [hl]
	ld [hl], a
	ret

Func_30b6:
	push af
	ld h, $ce
	ld a, $4a
	add b
	ld l, a
	pop af
;	fallthrough
Func_30be:
	add [hl]
;	fallthrough
Func_30bf:
	ld hl, $ff99
	add [hl]
	ld l, a
	ld h, $ce
	ret
; 0x30c7

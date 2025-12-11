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

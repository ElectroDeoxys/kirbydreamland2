SECTION "_GameLoop", ROMX[$4062], BANK[$8]

_GameLoop::
	farcall DetectSGB
	farcall SGBTransferBorder

	xor a
	ld [$deff], a
	ld hl, $7a2d
	ld a, $10
	call Farcall

.asm_2007e
	ld hl, $5fee
	ld a, $07
	call Farcall

	ld a, [$deff]
	or a
	jp nz, $43f3 ; Func_203f3
	ld hl, $68d2
	ld a, $0f
	call Farcall

	ld a, [$df0a]
	cp $ff
	jr z, .asm_2007e
	cp $03
	jr c, .asm_200ab
	cp $04
	jp c, $43e8 ; Func_203e8
	jp z, $432c ; Func_2032c
	jp $438c ; Func_2038c

.asm_200ab
	call $449b ; Func_2049b
	ld hl, $db39
	ld [hl], $00
	ld e, $07
	ld hl, $606d
	ld a, $1e
	call Farcall

	ld hl, $32ff
	ld a, $00
	call Farcall

	ld e, $00
	ld hl, $606d
	ld a, $1e
	call Farcall

	call $46ef ; Func_206ef
	cp $ff
	jr z, .asm_200e8
	cp $07
	jr nc, .asm_200e8
	ld e, a
	ld hl, $2a2b
	ld a, $00
	call Farcall

	ld a, $01
	ld [$db38], a
.asm_200e8
	ld hl, $10e6
	ld a, $00
	call Farcall

	ld hl, $1166
	ld a, $00
	call Farcall

	ld a, [$db60]
	ld hl, $4278
	add a
	add l
	ld l, a
	jr nc, .asm_20104
	inc h
.asm_20104
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call $44d0 ; Func_204d0
	ld hl, $11be
	ld a, $00
	call Farcall

	ld a, [$a082]
	dec a
	ld hl, .PointerTable
	add a
	add l
	ld l, a
	jr nc, .got_ptr
	inc h
.got_ptr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.PointerTable:
	dw $4135
	dw $41a4
	dw $423b
	dw $4286
	dw $42be
	dw $4306
	dw $431e
	dw $4363
	dw $4487
; 0x20135

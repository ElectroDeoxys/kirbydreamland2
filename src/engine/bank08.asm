Func_20000::
	ld a, $a0
	ld [wda48], a
	xor a
	ld [wda46], a
	ld [wda47], a
	ld hl, sb201
	ld [hl], a
	dec h
	; hl = sb101
	ld b, $12
	ld a, $b2
.asm_20015
	ld [hl], a
	dec h
	dec a
	dec b
	jr nz, .asm_20015

	ld a, $ff
	ld b, $13
	ld hl, sa000
.asm_20022
	ld [hl], a
	inc h
	dec b
	jr nz, .asm_20022
	ret
; 0x20028

SECTION "_GameLoop", ROMX[$4062], BANK[$8]

_GameLoop::
	farcall DetectSGB
	farcall SGBTransferBorder

	xor a
	ld [wNextDemo], a

	; play starting intro
	farcall StartIntro

.asm_2007e
	farcall TitleScreen

	ld a, [wNextDemo]
	or a
	jp nz, $43f3 ; Func_203f3

	farcall FileSelectMenu

	ld a, [wdf0a]
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
	ld hl, wdb39
	ld [hl], $00

	ld e, SGB_SFX_WIND_LOW
	farcall SGBPlaySFX

	farcall Func_32ff

	ld e, SGB_SFX_STOP
	farcall SGBPlaySFX

	call Func_206ef
	cp $ff
	jr z, .asm_200e8
	cp $07
	jr nc, .asm_200e8
	ld e, a
	farcall Func_2a2b

	ld a, $01
	ld [wdb38], a
.asm_200e8
	farcall Func_10e6
	farcall Func_1166

	ld a, [wdb60]
	ld hl, $4278
	add a
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call $44d0 ; Func_204d0
	ld hl, $11be
	ld a, $00
	call Farcall

	ld a, [sa082]
	dec a
	ld hl, .PointerTable
	add a
	add l
	ld l, a
	incc h
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

SECTION "Func_206ef", ROMX[$46ef], BANK[$8]

; output:
; - a = ? 
Func_206ef:
	ld hl, wdb60
	ld a, [hl]
	ld b, $01
	and a
.asm_206f6
	jr z, .asm_206fd
	sla b
	dec a
	jr .asm_206f6

.asm_206fd
	ld hl, wdb39
	ld a, [hl]
	and b
	jr nz, .asm_2070b
	ld a, [hl]
	or b
	ld [hl], a
	ld a, [wdb60]
	ret
.asm_2070b
	ld a, $ff
	ret
; 0x2070e

SECTION "Func_21a79", ROMX[$5a79], BANK[$8]

Demo1Inputs:
	db NO_INPUT, 0
	db NO_INPUT, 49
	db D_RIGHT, 142
	db NO_INPUT, 8
	db B_BUTTON, 12
	db NO_INPUT, 34
	db D_RIGHT, 47
	db A_BUTTON | D_RIGHT, 16
	db D_RIGHT, 21
	db NO_INPUT, 32
	db B_BUTTON, 7
	db NO_INPUT, 33
	db D_RIGHT, 38
	db A_BUTTON | D_RIGHT, 16
	db D_RIGHT, 21
	db NO_INPUT, 28
	db B_BUTTON, 11
	db NO_INPUT, 63
	db B_BUTTON, 7
	db NO_INPUT, 17
	db D_RIGHT, 40
	db A_BUTTON | D_RIGHT, 12
	db D_RIGHT, 13
	db NO_INPUT, 1
	db B_BUTTON, 9
	db NO_INPUT, 37
	db B_BUTTON, 9
	db NO_INPUT, 26
	db D_RIGHT, 3
	db A_BUTTON | D_RIGHT, 8
	db D_RIGHT, 11
	db B_BUTTON | D_RIGHT, 8
	db D_RIGHT, 11
	db NO_INPUT, 36
	db A_BUTTON | D_RIGHT, 29
	db D_RIGHT, 8
	db NO_INPUT, 38
	db B_BUTTON, 7
	db NO_INPUT, 19
	db D_RIGHT, 14
	db NO_INPUT, 9
	db D_RIGHT, 2
	db NO_INPUT, 17
	db D_RIGHT, 22
	db A_BUTTON | D_RIGHT, 13
	db D_RIGHT, 10
	db NO_INPUT, 48
	db B_BUTTON, 18
	db NO_INPUT, 19
	db D_DOWN, 12
	db NO_INPUT, 68
	db D_RIGHT, 40
	db A_BUTTON | D_RIGHT, 10
	db D_RIGHT, 28
	db B_BUTTON | D_RIGHT, 36
	db D_RIGHT, 28
	db NO_INPUT, 22
	db A_BUTTON, 4
	db NO_INPUT, 12
	db B_BUTTON, 54
	db NO_INPUT, 44
	db D_RIGHT, 18
	db NO_INPUT, 11
	db D_UP, 17
	db NO_INPUT, 2
	db D_RIGHT, 19
	db A_BUTTON | D_RIGHT, 10
	db D_RIGHT, 18
	db NO_INPUT, 14
	db A_BUTTON, 7
	db NO_INPUT, 29
	db A_BUTTON, 2
	db A_BUTTON | D_RIGHT, 4
	db D_RIGHT, 19
	db NO_INPUT, 1
	db B_BUTTON, 35
	db NO_INPUT, 33
	db D_LEFT, 4
	db NO_INPUT, 1
	db B_BUTTON, 31
	db NO_INPUT, 19
	db D_RIGHT, 19
	db A_BUTTON | D_RIGHT, 9
	db D_RIGHT, 6
	db B_BUTTON | D_RIGHT, 2
	db B_BUTTON, 46
	db NO_INPUT, 43
	db D_LEFT, 22
	db A_BUTTON | D_LEFT, 9
	db D_LEFT, 31
	db NO_INPUT, 45
	db A_BUTTON, 2
	db A_BUTTON | D_LEFT, 5
	db D_LEFT, 7
	db NO_INPUT, 11
	db B_BUTTON, 45
	db NO_INPUT, 17
	db D_RIGHT, 4
	db NO_INPUT, 20
	db B_BUTTON, 33
	db NO_INPUT, 18
	db D_LEFT, 17
	db A_BUTTON | D_LEFT, 12
	db D_LEFT, 7
	db B_BUTTON | D_LEFT, 1
	db B_BUTTON, 43
	db NO_INPUT, 29
	db D_RIGHT, 29
	db A_BUTTON | D_RIGHT, 15
	db D_RIGHT, 22
	db NO_INPUT, 61
	db D_RIGHT, 5
	db B_BUTTON | D_RIGHT, 2
	db B_BUTTON, 43
	db NO_INPUT, 27
	db D_LEFT, 5
	db NO_INPUT, 2
	db B_BUTTON, 35
	db NO_INPUT, 16
	db D_RIGHT, 11
	db NO_INPUT, 17
	db D_RIGHT, 5
	db A_BUTTON | D_RIGHT, 13
	db D_RIGHT, 15
	db B_BUTTON | D_RIGHT, 3
	db B_BUTTON, 40
	db NO_INPUT, 29
	db D_LEFT, 25
	db NO_INPUT, 72
	db D_LEFT, 9
	db NO_INPUT, 22
	db D_LEFT, 12
	db NO_INPUT, 5
	db B_BUTTON, 45
	db NO_INPUT, 24
	db B_BUTTON | D_RIGHT, 11
	db B_BUTTON, 27
	db NO_INPUT, 19
	db D_LEFT, 9
	db NO_INPUT, 60
	db D_LEFT, 1
	db A_BUTTON | D_LEFT, 18
	db D_LEFT, 4
	db NO_INPUT, 3
	db B_BUTTON, 42
	db NO_INPUT, 57
	db D_RIGHT, 5
	db NO_INPUT, 52
	db B_BUTTON, 44
	db NO_INPUT, 135
	db D_LEFT, 2
	db NO_INPUT, 104
	db A_BUTTON, 6
	db A_BUTTON | D_LEFT, 14
	db D_LEFT, 4
	db NO_INPUT, 12
	db D_RIGHT, 6
	db NO_INPUT, 65
	db B_BUTTON, 83
	db NO_INPUT, 140
	db START, 1
	db $40
Demo1InputsEnd:

Demo2Inputs:
	db NO_INPUT, 0
	db NO_INPUT, 104
	db D_RIGHT, 63
	db NO_INPUT, 3
	db B_BUTTON, 65
	db NO_INPUT, 17
	db D_RIGHT, 52
	db B_BUTTON | D_RIGHT, 6
	db B_BUTTON, 27
	db NO_INPUT, 16
	db D_LEFT, 4
	db NO_INPUT, 36
	db B_BUTTON, 47
	db NO_INPUT, 15
	db D_RIGHT, 4
	db NO_INPUT, 16
	db B_BUTTON, 70
	db NO_INPUT, 30
	db SELECT, 10
	db NO_INPUT, 58
	db D_RIGHT, 91
	db A_BUTTON | D_RIGHT, 16
	db D_RIGHT, 8
	db B_BUTTON | D_RIGHT, 4
	db B_BUTTON, 4
	db NO_INPUT, 28
	db D_RIGHT, 5
	db NO_INPUT, 15
	db D_DOWN, 14
	db NO_INPUT, 97
	db B_BUTTON, 31
	db NO_INPUT, 12
	db D_RIGHT, 16
	db A_BUTTON | D_RIGHT, 23
	db D_RIGHT, 26
	db NO_INPUT, 27
	db B_BUTTON, 26
	db NO_INPUT, 15
	db A_BUTTON, 11
	db A_BUTTON | D_RIGHT, 22
	db D_RIGHT, 16
	db A_BUTTON | D_RIGHT, 42
	db NO_INPUT, 31
	db B_BUTTON, 24
	db NO_INPUT, 16
	db D_LEFT, 1
	db NO_INPUT, 34
	db B_BUTTON, 39
	db NO_INPUT, 16
	db A_BUTTON, 2
	db A_BUTTON | D_RIGHT, 22
	db D_RIGHT, 39
	db A_BUTTON | D_RIGHT, 15
	db D_RIGHT, 95
	db NO_INPUT, 2
	db D_LEFT, 8
	db NO_INPUT, 1
	db B_BUTTON, 41
	db B_BUTTON | D_RIGHT, 29
	db B_BUTTON, 39
	db NO_INPUT, 2
	db D_RIGHT, 85
	db NO_INPUT, 4
	db B_BUTTON, 158
	db NO_INPUT, 24
	db SELECT, 9
	db NO_INPUT, 63
	db A_BUTTON, 13
	db A_BUTTON | D_RIGHT, 6
	db D_RIGHT, 6
	db NO_INPUT, 7
	db B_BUTTON, 10
	db NO_INPUT, 35
	db D_DOWN, 13
	db NO_INPUT, 54
	db D_RIGHT, 25
	db NO_INPUT, 27
	db D_LEFT, 4
	db NO_INPUT, 32
	db B_BUTTON, 22
	db NO_INPUT, 17
	db A_BUTTON, 13
	db A_BUTTON | D_RIGHT, 19
	db D_RIGHT, 10
	db A_BUTTON | D_RIGHT, 20
	db D_RIGHT, 5
	db NO_INPUT, 2
	db D_LEFT, 6
	db NO_INPUT, 2
	db B_BUTTON, 37
	db NO_INPUT, 12
	db D_RIGHT, 19
	db NO_INPUT, 2
	db D_UP, 19
	db NO_INPUT, 41
	db B_BUTTON, 25
	db NO_INPUT, 6
	db D_RIGHT, 16
	db NO_INPUT, 2
	db D_LEFT, 7
	db NO_INPUT, 2
	db B_BUTTON, 19
	db NO_INPUT, 18
	db A_BUTTON, 19
	db A_BUTTON | D_LEFT, 7
	db A_BUTTON, 3
	db NO_INPUT, 4
	db D_RIGHT, 5
	db NO_INPUT, 54
	db B_BUTTON, 25
	db NO_INPUT, 16
	db A_BUTTON, 26
	db NO_INPUT, 13
	db D_RIGHT, 6
	db A_BUTTON | D_RIGHT, 20
	db D_RIGHT, 5
	db NO_INPUT, 25
	db B_BUTTON, 27
	db NO_INPUT, 12
	db D_LEFT, 9
	db A_BUTTON | D_LEFT, 29
	db D_LEFT, 17
	db A_BUTTON | D_LEFT, 30
	db A_BUTTON, 1
	db NO_INPUT, 16
	db D_RIGHT, 18
	db A_BUTTON | D_RIGHT, 31
	db D_RIGHT, 19
	db A_BUTTON | D_RIGHT, 29
	db A_BUTTON, 2
	db NO_INPUT, 23
	db D_LEFT, 14
	db A_BUTTON | D_LEFT, 14
	db D_LEFT, 35
	db A_BUTTON | D_LEFT, 32
	db D_LEFT, 1
	db NO_INPUT, 24
	db D_RIGHT, 14
	db A_BUTTON | D_RIGHT, 19
	db A_BUTTON | B_BUTTON | D_RIGHT, 7
	db A_BUTTON | B_BUTTON, 11
	db A_BUTTON, 2
	db NO_INPUT, 119
	db D_RIGHT, 17
	db A_BUTTON | D_RIGHT, 26
	db D_RIGHT, 2
	db D_RIGHT | D_UP, 4
	db D_UP, 20
	db NO_INPUT, 24
	db D_RIGHT, 40
	db NO_INPUT, 4
	db D_LEFT, 7
	db NO_INPUT, 2
	db B_BUTTON, 15
	db NO_INPUT, 10
	db D_LEFT, 45
	db NO_INPUT, 3
	db D_RIGHT, 8
	db NO_INPUT, 54
	db D_LEFT, 15
	db NO_INPUT, 24
	db B_BUTTON, 35
	db NO_INPUT, 11
	db D_RIGHT, 10
	db A_BUTTON | D_RIGHT, 9
	db D_RIGHT, 6
	db NO_INPUT, 5
	db D_LEFT, 5
	db B_BUTTON | D_LEFT, 19
	db D_LEFT, 31
	db NO_INPUT, 12
	db D_RIGHT, 7
	db A_BUTTON | D_RIGHT, 11
	db D_RIGHT, 5
	db NO_INPUT, 4
	db D_LEFT, 8
	db NO_INPUT, 1
	db B_BUTTON, 24
	db NO_INPUT, 12
	db A_BUTTON, 12
	db NO_INPUT, 12
	db B_BUTTON, 33
	db NO_INPUT, 94
	db B_BUTTON, 30
	db NO_INPUT, 13
	db D_RIGHT, 37
	db NO_INPUT, 73
	db D_RIGHT, 6
	db NO_INPUT, 4
	db D_LEFT, 6
	db NO_INPUT, 77
	db B_BUTTON, 43
	db NO_INPUT, 58
	db D_LEFT, 24
	db NO_INPUT, 49
	db D_UP, 42
	db NO_INPUT, 3
	db B_BUTTON, 152
	db NO_INPUT, 134
	db $08
Demo2InputsEnd:

Demo3Inputs:
	db NO_INPUT, 0
	db NO_INPUT, 79
	db D_RIGHT, 139
	db D_RIGHT | D_DOWN, 3
	db D_DOWN, 16
	db NO_INPUT, 38
	db B_BUTTON, 25
	db NO_INPUT, 15
	db D_RIGHT, 23
	db D_RIGHT | D_UP, 15
	db D_RIGHT, 80
	db NO_INPUT, 7
	db B_BUTTON, 19
	db NO_INPUT, 29
	db D_RIGHT, 5
	db D_RIGHT | D_UP, 14
	db D_RIGHT, 36
	db NO_INPUT, 62
	db B_BUTTON, 26
	db NO_INPUT, 13
	db D_UP, 8
	db D_RIGHT | D_UP, 3
	db D_RIGHT, 53
	db D_RIGHT | D_DOWN, 4
	db D_DOWN, 44
	db NO_INPUT, 142
	db SELECT, 9
	db NO_INPUT, 92
	db D_RIGHT, 21
	db B_BUTTON | D_RIGHT, 8
	db D_RIGHT, 15
	db NO_INPUT, 19
	db D_DOWN, 15
	db NO_INPUT, 58
	db D_RIGHT, 21
	db D_RIGHT | D_UP, 16
	db D_UP, 2
	db NO_INPUT, 15
	db B_BUTTON, 65
	db NO_INPUT, 6
	db D_RIGHT, 20
	db NO_INPUT, 122
	db D_RIGHT, 31
	db D_RIGHT | D_DOWN, 45
	db D_RIGHT, 40
	db NO_INPUT, 36
	db D_UP, 3
	db NO_INPUT, 3
	db B_BUTTON, 16
	db NO_INPUT, 18
	db D_UP, 24
	db D_RIGHT | D_UP, 1
	db D_RIGHT, 22
	db NO_INPUT, 6
	db B_BUTTON, 22
	db NO_INPUT, 28
	db D_RIGHT, 66
	db D_RIGHT | D_DOWN, 22
	db D_RIGHT, 16
	db NO_INPUT, 2
	db B_BUTTON, 10
	db NO_INPUT, 26
	db D_DOWN, 8
	db NO_INPUT, 3
	db D_RIGHT, 20
	db NO_INPUT, 2
	db D_UP, 11
	db NO_INPUT, 93
	db D_RIGHT, 13
	db D_RIGHT | D_UP, 17
	db D_RIGHT, 22
	db NO_INPUT, 7
	db B_BUTTON, 41
	db NO_INPUT, 5
	db D_LEFT, 21
	db D_LEFT | D_DOWN, 29
	db D_DOWN, 1
	db NO_INPUT, 4
	db D_RIGHT, 7
	db NO_INPUT, 24
	db D_RIGHT, 3
	db D_RIGHT | D_UP, 20
	db D_RIGHT, 1
	db B_BUTTON, 18
	db NO_INPUT, 11
	db D_RIGHT, 23
	db B_BUTTON, 154
	db NO_INPUT, 2
	db D_LEFT, 39
	db D_LEFT | D_DOWN, 5
	db D_LEFT, 9
	db D_LEFT | D_DOWN, 3
	db D_DOWN, 8
	db D_RIGHT | D_DOWN, 1
	db D_RIGHT, 11
	db NO_INPUT, 59
	db D_RIGHT, 1
	db D_RIGHT | D_UP, 20
	db D_UP, 2
	db NO_INPUT, 4
	db B_BUTTON, 17
	db NO_INPUT, 24
	db SELECT, 7
	db NO_INPUT, 23
	db D_LEFT, 8
	db B_BUTTON, 4
	db B_BUTTON | D_LEFT, 4
	db D_LEFT, 23
	db NO_INPUT, 3
	db D_RIGHT, 14
	db NO_INPUT, 8
	db B_BUTTON, 9
	db NO_INPUT, 0
	db NO_INPUT, 26
	db D_UP, 20
	db NO_INPUT, 2
	db B_BUTTON, 10
	db NO_INPUT, 84
	db B_BUTTON, 6
	db NO_INPUT, 127
	db B_BUTTON, 22
	db NO_INPUT, 16
	db D_RIGHT, 16
	db D_RIGHT | D_UP, 9
	db D_UP, 23
	db NO_INPUT, 123
	db D_DOWN, 12
	db NO_INPUT, 184
	db D_LEFT, 2
	db D_LEFT | D_UP, 22
	db D_LEFT, 3
	db NO_INPUT, 66
	db D_RIGHT, 6
	db NO_INPUT, 32
	db D_RIGHT, 40
	db A_BUTTON | D_RIGHT, 9
	db D_RIGHT, 13
	db NO_INPUT, 1
	db D_RIGHT, 1
	db NO_INPUT, 2
	db D_UP, 14
	db NO_INPUT, 45
	db D_RIGHT, 52
	db NO_INPUT, 20
	db B_BUTTON, 13
	db B_BUTTON | D_DOWN, 7
	db B_BUTTON | D_RIGHT | D_DOWN, 8
	db D_RIGHT | D_DOWN, 13
	db D_RIGHT, 52
	db NO_INPUT, 7
	db D_RIGHT, 4
	db D_RIGHT | D_DOWN, 4
	db D_RIGHT, 2
	db B_BUTTON, 29
	db D_RIGHT, 45
	db NO_INPUT, 5
	db D_RIGHT, 5
	db B_BUTTON | D_RIGHT, 14
	db B_BUTTON, 2
	db B_BUTTON | D_RIGHT, 12
	db B_BUTTON | D_UP, 3
	db B_BUTTON, 127
	db NO_INPUT, 153
	db $08
Demo3InputsEnd:

; input:
; - [wNextDemo] = DEMO_* constant
Func_21e92:
	ld hl, wNextDemo
	ld a, [hl]
	inc a
	cp NUM_DEMOS
	jr c, .got_demo
	; wrap back to DEMO_1
	ld a, DEMO_1
.got_demo
	ld [hl], a
	dec a
	add a
	add a ; *4
	ld hl, .DemoHeaders
	add l
	ld l, a
	jr nc, .got_header
	inc h
.got_header
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, sDemoInputs
	call CopyHLToDE
	farcall Func_1c000
	ret

.DemoHeaders:
	; size, inputs
	dw Demo1InputsEnd - Demo1Inputs, Demo1Inputs ; DEMO_1
	dw Demo2InputsEnd - Demo2Inputs, Demo2Inputs ; DEMO_2
	dw Demo3InputsEnd - Demo3Inputs, Demo3Inputs ; DEMO_3
; 0x21ecb

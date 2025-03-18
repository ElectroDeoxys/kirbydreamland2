Init::
	ld sp, $ffff
.wait_vblank
	ldh a, [rLY]
	cp $91
	jr nz, .wait_vblank

	xor a
	ldh [rLCDC], a

	ld a, CART_SRAM_ENABLE
	ld [rRAMG], a

	; clear VRAM
	ld hl, STARTOF(VRAM)
	ld bc, SIZEOF(VRAM)
	ld a, $00
	call FillHL

	; clear WRAM
	ld hl, STARTOF(WRAM0)
	ld bc, SIZEOF(WRAM0) + SIZEOF(WRAMX)
	ld a, $00
	call FillHL

	; set stack pointer
	ld sp, wStackTop

	; clear OAM
	ld hl, _OAMRAM
	ld bc, $100
	ld a, $00
	call FillHL

	; clear HRAM
	ld hl, STARTOF(HRAM)
	ld bc, SIZEOF(HRAM)
	ld a, $00
	call FillHL

	; clear SRAM
	ld hl, STARTOF(SRAM)
	ld bc, $1c00
	ld a, $00
	call FillHL

	xor a
	ldh [rIF], a
	ld a, IEF_VBLANK | IEF_STAT | IEF_TIMER
	ldh [rIE], a

	ld a, $ff
	ldh [rTIMA], a

	; sets timer to interrupt at
	; 4k Hz / 68 ~ 59 Hz
	ld a, -68
	ldh [rTMA], a
	xor a ; TACF_STOP
	ldh [rTAC], a

	ld a, STATF_LYC
	ldh [rSTAT], a
	ld a, $ff
	ldh [rLYC], a
	ld [wda29], a

	; initialise transfer OAM function in HRAM
	ld a, BANK(TransferVirtualOAM) ; useless UnsafeBankswitch
	call UnsafeBankswitch
	ld hl, TransferVirtualOAM
	ld de, hTransferVirtualOAM
	ld bc, SIZEOF("DMA Transfer")
	call CopyHLToDE

	ld hl, wda21
	ld a, $02
	ld [hld], a
	ld [hl], $2b
	xor a
	ld [wda1c], a

	farcall_unsafe InitAudio
	farcall_unsafe Func_1d7bc
	farcall_unsafe Func_1c01d

	xor a
	ldh [rBGP], a
	ld [wBGP], a
	ldh [rOBP0], a
	ld [wOBP0], a
	ldh [rOBP1], a
	ld [wOBP1], a
	ldh [rSCY], a
	ldh [rSCX], a
	ldh [rWY], a
	ldh [rWX], a
	ld [$da2b], a
	ld a, $c0
	ld [$da08], a
	ld a, $c2
	ld [$da28], a
	ld a, $c3
	ld [$da10], a

	ld hl, $342
	call Func_604

	ld hl, wStatTrampoline
	ld a, $c3 ; jp
	ld [hli], a
	ld a, LOW(StatHandler_Default)
	ld [hli], a
	ld [hl], HIGH(StatHandler_Default)
	ld hl, wda16
	ld a, LOW(StatHandler_Default)
	ld [hli], a
	ld [hl], HIGH(StatHandler_Default)

	ei
	ld a, TACF_START | TACF_4KHZ
	ldh [rTAC], a

	jp GameLoop

TransferVirtualOAM:
LOAD "DMA Transfer", HRAM
hTransferVirtualOAM::
	ld a, HIGH(wVirtualOAM)
	ldh [rDMA], a ; start DMA transfer (starts right after instruction)
	ld a, 160 / (1 + 3) ; delay for a total of 160 cycles
.loop
	dec a        ; 1 cycle
	jr nz, .loop ; 3 cycles
	ret
ENDL
; 0x680f2

SECTION "Func_681e0", ROMX[$41e0], BANK[$1a]

Func_681e0:
	ld a, [$deed]
	or a
	ret z
	pop hl
	ld a, d
	ld hl, $40f2
	add a
	add l
	ld l, a
	jr nc, .asm_681f0
	inc h
.asm_681f0
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hl]
	ld c, a
	ld de, $cd0c
	ld [de], a
	inc e
	ld b, $00
	add hl, bc
.asm_681fd
	ld a, [hld]
	ld [de], a
	inc e
	dec c
	jr nz, .asm_681fd
	jr Func_68235

Func_68205:
	ld a, [$deed]
	or a
	ret z
	pop hl
	ld a, d
	ld hl, $40f2
	add a
	add l
	ld l, a
	jr nc, .asm_68215
	inc h
.asm_68215
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld c, a
	ld de, $cd0c
	ld [de], a
	inc e
	inc hl
.loop_copy
	ld a, [hli]
	ld [de], a
	inc e
	dec c
	jr nz, .loop_copy

	ld hl, $cd09
	ld de, wBGP
	ld b, $03
.asm_6822e
	ld a, [hli]
	ld [de], a
	ld [$ff00+c], a
	inc e
	dec b
	jr nz, .asm_6822e
;	fallthrough
Func_68235:
	ld a, $0d
	ld [$da34], a
	ld a, $01
	ld [$da38], a
	ld a, $04
	ldh [$ff84], a
	jp Func_682ca

Func_68246:
	ld a, $ff
	ld [$da37], a
	call Func_68205
	ld a, e
	ldh [$ff84], a
	ld a, [wBGP]
	or a
	ld a, $00
	jr z, .asm_6825b
	ld a, $01
.asm_6825b
	ld [$da35], a
	ld hl, $cd08
	ld de, $cd0b
	ld c, $06
.asm_68266
	ld a, [de]
	dec e
	call Func_682dd
	ld [hld], a
	dec c
	jr nz, .asm_68266
	jr Func_682c5

	call Func_68292
	jr .asm_68283

	call Func_6829a
	jr .asm_68283

	call Func_682a4
	jr .asm_68283

	call Func_682ac
.asm_68283
	ld a, $01
	ld [$da39], a
	call Func_343
	ld a, [$da36]
	or a
	jr nz, .asm_68283
	ret

Func_68292:
	ld a, $01
	ld [$da37], a
	call Func_681e0
;	fallthrough
Func_6829a:
	ld a, $01
	ld [$da35], a
	ld a, e
	ldh [$ff84], a
	jr Func_682b4

Func_682a4:
	ld a, $00
	ld [$da37], a
	call Func_681e0
;	fallthrough
Func_682ac:
	ld a, $00
	ld [$da35], a
	ld a, e
	ldh [$ff84], a
Func_682b4:
	ld hl, $cd03
	ld de, wBGP
	ld c, $09
.asm_682bc
	ld a, [de]
	inc e
	call Func_682dd
	ld [hli], a
	dec c
	jr nz, .asm_682bc
;	fallthrough

Func_682c5:
	ld a, $03
	ld [$da34], a
Func_682ca:
	ldh a, [$ff84]
	ld [$da32], a
	ld [$da33], a
	ld a, $01
	ld [$da36], a
	ld hl, $684
	jp Func_5f9

Func_682dd:
	ld b, a
	ld a, [$da35]
	cp $00
	ld a, b
	jr nz, .asm_68305
	ld b, a
	and $c0
	ld a, b
	jr z, .asm_682ef
	sub $40
	ld b, a
.asm_682ef
	and $30
	ld a, b
	jr z, .asm_682f7
	sub $10
	ld b, a
.asm_682f7
	and $0c
	ld a, b
	jr z, .asm_682ff
	sub $04
	ld b, a
.asm_682ff
	and $03
	ld a, b
	ret z
	dec a
	ret
.asm_68305
	ld b, a
	and $c0
	cp $c0
	ld a, b
	jr z, .asm_68310
	add $40
	ld b, a
.asm_68310
	and $30
	cp $30
	ld a, b
	jr z, .asm_6831a
	add $10
	ld b, a
.asm_6831a
	and $0c
	cp $0c
	ld a, b
	jr z, .asm_68324
	add $04
	ld b, a
.asm_68324
	and $03
	cp $03
	ld a, b
	ret z
	inc a
	ret
; 0x6832c

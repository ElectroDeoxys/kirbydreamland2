Init::
	ld sp, $ffff
.wait_vblank
	ldh a, [rLY]
	cp $91
	jr nz, .wait_vblank

	xor a
	ldh [rLCDC], a

	; enable SRAM (it will always stay enabled)
	ld a, RAMG_SRAM_ENABLE
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
	ld hl, STARTOF(OAM)
	ld bc, $100
	ld a, $00
	call FillHL

	; clear HRAM
	ld hl, STARTOF(HRAM)
	ld bc, SIZEOF(HRAM)
	ld a, $00
	call FillHL

	; clear working SRAM
	ld hl, STARTOF("Working SRAM")
	ld bc, SIZEOF("Working SRAM")
	ld a, $00
	call FillHL

	; init IF and enable some interrupts
	xor a
	ldh [rIF], a
	ld a, IE_VBLANK | IE_STAT | IE_TIMER
	ldh [rIE], a

	; set Timer to be executed
	; as soon as possible
	ld a, -1
	ldh [rTIMA], a
	; sets timer to interrupt at
	; 4k Hz / 68 ~ 59 Hz
	ld a, -68
	ldh [rTMA], a
	xor a ; TAC_STOP
	ldh [rTAC], a

	ld a, STAT_LYC
	ldh [rSTAT], a
	ld a, $ff
	ldh [rLYC], a
	ld [wLYC], a

	; initialise transfer OAM function in HRAM
	ld a, BANK(TransferVirtualOAM) ; useless UnsafeBankswitch
	call UnsafeBankswitch
	ld hl, TransferVirtualOAM
	ld de, hTransferVirtualOAM
	ld bc, SIZEOF("DMA Transfer")
	call CopyHLToDE

	ld hl, wProcessBGMapQueueFunc + $1
	ld a, HIGH(ProcessBGMapQueue)
	ld [hld], a
	ld [hl], LOW(ProcessBGMapQueue)
	xor a
	ld [wda1c], a

	; initialise Audio engine and WRAM tables
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
	ld [wObjDisabled], a
	ld a, HIGH(wVirtualOAM1)
	ld [wVirtualOAMPtr + 0], a
	ld a, $c2
	ld [wda28], a

	ld a, $c3 ; jp
	ld [wVBlankTrampoline + 0], a
	ld hl, VBlankHandler_Default
	call UnsafeSetVBlankTrampoline

	ld hl, wStatTrampoline
	ld a, $c3 ; jp
	ld [hli], a
	ld a, LOW(StatHandler_Default)
	ld [hli], a
	ld [hl], HIGH(StatHandler_Default)
	ld hl, wNextStatTrampoline
	ld a, LOW(StatHandler_Default)
	ld [hli], a
	ld [hl], HIGH(StatHandler_Default)

	; finally, enable interrupts and start timer
	ei
	ld a, TAC_START | TAC_4KHZ
	ldh [rTAC], a

	; hand control over to the main game loop
	jp GameLoop

TransferVirtualOAM:
LOAD "DMA Transfer", HRAM
hTransferVirtualOAM::
	ld a, HIGH(wVirtualOAM1)
	ldh [rDMA], a ; start DMA transfer (starts right after instruction)
	ld a, 160 / (1 + 3) ; delay for a total of 160 cycles
.loop
	dec a        ; 1 cycle
	jr nz, .loop ; 3 cycles
	ret
ENDL

Pointers_680f2:
	dw $4136 ; $00
	dw $413b ; $01
	dw $4140 ; $02
	dw $4145 ; $03
	dw $414a ; $04
	dw $414f ; $05
	dw $4154 ; $06
	dw $4159 ; $07
	dw $415e ; $08
	dw $4163 ; $09
	dw $4168 ; $0a
	dw $416d ; $0b
	dw $4172 ; $0c
	dw $4177 ; $0d
	dw $417c ; $0e
	dw $4181 ; $0f
	dw $4186 ; $10
	dw $418b ; $11
	dw $4190 ; $12
	dw $4195 ; $13
	dw $419a ; $14
	dw $41a4 ; $15
	dw $419f ; $16
	dw $41ae ; $17
	dw $41a9 ; $18
	dw $41b3 ; $19
	dw $41b8 ; $1a
	dw $41bd ; $1b
	dw $41c2 ; $1c
	dw $41c7 ; $1d
	dw $41cc ; $1e
	dw $41d1 ; $1f
	dw $41d6 ; $20
	dw $41db ; $21
; 0x68136

SECTION "Func_681e0", ROMX[$41e0], BANK[$1a]

Func_681e0:
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	pop hl ; skips rest of caller's execution
	ld a, d
	ld hl, Pointers_680f2
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hl]
	ld c, a
	ld de, wcd0c
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

; input:
; - d = ?
Func_68205:
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	pop hl ; skips rest of caller's execution
	ld a, d
	ld hl, Pointers_680f2
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld c, a
	ld de, wcd0c
	ld [de], a
	inc e
	inc hl
.loop_copy
	ld a, [hli]
	ld [de], a
	inc e
	dec c
	jr nz, .loop_copy

	; c = $0 = LOW(rJOYP)
	ld hl, wcd09
	ld de, wBGOBPals
	ld b, wBGOBPalsEnd - wBGOBPals
.loop_pal_configs
	ld a, [hli]
	ld [de], a
	ld [$ff00+c], a ; bug, c should be LOW(rBGP)
	inc e
	dec b
	jr nz, .loop_pal_configs
;	fallthrough
Func_68235:
	ld a, $0d
	ld [wda34], a
	ld a, $01
	ld [wda38], a
	ld a, $04
	ldh [hff84], a
	jp Func_682ca

; input:
; - d = ?
; - e = ?
Func_68246::
	ld a, $ff
	ld [wda37], a

	call Func_68205
	; being here means no SGB
;	fallthrough

; input:
; - e = ?
Func_6824e::
	ld a, e
	ldh [hff84], a
	ld a, [wBGP]
	or a
	ld a, FALSE
	jr z, .asm_6825b
	ld a, TRUE
.asm_6825b
	ld [wda35], a
	; wda35 = (wBGP != 0)

	ld hl, wcd08
	ld de, wcd0b
	ld c, $06
.loop
	ld a, [de]
	dec e
	call Func_682dd
	ld [hld], a
	dec c
	jr nz, .loop
	jr Func_682c5

	call Func_68292
	jr Func_68283

Func_68276::
	call Func_6829a
	jr Func_68283
Func_6827b::
	call Func_682a4
	jr Func_68283
Func_68280::
	call Func_682ac
Func_68283:
.loop
	ld a, $01
	ld [wda39], a
	call DoFrame
	ld a, [wda36]
	or a
	jr nz, .loop
	ret

Func_68292:
	ld a, $01
	ld [wda37], a
	call Func_681e0
;	fallthrough
Func_6829a:
	ld a, TRUE
	ld [wda35], a
	ld a, e
	ldh [hff84], a
	jr Func_682b4

Func_682a4:
	ld a, $00
	ld [wda37], a
	call Func_681e0
;	fallthrough
Func_682ac:
	ld a, FALSE
	ld [wda35], a
	ld a, e
	ldh [hff84], a
Func_682b4:
	ld hl, wcd03
	ld de, wBGOBPals
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
	ld [wda34], a
Func_682ca:
	ldh a, [hff84]
	ld [wda32], a
	ld [wda33], a
	ld a, $01
	ld [wda36], a

	ld hl, Func_684
	jp SetVBlankTrampoline

; input:
; - a = ?
; output:
; - a = ?
Func_682dd:
	ld b, a
	ld a, [wda35]
	cp FALSE
	ld a, b
	jr nz, .asm_68305
	ld b, a ; unnecessary
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

SECTION "Bank 1A GFX", ROMX[$79fd], BANK[$1a]

Gfx_6b9fd: INCBIN "gfx/gfx_6b9fd.2bpp"
	ds 1 tiles
Gfx_6bacd: INCBIN "gfx/gfx_6bacd.2bpp"
Gfx_6bbcd: INCBIN "gfx/gfx_6bbcd.2bpp"

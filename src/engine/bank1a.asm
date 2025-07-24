Init::
	ld sp, $ffff
.wait_vblank
	ldh a, [rLY]
	cp LY_VBLANK + 1
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

MACRO sgb_palettes
	db _NARG - 1
REPT _NARG
	db \1
SHIFT
ENDR
ENDM

SGBPalSequences:
	table_width 2
	dw .pal_sequence_00 ; SGB_PALSEQUENCE_00
	dw .pal_sequence_01 ; SGB_PALSEQUENCE_01
	dw .pal_sequence_02 ; SGB_PALSEQUENCE_02
	dw .pal_sequence_03 ; SGB_PALSEQUENCE_03
	dw .pal_sequence_04 ; SGB_PALSEQUENCE_04
	dw .pal_sequence_05 ; SGB_PALSEQUENCE_05
	dw .pal_sequence_06 ; SGB_PALSEQUENCE_06
	dw .pal_sequence_07 ; SGB_PALSEQUENCE_07
	dw .pal_sequence_08 ; SGB_PALSEQUENCE_08
	dw .pal_sequence_09 ; SGB_PALSEQUENCE_09
	dw .pal_sequence_0a ; SGB_PALSEQUENCE_0A
	dw .pal_sequence_0b ; SGB_PALSEQUENCE_0B
	dw .pal_sequence_0c ; SGB_PALSEQUENCE_0C
	dw .pal_sequence_0d ; SGB_PALSEQUENCE_0D
	dw .pal_sequence_0e ; SGB_PALSEQUENCE_0E
	dw .pal_sequence_0f ; SGB_PALSEQUENCE_0F
	dw .pal_sequence_10 ; SGB_PALSEQUENCE_10
	dw .pal_sequence_11 ; SGB_PALSEQUENCE_11
	dw .pal_sequence_12 ; SGB_PALSEQUENCE_12
	dw .pal_sequence_13 ; SGB_PALSEQUENCE_13
	dw .pal_sequence_14 ; SGB_PALSEQUENCE_14
	dw .pal_sequence_15 ; SGB_PALSEQUENCE_15
	dw .pal_sequence_16 ; SGB_PALSEQUENCE_16
	dw .pal_sequence_17 ; SGB_PALSEQUENCE_17
	dw .pal_sequence_18 ; SGB_PALSEQUENCE_18
	dw .pal_sequence_19 ; SGB_PALSEQUENCE_19
	dw .pal_sequence_1a ; SGB_PALSEQUENCE_1A
	dw .pal_sequence_1b ; SGB_PALSEQUENCE_GRASS_LAND
	dw .pal_sequence_1c ; SGB_PALSEQUENCE_BIG_FOREST
	dw .pal_sequence_1d ; SGB_PALSEQUENCE_RIPPLE_FIELD
	dw .pal_sequence_1e ; SGB_PALSEQUENCE_ICEBERG
	dw .pal_sequence_1f ; SGB_PALSEQUENCE_RED_CANYON
	dw .pal_sequence_20 ; SGB_PALSEQUENCE_CLOUDY_PARK
	dw .pal_sequence_21 ; SGB_PALSEQUENCE_DARK_CASTLE
	assert_table_length NUM_SGB_PALSEQUENCES

.pal_sequence_00
	sgb_palettes SGB_PALS_34, SGB_PALS_37, SGB_PALS_36, $08
.pal_sequence_01
	sgb_palettes SGB_PALS_34, SGB_PALS_39, SGB_PALS_38, $10
.pal_sequence_02
	sgb_palettes SGB_PALS_34, SGB_PALS_3B, SGB_PALS_3A, $1f
.pal_sequence_03
	sgb_palettes SGB_PALS_34, SGB_PALS_3D, SGB_PALS_3C, $0b
.pal_sequence_04
	sgb_palettes SGB_PALS_34, SGB_PALS_3F, SGB_PALS_3E, $0e
.pal_sequence_05
	sgb_palettes SGB_PALS_34, SGB_PALS_41, SGB_PALS_40, $11
.pal_sequence_06
	sgb_palettes SGB_PALS_34, SGB_PALS_43, SGB_PALS_42, $13
.pal_sequence_07
	sgb_palettes SGB_PALS_34, SGB_PALS_45, SGB_PALS_44, $12
.pal_sequence_08
	sgb_palettes SGB_PALS_34, SGB_PALS_47, SGB_PALS_46, $14
.pal_sequence_09
	sgb_palettes SGB_PALS_34, SGB_PALS_49, SGB_PALS_48, $15
.pal_sequence_0a
	sgb_palettes SGB_PALS_34, SGB_PALS_4D, SGB_PALS_4C, $0a
.pal_sequence_0b
	sgb_palettes SGB_PALS_34, SGB_PALS_4B, SGB_PALS_4A, $0f
.pal_sequence_0c
	sgb_palettes SGB_PALS_34, SGB_PALS_4F, SGB_PALS_4E, $1d
.pal_sequence_0d
	sgb_palettes SGB_PALS_34, SGB_PALS_51, SGB_PALS_50, $16
.pal_sequence_0e
	sgb_palettes SGB_PALS_35, SGB_PALS_53, SGB_PALS_52, $16
.pal_sequence_0f
	sgb_palettes SGB_PALS_35, SGB_PALS_55, SGB_PALS_54, $17
.pal_sequence_10
	sgb_palettes SGB_PALS_35, SGB_PALS_57, SGB_PALS_56, $18
.pal_sequence_11
	sgb_palettes SGB_PALS_35, SGB_PALS_59, SGB_PALS_58, $19
.pal_sequence_12
	sgb_palettes SGB_PALS_35, SGB_PALS_5B, SGB_PALS_5A, $1b
.pal_sequence_13
	sgb_palettes SGB_PALS_35, SGB_PALS_5D, SGB_PALS_5C, $1a
.pal_sequence_14
	sgb_palettes SGB_PALS_35, SGB_PALS_5F, SGB_PALS_5E, $1c
.pal_sequence_16
	sgb_palettes SGB_PALS_35, SGB_PALS_61, SGB_PALS_60, $1e
.pal_sequence_15
	sgb_palettes SGB_PALS_34, SGB_PALS_63, SGB_PALS_62, $1e
.pal_sequence_18
	sgb_palettes SGB_PALS_35, SGB_PALS_65, SGB_PALS_64, $23
.pal_sequence_17
	sgb_palettes SGB_PALS_34, SGB_PALS_67, SGB_PALS_66, $23
.pal_sequence_19
	sgb_palettes SGB_PALS_34, SGB_PALS_69, SGB_PALS_68, $21
.pal_sequence_1a
	sgb_palettes SGB_PALS_34, SGB_PALS_6B, SGB_PALS_6A, $22
.pal_sequence_1b
	sgb_palettes SGB_PALS_34, SGB_PALS_6D, SGB_PALS_6C, $00
.pal_sequence_1c
	sgb_palettes SGB_PALS_34, SGB_PALS_6F, SGB_PALS_6E, $01
.pal_sequence_1d
	sgb_palettes SGB_PALS_34, SGB_PALS_71, SGB_PALS_70, $02
.pal_sequence_1e
	sgb_palettes SGB_PALS_34, SGB_PALS_73, SGB_PALS_72, $03
.pal_sequence_1f
	sgb_palettes SGB_PALS_34, SGB_PALS_75, SGB_PALS_74, $04
.pal_sequence_20
	sgb_palettes SGB_PALS_34, SGB_PALS_77, SGB_PALS_76, $05
.pal_sequence_21
	sgb_palettes SGB_PALS_34, SGB_PALS_79, SGB_PALS_78, $06

; input:
; - d = SGB_PALSEQUENCE_* constant
SGBFadeIn:
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	pop hl ; skips rest of caller's execution
	ld a, d
	ld hl, SGBPalSequences
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hl]
	ld c, a
	ld de, wSGBPalSequenceSize
	ld [de], a
	inc e
	ld b, $00
	add hl, bc
.loop_set_pal_list
	ld a, [hld]
	ld [de], a
	inc e
	dec c
	jr nz, .loop_set_pal_list
	jr DoSGBPalSequence

; input:
; - d = SGB_PALSEQUENCE_* constant
SGBFadeOut:
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	pop hl ; skips rest of caller's execution
	ld a, d
	ld hl, SGBPalSequences
	add a ; *2
	add l
	ld l, a
	incc h
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld c, a
	ld de, wSGBPalSequenceSize
	ld [de], a
	inc e
	inc hl
.loop_set_pal_list
	ld a, [hli]
	ld [de], a
	inc e
	dec c
	jr nz, .loop_set_pal_list

	; c = $0 = LOW(rJOYP)
	ld hl, wFadePals3
	ld de, wBGOBPals
	ld b, wBGOBPalsEnd - wBGOBPals
.loop_pal_configs
	ld a, [hli]
	ld [de], a
	ld [$ff00+c], a ; bug, writes to rJOYP
	inc e
	dec b
	jr nz, .loop_pal_configs
;	fallthrough

DoSGBPalSequence:
	ld a, LOW(wSGBPalSequence)
	ld [wActiveFadePal], a
	ld a, TRUE
	ld [wda38], a
	ld a, 4
	ldh [hff84], a
	jp Func_682ca

; input:
; - d = SGB_PALSEQUENCE_* constant
; - e = fade step duration
Func_68246::
	ld a, $ff
	ld [wda37], a

	call SGBFadeOut
	; being here means no SGB
;	fallthrough

; input:
; - e = fade step duration
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

	ld hl, wFadePals2OBP1
	ld de, wFadePals3OBP1
	ld c, $06
.loop
	ld a, [de]
	dec e
	call DarkenColorsInPalette
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
	ld a, TRUE
	ld [wda39], a
	call DoFrame
	ld a, [wda36]
	or a
	jr nz, .loop
	ret

; input:
; - d = SGB_PALSEQUENCE_* constant
Func_68292:
	ld a, $01
	ld [wda37], a
	call SGBFadeIn
;	fallthrough
Func_6829a:
	ld a, TRUE
	ld [wda35], a
	ld a, e
	ldh [hff84], a
	jr Func_682b4

; input:
; - d = SGB_PALSEQUENCE_* constant
; - e = fade step duration
Func_682a4:
	ld a, $00
	ld [wda37], a
	call SGBFadeIn
;	fallthrough
Func_682ac:
	ld a, FALSE
	ld [wda35], a
	ld a, e
	ldh [hff84], a
Func_682b4:
	; sets fade pals to fade to black
	ld hl, wFadePals1
	ld de, wBGOBPals
	ld c, wFadePalsEnd - wFadePals
.loop_set_fade_to_black
	ld a, [de]
	inc e
	call DarkenColorsInPalette
	ld [hli], a
	dec c
	jr nz, .loop_set_fade_to_black
;	fallthrough

Func_682c5:
	ld a, LOW(wFadePals1)
	ld [wActiveFadePal], a
Func_682ca:
	ldh a, [hff84]
	ld [wFadeStepDuration], a
	ld [wFadeCounter], a
	ld a, $01
	ld [wda36], a

	ld hl, Func_684
	jp SetVBlankTrampoline

; decrements all colors on palette given in a
; to achieve a fading into black effect
DarkenColorsInPalette:
	ld b, a
	ld a, [wda35]
	cp FALSE
	ld a, b
	jr nz, .asm_68305
	ld b, a ; unnecessary
	and %11 << COL_3
	ld a, b
	jr z, .col_2
	sub 1 << COL_3
	ld b, a
.col_2
	and %11 << COL_2
	ld a, b
	jr z, .col_1
	sub 1 << COL_2
	ld b, a
.col_1
	and %11 << COL_1
	ld a, b
	jr z, .col_0
	sub 1 << COL_1
	ld b, a
.col_0
	and %11 << COL_0
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

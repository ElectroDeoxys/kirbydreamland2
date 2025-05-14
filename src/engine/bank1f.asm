Instruments::
	table_width 4
	;  attack, release
	dw $40a8, $40b6 ; INSTRUMENT_00
	dw $40ab, $40b4 ; INSTRUMENT_01
	dw $40ae, $40b4 ; INSTRUMENT_02
	dw $40b1, $40b4 ; INSTRUMENT_03
	dw $40b8, $40b4 ; INSTRUMENT_04
	dw $40c0, $40b4 ; INSTRUMENT_05
	dw $40c8, $40b4 ; INSTRUMENT_06
	dw $40cc, $40b4 ; INSTRUMENT_07
	dw $40d4, $40b4 ; INSTRUMENT_08
	dw $40d8, $40b4 ; INSTRUMENT_09
	dw $40e2, $40b4 ; INSTRUMENT_0A
	dw $40e6, $40b4 ; INSTRUMENT_0B
	dw $40f0, $40b4 ; INSTRUMENT_0C
	dw $40fe, $4113 ; INSTRUMENT_0D
	dw $4124, $4113 ; INSTRUMENT_0E
	dw $4128, $40b4 ; INSTRUMENT_0F
	dw $413a, $40b4 ; INSTRUMENT_10
	dw $4143, $4165 ; INSTRUMENT_11
	dw $4155, $4113 ; INSTRUMENT_12
	dw $4159, $4165 ; INSTRUMENT_13
	dw $4169, $40b4 ; INSTRUMENT_14
	dw $4177, $40b4 ; INSTRUMENT_15
	dw $418b, $40b4 ; INSTRUMENT_16
	dw $418f, $4165 ; INSTRUMENT_17
	dw $419b, $4165 ; INSTRUMENT_18
	dw $41a4, $4165 ; INSTRUMENT_19
	dw $41af, $4165 ; INSTRUMENT_1A
	dw $41b9, $41be ; INSTRUMENT_1B
	dw $41c4, $41c9 ; INSTRUMENT_1C
	dw $41c4, $4167 ; INSTRUMENT_1D
	dw $41ce, $41db ; INSTRUMENT_1E
	dw $41df, $4167 ; INSTRUMENT_1F
	dw $41e7, $40b4 ; INSTRUMENT_20
	dw $41eb, $40b6 ; INSTRUMENT_21
	dw $41f1, $4113 ; INSTRUMENT_22
	dw $41f5, $40b4 ; INSTRUMENT_23
	dw $40fe, $40b6 ; INSTRUMENT_24
	dw $41fc, $40b6 ; INSTRUMENT_25
	dw $4206, $40b6 ; INSTRUMENT_26
	dw $4215, $41be ; INSTRUMENT_27
	dw $40cc, $4220 ; INSTRUMENT_28
	dw $4224, $40b6 ; INSTRUMENT_29
	assert_table_length NUM_INSTRUMENTS
; 0x7c0a8

SECTION "PlayMusic", ROMX[$4232], BANK[$1f]

; input:
; - e = MUSIC_* constant
PlayMusic::
	ld a, [wCurMusic]
	cp e
	ret z ; skip, already playing
	ld a, e
	ld [wCurMusic], a
	ld b, e

	ld hl, wAudioCommandDurations + CHANNEL5
	ld c, NUM_MUSIC_CHANNELS
	xor a ; CHANNEL_OFF
.loop_clear
	ld [hli], a
	dec c
	jr nz, .loop_clear

	ld hl, MusicChannelDefaultConfigs
	ld de, wMusicChannels
	ld c, wMusicChannelsEnd - wMusicChannels
.loop_copy
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop_copy
	ld a, MUSIC_NONE
	cp b
	ret z ; done

	ld e, b
	ld d, $00
	ld hl, MusicHeaders
	add hl, de
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, [de]
	ld h, a ; num channels
	push hl
	ld bc, CHANNEL8
.loop
	ld hl, wAudioCommandDurations
	add hl, bc
	ld a, [hl]
	and a
	jr nz, .next
	call InitChannel
	pop hl
	dec h
	push hl
	jr z, .done
.next
	dec c
	ld a, CHANNEL5 - 1
	cp c
	jr nz, .loop
.done
	pop hl
	ret

MusicChannelDefaultConfigs:
	db AUD1SWEEP_DOWN, AUDLEN_DUTY_12_5, AUDENV_UP, $00, AUDHIGH_RESTART, $00
	db AUDLEN_DUTY_12_5, AUDENV_UP, $00, AUDHIGH_RESTART
	db AUD3ENA_ON, $00, AUD3LEVEL_MUTE, $00, AUDHIGH_RESTART, $00
	db $00, AUDENV_UP, AUD4POLY_15STEP, $80
; 0x7c295

SECTION "MusicHeaders", ROMX[$7e0e], BANK[$1f]

MusicHeaders:
	table_width 2
	dw $4295 ; MUSIC_00
	dw $42a2 ; MUSIC_01
	dw $42af ; MUSIC_02
	dw $42b9 ; MUSIC_GRASS_LAND_HUB
	dw $42c3 ; MUSIC_04
	dw $42d0 ; MUSIC_05
	dw $42dd ; MUSIC_TITLE_SCREEN
	dw $42ea ; MUSIC_07
	dw $42f7 ; MUSIC_08
	dw $54b8 ; MUSIC_KINE
	dw $54c5 ; MUSIC_BIG_FOREST_HUB
	dw $54cf ; MUSIC_COO
	dw $54dc ; MUSIC_0C
	dw $54e9 ; MUSIC_0D
	dw $54f6 ; MUSIC_0E
	dw $5503 ; MUSIC_0F
	dw $5510 ; MUSIC_10
	dw $551d ; MUSIC_11
	dw $552a ; MUSIC_12
	dw $62e3 ; MUSIC_13
	dw $62f0 ; MUSIC_RICK
	dw $62fd ; MUSIC_15
	dw $6304 ; MUSIC_16
	dw $6311 ; MUSIC_17
	dw $631e ; MUSIC_18
	dw $632b ; MUSIC_19
	dw $6338 ; MUSIC_1A
	dw $6345 ; MUSIC_1B
	dw $6352 ; MUSIC_LEVEL_SELECT
	dw $635f ; MUSIC_1D
	dw $6369 ; MUSIC_1E
	dw $6376 ; MUSIC_1F
	dw $6383 ; MUSIC_20
	dw $6390 ; MUSIC_21
	dw $639d ; MUSIC_22
	dw $63a7 ; MUSIC_23
	dw $63b4 ; MUSIC_24
	dw $738b ; MUSIC_25
	dw $7398 ; MUSIC_26
	dw $73a5 ; MUSIC_27
	dw $73b2 ; MUSIC_28
	dw $73bf ; MUSIC_29
	dw $73cc ; MUSIC_2A
	dw $73d9 ; MUSIC_2B
	dw $73e6 ; MUSIC_2C
	dw $73ed ; MUSIC_2D
	dw $73fa ; MUSIC_FILE_SELECT_MENU
	assert_table_length NUM_MUSICS

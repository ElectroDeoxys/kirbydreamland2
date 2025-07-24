SECTION "InitAudio", ROMX[$4232], BANK[$1e]

InitAudio:
	; load wave samples to WRAM
	ld hl, WaveSamples
	ld de, wWaveSamples
	ld bc, WaveSamplesEnd - WaveSamples
	call CopyHLToDE

	; load tempo mode durations to WRAM
	ld hl, TempoModeDurations
	ld de, wTempoModeDurations
	ld bc, TempoModeDurationsEnd - TempoModeDurations
	call CopyHLToDE

	; enable sound
	ld a, AUDENA_ON
	ldh [rAUDENA], a

	; set full volume
	ld a, MAX_VOLUME
	ldh [rAUDVOL], a

	; set panning
	ld a, AUDTERM_1_RIGHT | AUDTERM_2_RIGHT | AUDTERM_3_RIGHT | AUDTERM_4_RIGHT | AUDTERM_1_LEFT | AUDTERM_2_LEFT | AUDTERM_3_LEFT | AUDTERM_4_LEFT
	ldh [rAUDTERM], a

	ld a, $ff
	ld [wce01], a
	ld [wce02], a
	; undefined wave sample
	ld [wWaveSample], a

	; reset channel configurations
	ld hl, wChannels
	ld b, wChannelsEnd - wChannels
	ld a, $aa ; invalid fill value
.loop_fill
	ld [hli], a
	dec b
	jr nz, .loop_fill

	ld hl, InitialWaveform
	call ExecuteInstrumentCommands.LoadWaveSample

	; no music and no SFX
	ld e, MUSIC_NONE
	farcall_unsafe PlayMusic
	ld e, SFX_NONE
	call PlaySFX

	call ApplyChannelConfigurations

	; restart all channel frequencies
	ld hl, rAUD1HIGH
	set 7, [hl]
	ld hl, rNR24
	set 7, [hl]
	ld hl, rAUD3HIGH
	set 7, [hl]
	ld hl, rNR44
	set 7, [hl]
	ret

; input:
; - e = SFX_* constant
PlaySFX::
	ld a, e
	cp SFX_NONE
	jp z, ClearAllSFXChannels
	ld d, $00
	ld a, [wSFXActiveChannelFlags]
	and a
	jr z, .play_sfx
	ld hl, SFXRequiredChannels
	add hl, de
	and [hl]
	jr z, .play_sfx ; no overlap

	; SFX already playing, if it's higher priority
	; then exit and don't play SFX
	ld bc, CHANNEL4
.loop_channel_priorities
	ld hl, SFXRequiredChannels
	add hl, de
	ld a, [hl]
	ld hl, wChannelSFXFlags
	add hl, bc
	and [hl]
	jr z, .next_channel_priority
	ld hl, wChannelSoundPriorities
	add hl, bc
	ld a, [hl]
	ld hl, SFXPriorities
	add hl, de
	cp [hl]
	jp c, .lower_priority ; current loaded SFX has higher priority
	ld hl, wAudioCommandDurations
	add hl, bc
	ld [hl], CHANNEL_OFF
.next_channel_priority
	dec c
	bit 7, c
	jr z, .loop_channel_priorities

.play_sfx
	ld hl, SFXRequiredChannels
	add hl, de
	ld a, [hl]
	ld [wce04], a
	ld hl, SFXPriorities
	add hl, de
	ld a, [hl]
	ld c, a
	ld hl, SFXHeaders
	add hl, de
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, [de]
	ld h, a ; num channels
	ld l, c ; sfx priority
	push hl
	ld bc, CHANNEL4
.loop_sfx_channels
	ld hl, wAudioCommandDurations
	add hl, bc
	ld a, [hl]
	and a
	jr nz, .next_channel
	call InitChannel
	ld hl, sp+$00
	ld a, [hl]
	ld hl, wChannelSoundPriorities
	add hl, bc
	ld [hl], a
	ld a, [wce04]
	ld hl, wChannelSFXFlags
	add hl, bc
	ld [hl], a
	pop hl
	dec h
	push hl
	jr z, .done
.next_channel
	dec c
	bit 7, c
	jr z, .loop_sfx_channels
.done
	pop hl
	jp UpdateActiveSFXChannels
.lower_priority
	ret

ClearAllSFXChannels:
	ld bc, CHANNEL4
.loop_sfx_channels
	ld hl, wAudioCommandDurations
	add hl, bc
	ld [hl], b ; CHANNEL_OFF
	ld hl, wChannelSFXFlags
	add hl, bc
	ld [hl], b ; 0
	ld hl, wChannelSoundPriorities
	add hl, bc
	ld [hl], SFX_MINIMUM_PRIORITY
	dec c
	bit 7, c
	jr z, .loop_sfx_channels

	ld hl, SFXChannelDefaultConfigs
	ld de, wSFXChannels
	ld c, wSFXChannelsEnd - wSFXChannels
.loop_copy
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop_copy
	ret

SFXChannelDefaultConfigs:
	db AUD1SWEEP_DOWN, AUD1LEN_DUTY_12_5, AUD1ENV_UP, $00, AUD1HIGH_RESTART, $00
	db AUD2LEN_DUTY_12_5, AUD2ENV_UP, $00, AUD2HIGH_RESTART
	db AUD3ENA_ON, $00, AUD3LEVEL_MUTE, $00, AUD3HIGH_RESTART, $00
	db $00, AUD4ENV_UP, AUD4POLY_15STEP, AUD4GO_RESTART

UpdateActiveSFXChannels:
	ld a, [wChannelSFXFlags + CHANNEL1]
	ld hl, wChannelSFXFlags + CHANNEL2
	ld c, NUM_SFX_CHANNELS - 1
.loop
	or [hl]
	inc hl
	dec c
	jr nz, .loop
	ld [wSFXActiveChannelFlags], a
	ret

UpdateSFX::
	; reset unused sfx channels
	ld b, CHANNEL4
.loop_sfx_channels
	ld h, HIGH(wAudioCommandDurations)
	ld a, LOW(wAudioCommandDurations)
	add b
	ld l, a
	ld a, [hl]
	and a
	jr nz, .next_sfx_channel
	ld a, LOW(wChannelSoundPriorities)
	add b
	ld l, a
	ld [hl], SFX_MINIMUM_PRIORITY
	add wChannelSFXFlags - wChannelSoundPriorities
	ld l, a
	ld [hl], $00
.next_sfx_channel
	dec b
	bit 7, b
	jr z, .loop_sfx_channels
	call UpdateActiveSFXChannels
;	fallthrough

; actually applies the configurations of audio channels
ApplyChannelConfigurations:
	ld de, wMusicChannel1
	ld a, [wSFXActiveChannelFlags]
	bit SFXFLAG_SQUARE1_F, a
	jr z, .no_sfx_1
	ld e, LOW(wSFXChannel1)
.no_sfx_1
	ld b, FALSE
	ld hl, wChannels
	ld c, LOW(rAUD1SWEEP)
.loop_channel_1
	ld a, [de]
	cp [hl]
	jr z, .next_channel_1
	ld [hl], a
	ld [$ff00+c], a
	ld a, c
	cp LOW(rAUD1ENV)
	jr nz, .next_channel_1
	inc b ; envelope is changed
.next_channel_1
	inc l
	inc e
	inc c
	ld a, c
	cp LOW(rAUD1HIGH + 1)
	jr nz, .loop_channel_1
	dec b
	jr nz, .channel_2
	; envelope changed, need to restart
	ld a, [wChannel1FreqHi]
	set 7, a
	ldh [rAUD1HIGH], a

.channel_2
	ld de, wMusicChannel2
	ld a, [wSFXActiveChannelFlags]
	bit SFXFLAG_SQUARE2_F, a
	jr z, .no_sfx_2
	ld e, LOW(wSFXChannel2)
.no_sfx_2
	ld b, FALSE
	ld hl, wChannel2
	ld c, LOW(rAUD2LEN)
.loop_channel_2
	ld a, [de]
	cp [hl]
	jr z, .next_channel_2
	ld [hl], a
	ld [$ff00+c], a
	ld a, c
	cp LOW(rAUD2ENV)
	jr nz, .next_channel_2
	inc b ; envelope is changed
.next_channel_2
	inc l
	inc e
	inc c
	ld a, c
	cp LOW(rAUD2HIGH + 1)
	jr nz, .loop_channel_2
	dec b
	jr nz, .channel_3
	; envelope changed, need to restart
	ld a, [wChannel2FreqHi]
	set 7, a
	ldh [rAUD2HIGH], a

.channel_3
	ld de, wMusicChannel3
	ld a, [wSFXActiveChannelFlags]
	bit SFXFLAG_WAVE_F, a
	jr z, .no_sfx_3
	ld e, LOW(wSFXChannel3)
.no_sfx_3
	ld hl, wChannel3
	ld c, LOW(rAUD3ENA)
.loop_channel_3
	ld a, [de]
	cp [hl]
	jr z, .next_channel_3
	ld [hl], a
	ld [$ff00+c], a
.next_channel_3
	inc l
	inc e
	inc c
	ld a, c
	cp LOW(rAUD3HIGH + 1)
	jr nz, .loop_channel_3

	ld de, wMusicChannel4
	ld a, [wSFXActiveChannelFlags]
	bit SFXFLAG_NOISE_F, a
	jr z, .no_sfx_4
	ld e, LOW(wSFXChannel4)
.no_sfx_4
	ld b, FALSE
	ld hl, wChannel4
	ld c, LOW(rAUD4LEN)
.loop_channel_4
	ld a, [de]
	cp [hl]
	jr z, .next_channel_4
	ld [hl], a
	ld [$ff00+c], a
	ld a, c
	cp LOW(rAUD4ENV)
	jr nz, .next_channel_4
	inc b ; envelope is changed
.next_channel_4
	inc l
	inc e
	inc c
	ld a, c
	cp LOW(rAUD4GO + 1)
	jr nz, .loop_channel_4
	dec b
	jr nz, .pan
	; envelope changed, need to restart
	ld a, [wChannel4Control]
	set 7, a
	ldh [rAUD4GO], a

.pan
	ld a, [wSFXActiveChannelFlags]
	ld c, a
	ld a, [wChannelPans + CHANNEL5]
	bit SFXFLAG_SQUARE1_F, c
	jr z, .no_pan_sfx_1
	ld a, [wChannelPans + CHANNEL1]
.no_pan_sfx_1
	ld b, a
	ld a, [wChannelPans + CHANNEL6]
	bit SFXFLAG_SQUARE2_F, c
	jr z, .no_pan_sfx_2
	ld a, [wChannelPans + CHANNEL2]
.no_pan_sfx_2
	or b
	ld b, a
	ld a, [wChannelPans + CHANNEL7]
	bit SFXFLAG_WAVE_F, c
	jr z, .no_pan_sfx_3
	ld a, [wChannelPans + CHANNEL3]
.no_pan_sfx_3
	or b
	ld b, a
	ld a, [wChannelPans + CHANNEL8]
	bit SFXFLAG_NOISE_F, c
	jr z, .no_pan_sfx_4
	ld a, [wChannelPans + CHANNEL4]
.no_pan_sfx_4
	or b
	ldh [rAUDTERM], a
	ret

WaveSamples:
	table_width 16
	dn  2,  2,  6,  6, 10, 10, 14, 14, 15, 15, 15, 15, 15, 14, 14, 10, 10,  6,  6,  6,  8, 10, 12, 15, 15, 14, 14, 12, 10,  6,  3,  3  ; WAVEFORM_M_SHAPE
	dn 15, 15, 15, 15, 15, 15, 15, 15,  0,  0,  0,  0,  0,  0,  0,  0, 15, 15, 15, 15, 15, 15, 15, 15,  0,  0,  0,  0,  0,  0,  0,  0  ; WAVEFORM_SQUARE
	dn  1,  3,  5,  7,  9, 11, 13, 15, 13, 11,  9,  7,  5,  3,  1,  0,  1,  3,  5,  7,  9, 11, 13, 15, 13, 11,  9,  7,  5,  3,  1,  0  ; WAVEFORM_SINE
	assert_table_length NUM_WAVEFORMS
WaveSamplesEnd:
; 0x7849e

SECTION "Func_79b6f", ROMX[$5b6f], BANK[$1e]

TempoModeDurations:
	table_width 6
	db  1,  2,  3,  4,  5,  6 ; TEMPO_00
	db  5, 10, 15, 20, 30, 80 ; TEMPO_01
	db  9, 18, 27, 36, 45, 54 ; TEMPO_02
	db  7, 14, 21, 28, 35, 42 ; TEMPO_03
	db  6, 12, 18, 24, 30, 36 ; TEMPO_04
	db  8, 16, 24, 32, 40, 48 ; TEMPO_05
	db 10, 20, 30, 40, 50, 60 ; TEMPO_06
	db 11, 22, 33, 44, 55, 66 ; TEMPO_07
	db  4,  4,  8, 16, 40, 32 ; TEMPO_08
	db  3,  4,  9, 12, 27, 63 ; TEMPO_09
	db  4,  8, 12, 16, 24, 64 ; TEMPO_0A
	db  1,  2,  3,  4,  5,  6 ; TEMPO_0B
	db  5, 10, 15, 20, 30, 80 ; TEMPO_0C
	db  9, 18, 27, 36, 45, 54 ; TEMPO_0D
	db  7, 14, 21, 28, 35, 42 ; TEMPO_0E
	db  6, 12, 18, 24, 30, 36 ; TEMPO_0F
	db  8, 16, 24, 32, 40, 48 ; TEMPO_10
	db 10, 20, 30, 40, 50, 60 ; TEMPO_11
	db 11, 22, 33, 44, 55, 66 ; TEMPO_12
	db  4,  4,  8, 16, 40, 32 ; TEMPO_13
	db  3,  4,  9, 12, 27, 63 ; TEMPO_14
	db  4,  8, 12, 16, 24, 64 ; TEMPO_15
	db  1,  2,  3,  4,  5,  6 ; TEMPO_16
	db  5, 10, 15, 20, 30, 80 ; TEMPO_17
	db  9, 18, 27, 36, 45, 54 ; TEMPO_18
	db  7, 14, 21, 28, 35, 42 ; TEMPO_19
	db  6, 12, 18, 24, 30, 36 ; TEMPO_1A
	db  8, 16, 24, 32, 40, 48 ; TEMPO_1B
	db 10, 20, 30, 40, 50, 60 ; TEMPO_1C
	db 11, 22, 33, 44, 55, 66 ; TEMPO_1D
	db  4,  4,  8, 16, 40, 32 ; TEMPO_1E
	db  3,  4,  9, 12, 27, 63 ; TEMPO_1F
	db  4,  8, 12, 16, 24, 64 ; TEMPO_20
	assert_table_length NUM_TEMPO_MODES
TempoModeDurationsEnd:

SFXHeaders:
	table_width 2
	dw $449e ; SFX_00
	dw $44a5 ; SFX_01
	dw $44ac ; SFX_02
	dw $44b0 ; SFX_03
	dw $44b4 ; SFX_04
	dw $44b8 ; SFX_05
	dw $44bc ; SFX_06
	dw $44c3 ; SFX_07
	dw $44ca ; SFX_08
	dw $44ce ; SFX_09
	dw $44d2 ; SFX_0A
	dw $44d9 ; SFX_0B
	dw $44dd ; SFX_0C
	dw $44e4 ; SFX_0D
	dw $44e8 ; SFX_0E
	dw $44ec ; SFX_0F
	dw $44f0 ; SFX_10
	dw $44f4 ; SFX_11
	dw $44f8 ; SFX_12
	dw $44fc ; SFX_13
	dw $4500 ; SFX_14
	dw $4504 ; SFX_15
	dw $4508 ; SFX_16
	dw $450f ; SFX_17
	dw $4516 ; SFX_18
	dw $451d ; SFX_19
	dw $4521 ; SFX_1A
	dw $4525 ; SFX_1B
	dw $4529 ; SFX_1C
	dw $452d ; SFX_1D
	dw $4531 ; SFX_1E
	dw $4535 ; SFX_1F
	dw $4539 ; SFX_20
	dw $453d ; SFX_21
	dw $4544 ; SFX_22
	dw $454b ; SFX_23
	dw $454f ; SFX_24
	dw $4553 ; SFX_25
	dw $4557 ; SFX_26
	dw $4564 ; SFX_27
	dw $4571 ; SFX_28
	dw $457b ; SFX_29
	dw $4588 ; SFX_2A
	dw $4592 ; SFX_2B
	dw $4596 ; SFX_2C
	dw $459a ; SFX_2D
	dw $459e ; SFX_2E
	dw $45a5 ; SFX_2F
	dw $45b2 ; SFX_30
	dw $45b6 ; SFX_31
	dw $45bd ; SFX_32
	dw $45c4 ; SFX_33
	dw $45c8 ; SFX_34
	dw $45cc ; SFX_35
	dw $45d3 ; SFX_36
	dw $45d7 ; SFX_37
	dw $45db ; SFX_38
	dw $45df ; SFX_39
	dw $45e6 ; SFX_3A
	dw $45ed ; SFX_3B
	dw $45f1 ; SFX_3C
	dw $45f5 ; SFX_3D
	dw $45f9 ; SFX_3E
	dw $45fd ; SFX_3F
	dw $4604 ; SFX_40
	dw $460b ; SFX_41
	dw $4612 ; SFX_42
	dw $4616 ; SFX_43
	dw $4620 ; SFX_44
	dw $4627 ; SFX_45
	dw $462b ; SFX_46
	dw $4632 ; SFX_47
	dw $4636 ; SFX_48
	dw $463a ; SFX_49
	dw $4641 ; SFX_4A
	dw $4648 ; SFX_4B
	dw $464c ; SFX_4C
	dw $4653 ; SFX_4D
	dw $4657 ; SFX_4E
	dw $465e ; SFX_4F
	dw $4668 ; SFX_50
	dw $466f ; SFX_51
	dw $4673 ; SFX_52
	dw $467a ; SFX_53
	dw $4681 ; SFX_54
	dw $4685 ; SFX_55
	dw $4689 ; SFX_56
	dw $468d ; SFX_57
	dw $4691 ; SFX_58
	dw $4698 ; SFX_59
	dw $46a5 ; SFX_5A
	dw $46b2 ; SFX_5B
	dw $46b9 ; SFX_5C
	dw $46c0 ; SFX_5D
	dw $46ca ; SFX_5E
	dw $46d7 ; SFX_5F
	dw $46db ; SFX_60
	dw $46df ; SFX_61
	assert_table_length NUM_SFX

SFXRequiredChannels:
	table_width 1
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_00
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_01
	db SFXFLAG_SQUARE2 ; SFX_02
	db SFXFLAG_SQUARE2 ; SFX_03
	db SFXFLAG_SQUARE2 ; SFX_04
	db SFXFLAG_SQUARE2 ; SFX_05
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_06
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_07
	db SFXFLAG_SQUARE2 ; SFX_08
	db SFXFLAG_SQUARE2 ; SFX_09
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_0A
	db SFXFLAG_SQUARE2 ; SFX_0B
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_0C
	db SFXFLAG_SQUARE2 ; SFX_0D
	db SFXFLAG_NOISE ; SFX_0E
	db SFXFLAG_SQUARE2 ; SFX_0F
	db SFXFLAG_SQUARE2 ; SFX_10
	db SFXFLAG_NOISE ; SFX_11
	db SFXFLAG_SQUARE2 ; SFX_12
	db SFXFLAG_SQUARE1 ; SFX_13
	db SFXFLAG_SQUARE1 ; SFX_14
	db SFXFLAG_NOISE ; SFX_15
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_16
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_17
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_18
	db SFXFLAG_NOISE ; SFX_19
	db SFXFLAG_SQUARE2 ; SFX_1A
	db SFXFLAG_SQUARE2 ; SFX_1B
	db SFXFLAG_NOISE ; SFX_1C
	db SFXFLAG_SQUARE2 ; SFX_1D
	db SFXFLAG_NOISE ; SFX_1E
	db SFXFLAG_NOISE ; SFX_1F
	db SFXFLAG_NOISE ; SFX_20
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_21
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_22
	db SFXFLAG_NOISE ; SFX_23
	db SFXFLAG_NOISE ; SFX_24
	db SFXFLAG_SQUARE2 ; SFX_25
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_26
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_27
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_WAVE ; SFX_28
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_29
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_WAVE ; SFX_2A
	db SFXFLAG_NOISE ; SFX_2B
	db SFXFLAG_SQUARE2 ; SFX_2C
	db SFXFLAG_SQUARE2 ; SFX_2D
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_2E
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_2F
	db SFXFLAG_SQUARE2 ; SFX_30
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_31
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_32
	db SFXFLAG_NOISE ; SFX_33
	db SFXFLAG_NOISE ; SFX_34
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_35
	db SFXFLAG_NOISE ; SFX_36
	db SFXFLAG_NOISE ; SFX_37
	db SFXFLAG_SQUARE2 ; SFX_38
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_39
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_3A
	db SFXFLAG_SQUARE1 ; SFX_3B
	db SFXFLAG_SQUARE2 ; SFX_3C
	db SFXFLAG_NOISE ; SFX_3D
	db SFXFLAG_NOISE ; SFX_3E
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_3F
	db SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_40
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_41
	db SFXFLAG_SQUARE2 ; SFX_42
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_43
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_44
	db SFXFLAG_NOISE ; SFX_45
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_46
	db SFXFLAG_SQUARE2 ; SFX_47
	db SFXFLAG_SQUARE2 ; SFX_48
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_49
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_4A
	db SFXFLAG_SQUARE2 ; SFX_4B
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_4C
	db SFXFLAG_NOISE ; SFX_4D
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_4E
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_4F
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_50
	db SFXFLAG_NOISE ; SFX_51
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_52
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_53
	db SFXFLAG_NOISE ; SFX_54
	db SFXFLAG_SQUARE2 ; SFX_55
	db SFXFLAG_SQUARE2 ; SFX_56
	db SFXFLAG_NOISE ; SFX_57
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_58
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_59
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_5A
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 ; SFX_5B
	db SFXFLAG_SQUARE2 | SFXFLAG_NOISE ; SFX_5C
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_WAVE ; SFX_5D
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_NOISE | SFXFLAG_WAVE ; SFX_5E
	db SFXFLAG_SQUARE2 ; SFX_5F
	db SFXFLAG_SQUARE2 ; SFX_60
	db SFXFLAG_SQUARE1 | SFXFLAG_SQUARE2 | SFXFLAG_WAVE ; SFX_61
	assert_table_length NUM_SFX

; priority values for each SFX
; lower value means higher priority
SFXPriorities:
	table_width 1
	db 15 ; SFX_00
	db 30 ; SFX_01
	db 30 ; SFX_02
	db 30 ; SFX_03
	db 30 ; SFX_04
	db 30 ; SFX_05
	db 20 ; SFX_06
	db 15 ; SFX_07
	db 33 ; SFX_08
	db 35 ; SFX_09
	db 30 ; SFX_0A
	db 30 ; SFX_0B
	db 20 ; SFX_0C
	db 32 ; SFX_0D
	db 31 ; SFX_0E
	db 15 ; SFX_0F
	db 15 ; SFX_10
	db 20 ; SFX_11
	db 10 ; SFX_12
	db  9 ; SFX_13
	db  9 ; SFX_14
	db 30 ; SFX_15
	db 30 ; SFX_16
	db 30 ; SFX_17
	db 30 ; SFX_18
	db 30 ; SFX_19
	db 30 ; SFX_1A
	db 30 ; SFX_1B
	db 30 ; SFX_1C
	db 30 ; SFX_1D
	db 30 ; SFX_1E
	db 30 ; SFX_1F
	db  5 ; SFX_20
	db  5 ; SFX_21
	db 30 ; SFX_22
	db 30 ; SFX_23
	db 30 ; SFX_24
	db 30 ; SFX_25
	db  9 ; SFX_26
	db 10 ; SFX_27
	db 15 ; SFX_28
	db 20 ; SFX_29
	db  3 ; SFX_2A
	db 15 ; SFX_2B
	db  3 ; SFX_2C
	db  3 ; SFX_2D
	db 25 ; SFX_2E
	db  5 ; SFX_2F
	db 30 ; SFX_30
	db 30 ; SFX_31
	db 25 ; SFX_32
	db 30 ; SFX_33
	db 20 ; SFX_34
	db 30 ; SFX_35
	db 20 ; SFX_36
	db 30 ; SFX_37
	db 30 ; SFX_38
	db 30 ; SFX_39
	db 29 ; SFX_3A
	db 30 ; SFX_3B
	db 15 ; SFX_3C
	db 25 ; SFX_3D
	db 30 ; SFX_3E
	db 30 ; SFX_3F
	db 20 ; SFX_40
	db 30 ; SFX_41
	db 30 ; SFX_42
	db 10 ; SFX_43
	db 29 ; SFX_44
	db 30 ; SFX_45
	db 30 ; SFX_46
	db 28 ; SFX_47
	db 31 ; SFX_48
	db 30 ; SFX_49
	db 15 ; SFX_4A
	db 15 ; SFX_4B
	db 30 ; SFX_4C
	db 30 ; SFX_4D
	db 30 ; SFX_4E
	db 30 ; SFX_4F
	db  6 ; SFX_50
	db 28 ; SFX_51
	db 30 ; SFX_52
	db 15 ; SFX_53
	db 25 ; SFX_54
	db 30 ; SFX_55
	db 20 ; SFX_56
	db 25 ; SFX_57
	db  0 ; SFX_58
	db  6 ; SFX_59
	db  6 ; SFX_5A
	db  6 ; SFX_5B
	db 30 ; SFX_5C
	db 20 ; SFX_5D
	db 50 ; SFX_5E
	db 20 ; SFX_5F
	db 11 ; SFX_60
	db  0 ; SFX_61
	assert_table_length NUM_SFX

; input:
; - hl = packets data
SGBTransfer:
	ld a, [hl]
	and $07
	ret z

	ld b, a ; number of packets
	ld c, LOW(rJOYP)
.loop_packets
	push bc

	; start ICD2 packet
	ld a, $00
	ld [$ff00+c], a
	ld a, P1F_4 | P1F_5
	ld [$ff00+c], a

	ld b, SGB_PACKET_SIZE
.loop_packet_bytes
	ld e, 8 ; number of bits
	ld a, [hli]
	ld d, a ; next byte data
.loop_bits
	; check LSB, if 1, use JOYP4,
	; if 0, use JOYP5
	bit 0, d
	ld a, P1F_4 ; bit is 1
	jr nz, .got_bit
	ld a, P1F_5 ; bit is 0
.got_bit
	ld [$ff00+c], a
	ld a, P1F_4 | P1F_5
	ld [$ff00+c], a
	rr d ; rotate byte for next bit
	dec e
	jr nz, .loop_bits
	dec b
	jr nz, .loop_packet_bytes

	; stop bit
	ld a, P1F_5
	ld [$ff00+c], a
	ld a, P1F_4 | P1F_5
	ld [$ff00+c], a

	pop bc
	dec b
	ret z ; no more packets
	call SGBWait_Long
	jr .loop_packets

; waits a total of about 70'000 cycles
SGBWait_Long:
	ld de, 7000
	; wastes 10 cycles per loop
.loop_wait
	nop      ; 1 cycle
	nop      ; 1 cycle
	nop      ; 1 cycle
	dec de   ; 2 cycle
	ld a, d  ; 1 cycle
	or e     ; 1 cycle
	jr nz, .loop_wait ; 3 cycles (taken)
	ret

; waits a total of about 17'500 cycles
SGBWait_Short::
	ld de, 1750
.loop_wait
	nop      ; 1 cycle
	nop      ; 1 cycle
	nop      ; 1 cycle
	dec de   ; 2 cycle
	ld a, d  ; 1 cycle
	or e     ; 1 cycle
	jr nz, .loop_wait ; 3 cycles (taken)
	ret

; detects SGB through MULT_REQ command
; output:
; - carry set if SGB detected
_DetectSGB:
	ld hl, .MltReq_Enable
	call SGBTransfer
	call SGBWait_Long

	ldh a, [rJOYP]
	and P1F_0 | P1F_1
	cp P1F_0 | P1F_1
	jr nz, .detected
	ld a, P1F_5
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	call SGBWait_Long

	ld a, P1F_4 | P1F_5
	ldh [rJOYP], a
	call SGBWait_Long

	ld a, P1F_4
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	call SGBWait_Long

	ld a, P1F_4 | P1F_5
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	call SGBWait_Long

	ldh a, [rJOYP]
	and P1F_0 | P1F_1
	cp P1F_0 | P1F_1
	jr nz, .detected
	ld hl, .MltReq_Disable
	call SGBTransfer
	call SGBWait_Long
	sub a ; no carry
	ret

.detected
	ld hl, .MltReq_Disable
	call SGBTransfer
	call SGBWait_Long
	scf
	ret

.MltReq_Disable:
	sgb_mlt_req MLT_REQ_1P

.MltReq_Enable:
	sgb_mlt_req MLT_REQ_2P

; input:
; - hl = compressed data to transfer
; - de = SGB packet to send
SGBVRAMTransfer:
	; store current BGP to stack
	ld a, [wBGP]
	push af

	; overwrite BGP, needs to be set to $e4
	ld a, BGP_SGB_TRANSFER
	ld [wBGP], a
	ldh [rBGP], a

	push de
	ld de, vTiles1
	call Decompress

	; bg map needs to hold incremental values
	; $80, $81, $82...
	hlbgcoord 0, 0
	ld de, TILEMAP_WIDTH - SCREEN_WIDTH
	ld a, $80
	ld c, 13 ; number of rows to fill
.loop_rows
	ld b, SCREEN_WIDTH
.loop_bytes
	ld [hli], a
	inc a
	dec b
	jr nz, .loop_bytes
	; next row
	add hl, de
	dec c
	jr nz, .loop_rows

	; turn on BG
	ld a, LCDC_BG_ON
	ldh [rLCDC], a

	call StopTimerAndTurnLCDOn
	call SGBWait_Long
	pop hl

	; hl= input SGB packet to send
	call SGBTransfer
	call SGBWait_Long

	call Func_452

	; retrieve BGP from stack
	pop af
	ld [wBGP], a
	ldh [rBGP], a
	ret

Func_79ece:
	ld hl, .data
	ld bc, SGB_PACKET_SIZE
	ld e, 8 ; number of packets
.loop
	push hl
	push bc
	push de
	call SGBTransfer
	call SGBWait_Long
	pop de
	pop bc
	pop hl
	add hl, bc
	dec e
	jr nz, .loop
	ret

	ret ; stray ret

.data
	sgb_data_snd $81b, $00, $ea, $ea, $ea, $ea, $ea, $a9, $01, $cd, $4f, $0c, $d0
	sgb_data_snd $826, $00, $39, $cd, $48, $0c, $d0, $34, $a5, $c9, $c9, $80, $d0
	sgb_data_snd $831, $00, $0c, $a5, $ca, $c9, $7e, $d0, $06, $a5, $cb, $c9, $7e
	sgb_data_snd $83c, $00, $f0, $12, $a5, $c9, $c9, $c8, $d0, $1c, $a5, $ca, $c9
	sgb_data_snd $847, $00, $c4, $d0, $16, $a5, $cb, $c9, $05, $d0, $10, $a2, $28
	sgb_data_snd $852, $00, $a9, $e7, $9f, $01, $c0, $7e, $e8, $e8, $e8, $e8, $e0
	sgb_data_snd $85d, $00, $8c, $d0, $f4, $60
	sgb_data_snd $810, $00, $4c, $20, $08, $ea, $ea, $ea, $ea, $ea, $60, $ea, $ea

InitSGB:
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	; init SGB packet to send
	xor a
	ld hl, wSGBPacket
	ld bc, SGB_PACKET_SIZE
	call FillHL
	call SGBWait_Long

	; show black screen
	ld d, MASK_EN_BLANK_COLOR0
	call SGB_MaskEn

	; set SGB WRAM
	call Func_79ece

	ld hl, SGBPacket_MltReq_2Players
	call SGBTransfer
	call SGBWait_Long

	; send pal data
	ld hl, $7274
	ld de, SGBPacket_PalTrn
	call SGBVRAMTransfer

	; send ATF data
	ld hl, $6f8a
	ld de, SGBPacket_AttrTrn
	call SGBVRAMTransfer

	; send character data
	ld hl, wSGBPacket
	ld a, CHR_TRN_CMD
	inc a ; length 1
	ld [hli], a
	ld [hl], $0 ; tiles $00-$7F
	inc hl
	xor a
	ld bc, SGB_PACKET_SIZE - 2
	call FillHL
	ld hl, $60d7
	ld de, wSGBPacket
	call SGBVRAMTransfer

	ld hl, wSGBPacket
	ld a, CHR_TRN_CMD
	inc a ; length 1
	ld [hli], a
	ld [hl], $1 ; tiles $80-$FF
	inc hl
	xor a
	ld bc, SGB_PACKET_SIZE - 2
	call FillHL
	ld hl, $6b24
	ld de, wSGBPacket
	call SGBVRAMTransfer

	; border tile map and palette data
	ld hl, $6cc1
	ld de, SGBPacket_PctTrn
	call SGBVRAMTransfer

	ld hl, SGBPacket_PalPri_Enable
	call SGBTransfer
	ret

DetectSGB:
	call _DetectSGB
	ld a, 0
	rla
	ld [wSGBEnabled], a
	ret

; input:
; - d = MASK_EN_* constant
SGB_MaskEn::
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	ld hl, wSGBPacket
	ld a, MASK_EN_CMD
	inc a ; length
	ld [hli], a
	ld [hl], d

	ld hl, wSGBPacket
	call SGBTransfer
	call SGBWait_Long
	ret

; input:
; - e = SGB_PALS_* constant
SGBSetPalette_WithoutATF::
	xor a ; no ATF
	ldh [hff84], a
	call Func_7a039
	ret z
	jp SGBWait_Long

; input:
; - e = SGB_PALS_* constant
SGBSetPalette_WithoutATF_NoWait::
	xor a ; no ATF
	ldh [hff84], a
	jr Func_7a039

; input:
; - e = ATF to set
Func_7a011::
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	ld a, $80 ; apply ATF
	ldh [hff84], a
	ld a, e
	ld [wdefe], a
	ld a, [wBGP]
	or a
	ld a, SGB_PALS_34
	jr z, .got_pal_id
	ld a, SGB_PALS_35
.got_pal_id
	call _SGBPaletteSet
	jp SGBWait_Long

; input:
; - e = SGB_PALS_* constant (coincides with SGB_ATF_*)
SGBPaletteSet_WithATF::
	call SGBSetPalette_WithATF_NoWait
	ret z
	jp SGBWait_Long

SGBSetPalette_WithATF_NoWait:
	ld a, $80 ; apply ATF
	ldh [hff84], a
;	fallthrough

; input:
; - e = SGB_PALS_* constant (coincides with SGB_ATF_*)
; - [hff84] = additional palette set flags
Func_7a039:
	ld a, [wSGBEnabled]
	or a
	ret z
	ld a, e
	ld [wdefe], a
;	fallthrough

; requests SGB to set the pre-loaded palettes from SNES WRAM
; uses as input a palette group, which includes 4 (consecutive) palettes
; input:
; - a = SGB_PALS_* constant
; - e = ATF to set
; - [hff84] = additional palette set flags
_SGBPaletteSet:
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl ; *4
	ld c, l
	ld b, h
	ld hl, wSGBPacket
	ld [hl], PAL_SET_CMD | 1
	inc hl
	ld a, 4 ; num of pals
.loop_pals
	ld [hl], c
	inc hl
	ld [hl], b
	inc hl
	inc bc ; next pal ID
	dec a
	jr nz, .loop_pals
	ldh a, [hff84]
	or e
	ld [hli], a

	; fill rest of packet with 0
	xor a
	ld bc, $6
	call FillHL

	ld hl, wSGBPacket
	call SGBTransfer
	xor a
	inc a
	ret

; input:
; - e = SGB_SFX_*
SGBPlaySFX:
	ld a, [wSGBEnabled]
	or a
	ret z ; no SGB

	ld hl, SGBSFXPackets
	swap e
	ld a, e
	and $f0
	ld c, a
	ld a, e
	and $0f
	ld b, a
	; bc = e * 16
	add hl, bc
	call SGBTransfer
	call SGBWait_Long
	ret

SGBPacket_MltReq_2Players:
	sgb_mlt_req MLT_REQ_2P

SGBPacket_PalPri_Enable:
	sgb_pal_pri PAL_PRI_ENABLE

SGBPacket_PalTrn:
	sgb_pal_trn

SGBPacket_PctTrn:
	sgb_pct_trn

SGBPacket_AttrTrn:
	sgb_attr_trn
; 0x7a0d7

SECTION "Func_7badf", ROMX[$7adf], BANK[$1e]

SGBSFXPackets:
	table_width SGB_PACKET_SIZE
	sgb_sound_b SGBSOUNDB_STOP, 0, 0           ; SGB_SFX_STOP
	sgb_sound_a SGBSOUNDA_SMALL_LASER, 3, 0    ; SGB_SFX_LASER
	sgb_sound_a SGBSOUNDA_PIC_FLOATS, 3, 0     ; SGB_SFX_PIC_FLOATS
	sgb_sound_a SGBSOUNDA_SWORD_SWING, 1, 0    ; SGB_SFX_SWORD_SWING
	sgb_sound_b SGBSOUNDB_WIND, 0, 1           ; SGB_SFX_WIND_HIGH
	sgb_sound_b SGBSOUNDB_WAVE, 2, 2           ; SGB_SFX_WAVE
	sgb_sound_b SGBSOUNDB_APPLAUSE_SMALL, 3, 0 ; SGB_SFX_APPLAUSE
	sgb_sound_b SGBSOUNDB_WIND, 0, 0           ; SGB_SFX_WIND_LOW
	sgb_sound_b SGBSOUNDB_THUNDERSTORM, 3, 2   ; SGB_SFX_THUNDERSTORM
	sgb_sound_b SGBSOUNDB_LIGHTNING, 0, 1      ; SGB_SFX_LIGHTNING
	assert_table_length NUM_SGB_SFX

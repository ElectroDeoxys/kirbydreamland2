INCLUDE "vram.asm"

SECTION "WRAM0", WRAM0

wVirtualOAM:: ; c000
	ds $4 * OAM_COUNT
wVirtualOAMEnd::


SECTION "WRAM0@cd00", WRAM0[$cd00]

wBGP::  db ; cd00
wOBP0:: db ; cd01
wOBP1:: db ; cd02


SECTION "Audio WRAM", WRAM0[$ce00]

wce00:: ; ce00
	db

wce01:: ; ce01
	db

wce02:: ; ce02
	db

wSFXActiveChannelFlags:: ; ce03
	db

wce04:: ; ce04
	db

	ds $1

; these are the final channel configurations
; that are applied to the actual hardware
wChannels::
wChannel1:: channel1_struct wChannel1 ; ce06
wChannel2:: channel2_struct wChannel2 ; ce0c
wChannel3:: channel3_struct wChannel3 ; ce10
wChannel4:: channel4_struct wChannel4 ; ce16
wChannelsEnd::

wSFXChannels::
wSFXChannel1:: channel1_struct wSFXChannel1 ; ce1a
wSFXChannel2:: channel2_struct wSFXChannel2 ; ce20
wSFXChannel3:: channel3_struct wSFXChannel3 ; ce24
wSFXChannel4:: channel4_struct wSFXChannel4 ; ce2a
wSFXChannelsEnd::

wMusicChannels::
wMusicChannel1:: channel1_struct wMusicChannel1 ; ce2e
wMusicChannel2:: channel2_struct wMusicChannel2 ; ce34
wMusicChannel3:: channel3_struct wMusicChannel3 ; ce38
wMusicChannel4:: channel4_struct wMusicChannel4 ; ce3e
wMusicChannelsEnd::

wChannelPans:: ; ce42
	ds NUM_CHANNELS

wChannelSelectorOffsets:: ; ce4a
	ds NUM_CHANNELS

wAudioCommandDurations:: ; ce52
	ds NUM_CHANNELS

wAudioCommandPointersLo:: ; ce5a
	ds NUM_CHANNELS

wAudioCommandPointersHi:: ; ce62
	ds NUM_CHANNELS

wInstrumentCommandDurations:: ; ce6a
	ds NUM_CHANNELS

wInstrumentAudioCommandPointersLo:: ; ce72
	ds NUM_CHANNELS

wInstrumentAudioCommandPointersHi:: ; ce7a
	ds NUM_CHANNELS

wInstrumentSustain:: ; ce82
	ds NUM_CHANNELS

wChannelBaseNotes:: ; ce8a
	ds NUM_CHANNELS

wInstrumentSustainLength:: ; ce92
	ds NUM_CHANNELS

; low nybble is note and instrument volume
; high nybble is base volume of track
wChannelVolumes:: ; ce9a
	ds NUM_CHANNELS

wChannelInstruments:: ; cea2
	ds NUM_CHANNELS

wChannelTempoModes:: ; ceaa
	ds NUM_CHANNELS

wNoteFrequencyTables:: ; ceb2
	ds NUM_CHANNELS

; low byte of the pointer in wAudioStack
; corresponding to each channel
wAudioStackPointers:: ; ceba
	ds NUM_CHANNELS

; low byte of the pointer in wAudioStack
; corresponding to each channel's instrument
wInstrumentStackPointers:: ; cec2
	ds NUM_CHANNELS

wChannelSFXFlags:: ; ceca
	ds NUM_SFX_CHANNELS

wChannelSoundPriorities:: ; cece
	ds NUM_MUSIC_CHANNELS

wWaveSample:: ; ced2
	db

SECTION "WRAM1", WRAMX


SECTION "WRAM1@d700", WRAMX[$d700], BANK[$1]

wd700:: ; d700
	ds $100

wd800:: ; d800
	ds $100

wd900:: ; d900
	ds $100

SECTION "WRAM1@da0d", WRAMX[$da0d], BANK[$1]

; whether Timer interrupt has occurred
wTimerExecuted:: ; da0d
	db

	ds $13 - $e

; called during Stat interrupt handler
; has a jump instruction to some variable function
wStatTrampoline:: ; da13
	ds $3

; function pointer, starts with StatHandler_Default
wda16:: ; da16
	dw

	ds $1c - $18

wda1c:: ; da1c
	db

	ds $21 - $1d

wda21:: ; da21
	dw

	ds $6

wda29:: ; da29
	db

	ds $6

wda30:: ; da30
	dw

	ds $a - $2

wda3a:: db ; da3a
wda3b:: db ; da3b
wda3c:: dw ; da3c

wJoypad1:: ; da3e
	joypad_struct wJoypad1
wJoypad2:: ; da42
	joypad_struct wJoypad2

SECTION "WRAM1@dd64", WRAMX[$dd64], BANK[$1]

; each channel has 2 stacks
; one for the general audio commands
; and another specific for the instrument attack/release scripts
wAudioStack:: ; dd64
wChannel1Stack:: ; dd64
	channel_stack_struct wChannel1Stack
wChannel2Stack:: ; dd74
	channel_stack_struct wChannel2Stack
wChannel3Stack:: ; dd84
	channel_stack_struct wChannel3Stack
wChannel4Stack:: ; dd94
	channel_stack_struct wChannel4Stack
wChannel5Stack:: ; dda4
	channel_stack_struct wChannel5Stack
wChannel6Stack:: ; ddb4
	channel_stack_struct wChannel6Stack
wChannel7Stack:: ; ddc4
	channel_stack_struct wChannel7Stack
wChannel8Stack:: ; ddd4
	channel_stack_struct wChannel8Stack

wCurMusic:: ; dde4
	db

; WaveSamples is copied here
wWaveSamples:: ; dde5
	ds NUM_WAVEFORMS * $10

SECTION "WRAM1@de15", WRAMX[$de15], BANK[$1]

; TempoModeDurations is copied here
wTempoModeDurations:: ; de15
	ds NUM_TEMPO_MODES * $6

SECTION "WRAM1@deed", WRAMX[$deed], BANK[$1]

; if TRUE, then SGB was detected
wSGBEnabled:: ; deed
	db

; packet of data to send to SGB
wSGBPacket:: ; deee
	ds SGB_PACKET_SIZE

SECTION "Stack", WRAMX

wStack:: ; dfc0
	ds $40 ; just guessing the size
wStackTop::

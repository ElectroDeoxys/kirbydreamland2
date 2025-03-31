SECTION "WRAM0", WRAM0

wVirtualOAM:: ; c000
	ds $4 * OAM_COUNT
wVirtualOAMEnd::

SECTION "WRAM0@c200", WRAM0[$c200]

wc200:: ; c200
	ds $100

wc300:: ; c300
	ds $100

wc400:: ; c400
	ds $100

wc500:: ; c500
	ds $100

SECTION "WRAM0@cd00", WRAM0[$cd00]

wBGOBPals::
wBGP::  db ; cd00
wOBP0:: db ; cd01
wOBP1:: db ; cd02
wBGOBPalsEnd::

wcd03:: db ; cd03
wcd04:: db ; cd04
wcd05:: db ; cd05

wcd06:: db ; cd06
wcd07:: db ; cd07
wcd08:: db ; cd08

wcd09:: db ; cd09
wcd0a:: db ; cd0a
wcd0b:: db ; cd0b

wcd0c:: ; cd0c
	db

	ds $2d - $d

wcd2d:: ; cd2d
	db

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

	ds $f00 - $ed3

wcf00:: ; cf00
	ds $100


SECTION "WRAM1", WRAMX

SECTION "WRAM1@d060", WRAMX[$d060], BANK[$1]

wd060:: ; d060
	ds SCRN_VX_B

wd080:: ; d080
	ds SCRN_VX_B

SECTION "WRAM1@d700", WRAMX[$d700], BANK[$1]

wd700:: ; d700
	ds $100

wd800:: ; d800
	ds $100

wd900:: ; d900
	ds $100

wda00:: db ; da00
wda01:: db ; da01

wScroll1::
wSCY1:: db ; da02
wSCX1:: db ; da03

wScroll2::
wSCY2:: db ; da04
wSCX2:: db ; da05

wda06:: db ; da06
wda07:: db ; da07

wda08:: ; da08
	db

wda09:: ; da09
	db

wda0a:: db ; da0a
wda0b:: db ; da0b

wda0c:: ; da0c
	db

; whether Timer interrupt has occurred
wTimerExecuted:: ; da0d
	db

wda0e:: ; da0e
	db

wda0f:: ; da0f
	db

; has a jump instruction to some variable function
wVBlankTrampoline:: ; da10
	ds $3

; called during Stat interrupt handler
; has a jump instruction to some variable function
wStatTrampoline:: ; da13
	ds $3

; function pointer, starts with StatHandler_Default,
; V-blank handler will overwrite current wStatTrampoline
; function with this
wNextStatTrampoline:: ; da16
	dw

; V-blank caches regular stack pointer here,
; at the end of the execution sp is restored
wVBlankCachedSP2:: ; da18
	dw

wda1a:: ; da1a
	dw

wda1c:: ; da1c
	db

	ds $1

wda1e:: ; da1e
	db

	ds $1

wda20:: ; da20
	dw

wda22:: ; da22
	db

wda23:: db ; da23
wda24:: db ; da24

; V-blank caches regular stack pointer here,
; at the end of the execution sp is restored
wVBlankCachedSP1:: ; da25
	dw

wda27:: ; da27
	db

wda28:: ; da28
	db

wLYC:: ; da29
	db

	ds $1

; if TRUE, V-blank will disable object display
wObjDisabled:: ; da2b
	db

	ds $1

wScreenSectionSCX:: ; da2d
	db

	ds $2

wda30:: ; da30
	dw

wda32:: ; da32
	db

wda33:: ; da33
	db

wda34:: ; da34
	db

wda35:: ; da35
	db

wda36:: ; da36
	db

wda37:: ; da37
	db

wda38:: ; da38
	db

wda39:: ; da39
	db

wDemoActive:: db ; da3a
wDemoInputDuration:: db ; da3b
wDemoInputPtr:: dw ; da3c

wJoypad1:: ; da3e
	joypad_struct wJoypad1
wJoypad2:: ; da42
	joypad_struct wJoypad2

wda46:: ; da46
	db

wda47:: ; da47
	db

wda48:: ; da48
	db

wda49:: ; da49
	db

wda4a:: ; da4a
	db

SECTION "WRAM1@db38", WRAMX[$db38], BANK[$1]

wdb38:: ; db38
	db

wdb39:: ; db39
	db

	ds $d - $a

wdb3d:: ; db3d
	db

wdb3e:: ; db3e
	db

	ds $45 - $3f

wdb45:: ; db45
	dw

wdb47:: ; db47
	dw

wdb49:: ; db49
	dw

wdb4b:: ; db4b
	dw

	ds $51 - $4d

wdb51:: dw ; db51
wdb53:: dw ; db53

wdb55:: ; db55
	db

wdb56:: ; db56
	db

	ds $9 - $7

wdb59:: ; db59
	db

	ds $c - $a

wdb5c:: ; db5c
	db

	ds $60 - $5d

wdb60:: ; db60
	db

	ds $6a - $61

wdb6a:: ; db6a
	db

SECTION "WRAM1@dd2d", WRAMX[$dd2d], BANK[$1]

wdd2d:: ; dd2d
	db

wdd2e:: ; dd2e
	db

	ds $63 - $2f

wdd63:: ; dd63
	db

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

SECTION "WRAM1@dede", WRAMX[$dede], BANK[$1]

wdede:: ; dede
	db

wdedf:: ; dedf
	db

wdee0:: ; dee0
	db

	ds $ed - $e1

; if TRUE, then SGB was detected
wSGBEnabled:: ; deed
	db

; packet of data to send to SGB
wSGBPacket:: ; deee
	ds SGB_PACKET_SIZE

wdefe:: ; defe
	db

wNextDemo:: ; deff
	db

wTitleScreenDemoTimer:: ; df00
	dw

wdf02:: ; df02
	db

wdf03:: ; df03
	db

	ds $a - $4

wdf0a:: ; df0a
	db

	ds $11 - $b

wdf11:: ; df11
	db

	ds $32 - $12

wdf32:: ; df32
	db

wdf33:: ; df33
	db

SECTION "Stack", WRAMX

wStack:: ; dfc0
	ds $40 ; just guessing the size
wStackTop::

SECTION "WRAM0", WRAM0

wVirtualOAM1:: ; c000
	ds $4 * OAM_COUNT
wVirtualOAM1End::

SECTION "WRAM0@c100", WRAM0[$c100]

wVirtualOAM2:: ; c100
	ds $4 * OAM_COUNT
wVirtualOAM2End::

SECTION "WRAM0@c200", WRAM0[$c200]

wc200:: ; c200
	ds $100

wc300:: ; c300
	ds $100

; holds several entries to process in ProcessBGMapQueue
; each entry consists of a pointer in BG map,
; the number of tiles indices to copy over and the
; tile index data (copied continuously in a line)
wBGMapQueue:: ; c400
	ds $100

wc500:: ; c500
	ds $100

SECTION "WRAM0@c900", WRAM0[$c900]

wc900:: ; c900
	ds $100

wca00:: ds $100 ; ca00
wcb00:: ds $100 ; cb00
wcc00:: ds $100 ; cc00

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
	ds $8

wcd35:: ; cd35
	ds $8

wcd3d:: ; cd3d
	ds 2 * $8

wcd4d:: ; cd4d
	db

	ds $56 - $4e

wcd56:: ; cd56
	ds $18

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
	ds TILEMAP_WIDTH

wd080:: ; d080
	ds TILEMAP_WIDTH

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

; points to the next empty spot in a virtual OAM
; (either wVirtualOAM1 or wVirtualOAM2)
wVirtualOAMPtr:: ; da08
	dw

wda0a:: db ; da0a
wda0b:: db ; da0b

; if TRUE, then V-Blank has been
; executed for this frame
wVBlankExecuted:: ; da0c
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

wProcessBGMapQueueFunc:: ; da20
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

wda2c:: ; da2c
	db

wScreenSectionSCX:: ; da2d
	db

	ds $2

wRNG:: ; da30
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

SECTION "WRAM1@db36", WRAMX[$db36], BANK[$1]

wdb36:: ; db36
	dw

wdb38:: ; db38
	db

wdb39:: ; db39
	db

wdb3a:: ; db3a
	db

wdb3b:: ; db3b
	db

wdb3c:: ; db3c
	db

wdb3d:: ; db3d
	db

wdb3e:: ; db3e
	db

wdb3f:: ; db3f
	db

	ds $1

wdb41:: ; db41
	dw

wdb43:: ; db43
	dw

wdb45:: ; db45
	dw

wdb47:: ; db47
	dw

wdb49:: ; db49
	dw

wdb4b:: ; db4b
	dw

wdb4d:: ; db4d
	dw

wdb4f:: db ; db4f
wdb50:: db ; db50

wdb51:: dw ; db51
wdb53:: dw ; db53

wdb55:: ; db55
	db

wdb56:: ; db56
	db

wdb57:: ; db57
	db

wdb58:: ; db58
	db

wdb59:: ; db59
	db

wdb5a:: ; db5a
	db

wdb5b:: ; db5b
	db

wdb5c:: ; db5c
	db

wdb5d:: ; db5d
	db

wdb5e:: ; db5e
	db

wdb5f:: ; db5f
	db

wLevel:: ; db60
	db

wdb61:: ; db61
	db

wdb62:: ; db62
	ds $8

wdb6a:: ; db6a
	db

wdb6b:: ; db6b
	db

wdb6c:: ; db6c
	db

wdb6d:: ; db6d
	db

wdb6e:: ; db6e
	db

wdb6f:: ; db6f
	db

wdb70:: ; db70
	db

wdb71:: ; db71
	db

wdb72:: ; db72
	db

wdb73:: db ; db73
wdb74:: db ; db74
wdb75:: db ; db75
wdb76:: db ; db76
wdb77:: db ; db77

wdb78:: ; db78
	ds $3

wdb7b:: ; db7b
	db

wdb7c:: ; db7c
	db

wdb7d:: ; db7d
	db

wdb7e:: ; db7e
	db

wObjectOAMs:: ; db7f
ObjectOAM1:: obj_oam_struct ObjectOAM1 ; db7f
ObjectOAM2:: obj_oam_struct ObjectOAM2 ; db84
ObjectOAM3:: obj_oam_struct ObjectOAM3 ; db89
ObjectOAM4:: obj_oam_struct ObjectOAM4 ; db8e

	ds $d0 - $93

wdbd0:: ; dbd0
	ds $12c

	ds $1

wdcfd:: ; dcfd
	dw

SECTION "WRAM1@dd2d", WRAMX[$dd2d], BANK[$1]

wdd2d:: ; dd2d
	db

wdd2e:: ; dd2e
	db

	ds $59 - $2f

wdd59:: ; dd59
	db

	ds $1

wdd5b:: ; dd5b
	db

	ds $62 - $5c

wdd62:: ; dd62
	db

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

SECTION "WRAM1@dedb", WRAMX[$dedb], BANK[$1]

wScore:: ; dedb
	ds $3

wHUDUpdateFlags:: ; dede
	db

wdedf:: ; dedf
	db

wCopyAbility:: ; dee0
	db

wdee1:: ; dee1
	db

	ds $1

wdee3:: ; dee3
	db

wdee4:: ; dee4
	db

wdee5:: ; dee5
	db

wdee6:: dw ; dee6
wdee8:: db ; dee8
wdee9:: db ; dee9

wdeea:: ; deea
	db

wdeeb:: ; deeb
	db

wdeec:: ; deec
	db

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

wdf0b:: ; df0b
	db

wdf0c:: ; df0c
	db

wdf0d:: ; df0d
	db

wdf0e:: ; df0e
	db

wdf0f:: ; df0f
	db

wdf10:: ; df10
	db

wdf11:: ; df11
	db

wdf12:: ; df12
	db

wdf13:: ; df13
	db

wdf14:: ; df14
	db

wdf15:: ; df15
	db

	ds $32 - $16

wdf32:: ; df32
	db

wdf33:: ; df33
	db

SECTION "Stack", WRAMX

wStack:: ; dfc0
	ds $40 ; just guessing the size
wStackTop::

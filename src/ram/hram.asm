SECTION "HRAM 1", HRAM

UNION

hff80:: ; ff80
	dw

NEXTU

	ds $1

hff81:: ; ff81
	db

ENDU

hff82:: ; ff82
	db

hff83:: ; ff83
	db

hff84:: ; ff84
	db

hff85:: ; ff85
	db

hff86:: ; ff86
	db

hff87:: ; ff87
	db

SECTION "HRAM 2", HRAM

; size of wBGMapQueue in bytes
hBGMapQueueSize:: ; ff92
	db

; if bit 7 is set, then mirror sprite horizontally
hObjectOrientation:: db ; ff93
hOAMBaseTileID::     db ; ff94
hOAMFlags::          db ; ff95

; holds a ROM bank temporarily for general purposes
; (e.g. doing a far call, copying far bytes)
hTempROMBank:: ; ff96
	db

hff97:: ; ff97
	dw

wChannelConfigLowByte:: ; ff99
	db

hff9a:: ; ff9a
	db

hUpdateFuncTimer:: ; ff9b
	db

hff9c:: ; ff9c
	db

hff9d:: ; ff9d
	db

hff9e:: db ; ff9e
hff9f:: db ; ff9f

hffa0:: ; ffa0
	db

hffa1:: ; ffa1
	db

hffa2:: ; ffa2
	db

hffa3:: ; ffa3
	db

hROMBank:: db ; ffa4

hJoypad1:: ; ffa5
	joypad_struct hJoypad1
hJoypad2:: ; ffa9
	joypad_struct hJoypad2

	ds $ae - $ad

hffae:: ; ffae
	db

hffaf:: ; ffaf
	db

hffb0:: ; ffb0
	db

hffb1:: ; ffb1
	db

hffb2:: ; ffb2
	db

hffb3:: ; ffb3
	db

hffb4:: ; ffb4
	db

; if TRUE, then during V-Blank LCD is switched off
hRequestLCDOff:: ; ffb5
	db

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

	ds $1

hff84:: ; ff84
	db

	ds $2

hff87:: ; ff87
	db

SECTION "HRAM 2", HRAM

hff92:: ; ff92
	db

; if bit 7 is set, then mirror sprite horizontally
wObjectDirection:: db ; ff93
hOAMBaseTileID::   db ; ff94
hOAMFlags::        db ; ff95

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

hff9b:: ; ff9b
	db

hff9c:: ; ff9c
	db

hff9d:: ; ff9d
	db

	ds $a4 - $9e

hROMBank:: db ; ffa4

hJoypad1:: ; ffa5
	joypad_struct hJoypad1
hJoypad2:: ; ffa9
	joypad_struct hJoypad2

	ds $b5 - $ad

; if TRUE, then during V-Blank LCD is switched off
hRequestLCDOff:: ; ffb5
	db

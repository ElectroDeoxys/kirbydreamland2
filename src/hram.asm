SECTION "HRAM", HRAM

	ds $5

hff97:: dw ; ff97

	ds $b

hROMBank:: db ; ffa4

hJoypad1:: ; ffa5
	joypad_struct hJoypad1
hJoypad2:: ; ffa9
	joypad_struct hJoypad2

	ds $b5 - $ad

; if TRUE, then during V-Blank LCD is switched off
hRequestLCDOff:: ; ffb5
	db

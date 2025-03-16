INCLUDE "vram.asm"

SECTION "WRAM0", WRAM0

wVirtualOAM:: ; c000
	ds $4 * OAM_COUNT
wVirtualOAMEnd::

SECTION "WRAM0@cd00", WRAM0[$cd00]

wBGP::  db ; cd00
wOBP0:: db ; cd01
wOBP1:: db ; cd02

SECTION "WRAM1", WRAMX


SECTION "WRAM1@da13", WRAMX[$da13], BANK[$1]

; called during Stat interrupt handler
; has a jump instruction to some variable function
wStatTrampoline:: ; da13
	ds $3

; function pointer, starts with StatHandler_Default
wda16:: ; da16
	dw

SECTION "WRAM1@da30", WRAMX[$da30], BANK[$1]

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

SECTION "Stack", WRAMX

wStack:: ; dfc0
	ds $40 ; just guessing the size
wStackTop::

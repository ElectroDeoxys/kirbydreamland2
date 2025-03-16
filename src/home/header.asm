SECTION "RST38", ROM0

RST38:
	ret
; 0x39

SECTION "VBlank", ROM0

VBlank:
	push af
	push hl
	push bc
	push de
	jp _VBlank
; 0x47

SECTION "Stat", ROM0

Stat:
	jp wStatTrampoline
; 0x4b

SECTION "Timer", ROM0

Timer:
	push af
	push hl
	push bc
	push de
	jp _Timer
; 0x57

SECTION "Serial", ROM0

Serial:
	reti
; 0x59

SECTION "Joypad", ROM0

Joypad:
	reti
; 0x61

SECTION "Start", ROM0

Start:
	nop
	jp _Start

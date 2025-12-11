_Start:
	di
	ld a, BANK(Init)
	ld [rROMB0 + $100], a
	jp Init

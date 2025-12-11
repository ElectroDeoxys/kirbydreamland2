; to turn LCD off, render a frame, send a freeze mask to SGB
; and start timer in order to update audio
TurnLCDOff::
	call Func_496
	call Func_4ae
	call DoFrame

	ld d, MASK_EN_FREEZE
	farcall SGB_MaskEn
	farcall SGBWait_Short
;	fallthrough

StartTimerAndTurnLCDOff::
	ld a, TRUE
	ldh [hRequestLCDOff], a
.wait_lcd_off
	ldh a, [hRequestLCDOff]
	or a
	jr nz, .wait_lcd_off

	di
	ld hl, rIF
	res B_IF_VBLANK, [hl]
	res B_IF_STAT, [hl]
	; set Timer to be executed as soon as possible
	ld a, -1
	ldh [rTIMA], a
	; start Timer
	ld a, TAC_START | TAC_4KHZ
	ldh [rTAC], a
	ei
	ret

; to turn LCD on, stop timer (since audio update will happen in V-Blank)
; and send mask cancel command to SGB
TurnLCDOn::
	call StopTimerAndTurnLCDOn
	farcall SGBWait_Short
	ld d, MASK_EN_CANCEL
	farcall SGB_MaskEn
	ret

StopTimerAndTurnLCDOn::
	ld hl, wTimerExecuted
	ld [hl], FALSE

	; stay in low power mode
	; until timer is executed
.wait_timer
	halt
	bit 0, [hl]
	jr z, .wait_timer

	xor a ; TAC_STOP
	ldh [rTAC], a
	ld hl, rLCDC
	set B_LCDC_ENABLE, [hl]
	ret

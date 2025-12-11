SECTION "_Timer", ROM0[$333]

; the function of the timer is to update audio when LCD is off
; normally, audio update happens in V-Blank
; the timer is set to update at more or less same frequency
; as LCD update (~60 Hz), so even when LCD is off, audio is
; still updated at the same frequency
_Timer:
	ld a, TRUE
	ld [wTimerExecuted], a
	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a
	jp z, UpdateAudio ; lcd off
	jp InterruptRet

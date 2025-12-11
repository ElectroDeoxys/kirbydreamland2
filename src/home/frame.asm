VBlankHandler_Default::
StatHandler_Default::
Func_342:
	ret

DoFrame::
	ld hl, wVBlankExecuted
.loop_wait_vblank
	di
	bit 0, [hl]
	jr nz, .vblank_executed
	halt
	ei
	jr .loop_wait_vblank
.vblank_executed
	ei
	ld [hl], FALSE ; wVBlankExecuted
	ld hl, wFrameCounter
	inc [hl]
	ret

	const_def

	const SCRIPT_END_CMD ; $00
MACRO script_end
	db SCRIPT_END_CMD
ENDM

	const SET_FRAME_CMD ; $01
MACRO set_frame
	db SET_FRAME_CMD
	db \1 ; frame
ENDM

	const UNK02_CMD ; $02

	const UNK03_CMD ; $03
MACRO unk03_cmd
	db UNK03_CMD
	dw \1
	db BANK(\1) | $40
ENDM

	const SET_OAM_CMD ; $04
MACRO set_oam
	db SET_OAM_CMD
IF _NARG == 1
	dab \1 ; oam data
ELSE
	dw \1
	db \2
ENDC
ENDM

	const WAIT_CMD ; $05
MACRO wait
	db WAIT_CMD
	db \1 ; number of frames
ENDM

	const JUMP_CMD ; $06
MACRO jump
	db JUMP_CMD
	dw \1 ; address
ENDM

	const SET_X_VEL_CMD ; $07
MACRO set_x_vel
	db SET_X_VEL_CMD
	dw \1 ; velocity
ENDM

	const SET_Y_VEL_CMD ; $08
MACRO set_y_vel
	db SET_Y_VEL_CMD
	dw \1 ; velocity
ENDM

	const REPEAT_CMD ; $09
MACRO repeat
	db REPEAT_CMD
	db \1 ; number of repetitions
ENDM

	const REPEAT_END_CMD ; $0a
MACRO repeat_end
	db REPEAT_END_CMD
ENDM

	const CALL_CMD ; $0b
MACRO script_call
	db CALL_CMD
	dw \1 ; call address
ENDM

	const RET_CMD ; $0c
MACRO script_ret
	db RET_CMD
ENDM

	const EXEC_ASM_CMD ; $0d
MACRO exec_asm
	db EXEC_ASM_CMD
	dw \1 ; function to execute
ENDM

MACRO create_object
	exec_asm Func_f50
	db \1
	db \2, \3 ; object groups
ENDM

MACRO exec_func_f77
	exec_asm Func_f77
	db \1 ; ?
ENDM

MACRO set_frame_with_orientation
	exec_asm Func_7b2b
	db \1, \2 ; frames
ENDM

	const VAR_JUMPTABLE_CMD ; $0e
MACRO var_jumptable
	db VAR_JUMPTABLE_CMD
	db \1 ; number of entries
ENDM

	const SET_FIELD_CMD ; $0f
MACRO set_field
	db SET_FIELD_CMD
	db \1 ; which field
	db \2 ; value
ENDM

	const SET_VAR_TO_FIELD_CMD ; $10
MACRO set_var_to_field
	db SET_VAR_TO_FIELD_CMD
	db \1 ; which field
ENDM

	const JUMP_IF_NOT_VAR_CMD ; $11
MACRO jump_if_not_var
	db JUMP_IF_NOT_VAR_CMD
	dw \1 ; address
ENDM

	const JUMP_IF_VAR_CMD ; $12
MACRO jump_if_var
	db JUMP_IF_VAR_CMD
	dw \1 ; address
ENDM

	const UNK13_CMD ; $13

	const JUMP_IF_VAR_LT_CMD ; $14
MACRO jump_if_var_lt
	db JUMP_IF_VAR_LT_CMD
	db \1 ; value
	dw \2 ; address
ENDM

	const WAIT_VAR_CMD ; $15
MACRO wait_var
	db WAIT_VAR_CMD
ENDM

	const SCRIPT_STOP_CMD ; $16
MACRO script_stop
	db SCRIPT_STOP_CMD
ENDM

	const SET_DRAW_FUNC_CMD ; $17
MACRO set_draw_func
	db SET_DRAW_FUNC_CMD
	dw \1 ; draw function
ENDM

	const UNK18_CMD ; $18

	const SET_FRAME_WAIT_CMD ; $19
MACRO set_frame_wait
	db SET_FRAME_WAIT_CMD
	db \1 ; frame
	db \2 ; number of frames
ENDM

	const SET_FIELD_TO_VAR_CMD ; $1a
MACRO set_field_to_var
	db SET_FIELD_TO_VAR_CMD
	db \1 ; which field
ENDM

	const FAR_JUMP_CMD ; $1b
MACRO far_jump
	db FAR_JUMP_CMD
	dab \1 ; address
ENDM

	const UNK1C_CMD ; $1c
	const UNK1D_CMD ; $1d
	const UNK1E_CMD ; $1e
	const UNK1F_CMD ; $1f

	const SET_X_CMD ; $20
MACRO set_x
	db SET_X_CMD
	dw \1 ; x position
ENDM

	const SET_Y_CMD ; $21
MACRO set_y
	db SET_Y_CMD
	dw \1 ; y position
ENDM

	const UNK22_CMD ; $22
	const UNK23_CMD ; $23

	const PLAY_SFX_CMD ; $24
MACRO play_sfx
	db PLAY_SFX_CMD
	db \1 ; SFX
ENDM

	const UNK25_CMD ; $25
	const UNK26_CMD ; $26
	const UNK27_CMD ; $27
	const UNK28_CMD ; $28
	const UNK29_CMD ; $29

	const SET_Y_ACC_CMD ; $2a
MACRO set_y_acc
	db SET_Y_ACC_CMD
	db \1 ; acceleration
ENDM

DEF NUM_CMDS EQU const_value

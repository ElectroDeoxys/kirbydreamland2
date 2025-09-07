; copy ability constants

MACRO copy_ability
	const \1
DEF \1_ICON EQU const_value + 1
ENDM

	const_def
	copy_ability FIRE    ; $0
	copy_ability PARASOL ; $1
	copy_ability STONE   ; $2
	copy_ability CUTTER  ; $3
	copy_ability NEEDLE  ; $4
	copy_ability SPARK   ; $5
	copy_ability ICE     ; $6
DEF NUM_COPY_ABILITIES EQU const_value
	const_def $ff
	const NO_COPY_ABILITY ; $ff

; animal friend constants
	const_def 1
	const RICK ; $1
	const KINE ; $2
	const COO  ; $3
DEF NUM_ANIMAL_FRIENDS EQU const_value - 1

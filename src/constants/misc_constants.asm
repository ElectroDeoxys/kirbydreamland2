; Boolean checks
DEF FALSE EQU 0
DEF TRUE  EQU 1

	const_def
	const NO_DEMO ; $0
	const DEMO_1  ; $1
	const DEMO_2  ; $2
	const DEMO_3  ; $3
DEF NUM_DEMOS EQU const_value

; wHUDUpdateFlags constants
	const_def
	const UPDATE_SCORE_F        ; 0
	const UPDATE_KIRBY_HP_F     ; 1
	const UPDATE_LIVES_F        ; 2
	const UPDATE_COPY_ABILITY_F ; 3
	const UPDATE_BOSS_HP_F      ; 4
	const UPDATE_STARS_F        ; 5
	const UPDATE_LEVEL_F        ; 6

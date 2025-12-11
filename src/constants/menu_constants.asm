	const_def
	const FILE_1 ; $0
	const FILE_2 ; $1
	const FILE_3 ; $2
DEF NUM_FILES EQU const_value

; file structure
RSRESET
DEF FILESTRUCT_COMPLETION    RW     ; $00
DEF FILESTRUCT_CURRENT_LEVEL RB     ; $02
DEF FILESTRUCT_UNK03         RB $8  ; $03
DEF FILESTRUCT_UNK0B         RB     ; $0b
DEF FILESTRUCT_UNK0C         RB     ; $0c
DEF FILESTRUCT_UNK0D         RB     ; $0d
DEF FILESTRUCT_UNK0E         RB     ; $0e
DEF FILESTRUCT_UNK0F         RB     ; $0f
DEF FILESTRUCT_UNK10         RB     ; $10
DEF FILESTRUCT_LIVES         RB     ; $11
DEF FILESTRUCT_HP            RB     ; $12
DEF FILESTRUCT_UNK13         RB     ; $13
DEF FILESTRUCT_UNK14         RB     ; $14
DEF FILESTRUCT_COPY_ABILITY  RB     ; $15
DEF FILESTRUCT_ANIMAL_FRIEND RB     ; $16
DEF FILESTRUCT_SCORE         RB $3  ; $17
DEF FILESTRUCT_CHECKSUM1     RB     ; $1a
DEF FILESTRUCT_CHECKSUM2     RB     ; $1b
DEF FILESTRUCT_STRUCT_SIZE EQU _RS  ; $1c

; File Menu constants
	const_def
	const FILEMENU_1     ; $0
	const FILEMENU_2     ; $1
	const FILEMENU_3     ; $2
	const FILEMENU_ERASE ; $3

; wGameMode constants
	const_def
	const GAMEMODE_FILE_1         ; $0
	const GAMEMODE_FILE_2         ; $1
	const GAMEMODE_FILE_3         ; $2
DEF SPECIAL_GAME_MODE EQU const_value
	const GAMEMODE_SOUND_TEST     ; $3
	const GAMEMODE_BOSS_ENDURANCE ; $4
	const GAMEMODE_BONUS_GAME     ; $5
	const GAMEMODE_DEMO           ; $6

; how many frames for Demo to
; start playing in the Title Screen
DEF DEMO_TIMER EQU 1598 ; ~26 seconds

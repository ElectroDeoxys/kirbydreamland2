	const_def
	const FILE_1     ; $0
	const FILE_2     ; $1
	const FILE_3     ; $2
DEF NUM_FILES EQU const_value

; file structure
RSRESET
DEF FILE_COMPLETION    RW     ; $00
DEF FILE_CURRENT_LEVEL RB     ; $02
DEF FILE_UNK03         RB $8  ; $03
DEF FILE_UNK0B         RB     ; $0b
DEF FILE_UNK0C         RB     ; $0c
DEF FILE_UNK0D         RB     ; $0d
DEF FILE_UNK0E         RB     ; $0e
DEF FILE_UNK0F         RB     ; $0f
DEF FILE_UNK10         RB     ; $10
DEF FILE_LIVES         RB     ; $11
DEF FILE_HP            RB     ; $12
DEF FILE_UNK13         RB     ; $13
DEF FILE_UNK14         RB     ; $14
DEF FILE_UNK15         RB     ; $15
DEF FILE_ANIMAL_FRIEND RB     ; $16
DEF FILE_SCORE         RB $3  ; $17
DEF FILE_CHECKSUM1     RB     ; $1a
DEF FILE_CHECKSUM2     RB     ; $1b
DEF FILE_STRUCT_SIZE EQU _RS  ; $1c

; File Menu constants
	const_def
	const FILE_SELECT_1     ; $0
	const FILE_SELECT_2     ; $1
	const FILE_SELECT_3     ; $2
	const FILE_SELECT_ERASE ; $3

; how many frames for Demo to
; start playing in the Title Screen
DEF DEMO_TIMER EQU 1598 ; ~26 seconds

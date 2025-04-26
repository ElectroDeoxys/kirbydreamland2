	const_def
	const FILE_1     ; $0
	const FILE_2     ; $1
	const FILE_3     ; $2
DEF NUM_FILES EQU const_value

; file structure
RSRESET
DEF FILE_COMPLETION    RW     ; $00
DEF FILE_CURRENT_LEVEL RB     ; $02
DEF FILE_UNK03         RB $17 ; $03
DEF FILE_CHECKSUM1     RB     ; $1a
DEF FILE_CHECKSUM2     RB     ; $1b
DEF FILE_STRUCT_SIZE EQU _RS

; File Menu constants
	const_def
	const FILE_SELECT_1     ; $0
	const FILE_SELECT_2     ; $1
	const FILE_SELECT_3     ; $2
	const FILE_SELECT_ERASE ; $3

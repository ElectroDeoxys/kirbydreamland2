; tile size
DEF tiles EQUS "* TILE_SIZE"
DEF tile  EQUS "+ TILE_SIZE *"

	const_def 0, 2
	const COL_0 ; 0
	const COL_1 ; 2
	const COL_2 ; 4
	const COL_3 ; 6

MACRO ldpal
ASSERT \2 < 4 && \3 < 4 && \4 < 4 && \5 < 4
	ld \1, (\2 << COL_0) | (\3 << COL_1) | (\4 << COL_2) | (\5 << COL_3)
ENDM

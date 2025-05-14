MACRO level
	db \1, \2 ; ?
	dn \4, \3
	dn \6, \5
	dn \8, \7
	dn \9, \<10>
	dwb \<11>, \<12>
	dwb \<13>, \<14>
	dwb \<15>, \<16>
	db \<17>
ENDM

SECTION "Data_4537a", ROMX[$537a], BANK[$11]

Data_4537a:
	level $02, $01, 1, 0, 1, 0, 10, 0, 0, 7, $5b5c, $16, $5365, $11, $48d1, $08, $00

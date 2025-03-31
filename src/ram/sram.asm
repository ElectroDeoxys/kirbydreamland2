SECTION "SRAM0", SRAM

sa000:: ; a000
	db

sa001:: ; a001
	db

	ds $2

sa004:: ; a004
	dw

sa006:: ; a006
	ds $d

	ds $51 - $13

sa051:: ; a051
	db

	ds $5b - $52

sa05b:: ; a05b
	db

	ds $71 - $5c

sa071:: ; a071
	db

	ds $82 - $72

sa082:: ; a082
	db

	ds $a1 - $83

sa0a1:: ; a0a1
	db

	ds $b3 - $a2

sa0b3:: ; a0b3
	db

	ds $101 - $b4

sa101:: ; a101
	db

	ds $ff

sa201:: ; a201
	db

	ds $ff

sa301:: ; a301
	db

	ds $ff

sa401:: ; a401
	db

	ds $ff

sa501:: ; a501
	db

	ds $ff

sa601:: ; a601
	db

	ds $ff

sa701:: ; a701
	db

	ds $ff

sa801:: ; a801
	db

	ds $ff

sa901:: ; a901
	db

	ds $ff

saa01:: ; aa01
	db

	ds $ff

sab01:: ; ab01
	db

	ds $ff

sac01:: ; ac01
	db

	ds $ff

sad01:: ; ad01
	db

	ds $ff

sae01:: ; ae01
	db

	ds $ff

saf01:: ; af01
	db

	ds $ff

sb001:: ; b001
	db

	ds $ff

sb101:: ; b101
	db

	ds $201 - $102

sb201:: ; b201
	db

	ds $300 - $202

sb300:: ; b300
	ds $100

	ds $c00 - $400

sDemoInputs:: ; bc00
	ds $100


SECTION "SRAM1", SRAM

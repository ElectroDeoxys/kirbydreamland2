MACRO joypad_struct
\1Down::    db
\1Pressed:: db
	db ; ?
	db ; ?
ENDM

MACRO obj_struct
\1Unk00:: db ; $00
\1Unk01:: db ; $01
\1Unk02:: db ; $02
\1Unk03:: db ; $03
\1Unk04:: dw ; $04
\1Unk06:: db ; $06
\1Unk07:: dw ; $07
\1Unk09:: dw ; $09
\1Unk0b:: dW ; $0b
\1Unk0d:: dw ; $0d
\1Unk0f:: dw ; $0f
\1Unk11:: db ; $11
\1Unk12:: db ; $12
\1Unk13:: db ; $13
\1Unk14:: db ; $14
\1Unk15:: db ; $15
\1Unk16:: db ; $16
\1Unk17:: dW ; $17
\1Unk19:: db ; $19
\1Unk1a:: dw ; $1a
\1Unk1c:: db ; $1c
\1Unk1d:: db ; $1d
\1Unk1e:: db ; $1e
\1Unk1f:: db ; $1f
\1Unk20:: db ; $20
\1Unk21:: db ; $21
\1Unk22:: dw ; $22
\1Unk24:: db ; $24
\1Unk25:: db ; $25
\1Unk26:: db ; $26
\1Unk27:: db ; $27
\1Unk28:: db ; $28
\1Unk29:: db ; $29
\1Unk2a:: db ; $2a
\1Unk2b:: db ; $2b
\1Unk2c:: db ; $2c
\1Unk2d:: db ; $2d
\1Unk2e:: db ; $2e
\1Unk2f:: db ; $2f
\1Unk30:: db ; $30
\1Unk31:: db ; $31
\1Unk32:: db ; $32
\1Unk33:: db ; $33
\1Unk34:: db ; $34
\1Unk35:: db ; $35
\1Unk36:: db ; $36
\1Unk37:: db ; $37
\1Unk38:: db ; $38
\1Unk39:: db ; $39
\1Unk3a:: db ; $3a
\1Unk3b:: db ; $3b
\1Unk3c:: db ; $3c
\1Unk3d:: db ; $3d
\1Unk3e:: db ; $3e
\1Unk3f:: db ; $3f
\1Unk40:: db ; $40
\1Unk41:: db ; $41
\1Unk42:: db ; $42
\1Unk43:: db ; $43
\1Unk44:: db ; $44
\1Unk45:: db ; $45
\1Unk46:: db ; $46
\1Unk47:: db ; $47
\1Unk48:: db ; $48
\1Unk49:: db ; $49
\1Unk4a:: dw ; $4a
\1Unk4c:: db ; $4c
\1Unk4d:: db ; $4d
\1Unk4e:: db ; $4e
\1Unk4f:: db ; $4f
\1Unk50:: db ; $50
\1Unk51:: db ; $51
\1Unk52:: db ; $52
\1Unk53:: db ; $53
\1Unk54:: db ; $54
\1Unk55:: db ; $55
\1Unk56:: db ; $56
\1Unk57:: db ; $57
\1Unk58:: db ; $58
\1Unk59:: db ; $59
\1Unk5a:: db ; $5a
\1Unk5b:: db ; $5b
\1Unk5c:: db ; $5c
\1Unk5d:: db ; $5d
\1Unk5e:: db ; $5e
\1Unk5f:: db ; $5f
\1Unk60:: db ; $60
\1Unk61:: db ; $61
\1Unk62:: db ; $62
\1Unk63:: db ; $63
\1Unk64:: db ; $64
\1Unk65:: db ; $65
\1Unk66:: db ; $66
\1Unk67:: db ; $67
\1Unk68:: db ; $68
\1Unk69:: db ; $69
\1Unk6a:: db ; $6a
\1Unk6b:: db ; $6b
\1Unk6c:: db ; $6c
\1Unk6d:: db ; $6d
\1Unk6e:: db ; $6e
\1Unk6f:: db ; $6f
\1Unk70:: db ; $70
\1Unk71:: db ; $71
\1Unk72:: db ; $72
\1Unk73:: db ; $73
\1Unk74:: db ; $74
\1Unk75:: db ; $75
\1Unk76:: db ; $76
\1Unk77:: db ; $77
\1Unk78:: db ; $78
\1Unk79:: db ; $79
\1Unk7a:: db ; $7a
\1Unk7b:: db ; $7b
\1Unk7c:: db ; $7c
\1Unk7d:: db ; $7d
\1Unk7e:: db ; $7e
\1Unk7f:: db ; $7f
\1Unk80:: db ; $80
\1Unk81:: db ; $81
\1Unk82:: db ; $82
\1Unk83:: db ; $83
\1Unk84:: db ; $84
\1Unk85:: db ; $85
\1Unk86:: db ; $86
\1Unk87:: db ; $87
\1Unk88:: db ; $88
\1Unk89:: db ; $89
\1Unk8a:: db ; $8a
\1Unk8b:: db ; $8b
\1Unk8c:: db ; $8c
\1Unk8d:: db ; $8d
\1Unk8e:: db ; $8e
\1Unk8f:: db ; $8f
\1Unk90:: db ; $90
\1Unk91:: db ; $91
\1Unk92:: db ; $92
\1Unk93:: db ; $93
\1Unk94:: db ; $94
\1Unk95:: db ; $95
\1Unk96:: db ; $96
\1Unk97:: db ; $97
\1Unk98:: db ; $98
\1Unk99:: db ; $99
\1Unk9a:: db ; $9a
\1Unk9b:: db ; $9b
\1Unk9c:: db ; $9c
\1Unk9d:: db ; $9d
\1Unk9e:: db ; $9e
\1Unk9f:: db ; $9f
\1Unka0:: db ; $a0
\1Unka1:: db ; $a1
\1Unka2:: db ; $a2
\1Unka3:: db ; $a3
\1Unka4:: db ; $a4
\1Unka5:: db ; $a5
\1Unka6:: db ; $a6
\1Unka7:: db ; $a7
\1Unka8:: db ; $a8
\1Unka9:: db ; $a9
\1Unkaa:: db ; $aa
\1Unkab:: db ; $ab
\1Unkac:: db ; $ac
\1Unkad:: db ; $ad
\1Unkae:: db ; $ae
\1Unkaf:: db ; $af
\1Unkb0:: db ; $b0
\1Unkb1:: db ; $b1
\1Unkb2:: db ; $b2
\1Unkb3:: db ; $b3
\1Unkb4:: db ; $b4
\1Unkb5:: db ; $b5
\1Unkb6:: db ; $b6
\1Unkb7:: db ; $b7
\1Unkb8:: db ; $b8
\1Unkb9:: db ; $b9
\1Unkba:: db ; $ba
\1Unkbb:: db ; $bb
\1Unkbc:: db ; $bc
\1Unkbd:: db ; $bd
\1Unkbe:: db ; $be
\1Unkbf:: db ; $bf
\1Unkc0:: db ; $c0
\1Unkc1:: db ; $c1
\1Unkc2:: db ; $c2
\1Unkc3:: db ; $c3
\1Unkc4:: db ; $c4
\1Unkc5:: db ; $c5
\1Unkc6:: db ; $c6
\1Unkc7:: db ; $c7
\1Unkc8:: db ; $c8
\1Unkc9:: db ; $c9
\1Unkca:: db ; $ca
\1Unkcb:: db ; $cb
\1Unkcc:: db ; $cc
\1Unkcd:: db ; $cd
\1Unkce:: db ; $ce
\1Unkcf:: db ; $cf
\1Unkd0:: db ; $d0
\1Unkd1:: db ; $d1
\1Unkd2:: db ; $d2
\1Unkd3:: db ; $d3
\1Unkd4:: db ; $d4
\1Unkd5:: db ; $d5
\1Unkd6:: db ; $d6
\1Unkd7:: db ; $d7
\1Unkd8:: db ; $d8
\1Unkd9:: db ; $d9
\1Unkda:: db ; $da
\1Unkdb:: db ; $db
\1Unkdc:: db ; $dc
\1Unkdd:: db ; $dd
\1Unkde:: db ; $de
\1Unkdf:: db ; $df
\1Unke0:: db ; $e0
\1Unke1:: db ; $e1
\1Unke2:: db ; $e2
\1Unke3:: db ; $e3
\1Unke4:: db ; $e4
\1Unke5:: db ; $e5
\1Unke6:: db ; $e6
\1Unke7:: db ; $e7
\1Unke8:: db ; $e8
\1Unke9:: db ; $e9
\1Unkea:: db ; $ea
\1Unkeb:: db ; $eb
\1Unkec:: db ; $ec
\1Unked:: db ; $ed
\1Unkee:: db ; $ee
\1Unkef:: db ; $ef
\1Unkf0:: db ; $f0
\1Unkf1:: db ; $f1
\1Unkf2:: db ; $f2
\1Unkf3:: db ; $f3
\1Unkf4:: db ; $f4
\1Unkf5:: db ; $f5
\1Unkf6:: db ; $f6
\1Unkf7:: db ; $f7
\1Unkf8:: db ; $f8
\1Unkf9:: db ; $f9
\1Unkfa:: db ; $fa
\1Unkfb:: db ; $fb
\1Unkfc:: db ; $fc
\1Unkfd:: db ; $fd
\1Unkfe:: db ; $fe
\1Unkff:: db ; $ff
ENDM

MACRO file_struct
\1Completion::   dw
\1CurrentLevel:: db
	ds $17
\1Checksum1::     db
\1Checksum2::     db
ENDM

MACRO channel1_struct
\1Sweep::    db
\1Length::   db
\1Envelope:: db
\1FreqLo::   db
\1FreqHi::   db
	ds $1
ENDM

MACRO channel2_struct
\1Length::   db
\1Envelope:: db
\1FreqLo::   db
\1FreqHi::   db
ENDM

MACRO channel3_struct
\1Enabled:: db
\1Length::  db
\1Level::   db
\1FreqLo::  db
\1FreqHi::  db
	ds $1
ENDM

MACRO channel4_struct
\1Length::    db
\1Envelope::  db
\1Frequency:: db
\1Control::   db
ENDM

MACRO channel_stack_struct
\1Instrument::
	ds $6
\1InstrumentBottom::
\1Audio::
	ds $a
\1AudioBottom::
ENDM

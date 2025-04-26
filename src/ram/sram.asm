SECTION "SRAM", SRAM

sObjects::
sObjectGroup1::
sa000:: obj_struct sa000 ; a000
sObjectGroup1End::
sObjectGroup2::
sa100:: obj_struct sa100 ; a100
sa200:: obj_struct sa200 ; a200
sa300:: obj_struct sa300 ; a300
sa400:: obj_struct sa400 ; a400
sa500:: obj_struct sa500 ; a500
sa600:: obj_struct sa600 ; a600
sa700:: obj_struct sa700 ; a700
sObjectGroup2End::
sObjectGroup3::
sa800:: obj_struct sa800 ; a800
sa900:: obj_struct sa900 ; a900
saa00:: obj_struct saa00 ; aa00
sab00:: obj_struct sab00 ; ab00
sac00:: obj_struct sac00 ; ac00
sad00:: obj_struct sad00 ; ad00
sae00:: obj_struct sae00 ; ae00
saf00:: obj_struct saf00 ; af00
sb000:: obj_struct sb000 ; b000
sb100:: obj_struct sb100 ; b100
sObjectGroup3End::
sb200:: obj_struct sb200 ; b200
sObjectsEnd::

sb300:: ; b300
	ds $100

	ds $b00 - $400

sbb00:: ; bb00
	ds $100

sDemoInputs:: ; bc00
	ds $100

	ds $200

sFileSaveData::
sFile1:: file_struct sFile1 ; bf00
sFile2:: file_struct sFile2 ; bf1c
sFile3:: file_struct sFile3 ; bf38

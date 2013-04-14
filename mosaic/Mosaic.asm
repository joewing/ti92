;+------------------------------------------------------+
;|		      Mosaic v1.0b3			|
;|		   by Joe Wingbermuehle			|
;|			3-28-1997			|
;+------------------------------------------------------+
;Requires:  flib and romlib
;(requires Mosaic.h to be assembled)

	@program	pcode,pname
	include		Mosaic.h

pcode:	;**** draw menu screen ****
	jsr		sscr
	SetFont		#1
	WriteStr	#50,#35,#4,m1
	WriteStr	#50,#45,#4,m2

menu:	;**** Wait for input ****
	jsr		flib[idle_loop]
	cmp		#268,d0
	beq		play	
	cmp		#264,d0
	bne		menu
	rts

sscr:	;**** setup screen ****
	jsr		flib[clr_scr]
	SetFont		#2
	WriteStr	#55,#2,#4,pname
	rts

play:	;**** Setup game ****
	; Init Vars
	move.b		#57,box1
	move.b		#57,box2
	move.b		#57,box3
	move.b		#57,box4
	move.b		#57,box5
	move.b		#57,box6
	move.b		#57,box7
	move.b		#57,box8
	move.b		#57,box9

	;**** Randomize Tiles ****
	jsr		getran
	move.b		d0,box1
	jsr		getran
	move.b		d0,box2
	jsr		getran
	move.b		d0,box3
	jsr		getran
	move.b		d0,box4
	jsr		getran
	move.b		d0,box5
	jsr		getran
	move.b		d0,box6
	jsr		getran
	move.b		d0,box7
	jsr		getran
	move.b		d0,box8
	jsr		getran
	move.b		d0,box9

	;**** Draw game screen ****
	jsr		sscr
	DrawBox		#20,#20,#110,#110
	DrawBox		#50,#20,#80,#110
	DrawBox		#20,#50,#110,#80
drscr:	WriteStr	#30,#30,#4,box1
	WriteStr	#30,#60,#4,box2
	WriteStr	#30,#90,#4,box3
	WriteStr	#60,#30,#4,box4
	WriteStr	#60,#60,#4,box5
	WriteStr	#60,#90,#4,box6
	WriteStr	#90,#30,#4,box7
	WriteStr	#90,#60,#4,box8
	WriteStr	#90,#90,#4,box9

	;**** Check for a win ****
	cmp.b		#49,box1
	bne		main
	cmp.b		#52,box2
	bne		main
	cmp.b		#55,box3
	bne		main
	cmp.b		#50,box4
	bne		main
	cmp.b		#53,box5
	bne		main
	cmp.b		#56,box6
	bne		main
	cmp.b		#51,box7
	bne		main
	cmp.b		#54,box8
	bne		main
	WriteStr	#130,#30,#4,win
wait1:	jsr		flib[idle_loop]
	cmp		#264,d0
	bne		wait1
	bra		pcode

main:	;**** Wait for input (Game) ****
	jsr		flib[idle_loop]
	cmp		#264,d0
	beq		pcode
	cmp		#55,d0
	beq		mv1
	cmp		#52,d0
	beq		mv2
	cmp		#49,d0
	beq		mv3
	cmp		#56,d0
	beq		mv4
	cmp		#53,d0
	beq		mv5
	cmp		#50,d0
	beq		mv6
	cmp		#57,d0
	beq		mv7
	cmp		#54,d0
	beq		mv8
	cmp		#51,d0
	beq		mv9
	bra		main

mv1:	;**** Move Tile ****
	cmp.b		#32,box2
	bne		sm1
	move.b		box1,box2
	bra		m1x
sm1:	cmp.b		#32,box4
	bne		main
	move.b		box1,box4
m1x:	move.b		#32,box1
	bra		drscr
mv2:
	cmp.b		#32,box1
	bne		sm2a
	move.b		box2,box1
	bra		m2x
sm2a:	cmp.b		#32,box3
	bne		sm2b
	move.b		box2,box3
	bra		m2x
sm2b:	cmp.b		#32,box5
	bne		main
	move.b		box2,box5
m2x:	move.b		#32,box2
	bra		drscr
mv3:
	cmp.b		#32,box2
	bne		sm3
	move.b		box3,box2
	bra		m3x
sm3:	cmp.b		#32,box6
	bne		main
	move.b		box3,box6
m3x:	move.b		#32,box3
	bra		drscr
mv4:
	cmp.b		#32,box1
	bne		sm4a
	move.b		box4,box1
	bra		m4x
sm4a:	cmp.b		#32,box5
	bne		sm4b
	move.b		box4,box5
	bra		m4x
sm4b:	cmp.b		#32,box7
	bne		main
	move.b		box4,box7
m4x:	move.b		#32,box4
	bra		drscr
mv5:
	cmp.b		#32,box2
	bne		sm5a
	move.b		box5,box2
	bra		m5x
sm5a:	cmp.b		#32,box4
	bne		sm5b
	move.b		box5,box4
	bra		m5x
sm5b:	cmp.b		#32,box6
	bne		sm5c
	move.b		box5,box6
	bra		m5x
sm5c:	cmp.b		#32,box8
	bne		main
	move.b		box5,box8
m5x:	move.b		#32,box5
	bra		drscr
mv6:
	cmp.b		#32,box3
	bne		sm6a
	move.b		box6,box3
	bra		m6x
sm6a:	cmp.b		#32,box5
	bne		sm6b
	move.b		box6,box5
	bra		m6x
sm6b:	cmp.b		#32,box9
	bne		main
	move.b		box6,box9
m6x:	move.b		#32,box6
	bra		drscr
mv7:	
	cmp.b		#32,box4
	bne		sm7
	move.b		box7,box4
	bra		m7x
sm7:	cmp.b		#32,box8
	bne		main
	move.b		box7,box8
m7x:	move.b		#32,box7
	bra		drscr
mv8:
	cmp.b		#32,box5
	bne		sm8a
	move.b		box8,box5
	bra		m8x
sm8a:	cmp.b		#32,box7
	bne		sm8b
	move.b		box8,box7
	bra		m8x
sm8b:	cmp.b		#32,box9
	bne		main
	move.b		box8,box9
m8x:	move.b		#32,box8
	bra		drscr
mv9:
	cmp.b		#32,box6
	bne		sm9
	move.b		box9,box6
	bra		m9x
sm9:	cmp.b		#32,box8
	bne		main
	move.b		box9,box8
m9x:	move.b		#32,box9
	bra		drscr

getran:	;**** Get unused random number ****
nran:
	move.w		#9,d0
	jsr		flib[random]
	add.b		#32,d0
	cmp.b		#32,d0
	beq		nxr
	add.b		#16,d0
nxr:	cmp.b		box1,d0
	beq		nran
	cmp.b		box2,d0
	beq		nran
	cmp.b		box3,d0
	beq		nran
	cmp.b		box4,d0
	beq		nran
	cmp.b		box5,d0
	beq		nran
	cmp.b		box6,d0
	beq		nran
	cmp.b		box7,d0
	beq		nran
	cmp.b		box8,d0
	beq		nran
	cmp.b		box9,d0
	beq		nran
	rts

	;**** Variables ****
pname	dc.b		"Mosaic v1.0b3",0
m1	dc.b		"F1-Play",0
m2	dc.b		"ESC-Exit",0
win	dc.b		"You Won!!!",0
box1	dc.b		57,0
box2	dc.b		57,0
box3	dc.b		57,0
box4	dc.b		57,0
box5	dc.b		57,0
box6	dc.b		57,0
box7	dc.b		57,0
box8	dc.b		57,0
box9	dc.b		57,0

	;**** Libraries ****
	reloc_open
	add_library	flib
	add_library	romlib
	reloc_close
	end
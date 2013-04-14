;+--------------------------------------------------------------+
;|			 Tic-Tac-Toe v1.0			|
;|		       by Joe Wingbermuehle			|
;|			   3-28-1997				|
;+--------------------------------------------------------------+


	@program	pcode,pname
	include		magicsq.h

pcode:
	jsr		sscr
	SetFont		#1
	WriteStr	#50,#35,#4,m1
	WriteStr	#50,#45,#4,m2
	WriteStr	#50,#55,#4,m3
	move.b		#2,np

menu:	jsr		flib[idle_loop]
	cmp		#268,d0
	beq		play1
	cmp.b		#269,d0
	beq		play2
	cmp		#264,d0
	bne		menu
	rts

sscr:	jsr		flib[clr_scr]
	SetFont		#2
	WriteStr	#30,#2,#4,pname
	rts	

play1:	move.b		#1,np
play2:	bra		setgm
main:	jsr		flib[idle_loop]
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

mv1:
	cmp.b		#32,box1
	bne		main
	cmp.b		#79,trn
	bne		sm1
	move.b		#23,box1
sm1:	add.b		#56,box1
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv2:
	cmp.b		#32,box2
	bne		main
	cmp.b		#79,trn
	bne		sm2
	move.b		#23,box2
sm2:	add.b		#56,box2
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv3:
	cmp.b		#32,box3
	bne		main
	cmp.b		#79,trn
	bne		sm3
	move.b		#23,box3
sm3:	add.b		#56,box3
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv4:
	cmp.b		#32,box4
	bne		main
	cmp.b		#79,trn
	bne		sm4
	move.b		#23,box4
sm4:	add.b		#56,box4
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv5:
	cmp.b		#32,box5
	bne		main
	cmp.b		#79,trn
	bne		sm5
	move.b		#23,box5
sm5:	add.b		#56,box5
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv6:
	cmp.b		#32,box6
	bne		main
	cmp.b		#79,trn
	bne		sm6
	move.b		#23,box6
sm6:	add.b		#56,box6
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv7:
	cmp.b		#32,box7
	bne		main
	cmp.b		#79,trn
	bne		sm7
	move.b		#23,box7
sm7:	add.b		#56,box7
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv8:
	cmp.b		#32,box8
	bne		main
	cmp.b		#79,trn
	bne		sm8
	move.b		#23,box8
sm8:	add.b		#56,box8
	cmp.b		#1,np
	beq		cturn
	bra		drscr
mv9:
	cmp.b		#32,box9
	bne		main
	cmp.b		#79,trn
	bne		sm9
	move.b		#23,box9
sm9:	add.b		#56,box9
	cmp.b		#1,np
	beq		cturn
	bra		drscr

cturn:
	jsr		rfrsh
	move.b		#2,d2
	bra		winchk
nnum:	move		#9,d0
	jsr		flib[random]
	cmp		#0,d0
	bne		nt0
	cmp.b		#32,box1
	bne		nnum
	move.b		#88,box1
nt0:	cmp		#1,d0
	bne		nt1
	cmp.b		#32,box2
	bne		nnum
	move.b		#88,box2
nt1:	cmp		#2,d0
	bne		nt2
	cmp.b		#32,box3
	bne		nnum
	move.b		#88,box3
nt2:	cmp		#3,d0
	bne		nt3
	cmp.b		#32,box4
	bne		nnum
	move.b		#88,box4
nt3:	cmp		#4,d0
	bne		nt4
	cmp.b		#32,box5
	bne		nnum
	move.b		#88,box5
nt4:	cmp		#5,d0
	bne		nt5
	cmp.b		#32,box6
	bne		nnum
	move.b		#88,box6
nt5:	cmp		#6,d0
	bne		nt6
	cmp.b		#32,box7
	bne		nnum
	move.b		#88,box7
nt6:	cmp		#7,d0
	bne		nt7
	cmp.b		#32,box8
	bne		nnum
	move.b		#88,box8
nt7:	cmp.b		#8,d0
	bne		drscr
	cmp.b		#32,box9
	bne		nnum
	move.b		#88,box9
	bra		drscr

setgm:	jsr		sscr
	move.b		#32,box1
	move.b		#32,box2
	move.b		#32,box3
	move.b		#32,box4
	move.b		#32,box5
	move.b		#32,box6
	move.b		#32,box7
	move.b		#32,box8
	move.b		#32,box9
	move.b		#79,trn
	move.b		#0,flled
	DrawBox		#20,#20,#110,#110
	DrawBox		#50,#20,#80,#110
	DrawBox		#20,#50,#110,#80
drscr:	jsr		rfrsh
	bra		winchk

wnckcn:	cmp.b		#1,np
	beq		main
	cmp.b		#79,trn
	beq		nxtt
	move.b		#70,trn
nxtt:	add.b		#9,trn
	WriteStr	#130,#50,#4,ntrn
	WriteStr	#180,#50,#4,trn
	bra		main

winchk:	move.b		#70,d1
clp:	add.b		#9,d1
	cmp.b		box1(PC),d1
	bne		cn1
	cmp.b		box2(PC),d1
	bne		cn1
	cmp.b		box3(PC),d1
	bne		cn1
	bra		winner
cn1:	cmp.b		box4(PC),d1
	bne		cn2
	cmp.b		box5(PC),d1
	bne		cn2
	cmp.b		box6(PC),d1
	bne		cn2
	bra		winner
cn2:	cmp.b		box7(PC),d1
	bne		cn3
	cmp.b		box8(PC),d1
	bne		cn3
	cmp.b		box9(PC),d1
	bne		cn3
	bra		winner
cn3:	cmp.b		box1(PC),d1
	bne		cn4
	cmp.b		box4(PC),d1
	bne		cn4
	cmp.b		box7(PC),d1
	bne		cn4
	bra		winner
cn4:	cmp.b		box2(PC),d1
	bne		cn5
	cmp.b		box5(PC),d1
	bne		cn5
	cmp.b		box8(PC),d1
	bne		cn5
	bra		winner
cn5:	cmp.b		box3(PC),d1
	bne		cn6
	cmp.b		box6(PC),d1
	bne		cn6
	cmp.b		box9(PC),d1
	bne		cn6
	bra		winner
cn6:	cmp.b		box1(PC),d1
	bne		cn7
	cmp.b		box5(PC),d1
	bne		cn7
	cmp.b		box9(PC),d1
	bne		cn7
	bra		winner
cn7:	cmp.b		box3(PC),d1
	bne		cn8
	cmp.b		box5(PC),d1
	bne		cn8
	cmp.b		box7(PC),d1
	bne		cn8
	bra		winner
cn8:	cmp.b		#88,d1
	ble		clp
	add.b		#1,flled
	cmp.b		#10,flled
	bge		tied
	cmp.b		#2,d2
	beq		nnum
	bra		wnckcn

rfrsh:	WriteStr	#30,#30,#4,box1
	WriteStr	#30,#60,#4,box2
	WriteStr	#30,#90,#4,box3
	WriteStr	#60,#30,#4,box4
	WriteStr	#60,#60,#4,box5
	WriteStr	#60,#90,#4,box6
	WriteStr	#90,#30,#4,box7
	WriteStr	#90,#60,#4,box8
	WriteStr	#90,#90,#4,box9
	rts

tied:	WriteStr	#130,#30,#4,tie
	bra		wait1
winner:	cmp.b		#1,np
	bne		twop
	cmp.b		#79,d1
	bne		losser
	WriteStr	#130,#30,#4,win
	bra		wait1
losser:	WriteStr	#130,#30,#4,lost
	bra		wait1
twop:	WriteStr	#130,#30,#4,trn
	WriteStr	#145,#30,#4,p2win
wait1:	jsr		flib[idle_loop]
	cmp.b		#264,d0
	bne		wait1
	bra		pcode

pname	dc.b		"Tic-Tac-Toe v1.0",0
m1	dc.b		"F1-1 Player",0
m2	dc.b		"F2-2 Player",0
m3	dc.b		"ESC-Exit",0
win	dc.b		"You Won!!!",0
lost	dc.b		"You Lost",0
p2win	dc.b		"Won!!!",0
tie	dc.b		"Tied Game",0
ntrn	dc.b		"Turn:",0
np	dc.b		2
flled	dc.b		0
trn	dc.b		79,0
box1	dc.b		32,0
box2	dc.b		32,0
box3	dc.b		32,0
box4	dc.b		32,0
box5	dc.b		32,0
box6	dc.b		32,0
box7	dc.b		32,0
box8	dc.b		32,0
box9	dc.b		32,0

	reloc_open
	add_library	romlib
	add_library	flib
	reloc_close
	end
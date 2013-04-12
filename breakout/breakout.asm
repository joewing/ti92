; Breakout v0.1 by Joe Wingbermuehle
; 19981111
; TI-92 Fargo II

	include	"tios.h"
	include	"flib.h"
	include	"hexlib.h"
	include	"gray4lib.h"
	include	"macros.h"

;---------= Header =---------
	xdef	_main
	xdef	_comment

;---------= Program =----------
_main:	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_interrupt
	bclr.b	#2,$600001
	move.l	#interrupt,$64
	bset.b	#2,$600001
	trap	#1
	move.b	#'i',i_txt

	jsr	gray4lib::on
	tst.l	d0
	beq	quit

startOver:
	clr.w	score
	move.w	#5,lives
	move.w	#1,level
showMenu:
	bsr	setScreen
	drawFrame #23,#35,#165,#80
	setFont	#1
	puts	#25,#40,#4,option1
	puts	#25,#50,#4,option2
	puts	#25,#60,#4,option3
	puts	#25,#70,#4,option4
	bsr	darkenScreen
	jsr	flib::idle_loop
	cmp.w	#$0108,d0
	beq	quit
	cmp.w	#$010C,d0
	beq	startGame
	cmp.w	#$010E,d0
	beq	dispHelp
	cmp.w	#$010D,d0
	beq	setStartLevel
	bra	showMenu
dispHelp:
	bsr	setScreen
	drawFrame #18,#25,#170,#80
	setFont	#1
	puts	#20,#30,#4,help1
	puts	#20,#40,#4,help2
	puts	#20,#50,#4,help3
	puts	#20,#60,#4,help4
	puts	#20,#70,#4,help5
	bsr	darkenScreen
	jsr	flib::idle_loop
	bra	showMenu

setStartLevel:
	addq.w	#1,level
	cmp.w	#7,level
	bne	showMenu
	bra	startOver	

wrapLevel:
	move.w	#1,level
startGame:
	subq.w	#1,level
nextLevel:
	addq.w	#1,level
	cmp.w	#7,level
	beq	wrapLevel

;---------= Load the Level =---------
drawLevel:
	lea	level_data(pc),a0
	lea	level_matrix,a1
	move.w	level,d0
	cmp.w	#1,d0
	beq	firstLevel
	subq.w	#2,d0
findLevel_l:
	adda.w	#1,a0
	move.b	(a0)+,d1
	ext.w	d1
	adda.w	d1,a0
	adda.w	#1,a0
	dbra	d0,findLevel_l
firstLevel:
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,blocksLeft

;---------= Decompress =---------
; Input:  a0->compressed data
;	  a1->location to load data
; Output: data is decompressed
decompress:
	move.b	(a0)+,d0
	ext.w	d0
decompress_l1:
	move.b	(a0),d1
	lsr.b	#3,d1
	ext.w	d1
	move.b	(a0)+,d2
	andi.b	#%00000111,d2
decompress_l2:
	move.b	d2,(a1)+
	dbra	d1,decompress_l2
	dbra	d0,decompress_l1

;---------= Draw the Level =---------
redrawTheStinkenLevel:
	bsr	setScreen
	lea	level_matrix,a2
	moveq.w	#0,d6
drawLevel_l2:
	moveq.w	#0,d5
drawLevel_l1:
	move.b	(a2)+,d2
	move.w	d5,d0
	move.w	d6,d1
	bsr	drawBlock
	addq.w	#1,d5
	cmp.w	#11,d5
	blt	drawLevel_l1
	addq.w	#1,d6
	cmp.w	#11,d6
	blt	drawLevel_l2

restartLevel:
	clr.w	over
	move.b	#5,timer
	clr.b	motion

;---------= Main Game Loop =---------
game:	tst.w	blocksLeft	; check for winner/losser
	beq	nextLevel
	tst.w	over
	bne	gameOver

delay:	tst.b	timer		; delay
	bne	delay
	move.b	#2,timer

	tst.w	tios::kb_vars+$1C	; check for keys
	beq	noReset
	clr.w	tios::kb_vars+$1C
	move.w	tios::kb_vars+$1E,d0
	cmp.w	#$0101,d0
	beq	gameOver
	cmp.w	#$010A,d0
	bne	noPause
	trap	#4
	move.w	#300,timer
noPause:
	cmp.w	#$010C,d0
	bne	noMotion
	move.b	#1,motion
noMotion:
	cmp.w	#$0108,d0
	beq	startOver
noReset:

;---------= Update Game =---------
	tst.b	motion
	beq	notInMotion
	addq.b	#1,balld
	andi.b	#3,balld
	bne	notInMotion
	bsr	moveBall
	bsr	checkLocation
	not.b	fdelay
	bne	notInMotion
	bsr	fallDown
notInMotion:

;---------= Check Arrow Keys =---------
	move.w	#$FFFE,$600018
	move.w	#9,d0
IORefresh:
	dbra	d0,IORefresh
	move.b	$60001B,d0
	btst	#6,d0
	beq	moveRight
	btst	#4,d0
	beq	moveLeft
	bra	game

;---------= Game Over =---------
gameOver:
	bsr	drawPaddle
	bsr	drawBall
	bsr	setPos
	bsr	drawBall
	bsr	drawPaddle
	subq.w	#1,lives
	bsr	dispLives
	cmp.w	#0,lives
	bne	redrawTheStinkenLevel
	clr.w	tios::kb_vars+$1C
	bsr	setScreen
	setFont	#2
	puts	#50,#50,#4,game_over
	move.w	score,d0
	cmp.w	highScore,d0
	bls	noNHS
	move.w	d0,highScore
	puts	#30,#65,#4,nhs_txt
	setFont	#1
	puts	#50,#90,#4,initials_txt
	lea	hs_n(pc),a5
	moveq.w	#105,d5
initial_loop:
	bsr	darkenScreen
	jsr	flib::idle_loop
	cmp.w	#$0101,d0
	bne	notDelete
	cmp.w	#105,d5
	beq	notDelete
	subq.w	#7,d5
	putc	d5,#90,#4,#$20
	move.b	#$20,-(a5)
	bra	initial_loop
notDelete:
	cmp.w	#105+(3*7),d5
	beq	startOver
	move.w	d0,-(a7)
	putc	d5,#90,#4,d0
	move.w	(a7)+,d0
	move.b	d0,(a5)+
	addq.w	#7,d5
	bra	initial_loop
noNHS:	jsr	flib::idle_loop
	bra	startOver

;---------= Exit the Program =---------
quit:	jsr	gray4lib::off
	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_interrupt,$64
	bset.b	#2,$600001
	trap	#1
	move.b	#0,i_txt
	rts

;---------= Move the Paddle =---------
moveRight:
	bsr	drawPaddle
	move.w	padx,d0
	addq.w	#1,d0
	cmp.w	#166,d0
	beq	moveReturn
	move.w	d0,padx
	tst.b	motion
	bne	moveReturn
	bsr	drawBall
	addq.w	#1,ballx
	bsr	drawBall
	bra	moveReturn

moveLeft:
	bsr	drawPaddle
	move.w	padx,d0
	subq.w	#1,d0
	cmp.w	#0,d0
	beq	moveReturn
	move.w	d0,padx
	tst.b	motion
	bne	moveReturn
	bsr	drawBall
	subq.w	#1,ballx
	bsr	drawBall
moveReturn:
	bsr	drawPaddle
	bra	game

;---------= Draw the Paddle =---------
drawPaddle:
	move.w	padx,d0
	moveq.w	#116,d1
	moveq.w	#4,d2
	lea	paddle(pc),a0
	move.l	gray4lib::plane1,a1
	bsr	putSprite
	move.w	padx,d0
	addi.w	#16,d0
	moveq.w	#116,d1
	moveq.w	#4,d2
	move.l	gray4lib::plane1,a1
	bsr	putSprite

	move.w	padx,d0
	moveq.w	#116,d1
	moveq.w	#4,d2
	lea	paddle2(pc),a0
	move.l	gray4lib::plane0,a1
	bsr	putSprite
	move.w	padx,d0
	addi.w	#16,d0
	moveq.w	#116,d1
	moveq.w	#4,d2
	move.l	gray4lib::plane0,a1
	bra	putSprite

;---------= Move the Ball =---------
moveBall:
	bsr	drawBall
	move.w	ballx,d0
	add.w	dirx,d0
	move.w	d0,ballx
	cmp.w	#1,d0
	bgt	noChg1
	cmp.w	#0,dirx
	bgt	noChg1
	neg.w	dirx
noChg1:	cmp.w	#183,d0
	blt	noChg2
	cmp.w	#0,dirx
	blt	noChg2
	neg.w	dirx
noChg2:
	move.w	bally,d0
	add.w	diry,d0
	cmp.w	#1,d0
	bgt	noChg3
	move.w	#1,diry
noChg3:	cmp.w	#111,d0
	blt	noChg4
	move.w	#-1,diry
	move.w	ballx,d1
	addq.w	#3,d1
	move.w	padx,d2

	moveq.w	#-3,d3
	moveq.w	#5,d4
dirChangeL1:
	moveq.w	#3,d5
dirChangeL2:
	cmp.w	d1,d2
	bne	dirChangeS1
	move.w	d3,dirx
	bra	dirChangeX
dirChangeS1:
	addq.w	#1,d2
	dbra	d5,dirChangeL2

	addq.w	#1,d3
	bne	dirChangeS2
	addq.w	#1,d3
dirChangeS2:

	dbra	d4,dirChangeL1
	move.w	#1,over
dirChangeX:
noChg4:	move.w	d0,bally

;---------= Draw the Ball =---------
drawBall:
	move.w	ballx,d0
	move.w	bally,d1
	moveq.w	#5,d2
	lea	ball(pc),a0
	move.l	gray4lib::plane1,a1
	movem.w	d0-d2,-(a7)
	bsr	putSprite
	movem.w	(a7)+,d0-d2
	move.l	gray4lib::plane0,a1

;---------= Draw Sprite =---------
; Input: a0->sprite
;	 d0.w,d1.w = x,y
;	 d2.w = size
; Destroyed: a0,a1,d0,d1,d2,d3,d4
putSprite:
	mulu.w	#30,d1
	ext.l	d1
	adda.l	d1,a1
	ext.l	d0
	move.l	d0,d3
	andi.l	#15,d3
	andi.l	#$FFFFFFF0,d0
	lsr.l	#3,d0
	adda.l	d0,a1
putSprite_loop1:
	clr.l	d4
	move.w	(a0)+,d4
	swap	d4
	lsr.l	d3,d4
	eor.l	d4,(a1)
	lea	30(a1),a1
	dbra	d2,putSprite_loop1
	rts

;---------= Add 1 to the Score =---------
incScore:
	lea	score+2,a0
	lea	one+2(pc),a1
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)

;---------= Display Score =---------
dispScore:
	move.w	score,d0
	moveq.l	#4,d1
	move.l	#25,d2
	moveq.l	#3,d4
	jmp	hexlib::put_hex

;---------= Display Lives =---------
dispLives:
	move.w	lives,d0
	moveq.l	#10,d1
	moveq.l	#25,d2
	moveq.l	#3,d4
	jmp	hexlib::put_hex	

;---------= Timer Interrupt =---------
interrupt:
	tst.b	timer
	beq	interrupt_skip
	sub.b	#1,timer
interrupt_skip:
	move.l	old_interrupt,-(a7)
	rts

;---------= Set Paddle/Ball possitions =---------
setPos:	move.b	#0,fdelay
	move.w	#88,padx
	move.w	#97,ballx
	move.w	#110,bally
	move.w	#1,dirx
	move.w	#-1,diry
	move.b	#1,balld
	lea	falling,a0
	move.w	#47,d0
setPosLoop:
	move.b	#0,(a0)+
	dbra	d0,setPosLoop
	rts

;---------= Draw the Basics =---------
setScreen:
	jsr	flib::clr_scr
	drawFrame #0,#0,#189,#121
	drawFrame #190,#0,#239,#121

	drawFrame #190,#18,#239,#42
	drawFrame #190,#66,#239,#90

	move.w	#191,d0
	move.w	#1,d1
	move.w	#16,d2
	lea	picture(pc),a0
	move.l	gray4lib::plane1,a1
	bsr	putSprite
	move.w	#207,d0
	move.w	#1,d1
	move.w	#16,d2
	move.l	gray4lib::plane1,a1
	bsr	putSprite
	move.w	#223,d0
	move.w	#1,d1
	move.w	#16,d2
	move.l	gray4lib::plane1,a1
	bsr	putSprite

	setFont	#1
	puts	#192,#22,#4,score_txt
	puts	#192,#46,#4,level_txt
	puts	#192,#70,#4,lives_txt
	puts	#192,#94,#4,hs_txt
	setFont	#0
	puts	#192,#114,#4,name
	puts	#0,#123,#4,_comment

	bsr	darkenScreen

	move.w	highScore,d0
	moveq.l	#13,d1
	moveq.l	#25,d2
	moveq.l	#3,d4
	jsr	hexlib::put_hex
	move.w	level,d0
	moveq.l	#7,d1
	moveq.l	#25,d2
	moveq.l	#3,d4
	jsr	hexlib::put_hex
	bsr	setPos
	bsr	dispScore
	bsr	dispLives
	bsr	drawBall
	bra	drawPaddle

;---------= Draw Block =---------
; d0.w,d1.w = x,y (matrix coordinates)
; d2.b = type
; Destroys: a0,a1,d0,d1,d2,d3,d4
drawBlock:
	move.l	gray4lib::plane0,a1
	mulu.w	#17,d0
	mulu.w	#9,d1
	addq.w	#2,d0
	addq.w	#2,d1
	lea	blocks(pc),a0
	ext.w	d2
	lsl.w	#5,d2
	adda.w	d2,a0
	moveq.w	#7,d2
	movem.l	d0-d2,-(a7)
	bsr	putSprite
	movem.l	(a7)+,d0-d2
	move.l	gray4lib::plane1,a1
	bra	putSprite

;---------= Move Down Falling Block =---------
fallDown:
	lea	falling,a0
	move.w	#15,d7
fallDownL1:
	move.b	(a0)+,d2
	tst.b	d2
	beq	fallDownS2
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	bsr	drawFBlock
	addq.b	#1,d1
	cmp.b	#110,d1
	bne	fallDownS1
	sub	#3,a0
	move.b	#0,(a0)+
	ext.w	d0
	mulu.w	#17,d0
	move.w	padx,d4
	addi.w	#16,d4
	cmp.w	d4,d0
	bgt	fallDownS2
	subi.w	#40,d4
	cmp.w	d4,d0
	blt	fallDownS2

;-----> Collect Bonus
	cmp.b	#1,d2
	bne	type2
type1:	lea	fournine+2,a1	; 1
	lea	score+2,a2
	abcd.b	-(a1),-(a2)
	abcd.b	-(a1),-(a2)
type1a:	move.l	a0,-(a7)
	bsr	incScore
	move.l	(a7)+,a0
	bra	collectedBonus
type2:	cmp.b	#2,d2		; 2
	bne	type3
	cmp.w	#$50,score
	bge	type2a
	move.w	#$50,score
type2a:	lea	fiveone+2,a1
	lea	score+2,a2
	sbcd	-(a1),-(a2)
	sbcd	-(a1),-(a2)
	bra	type1a
type3:	cmp.b	#3,d2		; 3
	bne	type4
	cmp.w	#9,lives
	beq	collectedBonus
	addq.w	#1,lives
type3a:	move.l	a0,-(a7)
	bsr	dispLives
	move.l	(a7)+,a0
	bra	collectedBonus
type4:	cmp.b	#4,d2		; 4
	bne	type5
	cmp.w	#1,lives
	beq	gameOver
	subq.w	#1,lives
	bra	type3a
type5:	cmp.b	#5,d2		; 5
	bne	type6
type5a:	move.w	#0,blocksLeft
	bra	collectedBonus
type6:				; 6
	cmp.w	#1,level
	bne	type6a
	move.w	#7,level
type6a:	subi.w	#2,level
	bra	type5a
;<-----

fallDownS1:
	move.b	d1,-(a0)
	bsr	drawFBlock
	sub	#1,a0
collectedBonus:
fallDownS2:
	adda.w	#2,a0
fallDownS3:
	dbra	d7,fallDownL1
	rts

;---------= Draw Falling Block =---------
; Input:  d0.b,d1.b = x,y (screen coordinates)
;	  d2.b = type
drawFBlock:
	movem.l	d0-d2/a0,-(a7)
	lea	fblocks(pc),a0
	sub.b	#1,d2
	ext.w	d2
	lsl.w	#4,d2
	adda.w	d2,a0
	ext.w	d0
	mulu.w	#17,d0
	ext.w	d1
	move.w	#7,d2
	move.l	gray4lib::plane1,a1
	movem.l	d0-d2/a0,-(a7)
	bsr	putSprite
	movem.l	(a7)+,d0-d2/a0
	move.l	gray4lib::plane0,a1
	bsr	putSprite
	movem.l	(a7)+,d0-d2/a0
	rts

;---------= Check if a Block is Hit =---------
checkLocation:
	move.w	bally,d1
	moveq.w	#1,d3
checkLocation_loop2:
	moveq.w	#1,d2
	move.w	ballx,d0
checkLocation_loop1:
	movem.w	d0-d3,-(a7)
	ext.l	d0
	divu	#17,d0
	cmp.w	#10,d0
	bhi	checkLocation_exit
	move.b	d0,d6
	ext.l	d1
	divu	#9,d1
	cmp.w	#10,d1
	bhi	checkLocation_exit
	move.l	d1,d7
	lea	level_matrix,a0
	move.w	d1,d2
	mulu.w	#11,d2
	adda.w	d2,a0
	adda.w	d0,a0
	move.b	(a0),d2
	tst.b	d2
	beq	checkLocation_exit
	swap	d7
	cmp.b	#2,d7
	ble	pos2
pos1:	cmp.b	#6,d7
	bge	pos2
	neg.w	dirx
	bra	pos3
pos2:	neg.w	diry
pos3:	swap	d7
	cmp.b	#7,d2
	beq	checkLocation_end
	movem.l	d0-d2/a0,-(a7)
	bsr	drawBlock
	movem.l	(a7)+,d0-d2/a0
	cmp.b	#3,d2
	ble	removeBlock
	subq.b	#3,d2
	move.b	d2,(a0)
	bsr	drawBlock
	bra	keepBlock
removeBlock:
	clr.b	(a0)
keepBlock:

	bsr	incScore
	sub.w	#1,blocksLeft
	moveq.w	#4,d0			; 1 in 4 chance of falling block
	jsr	flib::random
	tst.w	d0
	bne	startFalling_failed
	lea	falling-3,a0
	move.w	#15,d0
startFalling:
	adda.w	#3,a0
	move.b	(a0),d1
	tst.b	d1
	dbeq	d0,startFalling
	cmp.b	#255,d0
	beq	startFalling_failed

	moveq.w	#6,d0			; 6 types
	jsr	flib::random
	addq.b	#1,d0
	move.b	d0,(a0)+
	move.b	d0,d2
	mulu.b	#9,d7
	move.b	d6,(a0)+
	move.b	d7,(a0)

	move.b	d6,d0
	move.b	d7,d1
	bsr	drawFBlock
startFalling_failed:
checkLocation_end:
	lea	8(a7),a7
	rts
checkLocation_exit:
	movem.w	(a7)+,d0-d3
	addq.w	#5,d0
	dbra	d2,checkLocation_loop1
	addq.w	#5,d1
	dbra	d3,checkLocation_loop2
	rts

;---------= Darken the GrayScale =---------
darkenScreen:
	move.l	gray4lib::plane1,a0
	move.l	gray4lib::plane0,a1
	move.w	#$0EFF,d0
	clr.b	d1
copyBuffers:
	move.b	(a0)+,(a1)+
	dbra	d0,copyBuffers
	rts

;====================> Data <====================
;---------= Numbers =---------
one:	dc.w	1
fournine:
	dc.w	$49
fiveone:
	dc.w	$51

highScore:
	dc.w	0	; high score is written back

;---------= Sprites =---------
;-----> Ball (2-level grayscale)
ball:	dc.w	%0011000000000000
	dc.w	%0111100000000000
	dc.w	%1110110000000000
	dc.w	%1111110000000000
	dc.w	%0111100000000000
	dc.w	%0011000000000000
	dc.w	%0011000000000000
	dc.w	%0111100000000000
	dc.w	%1111110000000000
	dc.w	%1111110000000000
	dc.w	%0111100000000000
	dc.w	%0011000000000000


;-----> Paddle (2-level grayscale)
paddle:	dc.w	%0111111111111111
	dc.w	%1000001001011010
	dc.w	%1000010010100101
	dc.w	%1000001001011010
	dc.w	%0111111111111111
	dc.w	%1111111000000000
	dc.w	%0100000100000000
	dc.w	%0010000100000000
	dc.w	%0100000100000000
	dc.w	%1111111000000000
paddle2:
	dc.w	%0111111111111111
	dc.w	%1010000000011000
	dc.w	%1100000000100100
	dc.w	%1010000000011000
	dc.w	%0111111111111111
	dc.w	%1111111000000000
	dc.w	%0000010100000000
	dc.w	%0000001100000000
	dc.w	%0000010100000000
	dc.w	%1111111000000000

;-----> Blocks (2 level grayscale)
blocks:
	dc.w	0,0,0,0,0,0,0,0		; 0
	dc.w	0,0,0,0,0,0,0,0

	dc.w	%0111111111111110	; 1 - 3d (1 hit)
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000101
	dc.w	%1000111111111101
	dc.w	%1000000000000001
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1000000000000001
	dc.w	%1011111111111101
	dc.w	%1010000000000001
	dc.w	%1010000000000001
	dc.w	%1010000000000001
	dc.w	%1000000000000001
	dc.w	%0111111111111110

	dc.w	%0111111111111110	; 2 - plain (1 hit)
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%0111111111111110

	dc.w	%0111111111111110	; 3 - darker plain (1 hit)
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%0111111111111110

	dc.w	%0111111111111110	; 4 - 3d (2 hit)
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000101
	dc.w	%1000111111111101
	dc.w	%1000000000000001
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1100000000000011
	dc.w	%1101111111111111
	dc.w	%1101111111111011
	dc.w	%1101000000000011
	dc.w	%1111111111111111
	dc.w	%0111111111111110

	dc.w	%0111111111111110	; 5 - plain (2 hit)
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110

	dc.w	%0111111111111110	; 6 - darker plain (2 hit)
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110

	dc.w	%0111111111111110	; 7, not breakable
	dc.w	%1111111111111111
	dc.w	%1111100000011111
	dc.w	%1111000110001111
	dc.w	%1111000110001111
	dc.w	%1111100000011111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111001111111
	dc.w	%1111110000111111
	dc.w	%1111110000111111
	dc.w	%1111111001111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110

;-----> Falling Blocks (monochrome)
fblocks:
	dc.w	%0000000000000000	; 1
	dc.w	%0010001111001110
	dc.w	%0010001000010001
	dc.w	%1111101110010101
	dc.w	%0010000001010101
	dc.w	%0010001001010001
	dc.w	%0000000110001110
	dc.w	%0000000000000000
	dc.w	%0000000000000000	; 2
	dc.w	%0000001111001110
	dc.w	%0000001000010001
	dc.w	%1111101110010101
	dc.w	%0000000001010101
	dc.w	%0000001001010001
	dc.w	%0000000110001110
	dc.w	%0000000000000000
	dc.w	%0001000000000000	; 3
	dc.w	%0001000011001100
	dc.w	%0111110111111110
	dc.w	%0001000111111110
	dc.w	%0001000011111100
	dc.w	%0000000001111000
	dc.w	%0000000000110000
	dc.w	%0000000000000000
	dc.w	%0000000000000000	; 4
	dc.w	%0000000011001100
	dc.w	%0111110111111110
	dc.w	%0000000111111110
	dc.w	%0000000011111100
	dc.w	%0000000001111000
	dc.w	%0000000000110000
	dc.w	%0000000000000000

	dc.w	%0010000000000000
	dc.w	%0010001000000000
	dc.w	%1111101000000000
	dc.w	%0010001000110101
	dc.w	%0010001001110101
	dc.w	%0000001000110010
	dc.w	%0000001111000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000001000000000
	dc.w	%1111101000000000
	dc.w	%0000001000110101
	dc.w	%0000001001110101
	dc.w	%0000001000110010
	dc.w	%0000001111000000
	dc.w	%0000000000000000

;-----> Breakout picture (monochrome)
picture:
	dc.w	%0101010101010101
	dc.w	%1010101010101010
	dc.w	%0111111111111111
	dc.w	%1100000000000000
	dc.w	%1001111000000000
	dc.w	%1001000100000000
	dc.w	%1001000100000000
	dc.w	%1001000100110011
	dc.w	%1001111000100100
	dc.w	%1001000100100111
	dc.w	%1001000100100100
	dc.w	%1001000100100100
	dc.w	%1001111000100011
	dc.w	%1100000000000000
	dc.w	%0111111111111111
	dc.w	%1010101010101010
	dc.w	%0101010101010101
	dc.w	%0101010101010101
	dc.w	%1010101010101010
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%0000000001000000
	dc.w	%0000000001000000
	dc.w	%0000000001000000
	dc.w	%1000111001001000
	dc.w	%0100000101010001
	dc.w	%1100111101100001
	dc.w	%0001000101010001
	dc.w	%0101000101001001
	dc.w	%1000111101000100
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%1010101010101010
	dc.w	%0101010101010101
	dc.w	%0101010101010101
	dc.w	%1010101010101010
	dc.w	%1111111111111101
	dc.w	%0000000000000010
	dc.w	%0000000000000001
	dc.w	%0000000000010001
	dc.w	%0000000000010001
	dc.w	%1110010001011001
	dc.w	%1101010001010001
	dc.w	%1111010001010001
	dc.w	%1111010001010001
	dc.w	%1111010011010001
	dc.w	%1110001101001001
	dc.w	%0000000000000010
	dc.w	%1111111111111101
	dc.w	%1010101010101010
	dc.w	%0101010101010101

;---------= Levels =---------
; Level data format:
;  There are 122 bytes in an uncompressed level. A compressed level
;  will be a maximum of 122 bytes but will most likely be less than
;  half that size.
;  -First byte = number block hits required to beat the level
;  -Second byte = number of bytes of compressed data minus one
;  -The rest of the data is level data. It is set up as follows:
;	-Each byte specifies a run of data.
;		%xxxxxyyy = repeat value yyy xxxxx+1 times.
;		Levels do not need to be compressed to work.
level_data:
level1:	dc.b	28
	dc.b	57
	dc.b	%10101000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%00000000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%00000000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%00000000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%00000000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%00000000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%00000000,%00000011,%00000000,%00000011,%00000000,%00000011,%00000000,%00000011
	dc.b	%11111000,%01011000

level2:	dc.b	50
	dc.b	41
	dc.b	%00000000,%00001010,%00001000,%00001010,%00001000,%00011010,%00001000,%00001010
	dc.b	%00001000,%00001010,%00000000,%00000010,%00001000,%00001010,%00001000,%00001010
	dc.b	%00011000,%00001010,%00001000,%00001010,%00001000,%00000010,%00000000,%00001010
	dc.b	%00001000,%00001010,%00001000,%00011010,%00001000,%00001010,%00001000,%00001010
	dc.b	%00000000,%00000010,%00001000,%00001010,%00001000,%00001010,%00001000,%01010001
	dc.b	%11111000,%00000000

level3:	dc.b	53
	dc.b	64
	dc.b	%00000001,%00000000,%00000010,%00000000,%00000001,%00000000,%00000010,%00000000
	dc.b	%00000001,%00000000,%00000010,%00000001,%00000000,%00000010,%00000000,%00000001
	dc.b	%00000000,%00000010,%00000000,%00000001,%00000000,%00000010,%00000001,%00000000
	dc.b	%00000010,%00000000,%00000001,%00000000,%00000010,%00000000,%00000001,%00000000
	dc.b	%00000010,%00000001,%00000000,%00000010,%00000000,%00000001,%00000000,%00000010
	dc.b	%00000000,%00000001,%00000000,%00000010,%00000001,%00000000,%00000010,%00000000
	dc.b	%00000001,%00000000,%00000010,%00000000,%00000001,%00000000,%00000010,%01101000
	dc.b	%00100001,%00101000,%00000001,%00010000,%00000001,%00101000,%00100001,%01101000
	dc.b	%01010011

level4:	dc.b	65
	dc.b	33
	dc.b	%01011001,%01000000,%00001001,%01000000,%00100001,%00010000,%00011001,%00010000
	dc.b	%00000001,%00000000,%00000011,%00000000,%00000001,%00101000,%00000001,%00000000
	dc.b	%00000011,%00000000,%00000001,%00010000,%00011001,%00010000,%00100001,%01000000
	dc.b	%00001001,%01000000,%00011001,%00000001,%00010000,%00000001,%00010001,%00011110
	dc.b	%00010000,%00011110

level5:	dc.b	77
	dc.b	57
	dc.b	%01100000,2,%00001000,2,%00001000,%00010010,%00001000,2,0,2,0,2,0,2,%00011000,2,0
	dc.b	2,0,2,0,2,%00011000,2,0,2,0,2,0,%00001010,0,2,0,2,0,2,0,2,0,2,%00001000,2,0,2,0
	dc.b	2,0,2,0,2,%00010000,2,%00010000,2,%00001000,%00010010,%01010000,%10101101

level6:	dc.b	44
	dc.b	70
	dc.b	%00100000,1,%01000000,1,0,1,%00110000,1,0,4,0,1,%00100000,1,0,4,0,4,0,1,%00010000
	dc.b	1,0,4,0,7,0,4,0,1,0,1,0,4,0,%00010111,0,4,0,1,0,1,0,4,0,7,0,4,0,1,%00010000,1,0
	dc.b	4,0,4,0,1,%00100000,1,0,4,0,1,%00110000,1,0,1,%01000000,1,%00100000

;---------= Dialog =---------
_comment:
	dc.b	"Breakout v0.1 by Joe W"
i_txt:	dc.b	0,"ngbermuehle",0

score_txt:
	dc.b	"Score:",0
level_txt:
	dc.b	"Level:",0
lives_txt:
	dc.b	"Lives:",0

game_over:
	dc.b	"Game Over!",0
nhs_txt:
	dc.b	"New High Score!",0
initials_txt:
	dc.b	"Initials:",0
hs_txt:	dc.b	"HiScore",0
name:	dc.b	"by: "
hs_n:	dc.b	"JGW",0

option1:
	dc.b	"[F1] - Start Game",0
option2:
	dc.b	"[F2] - Set Start Level",0
option3:
	dc.b	"[F3] - Help",0
option4:
	dc.b	"[ESC] - Exit",0

help1:	dc.b	$11," and ",$12," move the paddle.",0
help2:	dc.b	"[F1] throws the ball.",0
help3:	dc.b	"[MODE] pauses.",0
help4:	dc.b	"[DEL] takes away a life.",0
help5:	dc.b	"[ESC] exits the game.",0

;---------= Variables =---------
	bss

old_interrupt:
	dc.l	0

ballx:	dc.w	0
bally:	dc.w	0
padx:	dc.w	0
dirx:	dc.w	0
diry:	dc.w	0
over:	dc.w	0

score:	dc.w	0
level:	dc.w	0
lives:	dc.w	0
blocksLeft:
	dc.w	0

timer:	dc.b	0
balld:	dc.b	0
motion:	dc.b	0

fdelay:	dc.b	0

falling:
	ds.b	48	; 16x {t,x,y}

level_matrix:
	ds.b	121

	end
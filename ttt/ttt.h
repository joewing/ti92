WriteStr	MACRO
		move.w		\3,-(a7)
		pea		\4(PC)
		move.w		\2,-(a7)
		move.w		\1,-(a7)
		jsr		romlib[puttext]
		lea		10(a7),a7
		ENDM

SetFont		MACRO
		move.w		\1,-(a7)
		jsr		romlib[set_font]
		lea		2(a7),a7
		ENDM

DrawBox		MACRO
		move.w		\4,-(a7)
		move.w		\3,-(a7)
		move.w		\2,-(a7)
		move.w		\1,-(a7)
		jsr 		flib[frame_rect]
		lea 		8(a7),a7
		ENDM
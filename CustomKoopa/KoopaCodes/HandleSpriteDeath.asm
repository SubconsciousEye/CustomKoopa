includefrom "../CustomKoopa.asm"

HandleSprDeath:
	lda !1510,x : and.b #~$60 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
;; Checking if we are squished.
	lda #$08					; Falling Death
	cpy #$03 : bne +
	lda #$09					; Squished Death
+	sta !1602,x
	cpy #$03 : bne FallingDeath
SquishedDeath:
	ldy !15EA,x : lda #$F0 : sta !oam1_ofsY+4,y
	lda !190F,x : and.b #~$20 : sta !190F,x
	jsr PrepKoopaGfx
	plb
	rtl

FallingDeath:
	LDA $64						;$019B4C	|\ 
	PHA							;$019B4E	||
	LDY !1632,x				;$019B4F	||
	BEQ CODE_019B56				;$019B52	||
	LDA #$10					;$019B54	|| Draw a 32x16 sprite, behind objects if applicable.
CODE_019B56:					;			||
	STA $64						;$019B56	||
	ldy !1504,x
	lda.w GraphicProps,y
	and #$02
	beq .OneTileHigh
.TwoTilesHigh
	lda #$20 : ora !190F,x : bra +
.OneTileHigh
	lda !190F,x : and.b #~$20
+	sta !190F,x
	JSR PrepKoopaGfx				;$019B58	||
	PLA							;$019B5B	||
	STA $64						;$019B5C	|/
	plb
	rtl


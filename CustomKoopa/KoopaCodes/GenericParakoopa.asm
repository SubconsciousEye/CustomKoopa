includefrom "../CustomKoopa.asm"

InitParakoopa:				;-----------| Standard sprite INIT. Used by all Koopas, Goombas, Buzzy Beetles, Spinies, and the Hopping Flame.
	tyx
	jsl !GetRand					;$018575	|
	sta !1570,x				;$018579	|
	%FacePlayerInit()
;; Acts Like
	lda #$11 : sta !9E,x
;; Stompable w/ Upwards Y Speed
	lda !190F,x : ora #$10 : sta !190F,x
;; Don't change direction when touched
	lda !1686,x : ora #$10 : sta !1686,x
	lda !extra_prop_1,x
	bmi .UnstunSprite
	lda !extra_byte_1,x
	bpl .ZeroExtraBytes
	lda #$09 : sta !14C8,x
	lda !extra_byte_2,x
	bne .ZeroExtraBytes
	lda #$ff : sta !1540,x
.ZeroExtraBytes:
;; Zero out the extra bytes since we
;;  no longer need them.
	lda #$00
	sta !extra_byte_1,x
	sta !extra_byte_2,x
	rts
.UnstunSprite:
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
	lda #$00 : sta !extra_prop_1,x
	rts


MainParakoopa:					;-----------| Green Parakoopa MAIN. Used by both the flying and bouncing ones.
	tyx
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
	LDA $9D						;$018C4D	|\ If sprites are locked, just draw the graphics.
	BNE DrawGraphics				;$018C4F	|/
	STz !B6,X					;$018C64	|/
	jsl !UpdateXPosNoGrvty		;$018C77	||\ Update the flying Parakoopa's position and speed without gravity. 
	LDY #$FC					;$018C7A	|||| Upwards Y speed for the flying Koopa.
	LDA !1570,X				;$018C7C	|||
	AND #$20					;$018C7F	|||| How often to change the flying Koopa's Y speed.
	BEQ VerticalBobbing				;$018C81	|||
	LDY #$04					;$018C83	|||| Downwards Y speed for the flying Koopa.
VerticalBobbing:					;			|||
	STY !AA,X					;$018C85	|||
	jsl !UpdateYPosNoGrvty		;$018C87	||/
	jsl !SprSprPMarioSprRts		;$018C91	| Process interaction with other sprites and Mario.
;; Clip Wings and fix Sprite State
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
+	
;; Resume Normal Sprite Behavior
	%SetAnimationFrame()		;$018CB1	|
	lda #$00 : %SubOffScreen()
DrawGraphics:					;			|
	JMP Spr0to13Gfx				;$018CB7	|



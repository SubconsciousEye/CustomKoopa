

namespace PositionalBouncer


Init:				;-----------| Bouncing green Koopa INIT
	tyx
	lda !D8,x					;$01856E	|\ 
	and #$10					;$018570	|| Get its bounce height based on its spawn Y position.
	sta !160E,x				;$018572	|/
	jmp InitParakoopa+1	; skip tyx (we already did ours)


Main:					;-----------| Green Parakoopa MAIN. Used by both the flying and bouncing ones.
	tyx
	LDA $9D						;$018C4D	|\ If sprites are locked, just draw the graphics.
	BNE DrawGraphics				;$018C4F	|/
	LDY !157C,X				;$018C51	|\ 
	LDA.w Spr0to13SpeedX,Y		;$018C54	||
	EOR !15B8,X				;$018C57	||
	ASL							;$018C5A	||
	LDA.w Spr0to13SpeedX,Y		;$018C5B	|| Set X speed. If it bounces against a slope, slow it down correspondingly.
	BCC +				;$018C5E	||  Kind of dumb though since the Koopa only gets slowed down for the frame it touches the slope.
	CLC							;$018C60	||
	ADC !15B8,X				;$018C61	||
+	STA !B6,X					;$018C64	|/
	TYA							;$018C66	|\ 
	INC						;$018C67	||
	AND !1588,X				;$018C68	|| If the Koopa lands against a very steep slope, stop it and turn it around.
	AND #$03					;$018C6B	||
	BEQ +				;$018C6D	||
	STZ !B6,X					;$018C6F	|/
+	jsl !UpdateSpritePos			;$018C8C	||\ Update X/Y position, apply gravity, and process interaction with blocks.
	DEC !AA,X					;$018C8F	|//
	jsl !SprSprPMarioSprRts		;$018C91	| Process interaction with other sprites and Mario.
;; Clip Wings and fix Sprite State
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
+	
;; Resume Normal Sprite Behavior
	%IsTouchingCeiling()		;$018C94	|\ 
	BEQ NoCeiling				;$018C97	|| If it hits a ceiling, clear Y speed.
	STZ !AA,X					;$018C99	|/
NoCeiling:
	%IsOnGround()				;$018C9B	|\ If it hits the ground, make it bounce.
	BEQ NotGrounded				;$018C9E	||
	;JSR SetSomeYSpeed			;$018CA0	||| (pointless)
	LDA #$D0					;$018CA3	||| Y speed to give the low bouncing Parakoopa when it hits the ground.
	LDY !160E,X				;$018CA5	||
	BNE +				;$018CA8	||
	LDA #$B0					;$018CAA	||| Y speed to give the high bouncing Parakoopa when it hits the ground.
+	STA !AA,X					;$018CAC	|/
NotGrounded:					;			|
	JSR FlipIfTouchingObj		;$018CAE	|
	%SetAnimationFrame()		;$018CB1	|
	lda #$00 : %SubOffScreen()
DrawGraphics:					;			|
	JMP Spr0to13Gfx				;$018CB7	|


namespace off

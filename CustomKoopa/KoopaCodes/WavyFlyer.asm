

namespace WavyFlyer


Acceleration:					;$01EBB4	| Acceleration values for a couple of sprites (Monty Mole, Eerie, Lakitu, Boo/Boo Block/Big Boo).
	db  $01,-$01

HorzSpeed:					;$01F88C	| X speeds for Eeries.
	db  $10,-$10
VertSpeed:					;$01F88E	| Max Y speeds for Eeries.
	db  $20,-$20

	; Eerie misc RAM:
	; $C2   - Direction of vertical acceleration for the wave Eerie. Even = down, odd = up.
	; $1570 - Frame counter for animation.
	; $157C - Horizontal direction the sprite is facing.
	; $1602 - Animation frame. 0/1 = normal.


Init:				;-----------| Standard sprite INIT. Used by all Koopas, Goombas, Buzzy Beetles, Spinies, and the Hopping Flame.
	tyx
	jsl !GetRand					;$018575	|
	sta !1570,x				;$018579	|
	%FacePlayerInit()
	lda.w HorzSpeed,y			;$01F87F	|| Set initial X speed towards Mario.
	sta !B6,x					;$01F882	|/
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
;; Set "Unstun" Flag
	lda #$80 : sta !1FD6,x
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
	lda #$00 : sta !extra_prop_1,x
Return018583:
	rts


Main:							;-----------| Eerie MAIN.
	tyx
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
;; Check Unstun Flag
	lda !1FD6,x : bpl .Continue
;; Wave State
	stz !C2,x
;; Set Vertical Speed
	lda.w VertSpeed+1
	sta !AA,x
;; Clear Unstun Flag
	stz !1FD6,x
.Continue
	LDA $9D						;$01F897	||
	BNE DrawGraphics				;$01F899	|/
	jsl !UpdateXPosNoGrvty		;$01F89B	| Update X position.
	LDA !C2,X					;$01F8A4	|\ 
	AND #$01					;$01F8A6	||
	TAY							;$01F8A8	||
	LDA !AA,X					;$01F8A9	||
	CLC							;$01F8AB	||
	ADC.w Acceleration,Y			;$01F8AC	|| Alternate vertical acceleration, to create the wave motion.
	STA !AA,X					;$01F8AF	||
	CMP.w VertSpeed,Y			;$01F8B1	||
	BNE +				;$01F8B4	||
	INC !C2,X					;$01F8B6	||
+					;			||
	jsl !UpdateYPosNoGrvty		;$01F8B8	|/
	lda #$03 : %SubOffScreen()
DoInteract:					;			|
	jsl !SprSprPMarioSprRts
;; Clip Wings and fix Sprite State
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
+	
;; Resume Normal Sprite Behavior
	%SetAnimationFrame()
DrawGraphics:
	JSR UpdateDirection
	jmp Spr0to13Gfx


namespace off

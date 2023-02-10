includefrom "../CustomKoopa.asm"

namespace ChasingFlyer


Acceleration:					;$01EBB4	| Acceleration values for a couple of sprites (Monty Mole, Eerie, Lakitu, Boo/Boo Block/Big Boo).
	db  $01,-$01

MaxSpeed:					;$01F8CF	| Max X/Y speeds for the Boo / Boo Block / Big Boo.
	db  $20,-$20


	; Red Parakoopa misc RAM:
	; $C2   - Timer for acceleration. Increments while accelerating; the Koopa's speed gets updated every 4th value.
	; $151C - Direction of next acceleration. Even = -, odd = +.
	; $1540 - Timer for how long to wait before applying acceleration again. Set to #$30 each time $151C increments.
	; $1570 - Frame counter for animation.
	; $157C - Direction of horizontal movement. 00 = right, 01 = left
	; $15AC - Timer to tell the sprite to turn around. Set to #$08 when turning, decreases every frame.
	; $1602 - Animation frame to use.
	;		   0/1 = walking, 02 = turning


Init:				;-----------| Standard sprite INIT. Used by all Koopas, Goombas, Buzzy Beetles, Spinies, and the Hopping Flame.
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
;; Set "Unstun" Flag
	lda #$80 : sta !1FD6,x
	lda #$00 : sta !extra_prop_1,x
Return018583:
	rts


Main:
	tyx
;; Check Unstun Flag
	lda !1FD6,x : bpl .SubOffScrn
;; Speed and Acceleration Timer
	stz !C2,x
;; Clear Unstun Flag
	stz !1FD6,x
.SubOffScrn
	lda #$00 : %SubOffScreen()
	LDA $9D						;$018CC6	|\ If sprites are locked, just draw the graphics.
	beq +				;$018CC8	|/
	jmp DrawGraphics
+	LDA.w !157C,X				;$018CCA	|\ 
	PHA							;$018CCD	||
	%FacePlayer()
	PLA							;$018CD1	|| If the sprite's direction of movement isn't the same as the one it's facing, turn it around.
	CMP.w !157C,X				;$018CD2	||
	BEQ NoTurnaround				;$018CD5	||
	LDA.b #$08					;$018CD7	||
	STA.w !15AC,X				;$018CD9	|/
NoTurnaround:					;			|
	%SetAnimationFrame()		;$018CDC	|
	INC !C2,X					;$018D02	||
	LDA !C2,X					;$018D04	||\ 
	AND.b #$01					;$018D06	||| Affect the Koopa's speed every 3 frames.
	BNE DoInteract				;$018D08	||/
;; Stolen from Boo following code.
	%SubHorzPosBnk1()			;$01F992	||\ 
	LDA !B6,X					;$01F995	|||
	CMP.w MaxSpeed,Y			;$01F997	|||
	BEQ +				;$01F99A	||| Accelerate horizontally towards Mario.
	CLC							;$01F99C	|||
	ADC.w Acceleration,Y			;$01F99D	|||
	STA !B6,X					;$01F9A0	||/
+					;			||
	LDA $D3						;$01F9A2	||\ 
	PHA							;$01F9A4	|||
	clc : adc #$10
	STA $D3						;$01F9A9	|||
	LDA $D4						;$01F9AB	|||
	PHA							;$01F9AD	|||
	adc #$00					;$01F9AE	|||
	STA $D4						;$01F9B0	|||
	%SubVertPosBnk1()			;$01F9B2	||| Accelerate vertically towards Mario.
	PLA							;$01F9B5	|||
	STA $D4						;$01F9B6	|||
	PLA							;$01F9B8	|||
	STA $D3						;$01F9B9	|||
	LDA !AA,X					;$01F9BB	|||
	CMP.w MaxSpeed,Y			;$01F9BD	|||
	BEQ +				;$01F9C0	|||
	CLC							;$01F9C2	|||
	ADC.w Acceleration,Y			;$01F9C3	|||
	STA !AA,X					;$01F9C6	|//
+
DoInteract:					;			|
	jsl !UpdateYPosNoGrvty		;$018CF7	||
	jsl !UpdateXPosNoGrvty		;$018CFA	|/
	jsl !CODE_019138
	%IsTouchingObjSide()
	beq +
	lda !B6,x : eor #$ff : inc : sta !B6,x
+	%IsTouchingObjVert()
	beq +
	lda !AA,x : eor #$ff : inc : sta !AA,x
+	jsl !SprSprPMarioSprRts		;$018D27	|
;; Clip Wings and fix Sprite State
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
;; Speed Shenanigans
	stz !AA,x
;; Halve Horizontal Speed (Signed)
	lda !B6,x : bpl .plus
	inc			; Ensures that #$FF turns into #$00
.plus
	cmp #$80 : ror
	sta !B6,x
+	
;; Resume Normal Sprite Behavior
DrawGraphics:					;			|
	jmp Spr0to13Gfx				;$018D2A	| Draw graphics.


namespace off

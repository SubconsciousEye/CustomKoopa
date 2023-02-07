

namespace DirectionalPatroller


Acceleration:					;$018CBA	| Acceleration values for the flying red Parakoopas. Affects both X and Y speeds!
	db -$01, $01

MaxSpeed:					;$01BCBC	| Max speeds for the flying red Parakoopas. Affects both X and Y speeds!
	db -$10, $10

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
;; Patrol State
	lda !157C,x
	bit !1510,x : bvs .HorzPatrol
	lda #$00
.HorzPatrol:
	sta !151C,x
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
	lda #$00 : sta !extra_prop_1,x
Return018583:
	rts


Main:
	tyx
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
;; Check Unstun Flag
	lda !1FD6,x : bpl .SubOffScrn
;; Acceleration Timer
	stz !C2,x
;; Zero Speed
	stz !AA,x : stz !B6,x
;; Clear Unstun Flag
	stz !1FD6,x
.SubOffScrn
	lda #$00
	bit !1510,x : bvc +
	inc					; Larger range for Horizontal
+	%SubOffScreen()
	LDA $9D						;$018CC6	|\ If sprites are locked, just draw the graphics.
	Beq +				;$018CC8	|/
	jmp DrawGraphics
+	LDA.w !157C,X				;$018CCA	|\ 
	PHA							;$018CCD	||
	JSR UpdateDirection			;$018CCE	||
	PLA							;$018CD1	|| If the sprite's direction of movement isn't the same as the one it's facing, turn it around.
	CMP.w !157C,X				;$018CD2	||
	BEQ NoTurnaround				;$018CD5	||
	LDA.b #$08					;$018CD7	||
	STA.w !15AC,X				;$018CD9	|/
NoTurnaround:					;			|
	%SetAnimationFrame()		;$018CDC	|
	bit !1510,x
	bvs HorizontalPatrol				;$018CE3	|/
	jsl !UpdateYPosNoGrvty		;$018CE5	|
	BRA CheckAccelerate				;$018CE8	|

HorizontalPatrol:
	LDY.b #$FC					;$018CEA	|\- Upwards Y speed for the horizontal Koopa.
	LDA.w !1570,X				;$018CEC	||
	AND.b #$20					;$018CEF	||| How often to change the horizontal Koopa's Y speed.
	BEQ VerticalBobbing				;$018CF1	||
	LDY.b #$04					;$018CF3	||| Downwards Y speed for the horizontal Koopa.
VerticalBobbing:					;			||
	STY !AA,X					;$018CF5	|| Update the Koopa's position and speed without gravity.
	jsl !UpdateYPosNoGrvty		;$018CF7	||
	jsl !UpdateXPosNoGrvty		;$018CFA	|/
CheckAccelerate:					;			|
	LDA.w !1540,X				;$018CFD	|\\ Branch if the Koopa is currently not accelerating.
	BNE DoInteract				;$018D00	||/
	INC !C2,X					;$018D02	||
	LDA !C2,X					;$018D04	||\ 
	AND.b #$03					;$018D06	||| Affect the Koopa's speed every 3 frames.
	BNE DoInteract				;$018D08	||/
	LDA.w !151C,X				;$018D0A	||\ 
	AND.b #$01					;$018D0D	|||
	TAY							;$018D0F	|||
	LDA !B6,X					;$018D10	||| Accelerate the Koopa.
	CLC							;$018D12	|||
	ADC.w Acceleration,Y			;$018D13	|||
	STA !AA,X					;$018D16	|||
	STA !B6,X					;$018D18	||/
	CMP.w MaxSpeed,Y			;$018D1A	||\ 
	BNE DoInteract				;$018D1D	||| If the Koopa has reached max speed, stop accelerating for a bit.
	INC.w !151C,X				;$018D1F	|||
	LDA.b #$30					;$018D22	|||| How many frames to wait before accelerating again.
	STA.w !1540,X				;$018D24	|//
DoInteract:					;			|
	jsl !SprSprPMarioSprRts		;$018D27	|
;; Clip Wings and fix Sprite State
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
+	
;; Resume Normal Sprite Behavior
DrawGraphics:					;			|
	jmp Spr0to13Gfx				;$018D2A	| Draw graphics.


namespace off

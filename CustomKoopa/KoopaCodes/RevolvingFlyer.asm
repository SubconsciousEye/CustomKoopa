

namespace RevolvingFlyer


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
;; Get Radius
	lda #$30					;$018396	| Radius of the circle that the ball part moves in.
	sta !C2,x				;$01839C	|
;; Preserve X Position
	lda !E4,x
	sta !151C,x
	lda !14E0,x
	sta !1528,x
;; Preserve Y Position
	lda !D8,x
	sta !1534,x
	lda !14D4,x
	sta !1594,x
	rts
.UnstunSprite:
;; Fix Angle and set "Unstun" Flag
	lda #$80 : sta !1FD6,x
	sta !160E,x
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
	lda #$00 : sta !extra_prop_1,x
Return018583:
	rts


Main:					;-----------| Ball 'n' Chain and Gray platform 
	tyx
;; Zero out some block-related stuff
	stz !1588,x : stz !15B8,x
;; Check Unstun Flag
	lda !1FD6,x : bpl .SubOffScrn
;; Fix Various 
.UnstunRevolver
;; Get Radius
	lda #$30					;$018396	| Radius of the circle that the ball part moves in.
	sta !C2,x				;$01839C	|
;; Preserve X Position
	lda !E4,x
	sta !151C,x
	lda !14E0,x
	sta !1528,x
;; Fix Origin Y position
	lda !D8,x : sec : sbc !C2,x : sta !1534,x
	lda !14D4,x : sbc #$00 : sta !1594,x
;; Zero Angle High Byte and Unstun Flag
	stz !1FD6,x
.SubOffScrn
	lda #$07 : %SubOffScreen()
	LDA $9D						;$02D62D	|\\ Don't rotate the sprite if game frozen.
;	BNE CODE_02D653				;$02D62F	||/
	beq +
	lda !1FD6,x : and #$01
	bra CODE_02D653
+	LDA !1510,X					;$02D631	||
	LDY #$02					;$02D633	||| Rotation speed counter-clockwise.
	AND #$40					;$02D635	||
	BNE CODE_02D63B				;$02D637	||
	LDY #$FE					;$02D639	||| Rotation speed clockwise.
CODE_02D63B:					;			||
	TYA							;$02D63B	||
	LDY #$00					;$02D63C	||
	CMP #$00					;$02D63E	|| Handle increasing the platform's rotation.
	BPL CODE_02D643				;$02D640	||
	DEY							;$02D642	||
CODE_02D643:					;			||
	CLC							;$02D643	||
	ADC !160E,X				;$02D644	||
	STA !160E,X				;$02D647	||
	TYA							;$02D64A	||
	ADC !1FD6,X				;$02D64B	||
	AND #$01					;$02D64E	||
	STA !1FD6,X				;$02D650	|/
CODE_02D653:					;			|
	sta !_05		; Angle high
	lda !160E,x
	sta !_04		; Angle low
	lda !C2,x
	sta !_06		; Radius
	%CircleX() : %CircleY()
;; X Position Set
	lda !151C,x
	clc : adc !_07
	sta !E4,x
	lda !1528,x
	adc !_08
	sta !14E0,x
;; Y Position Set
	lda !1534,x
	clc : adc !_09
	sta !D8,x
	lda !1594,x
	adc !_0a
	sta !14D4,x

	LDA $9D						;$018CC6	|\ If sprites are locked, just draw the graphics.
	BNE DrawGraphics				;$018CC8	|/
	LDA.w !157C,X				;$018CCA	|\ 
	PHA							;$018CCD	||
	%FacePlayer()			;$018CCE	||
	PLA							;$018CD1	|| If the sprite's direction of movement isn't the same as the one it's facing, turn it around.
	CMP.w !157C,X				;$018CD2	||
	BEQ NoTurnaround				;$018CD5	||
	LDA.b #$08					;$018CD7	||
	STA.w !15AC,X				;$018CD9	|/
NoTurnaround:					;			|
	%SetAnimationFrame()		;$018CDC	|
DoInteract:					;			|
	jsl !SprSprPMarioSprRts		;$018D27	|
;; Clip Wings and fix Sprite State
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
;; Clean out misc tables (to prevent bugs)
	stz !C2,x
	stz !151C,x : stz !1528,x
	stz !1534,x : stz !1594,x
+	
;; Resume Normal Sprite Behavior
DrawGraphics:					;			|
	jmp Spr0to13Gfx				;$018D2A	| Draw graphics.


namespace off

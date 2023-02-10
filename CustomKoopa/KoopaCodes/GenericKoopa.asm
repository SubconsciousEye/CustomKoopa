includefrom "../CustomKoopa.asm"

InitStandardSprite:				;-----------| Standard sprite INIT. Used by all Koopas, Goombas, Buzzy Beetles, Spinies, and the Hopping Flame.
	tyx
	jsl !GetRand					;$018575	|
	sta !1570,x				;$018579	|
	%FacePlayerInit()
;; Acts Like
	lda !1510,x : and #$20		; W bit
	bne .Parakoopa
	lda !1510,x : and #$02		; K bit
	bne .Smb3koopa
	lda #$04 : bra .SetActsLike
.Parakoopa
;; Don't change direction when touched
;;  SMW sets this for Yellow Parakoopas
;;  for *some* reason.
	lda !1686,x : ora #$10 : sta !1686,x
.Smb3koopa
	lda #$11
.SetActsLike
	sta !9E,x
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
	lda #$00 : sta !extra_prop_1,x
Return018583:					;			|
	rts							;$018583	|


Spr0to13Start:					;-----------| Starting MAIN for: All normal Koopas, Yellow Winged Koopas, Bob-ombs, Goombas, Buzzy Beetles, and Spinies.
	tyx
	LDA $9D						;$018AFC	|\ If the game is not frozen, branch to the MAIN.
	BEQ Spr0to13Main			;$018AFE	|/
	jmp Spr0to13Gfx


Spr0to13Main:					;-----------| Shared routine for most sprites 0 to 13.
	%IsOnGround()				;$018B0A	|\ Branch if the sprite is not on ground.
	BEQ CODE_018B2E				;$018B0D	|/
	ldy !1510,x					;$018B0F	|\ 
	LDA.w BehaviorProps,Y		;$018B11	|| 
	LSR							;$018B14	||
	LDY !157C,X				;$018B15	||
	BCC CODE_018B1C				;$018B18	||
	INY							;$018B1A	||
	INY							;$018B1B	||
CODE_018B1C:					;			|| Set the sprite's X speed, depending on the type of slope it's standing on.
	LDA.w Spr0to13SpeedX,Y		;$018B1C	|| If the corresponding property bit is set, the sprite will move a bit faster.
	EOR !15B8,X				;$018B1F	||
	ASL							;$018B22	||
	LDA.w Spr0to13SpeedX,Y		;$018B23	||
	BCC CODE_018B2C				;$018B26	||
	CLC							;$018B28	||
	ADC !15B8,X				;$018B29	||
CODE_018B2C:					;			||
	STA !B6,X					;$018B2C	|/
CODE_018B2E:					;			|
	LDY !157C,X				;$018B2E	|\ 
	TYA							;$018B31	||
	INC						;$018B32	||
	AND !1588,X				;$018B33	|| If the sprite walks into the side of a block, stop it.
	AND #$03					;$018B36	||
	BEQ CODE_018B3C				;$018B38	||
	STZ !B6,X					;$018B3A	|/
CODE_018B3C:					;			|
	%IsTouchingCeiling()		;$018B3C	|\ 
	BEQ CODE_018B43				;$018B3F	|| If the sprite is touching a ceiling, zero its Y speed.
	STZ !AA,X					;$018B41	|/
CODE_018B43:					;```````````| Primary code for handling most sprites in 00-13.
	lda #$00 : %SubOffScreen()
	jsl !UpdateSpritePos			;$018B46	| Update X/Y position, apply gravity, and process interaction with blocks.
	%SetAnimationFrame()		;$018B49	| Handle 2-frame animation.
	%IsOnGround()				;$018B4C	|\ If the sprite is not on the ground, branch.
	BEQ SpriteInAir				;$018B4F	|/
SpriteOnGround:					;```````````| Sprite is on the ground.
	JSR SetSomeYSpeed			;$018B51	| Set the sprite's ground Y speed (#$00 or #$18 depending on flat or slope).
	STZ !151C,X				;$018B54	| For sprites that stay on ledges: you're currently on a ledge.
	ldy !1510,x					;$018B57	|\ 
	LDA.w BehaviorProps,Y		;$018B59	||
	PHA							;$018B5C	|| Follow Mario if set to do so.
	AND #$04					;$018B5D	||  Don't turn if not time to or already facing Mario.
	BEQ DontFollowMario			;$018B5F	||
	LDA !1570,X				;$018B61	||
	AND #$7F					;$018B64	||| How often to poll for Mario's direction.
	BNE DontFollowMario			;$018B66	||
	LDA !157C,X				;$018B68	||
	PHA							;$018B6B	||
	%FacePlayer()				;$018B6C	||
	PLA							;$018B6F	||
	CMP !157C,X				;$018B70	||
	BEQ DontFollowMario			;$018B73	||
	LDA #$08					;$018B75	||\ Turn around.
	STA !15AC,X				;$018B77	|//
DontFollowMario:				;			|
	PLA							;$018B7A	|\ 
	AND #$08					;$018B7B	|| If the sprite is set to jump over shells (yellow Koopas), run the code for that.
	BEQ CODE_018B82				;$018B7D	||
	JSR JumpOverShells			;$018B7F	|/
CODE_018B82:					;			|
	BRA CODE_018BB0				;$018B82	|

SpriteInAir:					;```````````| Sprite is in midair.
	ldy !1510,x				;$018B84	|\ 
	LDA.w BehaviorProps,Y		;$018B86	||
	BPL CODE_018B90				;$018B89	|| If set to do so, animate the sprite twice as fast in mid-air.
	%SetAnimationFrame()		;$018B8B	||  (only winged yellow Koopas)
	BRA CODE_018B93				;$018B8E	||
CODE_018B90:					;			||
	STZ !1570,X				;$018B90	|/
CODE_018B93:					;			|
	LDA.w BehaviorProps,Y		;$018B93	|\ 
	AND #$02					;$018B96	|| 
	BEQ CODE_018BB0				;$018B98	||
	LDA !151C,X				;$018B9A	||
	ORA !1558,X				;$018B9D	||
	ORA !1528,X				;$018BA0	|| If the sprite is set to turn on ledges and is not having a special function run, flip its direction.
	ORA !1534,X				;$018BA3	||
	BNE CODE_018BB0				;$018BA6	||
	JSR FlipSpriteDir			;$018BA8	||
	LDA #$01					;$018BAB	||
	STA !151C,X				;$018BAD	|/
CODE_018BB0:					;```````````| On-ground code rejoins here.
	LDA !1528,X				;$018BB0	|\ 
	BEQ CODE_018BBA				;$018BB3	||
	JSR KickKill				;$018BB5	|| If the sprite is not sliding, process standard interaction with Mario.
	BRA CODE_018BBD				;$018BB8	||  If the sprite is sliding, process the kick-kill interaction with Mario.
CODE_018BBA:					;			||
	jsl !MarioSprInteract		;$018BBA	|/
;; Clip Wings and fix Sprite State
	lda !1510,x : and #$20 : beq +
	lda !14C8,x : cmp #$09 : bne +
	lda #$08 : sta !14C8,x
	lda !1510,x : and.b #~$20 : sta !1510,x
	lda !1504,x : and.b #~$20 : sta !1504,x
;; Override Squish State
;+	lda !14C8,x : cmp #$03 : bne +
;	lda #$80 : sta !extra_prop_2,x
+	
;; Resume Normal Sprite Behavior
CODE_018BBD:					;			|
	jsl !SprSprInteract		;$018BBD	|\ Process interaction with other sprites; turn around if it hits something.
	JSR FlipIfTouchingObj		;$018BC0	|/
Spr0to13Gfx:
;; TODO: See if it can be merged with PrepKoopaGfx
	LDA !157C,X				;$018BC3	|
	PHA							;$018BC6	|
	LDY !15AC,X				;$018BC7	|\ 
	BEQ CODE_018BDE				;$018BCA	||
	phy
	ldy !1510,x
	lda.w BehaviorProps,y
	and #$40
	beq .NoTurnFrame
	LDA #$02					;$018BCC	||
	STA !1602,X				;$018BCE	||
.NoTurnFrame:
	ply
	LDA #$00					;$018BD1	|| If the sprite's turn timer is non-zero, turn it around.
	CPY #$05					;$018BD3	|| The actual turn occurs on frame 3 of the animation.
	BCC CODE_018BD8				;$018BD5	||
	INC						;$018BD7	||
CODE_018BD8:					;			||
	EOR !157C,X				;$018BD8	||
	STA !157C,X				;$018BDB	|/
CODE_018BDE:					;			|
	ldy !1504,x
	lda.w GraphicProps,y
	and #$02
	beq .OneTileHigh
.TwoTilesHigh
	lda #$20 : ora !190F,x : bra +
.OneTileHigh
	lda !190F,x : and.b #~$20
+	sta !190F,x
	jsr PrepKoopaGfx		;$018BE7	||
DoneWithSprite:					;			|
	PLA							;$018C13	|
	STA !157C,X				;$018C14	|
	RTS							;$018C17	|


FlipIfTouchingObj:				;-----------| Subroutine to turn a sprite around if it hits an object.
	LDA !157C,X				;$019089	|
	INC						;$01908C	|
	AND !1588,X				;$01908D	|
	AND #$03					;$019090	|
	BEQ Return019097			;$019092	|
	;JSR FlipSpriteDir			;$019094	|
	;RTS							;$019097	|
FlipSpriteDir:					;-----------| Subroutine to change the direction of a sprite's movement.
	LDA !15AC,X				;$019098	|\ If it's already turning, return.
	BNE Return0190B1			;$01909B	|/
	LDA #$08					;$01909D	|\ Set the turning timer.
	STA !15AC,X				;$01909F	|/
CODE_0190A2:					;			|
	LDA !B6,X					;$0190A2	|\ 
	EOR #$FF					;$0190A4	||
	INC						;$0190A6	||
	STA !B6,X					;$0190A7	|| Invert the sprite's speed.
	LDA !157C,X				;$0190A9	||
	EOR #$01					;$0190AC	||
	STA !157C,X				;$0190AE	|/
Return0190B1:					;			|
Return019097:					;			|
	RTS


CheckKickKill:					;```````````| Handle interaction between Mario and a stunned Koopa.
	LDA !9E,X					;$018931	|\ 
	CMP #$02					;$018933	||
	BNE KickKill				;$018935	|| If the blue Koopa and in contact with it, hurt Mario.
	jsl !MarioSprInteract		;$018937	||
	;BRA Return018951			;$01893A	|/
	rts
KickKill:					;			|
	ASL !167A,X				;$01893C	|\ 
	SEC							;$01893F	||
	ROR !167A,X				;$018940	||
	jsl !MarioSprInteract		;$018943	|| If not the blue Koopa and in contact with it, kick-kill it.
	BCC +				;$018946	||
	LDA #$10					;$01B12A	| How long to show Mario's "kicked sprite" pose.
	STA $149A|!addr					;$01B12C	|
	LDA #$03					;$01B12F	|\ SFX for kicking the sprite.
	STA $1DF9|!addr				;$01B131	|/
	%SubHorzPosBnk1()			;$01B134	|\ 
	LDA #$E0					;$01B13C	| Speed to send the fish flying
	STA !AA,X					;$01B13E	|
	LDA #$02					;$01B140	|\ Kill the sprite.
	STA !14C8,X				;$01B142	|/
	STY $76						;$01B145	| Make Mario face the sprite he kicked.
	LDA #$01					;$01B147	| Number of points to give Mario for kicking a Koopa/Fish (200).
	JSL !GivePoints				;$01B149	|
+	ASL !167A,X				;$01894B	||
	LSR !167A,X				;$01894E	|/
	RTS							;$018951	|


JumpOverShells:					;-----------| Subroutine to make the yellow Koopa jump over shells.
	TXA							;$018898	|\ 
	EOR $13						;$018899	|| Divide detection across four frames. If not the right frame, return.
	AND #$03					;$01889B	||
	BNE Return0188AB			;$01889D	|/
	LDY #!SprSize-1					;$01889F	|\ 
JumpLoopStart:					;			||
	LDA !14C8,Y				;$0188A1	||
	CMP #$0A					;$0188A4	|| Look for a sprite that's been thrown. Return if none exists.
	BEQ HandleJumpOver			;$0188A6	||
JumpLoopNext:					;			||
	DEY							;$0188A8	||
	BPL JumpLoopStart			;$0188A9	|/
Return0188AB:					;			|
	RTS							;$0188AB	|

HandleJumpOver:
	LDA !E4,Y				;$0188AC	|\ Store some clipping values.
	SEC							;$0188AF	||
	SBC #$1A					;$0188B0	||
	STA $00						;$0188B2	|| $00 - Clipping X displacement lo
	LDA !14E0,Y				;$0188B4	|| 
	SBC #$00					;$0188B7	||
	STA $08						;$0188B9	|| $08 - Clipping X displacement hi
	LDA #$44					;$0188BB	||
	STA $02						;$0188BD	|| $02 - Clipping width
	LDA !D8,Y				;$0188BF	||
	STA $01						;$0188C2	|| $01 - Clipping Y displacement lo
	LDA !14D4,Y				;$0188C4	||
	STA $09						;$0188C7	|| $09 - Clipping Y displacement hi
	LDA #$10					;$0188C9	||
	STA $03						;$0188CB	|/ $03 - Clipping height
	JSL !GetSpriteClippingA		;$0188CD	|\ 
	JSL !CheckForContact			;$0188D1	|| Check if the shell is close enough to the Koopa. If not, loop back and check for any other shells.
	BCC JumpLoopNext			;$0188D5	|/
	%IsOnGround()				;$0188D7	|\ If the shell is not on the ground, loop back and check for any other shells.
	BEQ JumpLoopNext			;$0188DA	|/
	LDA !157C,Y				;$0188DC	|\ 
	CMP !157C,X				;$0188DF	|| If the Koopa and shell are moving in the same direction, return.
	BEQ Return0188EB			;$0188E2	|/
	LDA #$C0					;$0188E4	| Speed that the yellow Koopa jumps at.
	STA !AA,X					;$0188E6	|
	STZ !163E,X				;$0188E8	|
Return0188EB:					;			|
	RTS							;$0188EB	|


SetSomeYSpeed:					;-----------| Subroutine to set Y speed for a sprite when on the ground.
	LDA !1588,X				;$019A04	|\ 
	BMI CODE_019A10				;$019A07	||
	LDA #$00					;$019A09	|| 
	LDY !15B8,X				;$019A0B	|| If standing on a slope or Layer 2, give the sprite a Y speed of #$18.
	BEQ CODE_019A12				;$019A0E	|| Else, clear its Y speed.
CODE_019A10:					;			||
	LDA #$18					;$019A10	||
CODE_019A12:					;			||
	STA !AA,X					;$019A12	|/
	RTS							;$019A14	|


UpdateDirection:				;-----------| Subroutine to update a sprite's direction based on its current X speed.
	LDA #$00					;$019A15	|
	LDY !B6,X					;$019A17	|
	BEQ Return019A21			;$019A19	|
	BPL CODE_019A1E				;$019A1B	|
	INC						;$019A1D	|
CODE_019A1E:					;			|
	STA !157C,X				;$019A1E	|
Return019A21:					;			|
	RTS							;$019A21	|



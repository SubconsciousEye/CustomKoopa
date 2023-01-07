

namespace BeachKoopa


KickThrownSpd:					;$01A6D7	| X speeds for shells/Goombas/Bob-ombs/etc. after a blue Koopa kicks it. Right, left.
	db $30,-$30

MaxSliderSpeed:					;$038954	| Max X speeds down slopes for the sliding blue Koopa.
	db  $20,-$20

SliderAcceleration:					;$038956	| X accelerations down slopes for the sliding blue Koopa.
	db  $02,-$02


Init:
	tyx
	jsl !GetRand					;$018575	|
	sta !1570,x				;$018579	|
	%FacePlayerInit()
	lda !extra_byte_1,x
	bpl .ZeroExtraBytes
	lda #$04 : sta !1540,x
	lda #$80 : sta !1FD6,x		; Sliding Koopa Flag
.ZeroExtraBytes:
;; Zero out the extra bytes since we
;;  no longer need them.
	lda #$00
	sta !extra_byte_1,x
	sta !extra_byte_2,x
.ActsLike
;; Set up Acts Like for Hopping/Kicking Shells
	lda !1510,x : lsr : and #$0f : tay
	lda.w BeachActsLike,y
	beq ..disable
	sta !9E,x
	lda !1656,x : ora #$40 : sta !1656,x
	bra .OtherProps
..disable
	lda #$36
	sta !9E,x
.OtherProps
;; Fix up other sprite properties
;;  Can be squished
	lda #$20 : ora !1656,x : sta !1656,x
;;  Insta-eat via Yoshi
	lda !1686,x : and.b #~$02 : sta !1686,x
;;  "Getting stuck in walls flag"
	lda !190F,x : and.b #~$80 : sta !190F,x
	rts


Main:					;-----------| Shell-less Koopa MAIN
	tyx
	lda !1FD6,x : bpl +		; Not Sliding Koopa
	jsr SlidingKoopa
	jmp Spr0to13Gfx
+	LDA $9D						;$018904	|\ If the game is NOT frozen, branch.
	BEQ Continue				;$018906	|/
	jmp Spr0to13Gfx
KnockedOut:					;			|
	LDA !163E,X				;$018908	|\ 
	CMP #$80					;$01890B	|| Skip if the Koopa's stun timer is not >= 80.
	BCC DoInteract				;$01890D	|/
	LDA $9D						;$01890F	|\ Skip if the game is frozen.
	BNE DoInteract				;$018911	|/
KnockedOutFrame:					;			|
	%SetAnimationFrame()		;$018913	|\ 
	LDA !1602,X				;$018916	||
	CLC : ADC #$04						;$018919	|| Animate stunned Koopa (frames 5/6)
	STA !1602,X				;$01891C	|/
DoInteract:					;			|
	JSR CheckKickKill				;$01891F	| Handle contact with Mario (hurt if blue Koopa, else kick-kill it).
	jsl !UpdateSpritePos			;$018922	| Update X/Y position, apply gravity, and process interaction with blocks.
	STZ !B6,X					;$018925	|\ 
	%IsOnGround()				;$018927	|| Stop the Koopa and don't let it fall through the ground.
	BEQ + : STZ !AA,X : +
	JMP Finalize				;$01892E	| Process interaction with other sprites and draw graphics, then return.


Continue:					;```````````| Shell-less Koopa routine when the game is not frozen; check stunned.
	LDA !163E,X		 		;$018952	|\ Branch if the Koopa is not stunned nor stationary.
	BEQ CheckSkid 			;$018955	|/
	CMP #$80					;$018957	|\ 
	BNE NoWakeup				;$018959	||
	%FacePlayer()				;$01895B	|| If the stun timer is 80, unstun the sprite.
	LDA !9E,X					;$01895E	||  If not the blue Koopa, make it jump in the air too.
	CMP #$02					;$018960	||
	BEQ StandWakeup				;$018962	||
	LDA #$E0					;$018964	||| Speed to make the Koopa jump when flipping upright.
	STA !AA,X					;$018966	||
StandWakeup:					;			||
	STZ !163E,X				;$018968	|/
NoWakeup:					;			|
	CMP #$01					;$01896B	|\ 
	BNE KnockedOut				;$01896D	||
	LDY !160E,X				;$01896F	||
	LDA !14C8,Y				;$018972	||
	CMP #$09					;$018975	|| Jump back and handle basic functionality if:
	BNE KnockedOut				;$018977	||  - This is not a blue Koopa just about to kick a shell/goomba/etc.
	LDA !E4,X					;$018979	||  - The state of the sprite being kicked isn't still 09 (stationary/carryable).
	SEC							;$01897B	||  - The Koopa isn't close enough to the sprite.
	SBC !E4,Y				;$01897C	||
	CLC							;$01897F	||
	ADC #$12					;$018980	||
	CMP #$24					;$018982	||
	BCS KnockedOut				;$018984	|/
	%PlayKickSfx()				;$018986	| Play the kick sound effect.
	LDA #$20 : STA !C2,X			;$01A755	| How many frames Koopas freeze for after kicking a shell or flipping one over.
	STA !1558,X				;$01A759	|
	LDY !157C,X				;$01898C	|\ 
	LDA.w KickThrownSpd,Y			;$01898F	|| Kick the sprite in the direction the Koopa is facing.
	LDY !160E,X				;$018992	||
	STA !B6,Y				;$018995	|/
	LDA #$0A					;$018998	|\ Set the sprite to a kicked status.
	STA !14C8,Y				;$01899A	|/
	LDA !1540,Y				;$01899D	|\ As it happens, both of these should be zero.
	STA !C2,Y				;$0189A0	|/
	LDA #$08					;$0189A3	|\ Disable contact with other sprites for 8 frames after being kicked.
	STA !1564,Y				;$0189A5	|/
	LDA !167A,Y				;$0189A8	|\ 
	AND #$10					;$0189AB	|| If it can't be kicked like a shell (i.e. Goombas, Bob-ombs, etc.), kick it slightly upwards.
	BEQ CheckSkid				;$0189AD	||
	LDA #$E0					;$0189AF	||| Y speed to give non-shell sprites when kicked by a blue Koopa.
	STA !AA,Y				;$0189B1	|/

CheckSkid:					;```````````| Not stunned; check sliding.
	LDA !1528,X				;$0189B4	|\ If the Koopa is not sliding, skip this code.
	BEQ CheckCatch				;$0189B7	|/
	%IsTouchingObjSide()		;$0189B9	|\ 
	BEQ + : STZ !B6,X : +
	%IsOnGround()				;$0189C0	|\ 
	BEQ SkidNotGrounded				;$0189C3	||
	LDA $86						;$0189C5	|| 
	CMP #$01					;$0189C7	||
	LDA #$02					;$0189C9	|| Apply friction to the sliding Koopa, with slipperiness factored in.
	BCC + : LSR : +
	STA $00						;$0189CE	||
	LDA !B6,X					;$0189D0	||\ 
	CMP #$02					;$0189D2	||| If the Koopa's speed is less than #$02, branch to stop sliding.
	BCC CheckKnockOut				;$0189D4	||/
	BPL +				;$0189D6	||\ 
	CLC : ADC $00						;$0189D9	|||
	CLC : ADC $00						;$0189DC	||| Decelerate the Koopa.
+	SEC : SBC $00						;$0189DF	|||
	STA !B6,X					;$0189E1	||/
	JSR SpawnDust				;$0189E3	|/ Spawn sliding smoke sprites at the Koopa's position.
SkidNotGrounded:					;			|
	STZ !1570,X				;$0189E6	| Don't animate.
	lda #$04 : sta !1602,x
	bra FinishGeneric				;$0189E9	| Run the shared routine.

CheckKnockOut:
	%IsOnGround()				;$0189FD	|\ If the sprite is not on the ground, branch.
	BEQ KnockOutAir				;$018A00	|/
	LDA #$FF					;$018A02	|] How many frames the green/red/yellow Koopas are stunned for after being knocked out of a shell (+#$80). 
	LDY !9E,X					;$018A04	|
	CPY #$02					;$018A06	|
	BNE RegularKnockOut				;$018A08	|
	LDA #$A0					;$018A0A	|] How many frames the blue Koopas are stunned for after being knocked out of a shell (+#$80). 
RegularKnockOut:					;			|
	STA !163E,X				;$018A0C	|
KnockOutAir:					;			|
	STZ !1528,X				;$018A0F	| Track that the Koopa is no longer sliding.
	JMP KnockedOutFrame				;$018A12	| Return back for stunned Koopa interaction.


CheckCatch:					;```````````| Not sliding; check catching.
	LDA !1534,X				;$018A15	|\ Branch if the the sprite isn't catching a shell/goomba/etc.
	bne +				;$018A18	|/
	jmp NoCatch
+	LDY !160E,X				;$018A1A	|\ 
	LDA !14C8,Y				;$018A1D	||
	CMP #$0A					;$018A20	|| Clear the "catching" flag and branch if the shell has stopped.
	BEQ CaughtThrown				;$018A22	||
	STZ !1534,X				;$018A24	||
	BRA FinishSkid				;$018A27	|/

CaughtThrown:					;```````````| Blue Koopa is catching a shell (or Goomba/Bob-omb/MechaKoopa).
	STA !1528,Y				;$018A29	| Set the sliding flag.
	%IsTouchingObjSide()		;$018A2C	|\ 
	BEQ +				;$018A2F	||
	LDA #$00					;$018A31	|| If the Koopa is pushed into a solid block, clear the X speed for both sprites.
	STA !B6,Y				;$018A33	||
	STA !B6,X					;$018A36	|/
+	%IsOnGround()			;$018A38	|\ 
	BEQ FinishSkid				;$018A3B	||
	LDA $86						;$018A3D	||
	CMP #$01					;$018A3F	||
	LDA #$02					;$018A41	|| Apply friction to both sprites, with slipperiness factored in.
	BCC + : LSR : + : STA $00						;$018A46	||
	LDA !B6,Y				;$018A48	||\ 
	CMP #$02					;$018A4B	||| If the shell's speed is less than #$02, branch to stop sliding.
	BCC HaltThrown				;$018A4D	||/
	BPL +				;$018A4F	||\ 
	CLC : ADC $00						;$018A52	|||
	CLC : ADC $00						;$018A55	||| Decelerate the two sprites.
+	SEC : SBC $00						;$018A58	|||
	STA !B6,Y				;$018A5A	|||
	STA !B6,X					;$018A5D	||/
	JSR SpawnDust				;$018A5F	|/ Spawn sliding smoke sprites at the Koopa's position.
FinishSkid:					;			|
	STZ !1570,X				;$018A62	| Don't animate.
FinishGeneric:					;```````````| Primary code for handling most sprites in 00-13.
	lda #$00 : %SubOffScreen()
	jsl !UpdateSpritePos			;$018B46	| Update X/Y position, apply gravity, and process interaction with blocks.
	;JSR SetAnimationFrame		;$018B49	| Handle 2-frame animation.
	%IsOnGround()				;$018B4C	|\ If the sprite is not on the ground, branch.
	BEQ +				;$018B4F	|/
	jmp SpriteOnGround					;```````````| Sprite is on the ground.
+					;```````````| Sprite is in midair.
	ldy !1510,x
	jmp CODE_018B93


HaltThrown:					;```````````| Blue Koopa has just stopped a shell (or Goomba/Bob-omb/MechaKoopa).
	LDA #$00					;$018A69	|\ 
	STA !B6,X					;$018A6B	|| Clear both sprites' X speed.
	STA !B6,Y				;$018A6D	|/
	STZ !1534,X				;$018A70	| Clear catching flag.
	LDA #$09					;$018A73	|\ Make the sprite stationary/carryable.
	STA !14C8,Y				;$018A75	|/
	PHX							;$018A78	|
	TYX							;$018A79	|\ 
	JSR CODE_01AA0B				;$018A7A	||
	LDA !1540,X				;$018A7D	|| If the sprite is a Goomba/Bob-omb/MechaKoopa, reset their stun timer to #$FF.
	BEQ NotShell				;$018A80	||
	LDA #$FF					;$018A82	||
	STA !1540,X				;$018A84	|/
NotShell:					;			|
	PLX							;$018A87	|


NoCatch:					;```````````| Not catching; check kicking/flipping.
	LDA !C2,X					;$018A88	|\ If the Koopa is not kicking/flipping a shell, branch.
	BEQ CheckEntering				;$018A8A	|/
	DEC !C2,X					;$018A8C	|
	CMP #$08					;$018A8E	|\ 
	LDA #$03					;$018A90	||| Animation frame to use when it kicks a shell (including to flip a shell over).
	BCS +				;$018A92	||
	LDA #$00					;$018A94	||| Animation frame to use for a few frames after kicking before it starts moving again.
+					;			||
	STA !1602,X				;$018A96	|/
	jsl !MarioSprInteract		;$018B00	| Process standard Mario-Sprite interaction.
;; Override Squish State
;	lda !14C8,x : cmp #$03 : bne +
;	lda #$80 : sta !extra_prop_2,x
+	
Finalize:					;			|
	jsl !SprSprInteract		;$018B03	| Process interaction with other sprites.
	jmp Spr0to13Gfx				;$018B06	| Draw graphics.


CheckEntering:					;```````````| Not kicking/flipping; check entering.
	LDA !1558,X				;$018A9B	|\ 
	CMP #$01					;$018A9E	|| If not about to enter a shell, branch to the general sprite code.
	beq +
	jmp Spr0to13Main
+	LDY !1594,X				;$018AA2	|\ 
	LDA !14C8,Y				;$018AA5	||
	CMP #$08					;$018AA8	||
	BCC Return			;$018AAA	||
	LDA !AA,Y				;$018AAC	||
	BMI Return			;$018AAF	|| Return if:
	LDA !9E,Y				;$018AB1	||  - The shell is no longer alive.
	CMP #$21					;$018AB4	||  - The shell has Y speed.
	BEQ Return			;$018AB6	||  - The shell turned into a coin.
	JSL !GetSpriteClippingA		;$018AB8	||  - The Koopa and shell aren't touching anymore.
	PHX							;$018ABC	||
	TYX							;$018ABD	||
	JSL !GetSpriteClippingB		;$018ABE	||
	PLX							;$018AC2	||
	JSL !CheckForContact			;$018AC3	||
	BCC Return			;$018AC7	|/
	%OffScrEraseSprite()		;$018AC9	| Erase the Koopa.
	LDY !1594,X				;$018ACC	|\ 
	LDA #$10					;$018ACF	||| Number of frames to shake the Koopa shell for after a Koopa enters it.
	STA !1558,Y				;$018AD1	|/
	LDA !9E,X					;$018AD4	|\ Track the sprite ID of the Koopa that just jumped into the shell.
	STA !160E,Y				;$018AD6	|/
if !option_14C8EraseExtraBits == !True
	lda !extra_bits,x
	tyx
	sta !extra_prop_2,x
	ldx !sprite_slot
endif
Return:					;			|
	RTS							;$018AD9	|


SpawnDust:					;-----------| Subroutine to draw a smoke/dust sprite at the sprite's position. Specifically meant for sliding smoke from friction.
	LDA !1588,X				;$01804E	|\ If the sprite is not blocked on any side, return.
	BEQ ReturnDust			;$018051	|/
	LDA $13						;$018053	|\ 
	AND #$03					;$018055	|| Only calculate once every 4 frames, completely ignore if the level is slippery.
	ORA $86						;$018057	||
	BNE ReturnDust			;$018059	|/
	LDA #$04					;$01805B	|\\ Distance from the sprite's left side to spawn the smoke.
	STA $00						;$01805D	||
	LDA #$0A					;$01805F	||| Distance below the sprite's top to spawn the smoke.
	STA $01						;$018061	|/
	LDA !15A0,X : ORA !186C,X	;$018063	|\ If the sprite is offscreen, don't bother calculating.
	BNE ReturnDust			;$018066	|/
	LDY #$03					;$018068	|\ 
-					;			||
	LDA $17C0|!addr,Y				;$01806A	||
	BEQ +				;$01806D	|| Look for an empty smoke sprite slot, return if none are found.
	DEY							;$01806F	||
	BPL -				;$018070	||
ReturnDust:					;			||
	RTS							;$018072	|/
+	LDA.b #$03					;$018073	|\\ Draw sliding smoke...
	STA.w $17C0|!addr,Y				;$018075	||/
	LDA !E4,X					;$018078	||\ 
	ADC $00						;$01807A	|||
	STA.w $17C8|!addr,Y				;$01807C	||| ...at the sprite's position...
	LDA !D8,X					;$01807F	|||
	ADC $01						;$018081	|||
	STA.w $17C4|!addr,Y				;$018083	||/
	LDA.b #$13					;$018086	||\ ...for 19 frames.
	STA.w $17CC|!addr,Y				;$018088	|//
	RTS							;$01808B	|



	; Sliding Blue Koopa misc RAM:
	; $1540 - Timer set briefly on spawn, to prevent the Koopa from immediately falling.
	; $1558 - Timer after the Koopa stops to wait before turning into a normal Koopa.
	; $157C - Horizontal direction the sprite is facing.
	
SlidingKoopa:					;-----------| Sliding blue Koopa MAIN
	LDA #$00					;$038958	|\ 
	LDY !B6,X					;$03895A	||
	BEQ CODE_038964				;$03895C	||
	BPL CODE_038961				;$03895E	|| Update direction based on X speed.
	INC						;$038960	||
CODE_038961:					;			||
	STA !157C,X				;$038961	|/
CODE_038964:
	LDA !1558,X				;$03896B	|\ 
	CMP #$01					;$03896E	||
	LDA #$06					;$038983	||| Pose to use for the sliding blue Koopa while sliding.
	BCC CODE_038989				;$038985	||
	stz !1FD6,x
	LDA #$00					;$038987	||| Pose to use for the sliding blue Koopa when it's about to turn into a normal Koopa.
CODE_038989:					;			||
	sta !1602,x
	LDA !14C8,X				;$03898C	|\ 
	CMP #$08					;$03898F	|| Return if dead.
	BNE Return0389FE			;$038991	|/
	lda #$00 : %SubOffScreen()
	JSL !SprSprPMarioSprRts		;$038996	| Process interaction with Mario and other sprites.
;	lda !14C8,x : cmp #$03 : bne .NoSquish
;	lda #$80 : sta !extra_prop_2,x
.NoSquish:
	LDA $9D						;$03899A	|\ 
	ORA !1540,X				;$03899C	|| Return if game frozen or the Koopa has stopped.
	ORA !1558,X				;$03899F	||
	BNE Return0389FE			;$0389A2	|/
	JSL !UpdateSpritePos			;$0389A4	| Update X/Y position, apply gravity, and process interaction with blocks.
	LDA !1588,X				;$0389A8	|\ 
	AND #$04					;$0389AB	|| Return if not on the ground.
	BEQ Return0389FE			;$0389AD	|/
	JSR CODE_0389FF				;$0389AF	| Handle spawning the friction smoke.
	LDY #$00					;$0389B2	|\ 
	LDA !B6,X					;$0389B4	||
	BEQ CODE_0389CC				;$0389B6	||
	BPL CODE_0389BD				;$0389B8	||
	EOR #$FF : INC				;$0389BA	||
CODE_0389BD:					;			||
	STA $00						;$0389BD	|| Calculate Y speed for the blue Koopa based on the type of slope it's on and its current X speed.
	LDA !15B8,X				;$0389BF	||  Normally, it always tries to move the sprite in a 45-degree angle downwards, unless sliding up a slope.
	BEQ CODE_0389CC				;$0389C2	||
	LDY $00						;$0389C4	||
	EOR !B6,X					;$0389C6	||
	BPL CODE_0389CC				;$0389C8	||
	LDY #$D0					;$0389CA	||| Y speed to give the blue Koopa when sliding up a slope.
CODE_0389CC:					;			||
	STY !AA,X					;$0389CC	|/
	LDA $13						;$0389CE	|\ 
	AND #$01					;$0389D0	|| Return every odd frame.
	BNE Return0389FE			;$0389D2	|/
	LDA !15B8,X				;$0389D4	|\ Branch if not on flat ground.
	BNE CODE_0389EC				;$0389D7	|/
	LDA !B6,X					;$0389D9	|\ 
	BNE CODE_0389E3				;$0389DB	|| If the Koopa has come to a stop, set its timer for returning to normal.
	LDA #$20					;$0389DD	||
	STA !1558,X				;$0389DF	|/
	RTS							;$0389E2	|

CODE_0389E3:					;```````````| Not stationary.
	BPL CODE_0389E9				;$0389E3	|\ 
	INC !B6,X					;$0389E5	||
	INC !B6,X					;$0389E7	|| Apply friction.
CODE_0389E9:					;			||
	DEC !B6,X					;$0389E9	|/
	RTS							;$0389EB	|

CODE_0389EC:					;```````````| Not on flat ground; apply X acceleration.
	ASL							;$0389EC	|\ 
	ROL							;$0389ED	||
	AND #$01					;$0389EE	||
	TAY							;$0389F0	||
	LDA !B6,X					;$0389F1	|| Accelerate, if not already at the max X speed.
	CMP.w MaxSliderSpeed,Y			;$0389F3	||
	BEQ Return0389FE			;$0389F6	||
	CLC							;$0389F8	||
	ADC.w SliderAcceleration,Y			;$0389F9	||
	STA !B6,X					;$0389FC	|/
Return0389FE:					;			|
	RTS							;$0389FE	|


CODE_0389FF:					;```````````| Subroutine for the sliding blue Koopa to generate friction smoke.
	LDA !B6,X					;$0389FF	|\ 
	BEQ Return038A20			;$038A01	||
	LDA $13						;$038A03	||
	AND #$03					;$038A05	|| Return if:
	BNE Return038A20			;$038A07	|| - Not moving
	LDA #$04					;$038A09	|| - Not a frame to generate smoke
	STA $00						;$038A0B	|| - Offscreen
	LDA #$0A					;$038A0D	||
	STA $01						;$038A0F	||
	LDA !15A0,X : ORA !186C,X		;$038A11	||
	BNE Return038A20			;$038A14	|/
	LDY #$03					;$038A16	|\ 
CODE_038A18:					;			||
	LDA $17C0|!addr,Y				;$038A18	||
	BEQ CODE_038A21				;$038A1B	|| Find an empty smoke sprite slot and return if none found.
	DEY							;$038A1D	||
	BPL CODE_038A18				;$038A1E	||
Return038A20:					;			||
	RTS							;$038A20	|/
CODE_038A21:					;			|
	LDA #$03					;$038A21	|\\ Smoke sprite to spawn (friction smoke).
	STA $17C0|!addr,Y				;$038A23	|/
	LDA !E4,X					;$038A26	|\ 
	CLC							;$038A28	||
	ADC $00						;$038A29	||
	STA $17C8|!addr,Y				;$038A2B	|| Spawn a the Koopa's position.
	LDA !D8,X					;$038A2E	||
	CLC							;$038A30	||
	ADC $01						;$038A31	||
	STA $17C4|!addr,Y				;$038A33	|/
	LDA #$13					;$038A36	|\ Set initial timer for the smoke.
	STA $17CC|!addr,Y				;$038A38	|/
	RTS							;$038A3B	|


namespace off

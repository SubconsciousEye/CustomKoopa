includefrom "../CustomKoopa.asm"

HandleSprStunned:				;-----------| Routine to handle sprites in the stationary/carryable/stunned state (sprite status 9).
CODE_01956A:					;```````````| Routine for all stunned sprites except springboards and P-balloons.
	LDA $9D						;$01956A	|\ 
	BEQ CODE_019571				;$01956C	|| If sprites are locked, then skip object/sprite/Mario interaction and movement.
	JMP CODE_0195F5				;$01956E	|/

CODE_019571:
	JSR CODE_019624				;$019571	| Handle stun timer related routines.
if !SA1 == !True
	lda !9E,x
	sta $87		; sprite num cache?
endif
	jsl !UpdateSpritePos			;$019574	| Update X/Y position, apply gravity, and process interaction with blocks.
	%IsOnGround()				;$019577	|\ 
	BEQ CODE_019598				;$01957A	|| If the sprite is on the ground, process ground interaction.
	JSR CODE_0197D5				;$01957C	||
CODE_01958C:					;			||
CODE_019598:					;			|
	%IsTouchingCeiling()		;$019598	|\ 
	BEQ CODE_0195DB				;$01959B	|| If the sprite hits a ceiling, send it back downwards.
	LDA #$10					;$01959D	||
	STA !AA,X					;$01959F	||
	%IsTouchingObjSide()		;$0195A1	||\ 
	BNE CODE_0195DB				;$0195A4	|||
	LDA !E4,X					;$0195A6	|||
	CLC							;$0195A8	|||
	ADC #$08					;$0195A9	|||
	STA $9A						;$0195AB	|||
	LDA !14E0,X				;$0195AD	|||
	ADC #$00					;$0195B0	|||
	STA $9B						;$0195B2	|||
	LDA !D8,X					;$0195B4	|||
	AND #$F0					;$0195B6	|||
	STA $98						;$0195B8	|||
	LDA !14D4,X				;$0195BA	||| If the sprite isn't also touching the side of a block, make it interact with the block.
	STA $99						;$0195BD	|||  i.e. this is the code that lets you actually hit a block with a carryable sprite.
	LDA !1588,X				;$0195BF	|||
	AND #$20					;$0195C2	||| Why it matters that the side isn't being touched, who knows.
	ASL							;$0195C4	|||
	ASL							;$0195C5	|||
	ASL							;$0195C6	|||
	ROL							;$0195C7	|||
	AND #$01					;$0195C8	|||
	STA $1933|!addr					;$0195CA	|||
	LDY #$00					;$0195CD	|||
	LDA $1868|!addr					;$0195CF	|||
	JSL !CODE_00F160				;$0195D2	|||
	LDA #$08					;$0195D6	|||
	STA !1FE2,X				;$0195D8	|//
CODE_0195DB:					;			|
	%IsTouchingObjSide()		;$0195DB	|\ 
	BEQ CODE_0195F2				;$0195DE	||
CODE_0195E9:					;			||
	LDA !B6,X					;$0195E9	||\ 
	ASL							;$0195EB	|||
	PHP							;$0195EC	||| Make the sprite bounce backwards from the wall at 1/4th of its speed.
	ROR !B6,X					;$0195ED	|||
	PLP							;$0195EF	|||
	ROR !B6,X					;$0195F0	|//
CODE_0195F2:					;			|
	jsl !SprSprPMarioSprRts		;$0195F2	| Interact with Mario and other sprites.
CODE_0195F5:					;			|
	LDA #$04					;$019806	|\\ Default animation frame.
	STA !1602,X				;$01980F	|/
	lda #$00 : %SubOffScreen()		;$0195F8	| Process offscreen from -$40 to +$30.
	JSR PrepShellGfx				;$0195F5	| Draw graphics, and handle stunned sprite routines.
	RTS							;$0195FB	|


CODE_019624:					;-----------| Subroutine to handle routines relating to the stun timer for stunned sprites.
;CODE_01965C:					;```````````| Not a Bob-omb. This part checks if it's shell with a Koopa inside, that is about to turn into a normal Koopa.
	LDA !1540,X				;$01965C	|\ 
	ORA !1558,X				;$01965F	|| Duplicate the stun timer to $C2. No real reason for this (maybe?), but it happens.
	STA !C2,X					;$019662	|/
	LDA !1558,X				;$019664	|\ 
	bne +				;$019667	||
-	jmp CODE_01969C
+	CMP #$01					;$019669	|| Essentially, branch if this is not a shell
	BNE -				;$01966B	||  or there is not a Koopa currently jumping into it.
	LDY !1594,X				;$01966D	|| Of course, it doesn't explicitely check this, which results in some odd bugs.
	LDA !15D0,Y				;$019670	||
	BNE -				;$019673	|/
	;JSL LoadSpriteTables		;$019675	|
	phy
	%FacePlayer()				;$019679	|
	ply
	ASL !15F6,X				;$01967C	|\ Clear the shell's Y flip.
	LSR !15F6,X				;$01967F	|/
;; Preserve Sprite Number of other sprite
if !option_14C8EraseExtraBits == !True
	lda !extra_prop_2,x
endif
	tyx
if !option_14C8EraseExtraBits == !False
	lda !extra_bits,x
endif
if !option_ExtraBits_h03 == !True
	and #$03
else
	and #$0c
endif
	pha
	lda !new_sprite_num,x : pha
;; Get our original Sprite Number and compare
	ldx !sprite_slot
	lda !extra_bits,x
if !option_ExtraBits_h03 == !True
	and #$03
else
	and #$0c
endif
	xba
	lda !new_sprite_num,x
	rep #$20 : cmp 1,s
	beq .CustomKoopa
	pla : sep #$20
	LDA !160E,X				;$019682	|\ Turn the shell into a Koopa. If a yellow Koopa entered it, turn it into a disco shell.
	CMP #$03					;$019687	||| Koopa sprite ID that makes a disco shell.
	BNE .NotDisco				;$019689	||
	bra .DiscoShell
.CustomKoopa:
	pla : sep #$20
	;LDY !1594,X				;$019682	|\ Turn the shell into a Koopa. If a yellow Koopa entered it, turn it into a disco shell.
;; Check to see if the Beach Koopa
;;  can turn us into Disco Mode.
	lda !1510,y : tay
	lda.w BehaviorProps,y
	and #$10
	bne .DiscoShell
;; Check if we can turn into Disco Mode
;;  regardless of Beach Koopa.
	ldy !1510,x
	lda.w BehaviorProps,y
	and #$10
	bne .DiscoShell
;; No Disco Shell, return to normal state
;;  and reinitialize for parakoopas.
.NotDisco:
	lda #$08 : sta !14C8,x
	lda #$80 : sta !extra_prop_1,x
	jmp InitKoopa_JumpStart
.DiscoShell:
	INC !187B,X				;$01968B	||
	LDA !166E,X				;$01968E	||\ 
	ORA #$30					;$019691	||| Disable cape/fireball killing.
	STA !166E,X				;$019693	||/
	LDA #$0A					;$019696	||
if !SA1
	sta $87		; sprite num cache?
endif
	sta !9E,x
CODE_019698:					;			||
	STA !14C8,X				;$019698	|/
Return01969B:					;			|
	RTS							;$01969B	|

CODE_01969C:					;```````````| Not a shell turning into a Koopa. Check other stunned sprite routines.
	LDA !1540,X				;$01969C	|\ If the sprite's stun timer isn't set, return.
	BEQ Return01969B			;$01969F	|/  (i.e. it's not a stunned Goomba, Koopa, MechaKoopa, etc.)
	CMP #$03					;$0196A1	|\ 
	BEQ UnstunSprite			;$0196A3	|| If the stun timer is not #$03 or #$01, handle the stun timer as usual.
	CMP #$01					;$0196A5	||
	BNE IncrmntStunTimer		;$0196A7	|/
UnstunSprite:					;```````````| Routine to unstun a sprite.
	LDA !9E,X					;$0196A9	|
	CMP #$11					;$0196AB	|\ Sprite 11 (Buzzy Beetle): Return to normal status.
	BNE GeneralResetSpr			;$0196C5	||  Yellow koopas also spawn a coin.
SetNormalStatus:				;-----------| Subroutine to return a sprite to normal status.
	ldy !1510,x
	lda.w BehaviorProps,y
	and #$10
	bne CODE_019624_DiscoShell
	LDA #$08					;$0196CB	|
	STA !14C8,X				;$0196CD	|
	ASL !15F6,X				;$0196D0	|\ Reset Y flip.
	LSR !15F6,X				;$0196D3	|/
;; Reinitialize for parakoopas.
	lda #$80 : sta !extra_prop_1,x
	jmp InitKoopa_JumpStart

IncrmntStunTimer:				;-----------| Subroutine to counter the stun timer every other frame.
	LDA $13						;$0196D7	|\ 
	AND #$01					;$0196D9	|| Increment the stun timer every other frame.
	BNE Return0196E0			;$0196DB	|| Since the stun timer decrements EVERY frame, what this is actually doing is decrementing every two frames.
	INC !1540,X				;$0196DD	|/
Return0196E0:					;			|
	RTS							;$0196E0	|

GeneralResetSpr:				;-----------| Subroutine to spawn a sprite from a shell when unstunning (includes being knocked out from bouncing on).
	JSL !FindFreeSprSlot			;$0196E1	|\ Return if no empty slots.
	BMI Return0196E0			;$0196E5	|/
	LDA #$08					;$0196E7	|
	STA !14C8,Y				;$0196E9	|
	TYX							;$0196F5	|
	;JSL InitSpriteTables		;$0196F6	|
	lda #$00
	sta !extra_byte_1,x
	sta !extra_byte_2,x
	jsl !ZeroSpriteTables
	ldx !sprite_slot
;; Set Behavior Pointer and Gfx Pointer
	lda !1510,x
	and #$1f : ora #$80
	sta !1510,y
	and #$1f : ora #$40
	sta !1504,y
;; Set Extra Bits and Sprite Number
	lda !extra_bits,x
	tyx
	sta !extra_bits,x
	ldx !sprite_slot
	lda !new_sprite_num,x
	tyx
	sta !new_sprite_num,x
	jsl !SetSpriteTables
;; Fix Acts Like and Props
	jsr BeachKoopa_Init_ActsLike
	txy
	LDX !sprite_slot					;$0196FA	|
;; Fix Palette
	lda !1504,y : lsr : and #$0e
	ora !15F6,y : sta !15F6,y
;; Usual stuff
	LDA !E4,X					;$0196FD	|\ 
	STA !E4,Y				;$0196FF	||
	LDA !14E0,X				;$019702	||
	STA !14E0,Y				;$019705	|| Make sure it spawns at the same position as the shell.
	LDA !D8,X					;$019708	||
	STA !D8,Y				;$01970A	||
	LDA !14D4,X				;$01970D	||
	STA !14D4,Y				;$019710	|/
	LDA #$00					;$019713	|\ Face the koopa right.
	STA !157C,Y				;$019715	|/
	LDA #$10					;$019718	|\ Briefly disable sprite contact for the Koopa.
	STA !1564,Y				;$01971A	|/
	LDA !164A,X				;$01971D	|\ 
	STA !164A,Y				;$019720	|| Share RAM for being in water + being stunned.
	LDA !1540,X				;$019723	||
	STZ !1540,X				;$019726	|/
	CMP #$01					;$019729	|\ Branch if the koopa is being spawned from being knocked out of the shell, not shaking itself out.
	BEQ CODE_019747				;$01972B	|/
	LDA #$D0					;$01972D	|\\ Y speed for a shell-less Koopa when it jumps out of a shell.
	STA !AA,Y				;$01972F	|/
	PHY							;$019732	|
	%SubHorzPosBnk1()			;$019733	|\ 
	TYA							;$019736	||
	EOR #$01					;$019737	||
	PLY							;$019739	||
	STA !157C,Y				;$01973A	|| Face away from Mario.
	PHX							;$01973D	||
	TAX							;$01973E	||
	LDA.w Spr0to13SpeedX,X		;$01973F	||
	STA !B6,Y				;$019742	|/
	PLX							;$019745	|
	RTS							;$019746	|

CODE_019747:					;```````````| Spawning a koopa from a shell and about to unstun.
	PHY							;$019747	|
	%SubHorzPosBnk1()			;$019748	|\ 
	LDA.w DATA_0197AD,Y			;$01974B	||
	STY $00						;$01974E	||
	PLY							;$019750	|| Give Koopa an X speed away from Mario.
	STA !B6,Y				;$019751	||
	LDA $00						;$019754	||
	EOR #$01					;$019756	||
	STA !157C,Y				;$019758	||
	STA $01						;$01975B	|/
	LDA #$10					;$01975D	|\ 
	STA !154C,Y				;$01975F	|| Disable player contact and set sliding flag for the Koopa.
	STA !1528,Y				;$019762	|/
;; Check if we can spawn a Moving Coin
	ldy !1510,x
	lda.w BehaviorProps,y
	and #$20
	beq Return019775
	LDY #!SprSize-1					;$01976B	|\ 
CODE_01976D:					;			||
	LDA !14C8,Y				;$01976D	|| Spawn a coin too.
	BEQ SpawnMovingCoin			;$019770	||
	DEY							;$019772	||
	BPL CODE_01976D				;$019773	|/
Return019775:					;			|
	RTS							;$019775	|


SpawnMovingCoin:				;-----------| Routine to spawn a moving coin when a yellow koopa is hit.
	LDA #$08					;$019776	|
	STA !14C8,Y				;$019778	|
	LDA #$21					;$01977B	|
	STA !9E,Y				;$01977D	|
	LDA !E4,X					;$019780	|
	STA !E4,Y				;$019782	|
	LDA !14E0,X				;$019785	|
	STA !14E0,Y				;$019788	|
	LDA !D8,X					;$01978B	|
	STA !D8,Y				;$01978D	|
	LDA !14D4,X				;$019790	|
	STA !14D4,Y				;$019793	|
	PHX							;$019796	|
	TYX							;$019797	|
	JSL !InitSpriteTables		;$019798	|
	PLX							;$01979C	|
	LDA #$D0					;$01979D	|
	STA !AA,Y				;$01979F	|
	LDA $01						;$0197A2	|
	STA !157C,Y				;$0197A4	|
	LDA #$20					;$0197A7	|
	STA !154C,Y				;$0197A9	|
	RTS							;$0197AC	|

DATA_0197AD:					;$0197AD	| X speeds to give Koopas spawned when knocked out of a shell.
	db -$40, $40





DATA_0197AF:					;$0197AF	| Bounce speeds for carryable sprites when hitting the ground. Indexed by Y speed divided by 4.
	;db  $00, $00, $00, $F8, $F8, $F8, $F8, $F8
	;db  $F8, $F7, $F6, $F5, $F4, $F3, $F2, $E8
	;db  $E8, $E8, $E8
	db  $00, $00, $00,-$08,-$08,-$08,-$08,-$08
	db -$08,-$09,-$0a,-$0b,-$0c,-$0d,-$0e,-$18
	db -$18,-$18,-$18

CODE_0197D5:					;-----------| Subroutine to make carryable sprites bounce when they hit the ground.
	LDA !B6,X					;$0197D5	|\ 
	PHP							;$0197D7	||
	BPL CODE_0197DD				;$0197D8	||
	eor #$ff : inc
CODE_0197DD:					;			||
	LSR							;$0197DD	|| Halve the sprite's X speed.
	PLP							;$0197DE	||
	BPL CODE_0197E4				;$0197DF	||
	eor #$ff : inc
CODE_0197E4:					;			||
	STA !B6,X					;$0197E4	|/
	LDA !AA,X					;$0197E6	|\ 
	PHA							;$0197E8	|| Set a normal ground Y speed.
	JSR SetSomeYSpeed			;$0197E9	|/
	PLA							;$0197EC	|
	LSR							;$0197ED	|
	LSR							;$0197EE	|
	TAY							;$0197EF	|
CODE_0197FB:					;			|
	LDA.w DATA_0197AF,Y			;$0197FB	|\ 
	LDY !1588,X				;$0197FE	|| Get the Y speed to make the sprite bounce at when it hits the ground.
	BMI Return019805			;$019801	||
	STA !AA,X					;$019803	|/
Return019805:					;			|
	RTS							;$019805	|


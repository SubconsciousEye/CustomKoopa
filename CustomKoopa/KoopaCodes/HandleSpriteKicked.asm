includefrom "../CustomKoopa.asm"

;; $14C8 = #$0A

;;CODE_00F160 = $00F160|!bank

HandleSprKicked:				;-----------| Routine to handle a sprite being kicked (sprite status A). Serves as a MAIN for many carryable sprites.
	LDA !187B,X				;$019913	|\ 
	BEQ IsRegularShell				;$019916	|| Jump to the code above if it's a shell set to become a disco shell.
	JMP IsDiscoShell				;$019918	|/

IsRegularShell:
CODE_019928:					;```````````| Kicked shell MAIN (see other main for misc ram; this routine also includes Buzzy Beetle shells and throwblocks)
	LDA !1528,X				;$019928	|\ 
	BNE CODE_019939				;$01992B	||
	LDA !B6,X					;$01992D	||
	CLC							;$01992F	|| If not being caught by a Koopa, return the shell to carryable state if it somehow slows down enough.
	ADC #$20					;$019930	||  (how to do this, though, is a mystery)
	CMP #$40					;$019932	||
	BCS CODE_019939				;$019934	||
	JSR CODE_01AA0B				;$019936	|/
CODE_019939:					;			|
	STZ !1528,X				;$019939	|
	LDA $9D						;$01993C	|\ 
	ORA !163E,X				;$01993E	|| If sprites are frozen or (?) is happening, just draw graphics.
	BEQ CODE_019946				;$019941	||
	JMP CODE_01998F				;$019943	|/

CODE_019946:
	JSR UpdateDirection			;$019946	|
	LDA !15B8,X				;$019949	|
	PHA							;$01994C	|
	jsl !UpdateSpritePos			;$01994D	| Update X/Y position, apply gravity, and process interaction with blocks.
	PLA							;$019950	|
	BEQ CODE_019969				;$019951	|\ 
	STA $00						;$019953	||
	LDY !164A,X				;$019955	||
	BNE CODE_019969				;$019958	||
	CMP !15B8,X				;$01995A	|| If the sprite has just gone onto a slope, is not in water, and is moving faster than the slopes's angle,
	BEQ CODE_019969				;$01995D	||  then make it "bounce" slightly off the slope.
	EOR !B6,X					;$01995F	||
	BMI CODE_019969				;$019961	||
	LDA #$F8					;$019963	||
	STA !AA,X					;$019965	||
	BRA CODE_019975				;$019967	|/

CODE_019969:
	%IsOnGround()				;$019969	|\ 
	BEQ CODE_019984				;$01996C	|| If on the ground, set its Y speed to 10. (useless JSR)
	;JSR SetSomeYSpeed			;$01996E	||
	LDA #$10					;$019971	|| [Change to #$0C to make it never fall in one-tile gaps, and #$28 to make it always (#$19 if not sprinting)]
	STA !AA,X					;$019973	|/
CODE_019975:					;			|
	LDA $1860|!addr					;$019975	|\ 
	CMP #$B5					;$019978	||
	BEQ CODE_019980				;$01997A	||
	CMP #$B4					;$01997C	|| If the shell hits a purple triangle, send it flying in the air.
	BNE CODE_019984				;$01997E	||
CODE_019980:					;			||
	LDA #$B8					;$019980	||| Y speed to give the shell.
	STA !AA,X					;$019982	|/
CODE_019984:					;			|
	%IsTouchingObjSide()		;$019984	|\ 
	BEQ CODE_01998C				;$019987	|| If it hits the side of a block, handle interaction with it.
	JSR CODE_01999E				;$019989	|/
CODE_01998C:					;			|
	jsl !SprSprPMarioSprRts		;$01998C	| Process interaction with Mario and other sprites.
CODE_01998F:					;			|
	lda #$00 : %SubOffScreen()		;$01998F	| Process offscreen from -$40 to +$30.
	JMP SpinningShellFrame				;$019998	||  Else, draw shell graphics.


DiscoRebound:					;$0198A7	| X speeds to give the disco shell when it bumps into a wall.
	db -$20, $20

IsDiscoShell:					;-----------| Disco shell MAIN (see the actual shell's MAIN for misc ram)
	LDA $9D						;$0198A9	|\ 
	BEQ CODE_0198B0				;$0198AB	|| If the game is frozen, just draw graphics.
	JMP SpinningShellFrame				;$0198AD	|/

CODE_0198B0:
	jsl !UpdateSpritePos			;$0198B0	| Update X/Y position, apply gravity, and process interaction with blocks.
	LDA !151C,X				;$0198B3	|\ 
	AND #$1F					;$0198B6	|| Follow Mario, except when $151C is non-zero. Likely a beta remnant?
	BNE CODE_0198BD				;$0198B8	||
	%FacePlayer()				;$0198BA	|/
CODE_0198BD:					;			|
	LDA !B6,X					;$0198BD	|\ 
	LDY !157C,X				;$0198BF	|| If not at max speed, accelerate the disco Shell accordingly.
	CPY #$00					;$0198C2	||
	BNE CODE_0198D0				;$0198C4	||
	CMP #$20					;$0198C6	||| Maximum speed rightward for the disco shell.
	BPL CODE_0198D8				;$0198C8	||
	INC !B6,X					;$0198CA	||
	INC !B6,X					;$0198CC	||
	BRA CODE_0198D8				;$0198CE	||
CODE_0198D0:					;			||
	CMP.b #$E0					;$0198D0	||| Maximum speed leftward for the disco shell.
	BMI CODE_0198D8				;$0198D2	||
	DEC !B6,X					;$0198D4	||
	DEC !B6,X					;$0198D6	|/
CODE_0198D8:					;			|
	%IsTouchingObjSide()		;$0198D8	|\ 
	BEQ CODE_0198EA				;$0198DB	||
	PHA							;$0198DD	||
	JSR CODE_01999E				;$0198DE	||
	PLA							;$0198E1	|| If it hits the side of a block, interact with the block and bump it up to maximum X speed.
	AND #$03					;$0198E2	||
	TAY							;$0198E4	||
	LDA.w DiscoRebound-1,Y		;$0198E5	||
	STA !B6,X					;$0198E8	|/
CODE_0198EA:					;			|
	%IsOnGround()				;$0198EA	|\ 
	BEQ CODE_0198F6				;$0198ED	||
	;JSR SetSomeYSpeed			;$0198EF	|| If on the ground, set its Y speed to 10. (useless JSR)
	LDA #$10					;$0198F2	||
	STA !AA,X					;$0198F4	|/
CODE_0198F6:					;			|
	%IsTouchingCeiling()		;$0198F6	|\ 
	BEQ CODE_0198FD				;$0198F9	|| If it hits a ceiling, clear its Y speed.
	STZ !AA,X					;$0198FB	|/
CODE_0198FD:					;			|
	LDA $13						;$0198FD	|\ 
	AND.b #$01					;$0198FF	||
	BNE CODE_01990D				;$019901	||
	LDA !15F6,X				;$019903	|| Cycle through the palettes every other frame.
	INC A						;$019906	||
	INC A						;$019907	||
	AND #$4F					;$019908	||
	STA !15F6,X				;$01990A	|/
CODE_01990D:					;			|
	JMP CODE_01998C				;$01990D	|


CODE_01999E:					;-----------| Subroutine for thrown sprites interacting with the sides of blocks.
	LDA #$01					;$01999E	|\ SFX for hitting a block with any sprite.
	STA $1DF9|!addr					;$0199A0	|/
	JSR CODE_0190A2				;$0199A3	| Invert the sprite's X speed.
	LDA !15A0,X				;$0199A6	|\ 
	BNE CODE_0199D2				;$0199A9	||
	LDA !E4,X					;$0199AB	||
	SEC							;$0199AD	||
	SBC $1A						;$0199AE	||
	CLC							;$0199B0	||
	ADC #$14					;$0199B1	||
	CMP #$1C					;$0199B3	||
	BCC CODE_0199D2				;$0199B5	||
	LDA !1588,X				;$0199B7	|| If it's far enough on-screen, make it actually interact with the block.
	AND #$40					;$0199BA	||  i.e. this is the code that lets you actually hit a block with a thrown sprite.
	ASL							;$0199BC	||
	ASL							;$0199BD	||
	ROL							;$0199BE	||
	AND #$01					;$0199BF	||
	STA $1933|!addr					;$0199C1	||
	LDY #$00					;$0199C4	||
	LDA $18A7|!addr					;$0199C6	||
	JSL !CODE_00F160				;$0199C9	||
	LDA #$05					;$0199CD	||
	STA !1FE2,X				;$0199CF	|/
CODE_0199D2:					;			|
	RTS							;$0199DB	|


SpinningShellFrame:					;-----------| Subroutine to draw a spinning shell's graphics.
	LDA !C2,X					;$019A2A	|
	STA !1558,X				;$019A2C	|
	LDA $14						;$019A2F	|\ 
	LSR							;$019A31	||
	LSR							;$019A32	||
	AND #$03					;$019A33	||
	clc : adc #$04		; Starting Shell Frame
	sta !1602,x
	jsr PrepShellGfx
	STZ !1558,X
	RTS							;$019A4D	|


CODE_01AA0B:					;			||  If $C2 is non-zero or the sprite is coming from status 08, then also set the stun timer.
	LDA !C2,X					;$01AA0B	||
	BNE SetStunnedTimer			;$01AA0D	||
	STZ !1540,X				;$01AA0F	||
	BRA SetAsStunned			;$01AA12	|/

SetStunnedTimer:
	LDy.b #$02					;$01AA14	|\ 
;; SMB3 Koopa Check
	lda !1510,x
	and #$02 : beq CODE_01AA2A
CODE_01AA28:					;			|
	LDy #$FF					;$01AA28	| How long to stun the four above sprites for when kicked/hit.
CODE_01AA2A:					;			|
	tya
	STA !1540,X				;$01AA2A	|
SetAsStunned:					;			|
	LDA #$09					;$01AA2D	|\ Change to stationary/carryable status.
	STA !14C8,X				;$01AA2F	|/
	RTS							;$01AA32	|
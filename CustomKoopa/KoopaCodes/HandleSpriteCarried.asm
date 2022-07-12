;; $14C8 = #$0B

;;CODE_00F160 = $00F160|!bank
;;CODE_019806 = See Kicked State
;;CODE_019138 = JSL Block Interaction
;; CODE_019140 is the JSR version


DATA_019F5B:					;$019F5B	| X low position offsets for sprites from Mario when carrying them.
	db  $0B,-$0B, $04,-$04, $04, $00				; Right, left, turning (< 1), turning (< 2, > 1), turning (> 2), centered.

DATA_019F61:					;$019F61	| X high position offsets for sprites from Mario when carrying them.
	db  $00,-$01, $00,-$01, $00, $00

DATA_019F67:					;$019F67	| X low byte offsets from Mario to drop sprites at.
	db -$0D, $0D
DATA_019F69:					;$019F69	| X high byte offsets from Mario to drop sprites at.
	db -$01, $00

KickSpeedX:						;$019F6B	| Base X speeds for carryable sprites when kicked/thrown.
	db -$2E, $2E,-$34, $34						; Third and fourth bytes are when spit out by Yoshi.


HandleSprCarried:				;-----------| Routine to handle carried sprites (sprite status B).
	JSR CODE_019F9B				;$019F71	| Run specific sprite routines.
	LDA $13DD|!addr					;$019F74	|\ 
	BNE CODE_019F83				;$019F77	||
	LDA $1419|!addr					;$019F79	||
	BNE CODE_019F83				;$019F7C	|| If turning while sliding, going down a pipe, or otherwise facing the screen,
	LDA $1499|!addr					;$019F7E	||  center the item on Mario, and change OAM index to #00.
	BEQ CODE_019F86				;$019F81	||  (to make it go in front of Mario).
CODE_019F83:					;			||
	STZ !15EA,X				;$019F83	|/
CODE_019F86:					;			|
	LDA $64						;$019F86	|\ 
	PHA							;$019F88	||
	LDA $1419|!addr					;$019F89	|| If going down a pipe, send behind objects.
	BEQ CODE_019F92				;$019F8C	||
	LDA #$10					;$019F8E	||
	STA $64						;$019F90	|/
CODE_019F92:					;			|
	LDA #$04					;$019806	|\\ Default animation frame.
	LDY !15EA,X				;$019808	||
	BNE +				;$01980B	||
	LDA #$06					;$01980D	||| Animation frame when turning while Mario is holding it.
+	STA !1602,X				;$01980F	|/
	JSR PrepShellGfx				;$019F92	| Draw graphics and handle basic routines.
	PLA							;$019F95	|
	STA $64						;$019F96	|
	RTS							;$019F98	|



DATA_019F99:					;$019F99	| Base X speeds for carryable sprites when dropped.
	db -$04, $04

CODE_019F9B:					;```````````| Running carryable-sprite-specific routines; first up is P-balloon.
CODE_019FE0:					;```````````| Carrying sprite other than P-balloon (i.e. actually carrying something).
	jsl !CODE_019138				;$019FE0	| Handle interaction with blocks.
	LDA $71						;$019FE3	|\ 
	CMP #$01					;$019FE5	||
	BCC CODE_019FF4				;$019FE7	||
	LDA $1419|!addr					;$019FE9	|| If Mario let go of it (not thrown), return to stationary status.
	BNE CODE_019FF4				;$019FEC	||
	LDA #$09					;$019FEE	||
	STA !14C8,X				;$019FF0	||
	RTS							;$019FF3	|/

CODE_019FF4:
	LDA !14C8,X				;$019FF4	|\ 
	CMP #$08					;$019FF7	|| If the sprite returned to normal status (e.g. Goombas un-stunning), return.
	BEQ Return01A014			;$019FF9	|/
	LDA $9D						;$019FFB	|\ 
	BEQ CODE_01A002				;$019FFD	|| If the game is frozen, just handle offset from Mario.
	JMP CODE_01A0B1				;$019FFF	|/

CODE_01A002:
	JSR CODE_019624				;$01A002	| Handle stun timer routines.
	jsl !SprSprInteract		;$01A005	| Handle interaction with other sprites.
	LDA $1419|!addr					;$01A008	|\ 
	BNE CODE_01A011				;$01A00B	||
	BIT $15						;$01A00D	|| If X/Y are held or Mario is going down a pipe, offset the sprite from his position.
	BVC CODE_01A015				;$01A00F	||  Else, branch to let go of the sprite.
CODE_01A011:					;			||
	JSR CODE_01A0B1				;$01A011	|/
Return01A014:					;			|
	RTS							;$01A014	|



CODE_01A015:					;```````````| Subroutine to handle letting go of a sprite.
	STZ !1626,X				;$01A015	|
	LDY #$00					;$01A018	|\\ Base Y speed to give sprites when kicking them.
CODE_01A026:					;			||
	STY !AA,X					;$01A026	|/
	LDA #$09					;$01A028	|\ Return to carryable status. 
	STA !14C8,X				;$01A02A	|/
	LDA $15						;$01A02D	|\ 
	AND #$08					;$01A02F	|| Branch if holding up.
	BNE CODE_01A068				;$01A031	|/
	LDA $15						;$01A039	||
	AND #$04					;$01A03B	|| If not a Goomba or shell, don't kick by default.
	BEQ CODE_01A079				;$01A03D	|| If holding down, never kick.
	;BRA CODE_01A047				;$01A03F	|| If holding left/right and not down, always kick.


CODE_01A047:					;```````````| Gently dropping a sprite (holding down, or release a non-shell/goomba sprite).
	LDY $76						;$01A047	|\ 
	LDA $D1						;$01A049	||
	CLC							;$01A04B	||
	ADC.w DATA_019F67,Y			;$01A04C	|| Fix offset from Mario (in case of turning).
	STA !E4,X					;$01A04F	||
	LDA $D2						;$01A051	||
	ADC.w DATA_019F69,Y			;$01A053	||
	STA !14E0,X				;$01A056	|/
	%SubHorzPosBnk1()			;$01A059	|\ 
	LDA.w DATA_019F99,Y			;$01A05C	||
	CLC							;$01A05F	|| Set X speed.
	ADC $7B						;$01A060	||
	STA !B6,X					;$01A062	|/
	STZ !AA,X					;$01A064	|
	BRA CODE_01A0A6				;$01A066	|


CODE_01A068:					;```````````| Kicking a sprite upwards (holding up).
	JSL !DispContactSpr			;$01A068	|
	LDA #$90					;$01A06C	|\\ Y speed to give sprites kicked upwards.
	STA !AA,X					;$01A06E	|/
	LDA $7B						;$01A070	|\ 
	STA !B6,X					;$01A072	|| Give the sprite half Mario's speed.
	ASL							;$01A074	||
	ROR !B6,X					;$01A075	|/
	BRA CODE_01A0A6				;$01A077	|


CODE_01A079:					;```````````| Kicking a sprite sideways (holding left/right, or releasing a shell/Goomba).
	JSL !DispContactSpr			;$01A079	|
	LDA !1540,X				;$01A07D	|
	STA !C2,X					;$01A080	|
	LDA #$0A					;$01A082	|\ Set thrown status. 
	STA !14C8,X				;$01A084	|/
	LDY $76						;$01A087	|\ 
	LDA $187A|!addr					;$01A089	||
	BEQ CODE_01A090				;$01A08C	||
	INY							;$01A08E	||
	INY							;$01A08F	||
CODE_01A090:					;			||
	LDA.w KickSpeedX,Y			;$01A090	||
	STA !B6,X					;$01A093	|| Set X speed to throw the sprite at; take base speed, and add half Mario's speed if moving in the same direction as him.
	EOR $7B						;$01A095	||  For whatever reason, if Mario is throwing the item while on Yoshi, the base speed will be faster.
	BMI CODE_01A0A6				;$01A097	||  (not that you can do that without a glitch...)
	LDA $7B						;$01A099	||
	STA $00						;$01A09B	||
	ASL $00						;$01A09D	||
	ROR							;$01A09F	||
	CLC							;$01A0A0	||
	ADC.w KickSpeedX,Y			;$01A0A1	||
	STA !B6,X					;$01A0A4	|/
CODE_01A0A6:					;			|
	LDA #$10					;$01A0A6	|\\ Number of frames to disable contact with Mario for when kicking any carryable sprite.
	STA !154C,X				;$01A0A8	|/
	LDA #$0C					;$01A0AB	|\ Show Mario's kicking pose.
	STA $149A|!addr					;$01A0AD	|/
	RTS							;$01A0B0	|


	; Scratch RAM usage and output:
	; $00 - Mario X position, low
	; $01 - Mario X position, high
	; $02 - Mario Y position, low
	; $03 - Mario Y position, high

CODE_01A0B1:					;-----------| Subroutine to offset a carryable sprite from Mario's position.
	LDY #$00					;$01A0B1	|\ 
	LDA $76						;$01A0B3	|| Get 0 = right, 1 = left.
	BNE CODE_01A0B8				;$01A0B5	||
	INY							;$01A0B7	|/
CODE_01A0B8:					;			|
	LDA $1499|!addr					;$01A0B8	|\ 
	BEQ CODE_01A0C4				;$01A0BB	||
	INY							;$01A0BD	||
	INY							;$01A0BE	|| Set Y = 2/3 or 3/4 when turning.
	CMP #$05					;$01A0BF	||
	BCC CODE_01A0C4				;$01A0C1	||
	INY							;$01A0C3	|/
CODE_01A0C4:					;			|
	LDA $1419|!addr					;$01A0C4	|\ 
	BEQ CODE_01A0CD				;$01A0C7	||
	CMP #$02					;$01A0C9	||
	BEQ CODE_01A0D4				;$01A0CB	||
CODE_01A0CD:					;			|| If turning while sliding, going down a vertical pipe, or climbing, set Y = 5.
	LDA $13DD|!addr					;$01A0CD	||
	ORA $74						;$01A0D0	||
	BEQ CODE_01A0D6				;$01A0D2	||
CODE_01A0D4:					;			||
	LDY #$05					;$01A0D4	|/
CODE_01A0D6:					;			|
	PHY							;$01A0D6	|
	LDY #$00					;$01A0D7	|\ 
	LDA $1471|!addr					;$01A0D9	||
	CMP #$03					;$01A0DC	||
	BEQ CODE_01A0E2				;$01A0DE	||
	LDY #$3D					;$01A0E0	||
CODE_01A0E2:					;			||
	LDA $94,Y					;$01A0E2	|| Decide whether to use Mario's position on the next frame, 
	STA $00						;$01A0E5	||  or if on a revolving brown platform, current frame.
	LDA $95,Y					;$01A0E7	||
	STA $01						;$01A0EA	||
	LDA $96,Y					;$01A0EC	||
	STA $02						;$01A0EF	||
	LDA $97,Y					;$01A0F1	||
	STA $03						;$01A0F4	|/
	PLY							;$01A0F6	|
	LDA $00						;$01A0F7	|\ 
	CLC							;$01A0F9	||
	ADC.w DATA_019F5B,Y			;$01A0FA	||
	STA $E4,X					;$01A0FD	|| Offset horizontally from Mario.
	LDA $01						;$01A0FF	||
	ADC.w DATA_019F61,Y			;$01A101	||
	STA !14E0,X				;$01A104	|/
	LDA #$0D					;$01A107	|\\ Y offset when big.
	LDY $73						;$01A109	||
	BNE CODE_01A111				;$01A10B	||
	LDY $19						;$01A10D	|| Offset vertically from Mario.
	BNE CODE_01A113				;$01A10F	||
CODE_01A111:					;			||
	LDA #$0F					;$01A111	||| Y offset when ducking or small.
CODE_01A113:					;			||
	LDY $1498|!addr					;$01A113	||
	BEQ CODE_01A11A				;$01A116	||
	LDA #$0F					;$01A118	||| Y offset when picking up an item.
CODE_01A11A:					;			||
	CLC							;$01A11A	||
	ADC $02						;$01A11B	||
	STA !D8,X					;$01A11D	||
	LDA $03						;$01A11F	||
	ADC #$00					;$01A121	||
	STA !14D4,X				;$01A123	|/
	LDA #$01					;$01A126	|\ 
	STA $148F|!addr					;$01A128	|| Set the flag for carrying an item.
	STA $1470|!addr					;$01A12B	|/
	RTS							;$01A12E	|



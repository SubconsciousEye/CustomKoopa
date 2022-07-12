
incsrc "KoopaGfx/GfxPtrs_Default.asm"


GfxTable:
; db table:
;  width, height
;  size, tile, prop, xofs, yofs
;  terminate
.invalid
	dw ..0, ..0, ..0, ..0
	dw ..0, ..0, ..0, ..0
	dw ..0, ..0
..0
	db  $ff, $ff
	db  $ff

.SmwRegular
;; 0: stand/walk
;; 1: other walk
;; 2: turning
;; 3: unused
;; 4: shell front
;; 5: shell left
;; 6: shell "back"
;; 7: shell right
;; 8: falling death
;; 9: squished death

	dw ..walk0,		..walk1,	..turn,		.invalid_0
	dw ..shell0,	..shell1,	..shell2,	..shell3
	dw ..death,		..squish

..walk0
	db  $10, $18
	db  $02, $82, $00, $00,-$10
	db  $02, $a0, $00, $00, $00
	db  $ff
..walk1
	db  $10, $18
	db  $02, $82, $00, $00,-$0f
	db  $02, $a2, $00, $00, $01
	db  $ff
..turn
	db  $10, $18
	db  $02, $84, $00, $00,-$10
	db  $02, $a4, $00, $00, $00
	db  $ff
..shell0
	db  $10, $10
	db  $02, $8c, $00, $00, $00
	db  $ff
..shell1
	db  $10, $10
	db  $02, $8a, $00, $00, $00
	db  $ff
..shell2
	db  $10, $10
	db  $02, $8e, $00, $00, $00
	db  $ff
..shell3
	db  $10, $10
	db  $02, $8a, $40, $00, $00
	db  $ff
..death
	db  $10, $10
	db  $02, $8c, $80, $00, $00
	db  $ff
..squish
	db  $10, $10
	db  $02, $82, $80, $00, $04
	db  $ff

.SmwBeach
;; 0: stand/walk
;; 1: other walk
;; 2: turning
;; 3: kicking
;; 4: knocked out 1
;; 5: knocked out 2
;; 6: sliding koopa
;; 7: unused
;; 8: falling death
;; 9: squished death
	dw ..walk0,		..walk1,	..walk1,	..kick
	dw ..knocked0,	..knocked1,	..knocked0,	.invalid_0
	dw ..death,		..squish

..walk0
	db  $10, $10
	db  $02, $c8, $00, $00, $00
	db  $ff
..walk1
	db  $10, $10
	db  $02, $ca, $00, $00, $00
	db  $ff
..kick
	db  $10, $10
	db  $02, $cc, $00, $00, $00
	db  $ff
..knocked0
	db  $10, $10
	db  $02, $86, $00, $00, $00
	db  $ff
..knocked1
	db  $10, $10
	db  $02, $4e, $00, $00, $00
	db  $ff
..death
	db  $10, $10
	db  $02, $c8, $80, $00, $00
	db  $ff
..squish
	db  $10, $08
	db  $00, $ee, $00, $00, $08
	db  $00, $ee, $40, $08, $08
	db  $ff

.SmwBuffy
;; 0: stand/walk
;; 1: other walk
;; 2: turning
;; 3: kicking
;; 4: knocked out 1
;; 5: knocked out 2
;; 6: sliding koopa
;; 7: unused
;; 8: falling death
;; 9: squished death
	dw ..walk0,		..walk1,	..walk1,	..kick
	dw ..knocked0,	..knocked0,	..sliding,	.invalid_0
	dw ..death,		..squish
	
..walk0
	db  $10, $10
	db  $02, $e0, $00, $00, $00
	db  $ff
..walk1
	db  $10, $10
	db  $02, $e2, $00, $00, $00
	db  $ff
..kick
	db  $10, $10
	db  $02, $e4, $00, $00, $00
	db  $ff
..knocked0
	db  $10, $10
	db  $02, $e6, $00, $00, $00
	db  $ff
..sliding
	db  $10, $10
	db  $02, $86, $00, $00, $00
	db  $ff
..death
	db  $10, $10
	db  $02, $e0, $80, $00, $00
	db  $ff
..squish
	db  $10, $08
	db  $00, $ee, $00, $00, $08
	db  $00, $ee, $40, $08, $08
	db  $ff

.SmwEyes
	dw ..shell0no,	.invalid_0,	.invalid_0,	.invalid_0
	dw ..shell0ye,	.invalid_0,	.invalid_0,	.invalid_0

..shell0no
	db  $00, $4d, $00, $02, $08
	db  $00, $4d, $40, $06, $08
	db  $ff
..shell0ye
	db  $00, $64, $00, $02, $08
	db  $00, $64, $40, $06, $08
	db  $ff

.SmwWings
	dw ..closed,	..opened

..closed
	db  $00, $5d, $06, $09,-$04
	db  $ff
..opened
	db  $02, $c6, $06, $09,-$0c
	db  $ff


incsrc "KoopaGfx/MaskKoopa_Default.asm"
incsrc "KoopaGfx/Smb3Koopa_Default.asm"
incsrc "KoopaGfx/Smb1Koopa_Default.asm"


;;;; Normal Koopa Graphics Preparation


PrepKoopaGfx:
;; Set up index for Koopa's Wings.
;;  also "close up" wings if
;;  we're on the ground.
	stz !_8a
	%IsOnGround()
	BNE +
	lda !1602,x
	and #$01 : sta !_8a
+	lda !1504,x : asl
	pha				; All Koopas
	and #$3e : tay	; --PPPKG-
;; Prepare various pointers to our
;;  frames/poses of the Koopa.
	rep #$20
	lda.w #FrontWings : sta !_00
	lda.w #KoopaGfx : sta !_02
	lda.w #BackWings : sta !_04
	lda (!_00),y : sta !_00		; Indirect fWings Pointer
	lda (!_04),y : sta !_04		; Indirect bWings Pointer
	ply
	lda (!_02),y : sta !_02		; Indirect Koopa Pointer
;; Get actual Front Wings Frame to store
;;  we decrease it by one since
;;  our graphics loop use $0001-$0005
;;  during the draw frame rather than
;;  $0000-$0004
	lda !_8a : asl : tay
	lda (!_00),y : dec : sta !_8a
;; Get actual Back Wings Frame to store.
	lda (!_04),y : dec : sta !_8e
;; Get actual Koopa Frame to store.
	lda !1602,x : asl : tay
	lda (!_02),y
	sta !_0a		; Sprite "Width" for x-flip
	inc
	sta !_06		; Sprite "Height" for y-flip
	sta !_8c		; Actual Frame to Draw (Ptr)
	sep #$20
	jsr HandleKoopaGfx
	rts


;;;; Koopa Shell Graphics Preparation


PrepShellGfx:
;; Set up index for Eyes over Shell.
;;  SMW did lda $14 : and #$f8
;;  to determine if the eyes
;;  should be opened or closed.
	lda $14 : and #$f8 : beq +
	lda #$04
+	sta !_8a
	lda !1602,x
	sec : sbc #$04 : sta !_8e
	ora !_8a : sta !_8a
	lda !1504,x : asl
	pha				; All Koopas
	and #$3e : tay	; --PPPKG-
;; Prepare various pointers to our
;;  frames/poses of the Shell.
	rep #$20
	lda.w #ShellsEye : sta !_00
	lda.w #KoopaGfx : sta !_02
	lda.w #ShellsFeet : sta !_04
	lda (!_00),y : sta !_00		; Indirect Eye Pointer
	lda (!_04),y : sta !_04		; Indirect Feet Pointer
	ply
	lda (!_02),y : sta !_02		; Indirect Shell Pointer
;; Get actual Eye Frame to store
;;  we decrease it by one since
;;  our graphics loop use $0001-$0005
;;  during the draw frame rather than
;;  $0000-$0004
	lda !_8a : asl : tay
	lda (!_00),y : dec : sta !_8a
;; Get actual Feet Frame to store.
	lda !_8e : asl : tay
	lda (!_04),y : dec : sta !_8e
;; Get actual Shell Frame to store.
	lda !1602,x : asl : tay
	lda (!_02),y
	sta !_0a		; Sprite "Width" for x-flip
	inc
	sta !_06		; Sprite "Height" for y-flip
	sta !_8c		; Actual Frame to Draw (Ptr)
	sep #$20
	jsr HandleShellGfx
	rts


;;;; Normal Koopa Graphics Handler


HandleKoopaGfx:
;; Inlined GetDrawInfo Validation Check
;;  If we can draw, we skip over an rts to continue.
;;  Otherwise, we insta-terminate ourselves.
	%GetDrawCheck()
;; Slightly modified from GetDrawInfo, this just
;;  finishes up our vertical checks, using the
;;  bottom-most tile as our "origin" to draw.
	LDA !14D4,x
	XBA
	LDA !190F,x
	AND #$20
	BEQ .CheckOnce
.CheckTwice
	LDA !D8,x
	REP #$20
	SEC : SBC $1C
	SEP #$20
	LDA !14D4,x
	XBA
	BEQ .CheckOnce
	LDA #$02
.CheckOnce
	STA !186C,x
	LDA !D8,x
	REP #$21
	ADC.w #$0010
	SEC : SBC $1C
	SEP #$21
	SBC #$10
	STA !_01
	XBA
	BEQ .OnScreenY
	INC !186C,x
.OnScreenY
	ldy !1504,x
.PrepOfsAndOam:
	lda !15F6,x : and #$0e
	pha				; Palette
	lda.w GraphicProps,y
	pha				; Conditions
	%FTableMTS_PrepOfs_BotOrigin(!_0a,!_0c,!_06,!_0d)
	%FTableMTS_PrepOAM(!_08,!_0e)
	%FTableMTS_PrepOfsSelects(!_06,!_0a)
DrawKoopaConditions:
;; Draw order, first to last, front to behind.
;;  Front Wings -> Koopa -> Back Wings
.DrawWingsFront
	lda 1,s			; Branch if not drawing.
	bpl .DrawKoopa
	ldy !_8a
	jsr DrawLoop
.DrawKoopa
	lda 2,s			; Palette Swap
	eor !_05 : sta !_05
	ldy !_8c
	jsr DrawLoop
	lda 2,s			; Palette Swap
	eor !_05 : sta !_05
.DrawWingsBack
	lda 1,s
	asl				; Branch if not drawing.
	bpl .Finish
	ldy !_8e
	jsr DrawLoop
.Finish
	%FTableMTS_FinalizeDraw(!_08,!_0e)
	pla : pla
	rts


;;;; Koopa Shell Graphics Handler


HandleShellGfx:
;; Inlined GetDrawInfo Validation Check
;;  If we can draw, we skip over an rts to continue.
;;  Otherwise, we insta-terminate ourselves.
	%GetDrawCheck()
;; Slightly modified from GetDrawInfo, this just
;;  finishes up our vertical checks, using the
;;  bottom-most tile as our "origin" to draw.
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$21
	ADC.w #$0010
	SEC : SBC $1C
	SEP #$21
	SBC #$10
	STA !_01
	XBA
	BEQ .OnScreenY
	INC !186C,x
.OnScreenY
	ldy !1504,x
ShellShakeCheck:
	lda.w GraphicProps,y
	and #$04		; Branch if no shaking.
	beq .PrepOfsAndOam
	LDA !1558,X				;$019834	|\\ If the shell is being entered by a Koopa, make it shake.
	BNE +				;$019837	||/
	LDA !1540,X				;$019839	||\ Or if the shell already has a Koopa hiding inside, make it shake when it's about to emerge.
	BEQ .PrepOfsAndOam			;$01983C	|||  (else, return the routine)
	CMP #$30					;$01983E	|||| At what time the Koopa shell begins to shake when a Koopa is hiding inside..
	BCS .PrepOfsAndOam				;$019840	||/
+	LSR							;$019842	|| Make the Koopa shell shake.
	LDA !_00				;$019843	||
	ADC #$00					;$019846	||
	BCS .PrepOfsAndOam				;$019848	||
	STA !_00				;$01984A	|/
.PrepOfsAndOam:
	lda !15F6,x : and #$0e
	pha				; Palette
	lda !1540,x
	pha				; Stun Timer
	lda.w GraphicProps,y
	pha				; Conditions
	%FTableMTS_PrepOfs_BotOrigin(!_0a,!_0c,!_06,!_0d)
	%FTableMTS_PrepOAM(!_08,!_0e)
	%FTableMTS_PrepOfsSelects(!_06,!_0a)
DrawShellConditions:
;; Draw order, first to last, front to behind.
;;  Shell Eyes -> Actual Shell -> Shell Feet
	lda 3,s			; Palette Swap
	eor !_05 : sta !_05
.DrawEyes
	lda 1,s
	and #$30		; Branch if no eyes.
	beq .DrawShell
	lda 2,s
	beq .DrawShell
	ldy !_8a
	jsr DrawLoop
	lda 1,s
	and #$10		; Branch if override shell.
	bne .DrawFeet
.DrawShell
	ldy !_8c
	jsr DrawLoop
.DrawFeet
	lda 1,s
	and #$08		; Branch if no feet.
	beq .Finish
	lda 2,s
	cmp #$30		; Branch if not time yet.
	bcs .Finish
	and #$04		; "Flash" between shown or not.
	beq .Finish
	ldy !_8e
	jsr DrawLoop
.Finish
	%FTableMTS_FinalizeDraw(!_08,!_0e)
	pla : pla : pla
	rts


;;;; Generic-ish Graphics "Draw" Loop


DrawLoop:
	%FTableMTS_DrawLoop(!_06,!_0a,!_0c,!_0d,!_08,!_0e)
	rts
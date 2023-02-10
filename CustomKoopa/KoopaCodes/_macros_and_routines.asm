;;; macros and stuff
includefrom "../CustomKoopa.asm"
;; Replacement SetAnimationFrame


macro SetAnimationFrame()
	%SetAnimationFrame_f($01,3)
endmacro
macro SetAnimationFrame_0(frames)
	%SetAnimationFrame_f(frames,3)
endmacro
macro SetAnimationFrame_f(frames,lsr)
	inc !1570,x
	lda !1570,x
	lsr #<lsr>
	and #<frames>
	sta !1602,x
endmacro


;; Replacement OffScrEraseSprite
;;  The Beach Koopa needs this, so
;;  we just "borrow" the relevant tidbit
;;  from PIXI's SubOffScreen.

macro OffScrEraseSprite()
	LDA !14C8,x             ; \ if sprite status < 8, permanently erase sprite
	CMP #$08                ; |
	BCC ?kill               ; /
	LDY !161A,x             ;A:FF08 X:0007 Y:0001 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1108 VC:059 00 FL:2878
	CPY #$FF                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1140 VC:059 00 FL:2878
	BEQ ?kill               ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1156 VC:059 00 FL:2878

	PHX			;BlindEdit: houston we have a problem (preserve X)
	PHY			;preserve Y
	TYX			;transfer Y to X
	LDA #$00                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1172 VC:059 00 FL:2878
if !Disable255SpritesPerLevel
	STA !1938,x
else
	STA.L !7FAF00,x             ;$41A800 in SA-1 ROM, so it can't be Y indexed!
endif			
	PLY			;restore Y
	PLX			;BlindEdit: alright back to the planning phase (restore X)
?kill:
	STZ !14C8,x             ; erase sprite
endmacro


;; Replacement SubHorzPosBnk1
;;  For some reason, this is based
;;  on the player's current position
;;  rather than one frame later...
;; It also works slightly differntly
;;  from PIXI's version because ????


macro SubHorzPosBnk1()
	ldy #$00
	lda $d1
	sec : sbc !E4,x
	sta !_0f
	lda $d2 : sbc !14E0,x
	bpl ?+ : iny
	?+
endmacro


;; Replacement SubVertPosBnk1
;;  For some reason, this is based
;;  on the player's current position
;;  rather than one frame later...
;; It also stores into !_0e rather
;;  than !_0f (as in PIXI's version)
;;  because ???? No clue.


macro SubVertPosBnk1()
	ldy #$00
	lda $d3
	sec : sbc !D8,x
	sta !_0e
	lda $d4 : sbc !14D4,x
	bpl ?+ : iny
	?+
endmacro


;; FacePlayer
;;  PIXI doesn't have a version
;;  of this in its routines folder,
;;  for some reason.


macro FacePlayer()
	%SubHorzPosBnk1()
	tya : sta !157C,x
endmacro


;; FacePlayerInit
;;  Initialization version of FacePlayer


macro FacePlayerInit()
	ldy #$00
	lda $94
	sec : sbc !E4,x
	sta !_0f
	lda $95 : sbc !14E0,x
	bpl ?+ : iny
	?+
	tya : sta !157C,x
endmacro


;; Replacement Solid Block Checks
;;  Now includes a version for
;;  floors *AND* ceilings! Wow.


macro IsTouchingObjSide()
	lda !1588,x : and #$03
endmacro

macro IsOnGround()
	lda !1588,x : and #$04
endmacro

macro IsTouchingCeiling()
	lda !1588,x : and #$08
endmacro

macro IsTouchingObjVert()
	lda !1588,x : and #$0c
endmacro


;; Replacement PlayKickSfx


macro PlayKickSfx()
	lda #$03 : sta $1DF9|!addr
endmacro


;; Inline GetDrawCheck
;;  Based on PIXI's GetDrawInfo
;;  except this one invalidates
;;  via an rts, intended for
;;  inlining into your custom routine.
;; Note that !_01 does *NOT* contain
;;  the relative y position afterwards,
;;  you'll need to do that yourself.


macro GetDrawCheck()
	STZ !186C,x
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	SEC : SBC $1A
	STA !_00
	CLC
	ADC.w #$0040
	CMP.w #$0180
	SEP #$20
	LDA !_01
	BEQ ?+
	LDA #$01
	?+
	STA !15A0,x
   ; in sa-1, this isn't #$000
   ; this actually doesn't matter
   ; because we change A and B to different stuff
	TDC
	ROL A
	STA !15C4,x
	beq ?+
	rts
?+
endmacro


;%dys_ssr(GenericGfx_FTableMTS)
;	sta !_00
;	tya
;	asl
;	tay
;	lda (!_00),y
;	sta !_0a
;	inc
;	sta !_06
;	sep #$20
;	jsr + : rtl
;+	jsl GetDrawInfo
;	phx
;
;	lda !_00 : sta !_02
;	lda !157c,x : lsr : ror : lsr : eor #$40 : ora $64 : sta !_05
;	stz !_0c
;	and #$40 : beq +
;
;	lda !_00 : clc : adc (!_0a)
;	sec : sbc #$08 : sta !_00
;	sec : sbc #$08 : sta !_02
;	dec !_0c
;
;+	lda !_01 : sta !_03
;	lda !15f6,x : and #$80 : eor !_05 : sta !_05
;	stz !_0d
;	bpl +
;
;	lda !_01 : clc : adc #$10
;	sec : sbc (!_06) : sta !_03
;	clc : adc #$08 : sta !_01
;	;clc : adc #$08 : sta !_03
;	dec $0d
;
;+	rep #$30
;	tya : and #$00fc : lsr #2 : adc.w #!oam1_sizes : sta !_08
;	sep #$20
;	sta !_0e
;	; x = !oam1_tile & $ff00 | y & $00ff
;	lda.b #!oam1_tile>>8 : xba : tya : tax
;	ldy !_0a
;	stz !_04
;	stz !_07
;	stz !_0b
; 00:    X-offset 8x8
; 01:    Y-offset 8x8
; 02:    X-offset 16x16
; 03:    Y-offset 16x16
; 04:    0
; 05:    Sprite xy-flip | level tile props
; 06-07: X-offset select ptr
; 08-09: size table ptr
; 0a-0b: Y-offset select ptr
; 0c:    negation for x-offset
; 0d:    negation for y-offset
; 0e:    first size table index
;.loop
;    lda $0001,y : bmi .end
;	sta (!_08)
;	sta !_06
;	inc
;	sta !_0a
;	lda !_0c : lsr
;	lda $0004,y : eor !_0c : adc (!_06) : sta.b !oam1_ofsX,x
;	;lda $0005,y : clc : adc !_01 : sta.b !oam1_ofsY,x
;	lda !_0d : lsr
;	lda $0005,y : eor !_0d : adc (!_0a) : sta.b !oam1_ofsY,x
;	rep #$21
;	lda $0002,y : eor !_04 : sta.b !oam1_tile,x
;	txa : adc #$0004 : tax
;	tya : adc #$0005 : tay
;	sep #$20
;	inc !_08
;	bra .loop
;.end
;	sep #$31
;	plx
;	lda !_08 : sbc !_0e
;	ldy #$ff
;	jsl FinishOamWrite
;	lda !dys_lastOam : sta !spr_oamIndex,x
;	rts

;; FTableMTS Prepare Main Pointer
;;  Prepares some pointers for some
;;  pre-loop calculations.
;; Arguments:
;;  arg0: Label of Frame Table Pointers
;;  arg1: dpRAM to prepare pointers
;;  arg2: dpRAM for Sprite Draw Width
;;  arg3: dpRAM for Sprite Draw Height/Frame
;;  optarg4: dpRAM for Sprite Draw Frame
;; Inputs:
;;  A: Pointer to Frames
;;  Y: Frame Index
;; NOTE: Must be used before GetDrawInfo!


macro FTableMTS_PrepMainPtr(Ptr,temp,xOfs,yOfs)
	rep #$20
	lda.w #<Ptr>
	sta !_00
	tya
	asl
	tay
	lda (!_00),y
	sta !_0a
	inc
	sta !_06
	sep #$20
endmacro
macro FTableMTS_PrepMainPtr_f(Ptr,temp,xOfs,yOfs,Frames)
	rep #$20
	lda.w #<Ptr>
	sta <temp>
	tya
	asl
	tay
	lda (<temp>),y
	sta <xOfs>
	inc
	sta <yOfs>
	sta <Frames>
	sep #$20
endmacro


;; FTableMTS Prepare Other Pointer
;;  Prepares some other GFX pointers for
;;  irregular drawing.
;; Arguments:
;;  arg0: Label of Frame Table Pointers
;;  arg1: dpRAM to prepare pointers
;;  arg2: dpRAM for Misc Draw Frame
;; Inputs:
;;  A: Pointer to Frames
;;  Y: Frame Index
;; NOTE: Must be used before GetDrawInfo!


macro FTableMTS_PrepOthrPtr(Ptr,temp,store)
	rep #$20
	lda.w #<Ptr>
	sta <temp>
	tya
	asl
	tay
	lda (<temp>),y
	dec
	sta <store>
	sep #$20
endmacro


;; FTableMTS Prepare X/Y Offsets
;;  Calculates X/Y Offsets based on
;;  if the Sprite has H/V Flip Values.
;; Arguments:
;;  arg0: dpRAM for Sprite Draw Width/Height
;;  arg1: dpRAM for Negation for X/Y Offsets
;; NOTE1: Must be done after GetDrawInfo (Valid)!
;; NOTE2: Most sprites in SMW assume Top Origin
;;  when drawing vertical offsets (top to bottom),
;;  Bottom Origin version assumes a (presumably)
;;  "grounded" sprite, drawing bottom to top.
;; This also prepares dpRAM 05 for OAM props.


macro FTableMTS_CalcXOfs(xOfs,neg)
	lda !_00 : sta !_02
	lda !157C,x : lsr : ror : lsr : eor #$40 : ora $64 : sta !_05
	stz !_0c
	and #$40 : beq ?+

	lda !_00 : clc : adc (!_0a)
	sec : sbc #$08 : sta !_00
	sec : sbc #$08 : sta !_02
	dec !_0c : ?+
endmacro
macro FTableMTS_CalcYOfs_BotOrigin(yOfs,neg)
	lda !_01 : sta !_03
	lda !15F6,x : and #$80 : eor !_05 : sta !_05
	stz !_0d
	bpl ?+

	lda !_01 : sec : sbc (!_06)
	clc : adc #$10 : sta !_03
	clc : adc #$08 : sta !_01
	;clc : adc #$08 : sta !_03
	dec !_0d : ?+
endmacro
macro FTableMTS_CalcYOfs_TopOrigin(yOfs,neg)
	lda !_01 : sta !_03
	lda !15F6,x : and #$80 : eor !_05 : sta !_05
	stz !_0d
	bpl ?+

	lda !_01 : clc : adc (!_06)
	sec : sbc #$08 : sta !_01
	sec : sbc #$08 : sta !_03
	dec !_0d : ?+
endmacro


;; FTableMTS Offset Prepare Helpers for above
;;  Also clears dpRAM 04 for OAM tile.


macro FTableMTS_PrepOfs_BotOrigin(xOfs,xNeg,yOfs,yNeg)
	%FTableMTS_CalcXOfs(<xOfs>,<xNeg>)
	%FTableMTS_CalcYOfs_BotOrigin(<yOfs>,<yNeg>)
	stz !_04
endmacro
macro FTableMTS_PrepOfs_TopOrigin(xOfs,xNeg,yOfs,yNeg)
	%FTableMTS_CalcXOfs(<xOfs>,<xNeg>)
	%FTableMTS_CalcYOfs_TopOrigin(<yOfs>,<yNeg>)
	stz !_04
endmacro
macro FTableMTS_PrepOfs_BotOrigin_NoHFlip(xNeg,yOfs,yNeg)
	lda !_00 : sta !_02
	stz <xNeg>
	lda $64 : sta !_05
	%FTableMTS_CalcYOfs_BotOrigin(<yOfs>,<yNeg>)
	stz !_04
endmacro
macro FTableMTS_PrepOfs_TopOrigin_NoHFlip(xNeg,yOfs,yNeg)
	lda !_00 : sta !_02
	stz <xNeg>
	lda $64 : sta !_05
	%FTableMTS_CalcYOfs_TopOrigin(<yOfs>,<yNeg>)
	stz !_04
endmacro
macro FTableMTS_PrepOfs_NoVFlip(xOfs,xNeg,yNeg)
	%FTableMTS_CalcXOfs(<xOfs>,<xNeg>)
	lda !_01 : sta !_03
	stz <yNeg>
	stz !_04
endmacro
macro FTableMTS_PrepOfs_NoHVFlip(xNeg,yNeg)
	lda !_00 : sta !_02
	stz <xNeg>
	lda !_01 : sta !_03
	stz <yNeg>
	lda $64 : sta !_05
	stz !_04
endmacro


;; FTableMTS Prepare OAM Indexing
;;  Sets up RAM and X Index for OAM stuff.
;; Arguments:
;;  arg0: OAM Size Table Ptr
;;  arg1: **First** OAM Size Table Index
;;  optarg2: dpRAM of Sprite Draw Frame Ptr
;; Inputs:
;;  Y: Sprite's "Current" OAM Index
;; Outputs:
;;  X: Sprite's OAM Index, full 16-bit
;;  Y (Optional): Sprite Draw Frame Ptr
;; WARNING: X and Y are both 16-bit by
;;  the end of this! Careful with them!
;; NOTE: A is 8-bit by the end of this!


macro FTableMTS_PrepOAM(CurrSize,FirstSize)
	ldy !15EA,x
	rep #$30
	tya : and #$00fc : lsr #2 : adc.w #!oam1_sizes : sta <CurrSize>
	sep #$20
	sta <FirstSize>
	; x = !oam1_tile & $ff00 | y & $00ff
	lda.b #!oam1_tile>>8 : xba : tya : tax
endmacro
macro FTableMTS_PrepOAM_f(CurrSize,FirstSize,FramePtr)
	;rep #$30
	;tya : and #$00fc : lsr #2 : adc.w #!oam1_sizes : sta !_08
	;sep #$20
	;sta !_0e
	;; x = !oam1_tile & $ff00 | y & $00ff
	;lda.b #!oam1_tile>>8 : xba : tya : tax
	%FTableMTS_PrepOAM(<CurrSize>,<FirstSize>)
	ldy !_0a
endmacro


;; FTableMTS Prepare X/Y Offset Select Ptrs
;;  Just a simple helper for setting the
;;  high byte of these pointers (because SA-1).


macro FTableMTS_PrepOfsSelects(xSelect,ySelect)
if !sa1 == !False
	stz <xSelect>+1 : stz <ySelect>+1
else
	lda.b #!dp>>8
	sta <xSelect>+1
	sta <ySelect>+1
endif
endmacro


;; FTableMTS Sprite Palette EOR
;;  A code snippet that loads !15f6
;;  and EORs dpRAM 05.
;; Intended for switching between
;;  the sprite's actual palette
;;  and tiles that are drawn with
;;  a static palette.
;;  (e.g. wing tiles)


macro FTableMTS_SprPalEOR()
	lda !15F6,x : and #$0e
	eor !_05 : sta !_05
endmacro


;; FTableMTS Draw Loop
;;  The actual draw loop routine!
;; Arguments:
;;  arg0: X-offset Select Pointer
;;  arg1: Y-offset Select Pointer
;;  arg2: Negation for X Offset
;;  arg3: Negation for Y Offset
;;  arg4: Current OAM Size Table Ptr
;;  arg5: **First** OAM Size Table Index
;; Inputs:
;;  A: Must be 8-bit!
;;  X: Sprite's Current OAM Index, 16-bit
;;  Y: Sprite Draw Frame Pointer
;; Outputs:
;;  A: "Garbage"
;;  X: Sprite's Current OAM Index, 16-bit
;;  Y: "Garbage"
;; WARNING: X and Y must be 16-bit when
;;  starting the loop!
;; NOTE: The loop use $0001-$0005 to index
;;  with Draw Frame Pointer, not $0000-$0004!


macro FTableMTS_DrawLoop(xSelect,ySelect,xNeg,yNeg,CurrSize,FirstSize)
; 00:    X-offset 8x8
; 01:    Y-offset 8x8
; 02:    X-offset 16x16
; 03:    Y-offset 16x16
; 04:    0
; 05:    Sprite xy-flip | level tile props
; 06-07: X-offset select ptr
; 08-09: size table ptr
; 0a-0b: Y-offset select ptr
; 0c:    negation for x-offset
; 0d:    negation for y-offset
; 0e:    first size table index
?loop
    lda $0001,y : bmi ?end
	sta (!_08)
	sta !_06
	inc
	sta !_0a
	lda !_0c : lsr
	lda $0004,y : eor !_0c : adc (!_06) : sta.b !oam1_ofsX,x
	;lda $0005,y : clc : adc !_01 : sta.b !oam1_ofsY,x
	lda !_0d : lsr
	lda $0005,y : eor !_0d : adc (!_0a) : sta.b !oam1_ofsY,x
	rep #$21
	lda $0002,y : eor !_04 : sta.b !oam1_tile,x
	txa : adc #$0004 : tax
	tya : adc #$0005 : tay
	sep #$20
	inc !_08
	bra ?loop
?end
endmacro


;; FTableMTS Finalize Drawing
;;  Used after a draw loop to finalize
;;  drawing our tiles, calling FinishOAMWrite.
;; Arguments:
;;  arg0: Current OAM Size Table Ptr
;;  arg1: **First** OAM Size Table Index
;; NOTE1: A, X, and Y are both 8-bit going out.
;; NOTE2: This doesn't end in an rts in case
;;  you need to do other stuff, for some reason.


macro FTableMTS_FinalizeDraw(CurrSize,FirstSize)
	sep #$31
	ldx !sprite_slot
	lda !_08 : sbc !_0e
	ldy #$ff
	%FinishOAMWrite()
endmacro

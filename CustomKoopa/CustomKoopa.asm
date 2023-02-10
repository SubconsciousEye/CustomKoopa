

;; Extra Bit: -----K--
;;    K = 0, SMW Style Koopa
;;    K = 1, SMB3 Style Koopa
;; 
;; Extra Byte 1: SBAWPPPG
;;    G = Alternate Graphics Tilemap
;;    PPP = Koopa Palette Coloring
;;    W = Has Wings (Paratroopa)
;;    A = Alternate Behavior (Wings Only)
;;    B = Is Beach (Naked) Koopa
;;    S = Spawn in Stunned State
;; Extra Byte 2: 01-FF = Empty Shell
;; 
;; !1510 = Behavior Pointer Index * 2 w/ KG
;; !1504 = Graphics Pointer Index / 2
;; !1510 = Behavior Properties Index
;; !1504 = Graphic Properties Index
print "VERG", "32"


;;;;; Koopa Defines and Macros and stuff


incsrc "KoopaDefines.asm"
incsrc "KoopaCodes/_macros_and_routines.asm"


;;;;; Status Pointers


print "INIT", hex(Init)
print "MAIN", hex(Main)

print "CARRIABLE", hex(Stunned)
print "KICKED", hex(Kicked)
print "CARRIED", hex(Carried)

print "MOUTH", hex(Yoshi)


;;;;; Status Codes


Init:
	phb : phk : plb
	jsr InitKoopa
	plb
	rtl


Main:
	phb : phk : plb
;; Death Status Check
;;  Either h02, h03, or h05 can reach this.
;;  (Normal, Squished, and Lava Deaths)
;; Smushed is special-case from PIXI, the others
;;  get here from !167A,x having h01 bit set.
	ldy !14C8,x
;; WARNING: Unfortunately, there is a minor bug
;;  in PIXI where it'll call SpriteMain after
;;  running the Squished Status Handler for the
;;  Graphics, but said handler has already
;;  zeroed out !14C8,x by the time we get here.
;; This is due to PIXI storing a backup of !14C8
;;  into the stack, and using it to call the
;;  Sprite's Statuses, causing a desync for a
;;  single frame, which may cause issues if
;;  the sprite isn't careful about it.
;; There isn't a clean way to fix this within
;;  PIXI's internals since there may be an old
;;  sprite that somehow utilizes this behavior.
	beq .Terminate
	cpy #$08 : bcs +			; Not dead!
	jmp HandleSprDeath
;; Fix some stuff if we do a normal
;;  stomp on a Paratroopa (i.e. wings clipped).
;; Beach Koopas already did their stuff, so skip.
+	lda !1510,x : bmi .RunMain
	and #$20					; W bit
	bne .RunMain
;; Acts Like
	ldy #$04
	lda !1510,x : and #$02		; K bit
	beq .SetActsLike
	ldy #$11
.SetActsLike
if !SA1
	pha : tya
	sta !9E,x
	sta $87		; sprite num cache?
	pla
else
	sty !9E,x
endif
;; Not Stompable w/ Upwards Y Speed
	lda !190F,x : and.b #~$10 : sta !190F,x
;; Change direction when touched
	lda !1686,x : and.b #~$10 : sta !1686,x
.RunMain
	jsr MainKoopa
.Terminate
	plb
	rtl


Stunned:
;; Fix upside-down shell if Paratroopa
;;  SMW flips the shell if:
;;  +net-punched
;;  +cape-thwacked
;;  +block-bonked
;;  +ground-quake
;;  +anything else that calls a quake spr
;; These various interactions usually run
;;  after most sprites run their code,
;;  *especially* bounce blocks.
;; Kinda hacky, but it's the least intrusive
;;  way to fix such scenario.
	lda !1510,x : and #$20 : beq .ActsLike
	lda !15F6,x : bpl .ActsLike
	lda !1510,x : and.b #~$60 : sta !1510,x
	lda !1504,x : and.b #~$60 : sta !1504,x
;; Fix Acts Like setting from Paratroopa
.ActsLike
	ldy #$04
	lda !1510,x : and #$02
	beq +
	ldy #$11
+	
if !SA1
	pha : tya
	sta !9E,x
	sta $87		; sprite num cache?
	pla
else
	sty !9E,x
endif
;; Fix Stompable w/ Upwards Y Speed
	lda !190F,x : and.b #~$10 : sta !190F,x
;; Run actual stunned shell code.
	jsr HandleSprStunned
	rtl


Kicked:
	jsr HandleSprKicked
	rtl


Carried:
	jsr HandleSprCarried
	rtl


Yoshi:
;; Disco Shell doesn't need to do anything
	lda !187B : bne +
;; Get Yoshi Abilities Acts Like
;;  Should only apply to Non-Beach Koopas
	lda !1510,x : lsr : and #$0f : tay
	lda.w YoshiShellAbility,y
	sta !9E,x
if !SA1
	sta $87		; sprite num cache?
endif
+	rtl



;;;;; Actual Init and Main Handlers

InitKoopa:
;;; Prepare !1510,x and !1504,x
;;;  also !15f6,x (yxppccct props)
;;;  while we're at it.
	lda !extra_byte_1,x
	sta !_8a : xba : lda !_8a
	asl : and #$fc : sta !1510,x	; BAWPPP--
	and #$3c : sta !1504,x			; --WPPP--
	lsr : and #$0e					; ----PPP-
	ora !15F6,x : sta !15F6,x
if !option_ExtraBits_h03 == !False
	xba : and #$01 : sta !_8a		; -------G
	lda !extra_bits,x
	lsr : and #$02 : ora !_8a		; ------KG
else
	xba : ror						; G into carry
	lda !extra_bits,x : rol			; G transfer back
	and #$03						; ------KG
endif
	ora !1504,x : sta !1504,x		; --WPPPKG
	and #$03 : ora !1510,x			; BAWPPPKG
	sta !1510,x
	lsr : and #$40 : ora !1504,x	; -BWPPPKG
	sta !1504,x
;;; Prepare to Jump to actual Init
.JumpStart
	txy
	lda !1510,x : lsr : and #$7e	; -BAWPPP-
if !option_BehavPtrFailsafe == !True
	cmp #!maxBehavPtr+1				; -B--PPP- + 1
	bcc +					; Skip failsafe check
	and #!maxBehavPtr : +			; -B--PPP-
endif
	tax
	jmp (.Ptrs,x)
.Ptrs
;;; !1510 is ----PPP-
..StandardKoopa
...Pal8n9
	dw InitStandardSprite, InitStandardSprite
...PalAnB
	dw InitStandardSprite, InitStandardSprite
...PalCnD
	dw InitStandardSprite, InitStandardSprite
...PalEnF
	dw InitStandardSprite, InitStandardSprite
;;; !1510 is ---WPPP-
..Paratroopa
...Pal8n9
	dw InitParakoopa, ChasingFlyer_Init
...PalAnB
	dw InitStandardSprite, RevolvingFlyer_Init
...PalCnD
	dw DirectionalPatroller_Init, StraightFlyer_Init
...PalEnF
	dw InitParakoopa, InitParakoopa
;;; !1510 is --A-PPP-
..UnusedKoopa
...Pal8n9
	dw InitStandardSprite, InitStandardSprite
...PalAnB
	dw InitStandardSprite, InitStandardSprite
...PalCnD
	dw InitStandardSprite, InitStandardSprite
...PalEnF
	dw InitStandardSprite, InitStandardSprite
;;; !1510 is --AWPPP-
..ParatroopaAlt
...Pal8n9
	dw InitParakoopa, ChasingFlyer_Init
...PalAnB
	dw WavyFlyer_Init, RevolvingFlyer_Init
...PalCnD
	dw DirectionalPatroller_Init, PositionalBouncer_Init
...PalEnF
	dw InitParakoopa, InitParakoopa
;;; !1510 is -B--PPP-
..BeachKoopa
...Pal8n9
	dw BeachKoopa_Init, BeachKoopa_Init
...PalAnB
	dw BeachKoopa_Init, BeachKoopa_Init
...PalCnD
	dw BeachKoopa_Init, BeachKoopa_Init
...PalEnF
	dw BeachKoopa_Init, BeachKoopa_Init


MainKoopa:
	txy
	lda !1510,x : lsr : and #$7e	; -BAWPPP-
if !option_BehavPtrFailsafe == !True
	cmp #!maxBehavPtr+1				; -B--PPP- + 1
	bcc +					; Skip failsafe check
	and #!maxBehavPtr : +			; -B--PPP-
endif
	tax
	jmp (.Ptrs,x)
.Ptrs
;;; !1510 is ----PPP-
..StandardKoopa
...Pal8n9
	dw Spr0to13Start, Spr0to13Start
...PalAnB
	dw Spr0to13Start, Spr0to13Start
...PalCnD
	dw Spr0to13Start, Spr0to13Start
...PalEnF
	dw Spr0to13Start, Spr0to13Start
;;; !1510 is ---WPPP-
..Paratroopa
...Pal8n9
	dw MainParakoopa, ChasingFlyer_Main
...PalAnB
	dw Spr0to13Start, RevolvingFlyer_Main
...PalCnD
	dw DirectionalPatroller_Main, StraightFlyer_Main
...PalEnF
	dw MainParakoopa, MainParakoopa
;;; !1510 is --A-PPP-
..UnusedKoopa
...Pal8n9
	dw Spr0to13Start, Spr0to13Start
...PalAnB
	dw Spr0to13Start, Spr0to13Start
...PalCnD
	dw Spr0to13Start, Spr0to13Start
...PalEnF
	dw Spr0to13Start, Spr0to13Start
;;; !1510 is --AWPPP-
..ParatroopaAlt
...Pal8n9
	dw MainParakoopa, ChasingFlyer_Main
...PalAnB
	dw WavyFlyer_Main, RevolvingFlyer_Main
...PalCnD
	dw DirectionalPatroller_Main, PositionalBouncer_Main
...PalEnF
	dw MainParakoopa, MainParakoopa
;;; !1510 is -B--PPP-
..BeachKoopa
...Pal8n9
	dw BeachKoopa_Main, BeachKoopa_Main
...PalAnB
	dw BeachKoopa_Main, BeachKoopa_Main
...PalCnD
	dw BeachKoopa_Main, BeachKoopa_Main
...PalEnF
	dw BeachKoopa_Main, BeachKoopa_Main



;;;;; Behaviors


incsrc "KoopaCodes/GenericKoopa.asm"
incsrc "KoopaCodes/GenericParakoopa.asm"
incsrc "KoopaCodes/BeachKoopa.asm"

incsrc "KoopaCodes/StraightFlyer.asm"
incsrc "KoopaCodes/PositionalBouncer.asm"
incsrc "KoopaCodes/DirectionalPatroller.asm"

incsrc "KoopaCodes/WavyFlyer.asm"
incsrc "KoopaCodes/RevolvingFlyer.asm"
incsrc "KoopaCodes/ChasingFlyer.asm"


incsrc "KoopaCodes/HandleSpriteStunned.asm"
incsrc "KoopaCodes/HandleSpriteKicked.asm"
incsrc "KoopaCodes/HandleSpriteCarried.asm"
incsrc "KoopaCodes/HandleSpriteDeath.asm"


;;;;; Koopa Graphics

incsrc "KoopaGfx.asm"


;;;;; Koopa Props

Spr0to13SpeedX:					;$0188EC	| X speeds for sprites 00-13. First two are when the "move fast" bit below is clear; second two are when set.
	db $08,-$08, $0c,-$0c

;; BehaviorProps: atcdjfls
;;    a = Aerial Animation Doubled
;;    t = Enable Turning Frame
;;    c = Spawns Coin
;;    d = Turn Disco
;;    j = Jump over shells
;;    f = Follow Player
;;    l = Stay on Ledges
;;    s = Faster Speed


BehaviorProps:				;BAWPPPKG
.StandardKoopa
..Pal8
	db $40,$40,$00,$00		;------KG
..Pal9
	db $6d,$6d,$3d,$3d		;-----PKG
..PalA
	db $65,$65,$35,$35		;----P-KG
..PalB
	db $43,$43,$03,$03		;----PPKG
..PalC
	db $42,$42,$02,$02		;---P--KG
..PalD
	db $40,$40,$00,$00		;---P-PKG
..PalE
	db $40,$40,$00,$00		;---PP-KG
..PalF
	db $40,$40,$00,$00		;---PPPKG
.Paratroopa
..Pal8
	db $40,$40,$00,$00		;--W---KG
..Pal9
	db $4d,$4d,$1d,$1d		;--W--PKG
..PalA
	db $cd,$cd,$9d,$9d		;--W-P-KG
..PalB
	db $40,$40,$00,$00		;--W-PPKG
..PalC
	db $40,$40,$00,$00		;--WP--KG
..PalD
	db $40,$40,$00,$00		;--WP-PKG
..PalE
	db $40,$40,$00,$00		;--WPP-KG
..PalF
	db $40,$40,$00,$00		;--WPPPKG
.UnusedKoopa
..Pal8
	db $40,$40,$00,$00		;-A----KG
..Pal9
	db $6d,$6d,$3d,$3d		;-A---PKG
..PalA
	db $65,$65,$35,$35		;-A--P-KG
..PalB
	db $43,$43,$03,$03		;-A--PPKG
..PalC
	db $42,$42,$02,$02		;-A-P--KG
..PalD
	db $40,$40,$00,$00		;-A-P-PKG
..PalE
	db $40,$40,$00,$00		;-A-PP-KG
..PalF
	db $40,$40,$00,$00		;-A-PPPKG
.ParatroopaAlt
..Pal8
	db $40,$40,$00,$00		;-AW---KG
..Pal9
	db $4d,$4d,$1d,$1d		;-AW--PKG
..PalA
	db $40,$40,$10,$10		;-AW-P-KG
..PalB
	db $40,$40,$00,$00		;-AW-PPKG
..PalC
	db $40,$40,$00,$00		;-AWP--KG
..PalD
	db $40,$40,$00,$00		;-AWP-PKG
..PalE
	db $40,$40,$00,$00		;-AWPP-KG
..PalF
	db $40,$40,$00,$00		;-AWPPPKG
.BeachKoopa
..Pal8
	db $40,$40,$00,$00		;B-----KG
..Pal9
	db $5d,$5d,$1d,$1d		;B----PKG
..PalA
	db $5d,$5d,$1d,$1d		;B---P-KG
..PalB
	db $43,$43,$03,$03		;B---PPKG
..PalC
	db $42,$42,$02,$02		;B--P--KG
..PalD
	db $40,$40,$00,$00		;B--P-PKG
..PalE
	db $40,$40,$00,$00		;B--PP-KG
..PalF
	db $40,$40,$00,$00		;B--PPPKG


;; GraphicProps: wbeofstd
;;    w = Front Wings
;;    b = Back Wings
;;    e = Shell Eyes
;;    o = Occupied Shell Override ("Eyes")
;;    f = Koopa Feet Shell
;;    s = Shake Shell
;;    t = Two Tiles Tall (190F)
;;    d = Unused (Maybe Wing Disappear?)


incsrc "KoopaGfx/GfxProps_Default.asm"


;; BeachActsLike
;;  For handling if Beach Koopa can
;;  hop into a shell or kick objects
;; 00 = disables bit h40 in 1656
;; 02 = kick shells and objects
;; 36 = hop into empty shell


BeachActsLike:				;----PPPK
.Pal8
	db $36,$00
.Pal9
	db $36,$00
.PalA
	db $36,$00
.PalB
	db $02,$02
.PalC
	db $36,$00
.PalD
	db $36,$00
.PalE
	db $36,$00
.PalF
	db $36,$00


;; YoshiShellAbility
;;  For Non-Beach Koopas inside
;;  Yoshi's Mouth (Sets ActsLike).
;; 00 = Enable Shell Ability
;; 11 = Disable Shell Ability


YoshiShellAbility:			;----PPPK
.Pal8
	db $11,$11
.Pal9
	db $11,$11
.PalA
	db $00,$00
.PalB
	db $00,$00
.PalC
	db $00,$00
.PalD
	db $00,$00
.PalE
	db $11,$11
.PalF
	db $11,$11


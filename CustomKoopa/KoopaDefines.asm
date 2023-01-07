;;; True + False defines
;;;  do not change, ever

!True ?= 1
!False ?= 0

;;; Various compile-time options


;; Extra Bits in h03
;;  PIXI stores the extra bits
;;  in !extra_bits,x as
;;  0000ce0y rather than as
;;  0000cece (y = stray y-pos).
;; If the extra bits were stored
;;  as shown, we could shift the
;;  e bit into carry for slightly
;;  smaller (and somewhat faster)
;;  branching conditions + setup.
;; Obviously, if something else is
;;  already using the carry flag
;;  for something, we can't really
;;  do that, but it'd still be useful.
;; Technically, the ce bits only
;;  need to be in h01+h02, but
;;  some resources (read: most)
;;  expect them in h04+h08, so
;;  we just duplicate it in case
;;  anything expects it.
;; Oh well, we work what we have.
!option_ExtraBits_h03		?=	!False


;; Status 0 Erase Extra Bits
;;  PIXI, for some reason, hijacks
;;  $018151 to clear !extra_bits,x
;;  whenever !14C8,x is zero
;;  (i.e. sprite no longer exists).
;; As far as SMW is concerned, a slot
;;  is free if !14C8,x is 0, so there
;;  isn't really a reason to zero out
;;  !extra_bits,x unless PIXI or some
;;  other resource does something weird.
;; This inconveniences some (SMW) code
;;  that handles a Shell checking
;;  (loosely) for a Beach Koopa to
;;  determine if we can go disco, as
;;  the Beach Koopa erases itself upon
;;  entering the shell.
;; If we want to mimic SMW, we kind of
;;  want some sort of workaround, so
;;  we transfer the Beach Koopa's
;;  extra bits over to the Shell's
;;  !extra_prop_2.
!option_14C8EraseExtraBits		?=	!True


;; Behavior Pointer Failsafe
;;  This is used on the
;;  off-chance that some
;;  goof-ball use "invalid"
;;  values that would potentially
;;  crash the game due to the
;;  pointer table not being large
;;  enough.
;; By default, the maximum value
;;  is Beach Koopa, Pal F
;;  (ANDed to prevent leaks).
!option_BehavPtrFailsafe	=	!True
	!maxBehavPtr	=	%01001110	; -B--PPP-


;; Graphics Pointer Failsafe
;;  Same idea as the previous
;;  Behavior Pointer Failsafe.
;; By default, the maximum value
;;  is Beach Koopa, non-Alt Behavior
;;  (ANDed to prevent leaks).
!option_GfxPtrFailsafe		=	!True
	!maxGfxPtr		=	%10111110	; B-PPPKG-


;;; Misc Defines


;; JSL Names


!GetRand = $01ACF9|!bank
!ZeroSpriteTables = $07F722|!bank
!SetSpriteTables = $0187A7|!bank		;PIXI
;!SubSprYPosNoGrvty = $01801A|!bank
!UpdateYPosNoGrvty = $01801A|!bank
;!SubSprXPosNoGrvty = $018022|!bank
!UpdateXPosNoGrvty = $018022|!bank
;!SubUpdateSprPos = $01802A|!bank
!UpdateSpritePos = $01802A|!bank
;MarioSprInteractRt = $01A7DC|!bank
!MarioSprInteract = $01A7DC|!bank
;SubSprSprInteract = $018032|!bank
!SprSprInteract = $018032|!bank
;SubSprSprPMarioSpr = $01803A|!bank
!SprSprPMarioSprRts = $01803A|!bank
!GetMarioClipping = $03B664|!bank
!GetSpriteClippingA = $03B69F|!bank
!GetSpriteClippingB = $03B6E5|!bank
!CheckForContact = $03B72B|!bank
!GivePoints = $02ACE5|!bank
!FindFreeSprSlot = $02A9E4|!bank
!InitSpriteTables = $07F7D2|!bank
!DispContactSpr = $01AB6F|!bank
!CODE_00F160 = $00F160|!bank
!CODE_019138 = $019138|!bank


;; Current Sprite Slot
;;  Why PIXI didn't have this be
;;  a define is anybody's guess.


	!sprite_slot	?=	$15e9|!addr


;; OAM Shenanigans
;;  Slightly based on
;;  Daiyousei's naming


	!oam1_ofsX		?=	$0300|!addr
	!oam1_ofsY		?=	$0301|!addr
	!oam1_tile		?=	$0302|!addr
	!oam1_props		?=	$0303|!addr

	!oam0_ofsX		?=	$0200|!addr
	!oam0_ofsY		?=	$0201|!addr
	!oam0_tile		?=	$0202|!addr
	!oam0_props		?=	$0203|!addr

	!oam1_bitSizes	?=	$0410|!addr
	!oam0_bitSizes	?=	$0400|!addr
	!oam1_sizes		?=	$0460|!addr
	!oam0_sizes		?=	$0420|!addr

;; Direct Page versions
;;  In case something
;;  needs it, I guess.
;; (SA-1 sets dp to $3000)


	!oam1_ofsX_dp		?=	$0300|!dp
	!oam1_ofsY_dp		?=	$0301|!dp
	!oam1_tile_dp		?=	$0302|!dp
	!oam1_props_dp		?=	$0303|!dp

	!oam0_ofsX_dp		?=	$0200|!dp
	!oam0_ofsY_dp		?=	$0201|!dp
	!oam0_tile_dp		?=	$0202|!dp
	!oam0_props_dp		?=	$0203|!dp

	!oam1_bitSizes_dp	?=	$0410|!dp
	!oam0_bitSizes_dp	?=	$0400|!dp
	!oam1_sizes_dp		?=	$0460|!dp
	!oam0_sizes_dp		?=	$0420|!dp


;; Scratch RAMs


	!_00		?=	$00
	!_01		?=	$01
	!_02		?=	$02
	!_03		?=	$03
	!_04		?=	$04
	!_05		?=	$05
	!_06		?=	$06
	!_07		?=	$07
	!_08		?=	$08
	!_09		?=	$09
	!_0a		?=	$0a
	!_0b		?=	$0b
	!_0c		?=	$0c
	!_0d		?=	$0d
	!_0e		?=	$0e
	!_0f		?=	$0f

	!_8a		?=	$8a
	!_8b		?=	$8b
	!_8c		?=	$8c
	!_8d		?=	$8d
	!_8e		?=	$8e
	!_8f		?=	$8f

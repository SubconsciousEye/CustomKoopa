Custom Koopa Readme
;;;;;;;;;;;;;;;;;;;;;;;;;;;

Custom Koopa v0.04_c3
 By SubconsciousEye

Credits to Thomas/Kaizoman666 for the SMW Disassembly
Credits to Katrina for the Graphics Subroutine (from Daiyousei)
Credits to Erik/Alcaro for ideas of Blue and Yellow Koopa Paratroopas (code for Yellow Wavy Parakoopa was from the Eerie, code for the Blue Circling Parakoopa is based loosely on the Ball 'n' Chain)
Credits to the PIXI Crew for PIXI and some of its routines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

This "Custom Koopa" sprite is a highly modified version of (most) of SMW's Koopa variants, all rolled into one sprite! Technically, I had this idea years ago, but I only just started working on it around the time Winter 2022 C3 was coming up. I was working on this for about 1.5-2 weeks straight (with some breaks inbetween, of course!) before and during Winter 2022's C3.
By the time C3 closed, I was already pretty burnt out and was nearly done with a presentation-ready version. I *did* promise I would show this off back then, so I decided to come back to it for Summer 2022 C3. Do note that because of the rush back then, there may have been a few mishaps and other weird decisions.
Now that it is here, this is very much a heavy Works In Progress Beta (hence the "zeroth" version). Only the "Traditional" Custom Koopa is currently being worked on, but I do have some plans for a more "Freeform" version for a proper v1.00 edition.
Without further ado, let us list some features of this sprite:

* SMB3-Style and SMW-Style Koopas
-- Depending on the Extra Bit, you can make either a SMW-Style Koopa Troopa (spawns Beach Koopa when stomped) or a SMB3-Style Koopa Troopa (stuns inside its shell when stomped)! You can also have SMB3-Styled Beach Koopas, if you fancy that.

* All-in-One Sprite
-- This Custom Koopa sprite features a whole slew of Koopa variants packed into one sprite! Beach Koopas, Koopa Troopas, and Koopa Paratroopas are all in this one sprite, and the Beach Koopa can even be a Sliding Koopa!
-- The variants being in one sprite makes it easier for custom code to do certain checks, as you only need to check the ID and a few flags to figure out what type of Koopa it is! It can also be useful for "Kill All Koopa Variants" Rooms, in case you want to do strange things.

* Modular Behavior System
-- You can have different behaviors for different Koopa Types, dependent on Palette (if it's a "Traditional" Variant) and a few flags. Aside from the Generic Default Behaviors, each Behavior is separated into their own .asm file, and later included into the "Master" CustomKoopa.asm file.
-- Aside from the behaviors packaged with this sprite, you can also define your own custom behaviors! Things can only get dangerous from here on out.

* Enhanced Drawing System
-- This sprite uses a pretty robust drawing system, based on Katrina's "FrameTable MultiTileSystem" from Daiyousei! This can allow you to place assorted tiles in certain spots to really spice up your visuals!
-- The table format can allow you to draw any number of tiles for a given pose, granting you some fluid animations if you so desire! Just make sure you have enough OAM space for that!
-- You can also have an alternate graphics set for the given Koopa Type, allowing two graphics set for SMW-Styled Koopas and two graphics set for SMB3-Styled Koopas! Anybody want a special cloak for that?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Settings Information

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
;; 
;; !1510 = BAWPPPKG
;; !1504 = -BWPPPKG

Setting Extra Byte 1:

;;; Bit Information
;;;  SBAW PPPG
;;;  8421 8421
;;; Hex Numbering
;;;  Substitute as needed
;;;  0 = 0 + 0
;;;  1 = 0 + 1
;;;  2 = 0 + 2
;;;  3 = 2 + 1
;;;  4 = 2 + 2
;;;  5 = 4 + 1
;;;  6 = 4 + 2
;;;  7 = 4 + 3
;;;  8 = 4 + 4
;;;  9 = 8 + 1
;;;  A = 8 + 2
;;;  B = 8 + 3
;;;  C = 8 + 4
;;;  D = 8 + 5
;;;  E = 8 + 6
;;;  F = 8 + 7

Example:
;; If we want to set A, W, and -PP:
;;   $36 = 20 + 10 + 4 + 2
;;  In terms of bits activated:
;;   $36 = 00 + 00 + 20 + 10 + 0 + 4 + 2 + 0
;; If we want to set S, B, P-P, and G:
;;   $CB = 80 + 40 + 8 + 2 + 1
;;  In terms of bits activated:
;;   $CB = 80 + 40 + 00 + 00 + 8 + 0 + 2 + 1
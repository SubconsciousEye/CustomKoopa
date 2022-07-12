

;; Mask Koopa Tilemappings
;;  NOTE: Set the ShellsEye
;;  and ShellsFeet pointers
;;  to GfxTable_invalid


;; GraphicsProps:
;;  Regular: $06
;;  Winged: $86
;;  Beach: $02


; db table:
;  width, height
;  size, tile, prop, xofs, yofs
;  terminate


.MaskRegular
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
	db  $02, $c0, $01, $00,-$08
	db  $02, $a0, $01, $00, $00
	db  $ff
..walk1
	db  $10, $18
	db  $02, $c0, $01, $00,-$07
	db  $02, $a2, $01, $00, $01
	db  $ff
..turn
	db  $10, $18
	db  $02, $c2, $01, $00,-$08
	db  $02, $a6, $01, $00, $00
	db  $ff
..shell0
	db  $10, $10
	db  $02, $8c, $01, $00, $00
	db  $ff
..shell1
	db  $10, $10
	db  $02, $8a, $01, $00, $00
	db  $ff
..shell2
	db  $10, $10
	db  $02, $8e, $01, $00, $00
	db  $ff
..shell3
	db  $10, $10
	db  $02, $8a, $41, $00, $00
	db  $ff
..death
	db  $10, $10
	db  $02, $8c, $81, $00, $00
	db  $ff
..squish
	db  $10, $10
	db  $02, $82, $81, $00, $04
	db  $ff

.MaskBeach
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
	dw ..walk0,		..walk1,	..turn,		..kick
	dw ..knocked0,	..knocked1,	..knocked0,	.invalid_0
	dw ..death,		..squish

..walk0
	db  $10, $18
	db  $02, $80, $01,-$03,-$08
	db  $02, $a0, $01, $00, $00
	db  $ff
..walk1
	db  $10, $18
	db  $02, $80, $01,-$03,-$07
	db  $02, $a2, $01, $00, $01
	db  $ff
..turn
	db  $10, $18
	db  $02, $84, $01, $00,-$08
	db  $02, $a6, $01, $00, $00
	db  $ff
..kick
	db  $10, $18
	db  $02, $80, $01, $00,-$08
	db  $02, $a4, $01, $00, $00
	db  $00, $89, $01, $08, $00
	db  $ff
..knocked0
	db  $10, $10
	db  $02, $aa, $01, $00, $00
	db  $02, $ab, $01, $08, $00
	db  $ff
..knocked1
	db  $10, $10
	db  $02, $ad, $01, $00, $00
	db  $02, $ae, $01, $08, $00
	db  $ff
..death
	db  $10, $18
	db  $02, $80, $81,-$03, $08
	db  $02, $a0, $81, $00, $00
	db  $ff
..squish
	db  $10, $08
	db  $00, $88, $01, $00, $08
	db  $00, $88, $41, $08, $08
	db  $ff

.MaskBuffy
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
	dw ..walk0,		..walk1,	..turn,		..kick
	dw ..knocked0,	..knocked0,	..sliding,	.invalid_0
	dw ..death,		..squish

..walk0
	db  $10, $18
	db  $02, $82, $01,-$03,-$08
	db  $02, $a0, $01, $00, $00
	db  $ff
..walk1
	db  $10, $18
	db  $02, $82, $01,-$03,-$07
	db  $02, $a2, $01, $00, $01
	db  $ff
..turn
	db  $10, $18
	db  $02, $86, $01, $00,-$08
	db  $02, $a6, $01, $00, $00
	db  $ff
..kick
	db  $10, $18
	db  $02, $82, $01, $00,-$08
	db  $02, $a4, $01, $00, $00
	db  $00, $89, $01, $08, $00
	db  $ff
..knocked0
	db  $10, $18
	db  $02, $98, $01, $00,-$08
	db  $02, $a8, $01, $00, $00
	db  $ff
..sliding
	db  $10, $10
	db  $02, $aa, $01, $00, $00
	db  $02, $ab, $01, $08, $00
	db  $ff
..death
	db  $10, $18
	db  $02, $82, $81,-$03, $08
	db  $02, $a0, $81, $00, $00
	db  $ff
..squish
	db  $10, $08
	db  $00, $88, $01, $00, $08
	db  $00, $88, $41, $08, $08
	db  $ff

.MaskWings
	dw ..closed,	..opened

..closed
	db  $00, $5d, $06, $09,-$04
	db  $ff
..opened
	db  $02, $c6, $06, $09,-$0c
	db  $ff


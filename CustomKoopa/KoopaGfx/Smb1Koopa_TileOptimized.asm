

;; Smb1 Koopa Tilemappings
;;  NOTE: Set the ShellsEye
;;  and BeachKoopa Pointers
;;  to GfxTable_invalid


;; GraphicsProps:
;;  Regular: $0a
;;  Winged: $8a
;;  Beach: $00


; db table:
;  width, height
;  size, tile, prop, xofs, yofs
;  terminate


.Smb1Regular
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

	dw ..walk0,		..walk1,	..walk1,	.invalid_0
	dw ..shell0,	..shell1,	..shell2,	..shell3
	dw ..death,		..squish

..walk0
	db  $10, $18
	db  $00, $0a, $01, $00,-$08
	db  $02, $00, $01, $00, $00
	db  $ff
..walk1
	db  $10, $18
	db  $00, $0b, $01, $00,-$07
	db  $02, $02, $01, $00, $01
	db  $ff
..shell0
	db  $10, $0e
	db  $02, $08, $01, $00, $00
	db  $ff
..shell1
	db  $10, $0e
	db  $02, $06, $01, $00, $00
	db  $ff
..shell2
	db  $10, $0e
	db  $02, $04, $01, $00, $00
	db  $ff
..shell3
	db  $10, $0e
	db  $02, $06, $41, $00, $00
	db  $ff
..death
	db  $10, $0e
	db  $02, $08, $81, $00, $00
	db  $ff
..squish
	db  $10, $10
	db  $02, $0a, $81, $00, $04
	db  $ff

.Smb1Feet
	dw ..feet0,	.invalid_0,	.invalid_0,	.invalid_0

..feet0
	db  $00, $1a, $81, $00, $08
	db  $00, $1a, $c1, $08, $08
	db  $ff

.Smb1Wings
	dw ..closed,	..opened

..closed
	db  $00, $0d, $07, $08,-$08
	db  $00, $1d, $07, $08, $00
	db  $ff
..opened
	db  $00, $0c, $07, $08,-$08
	db  $00, $1c, $07, $08, $00
	db  $ff


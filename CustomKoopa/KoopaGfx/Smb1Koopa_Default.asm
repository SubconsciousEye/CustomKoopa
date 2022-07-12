

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
	db  $00, $ea, $01, $00,-$08
	db  $02, $e0, $01, $00, $00
	db  $ff
..walk1
	db  $10, $18
	db  $00, $eb, $01, $00,-$07
	db  $02, $e2, $01, $00, $01
	db  $ff
..shell0
	db  $10, $0e
	db  $02, $e8, $01, $00, $00
	db  $ff
..shell1
	db  $10, $0e
	db  $02, $e6, $01, $00, $00
	db  $ff
..shell2
	db  $10, $0e
	db  $02, $e4, $01, $00, $00
	db  $ff
..shell3
	db  $10, $0e
	db  $02, $e6, $41, $00, $00
	db  $ff
..death
	db  $10, $0e
	db  $02, $e8, $81, $00, $00
	db  $ff
..squish
	db  $10, $10
	db  $02, $ea, $81, $00, $04
	db  $ff

.Smb1Feet
	dw ..feet0,	.invalid_0,	.invalid_0,	.invalid_0

..feet0
	db  $00, $fa, $81, $00, $08
	db  $00, $fa, $c1, $08, $08
	db  $ff

.Smb1Wings
	dw ..closed,	..opened

..closed
	db  $00, $ed, $07, $08,-$08
	db  $00, $fd, $07, $08, $00
	db  $ff
..opened
	db  $00, $ec, $07, $08,-$08
	db  $00, $fc, $07, $08, $00
	db  $ff


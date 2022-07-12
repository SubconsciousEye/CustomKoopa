

;; Smb3 Koopa Tilemappings
;;  NOTE: Set the ShellsEye
;;  and BeachKoopa pointers
;;  to GfxTable_invalid


;; GraphicsProps:
;;  Regular: $0e
;;  Winged: $8e
;;  Beach: $00


; db table:
;  width, height
;  size, tile, prop, xofs, yofs
;  terminate


.Smb3Regular
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
	db  $00, $fb, $01, $00,-$0d
	db  $02, $ce, $01, $00,-$05
	db  $00, $d4, $01, $00, $0b
	db  $00, $d5, $01, $08, $0b
	db  $ff
..walk1
	db  $10, $18
	db  $00, $fb, $01, $00,-$0e
	db  $02, $cc, $01, $00,-$06
	db  $00, $c4, $01, $00, $0a
	db  $00, $c5, $01, $08, $0a
	db  $ff
..shell0
	db  $10, $10
	db  $02, $ca, $01, $00, $00
	db  $ff
..shell1
	db  $10, $10
	db  $02, $c8, $01, $00, $00
	db  $ff
..shell2
	db  $10, $10
	db  $02, $c6, $01, $00, $00
	db  $ff
..shell3
	db  $10, $10
	db  $02, $c8, $41, $00, $00
	db  $ff
..death
	db  $10, $10
	db  $02, $ca, $81, $00, $00
	db  $ff
..squish
	db  $10, $10
	db  $02, $c5, $81, $00, $04
	db  $ff

.Smb3Feet
	dw ..feet0,	.invalid_0,	.invalid_0,	.invalid_0

..feet0
	db  $00, $d4, $81,-$04, $08
	db  $00, $d4, $c1, $0c, $08
	db  $ff

.Smb3Wings
	dw ..closed,	..opened

..closed
	db  $00, $ef, $03, $08,-$0e
	db  $00, $ff, $03, $08,-$06
	db  $ff
..opened
	db  $00, $ee, $03, $08,-$0e
	db  $00, $fe, $03, $08,-$06
	db  $ff


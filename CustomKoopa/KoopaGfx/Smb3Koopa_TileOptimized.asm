

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
	db  $00, $0c, $01, $00,-$0d
	db  $02, $02, $01, $00,-$05
	db  $00, $14, $01, $00, $0b
	db  $00, $15, $01, $08, $0b
	db  $ff
..walk1
	db  $10, $18
	db  $00, $0c, $01, $00,-$0e
	db  $02, $00, $01, $00,-$06
	db  $00, $04, $01, $00, $0a
	db  $00, $05, $01, $08, $0a
	db  $ff
..shell0
	db  $10, $10
	db  $02, $0a, $01, $00, $00
	db  $ff
..shell1
	db  $10, $10
	db  $02, $08, $01, $00, $00
	db  $ff
..shell2
	db  $10, $10
	db  $02, $06, $01, $00, $00
	db  $ff
..shell3
	db  $10, $10
	db  $02, $08, $41, $00, $00
	db  $ff
..death
	db  $10, $10
	db  $02, $0a, $81, $00, $00
	db  $ff
..squish
	db  $10, $10
	db  $02, $0c, $81, $00, $04
	db  $ff

.Smb3Feet
	dw ..feet0,	.invalid_0,	.invalid_0,	.invalid_0

..feet0
	db  $00, $14, $81,-$04, $08
	db  $00, $14, $c1, $0c, $08
	db  $ff

.Smb3Wings
	dw ..closed,	..opened

..closed
	db  $00, $0f, $03, $08,-$0e
	db  $00, $1f, $03, $08,-$06
	db  $ff
..opened
	db  $00, $0e, $03, $08,-$0e
	db  $00, $1e, $03, $08,-$06
	db  $ff


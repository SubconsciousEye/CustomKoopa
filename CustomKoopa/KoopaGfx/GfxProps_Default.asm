;; GraphicProps: wbeofstd
;;    w = Front Wings
;;    b = Back Wings
;;    e = Shell Eyes
;;    o = Occupied Shell Override ("Eyes")
;;    f = Koopa Feet Shell
;;    s = Shake Shell
;;    t = Two Tiles Tall (190F)
;;    d = Unused (Maybe Wing Disappear?)


GraphicProps:				;-BWPPPKG
.StandardKoopa
..Pal8
	db $26,$06,$0e,$0a		;------KG
..Pal9
	db $26,$06,$0e,$0a		;-----PKG
..PalA
	db $26,$06,$0e,$0a		;----P-KG
..PalB
	db $26,$06,$0e,$0a		;----PPKG
..PalC
	db $26,$06,$0e,$0a		;---P--KG
..PalD
	db $26,$06,$0e,$0a		;---P-PKG
..PalE
	db $26,$06,$0e,$0a		;---PP-KG
..PalF
	db $26,$06,$0e,$0a		;---PPPKG
.Paratroopa
..Pal8
	db $a6,$86,$8e,$8a		;--W---KG
..Pal9
	db $a6,$86,$8e,$8a		;--W--PKG
..PalA
	db $a6,$86,$8e,$8a		;--W-P-KG
..PalB
	db $a6,$86,$8e,$8a		;--W-PPKG
..PalC
	db $a6,$86,$8e,$8a		;--WP--KG
..PalD
	db $a6,$86,$8e,$8a		;--WP-PKG
..PalE
	db $a6,$86,$8e,$8a		;--WPP-KG
..PalF
	db $a6,$86,$8e,$8a		;--WPPPKG
.BeachKoopa
..Pal8
	db $00,$02,$00,$00		;-B----KG
..Pal9
	db $00,$02,$00,$00		;-B---PKG
..PalA
	db $00,$02,$00,$00		;-B--P-KG
..PalB
	db $00,$02,$00,$00		;-B--PPKG
..PalC
	db $00,$02,$00,$00		;-B-P--KG
..PalD
	db $00,$02,$00,$00		;-B-P-PKG
..PalE
	db $00,$02,$00,$00		;-B-PP-KG
..PalF
	db $00,$02,$00,$00		;-B-PPPKG


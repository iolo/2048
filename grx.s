; apple2 lo-res graphics extension

		typ     $06
		dsk     grx
		org 	$6000
; zero page variables
x1		equ 	$06
y1		equ 	$07
src     	equ     $08 	; source(pixel data) address(lo, hi)
dst     	equ     $1d 	; dest(vram) address(lo, hi)

; soft switches
setgr		equ     $C050   ; graphics mode
settext 	equ	$C051   ; text mode
setfull		equ     $C052   ; full graphics mode
setmixed 	equ   	$C053   ; mixed graphics/text mode
setpage1 	equ     $C054   ; page 1
setpage2	equ     $C055   ; page 2
sethires  	equ     $C056 	; hi-res graphics mode
setlores	equ     $C057 	; lo-res graphics mode

; draw 8x8 tile at x1,y1
; x1: 0..39
; y1: 0..47 but must be even
; src: 8x8=64bytes
;
; y1 = y1 / 2
; for (dy = 0; dy < 4; dy++)
;   dst = text_row_addr[y1 + dy] + x1
;   for (dx = 0; dx < 8; dx++)
;     *dst++ = *src++;
	lsr	y1		; y1 = y1 / 2 (lo-res uses 24 rows)
	ldx	#0		; dy = 0

:dy_loop
	txa			;
	clc
	adc	y1		; y1 + dy
	asl			; (y1 + dy)*2 ; table is word-sized, so offset *= 2
	tay
	lda	text_row_addr+1,y
	sta	dst+1
	lda	text_row_addr,y
	sta	dst		; dst = text_row_addr[(y1 + dy)*2]
	clc
	adc	x1
	sta	dst		; dst += x1
	bcc	:skip_inc_dst
	inc	dst+1
:skip_inc_dst
	ldy	#0

:dx_loop
	lda	(src),y		; copy 8 bytes from src to dst
	sta	(dst),y
	iny
	cpy	#8
	bne	:dx_loop	; while dx < 8

	lda	src		; src += 8 ; advance src by 8 bytes for next row
	clc
	adc	#8
	sta	src
	bcc	:skip_inc_src
	inc	src+1
:skip_inc_src

	inx
	cpx	#4
	bne	:dy_loop	; while dy < 4
	rts

; offset for each 24 rows
text_row_addr
	dw 	$0400,$0480,$0500,$0580,$0600,$0680,$0700,$0780 
	dw	$0428,$04A8,$0528,$05A8,$0628,$06A8,$0728,$07A8
	dw	$0450,$04D0,$0550,$05D0,$0650,$06D0,$0750,$07D0

tiles
	dw tile_empty,tile_2,tile_4,tile_8,tile_16,tile_32,tile_64,tile_128
	dw tile_256,tile_512,tile_1024,tile_2048,tile_4096,tile_8192

;20000 REM TILE DATA (8x8 PIXELS)
; 1byte = 2pixels vertically(high nibble = bottom pixel, low nibble = top pixel)
tile_empty
;20001 DATA "FFFFFFF5"
;20002 DATA "FFFFFFF5"
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$55
;20003 DATA "FFFFFFF5"
;20004 DATA "FFFFFFF5"
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$55
;20005 DATA "FFFFFFF5" 
;20006 DATA "FFFFFFF5" 
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$55
;20007 DATA "FFFFFFF5"
;20008 DATA "55555555"
	db $5f,$5f,$5f,$5f,$5f,$5f,$5f,$55
tile_2
;20100 REM 2^1="2"
;20101 DATA "FFFFFFF5"
;20102 DATA "FF000FF5"
	db $ff,$ff,$0f,$0f,$0f,$ff,$ff,$55
;20103 DATA "FFFF0FF5"
;20104 DATA "FF000FF5"
	db $ff,$ff,$0f,$0f,$00,$ff,$ff,$55
;20105 DATA "FF0FFFF5" 
;20106 DATA "FF000FF5" 
	db $ff,$ff,$00,$0f,$0f,$ff,$ff,$55
;20107 DATA "FFFFFFF5"
;20108 DATA "55555555"
	db $5f,$5f,$5f,$5f,$5f,$5f,$5f,$55
tile_4
;20200 REM 2^2="4"
;20201 DATA "FFFFFFF5"
;20202 DATA "FF0F0FF5"
	db $ff,$ff,$0f,$ff,$0f,$ff,$ff,$55
;20203 DATA "FF0F0FF5"
;20204 DATA "FF000FF5"
	db $ff,$ff,$00,$0f,$00,$ff,$ff,$55
;20205 DATA "FFFF0FF5"
;20206 DATA "FFFF0FF5"
	db $ff,$ff,$ff,$ff,$00,$ff,$ff,$55
;20207 DATA "FFFFFFF5"
;20208 DATA "55555555"
	db $5f,$5f,$5f,$5f,$5f,$5f,$5f,$55
tile_8
;20300 REM 2^3="8"
;20301 DATA "DDDDDDD5"
;20302 DATA "DDFFFDD5"
	db $dd,$dd,$fd,$fd,$fd,$dd,$dd,$55
;20303 DATA "DDFDFDD5"
;20304 DATA "DDFFFDD5"
	db $dd,$dd,$ff,$fd,$ff,$dd,$dd,$55
;20305 DATA "DDFDFDD5"
;20306 DATA "DDFFFDD5"
	db $dd,$dd,$ff,$fd,$ff,$dd,$dd,$55
;20307 DATA "DDDDDDD5"
;20308 DATA "55555555"
	db $5d,$5d,$5d,$5d,$5d,$5d,$5d,$55
tile_16
;20400 REM 2^4="16"
;20401 DATA "BBBBBBB5"
;20402 DATA "BFBFFFB5"
	db $bb,$fb,$bb,$fb,$fb,$fb,$bb,$55
;20403 DATA "BFBFBBB5"
;20404 DATA "BFBFFFB5"
	db $bb,$ff,$bb,$ff,$fb,$fb,$bb,$55
;20405 DATA "BFBFBFB5"
;20406 DATA "BFBFFFB5"
	db $bb,$ff,$bb,$ff,$fb,$ff,$bb,$55
;20407 DATA "BBBBBBB5"
;20408 DATA "55555555"
	db $5b,$5b,$5b,$5b,$5b,$5b,$5b,$55
tile_32
;20500 REM 2^5="32"
;20501 DATA "BBBBBBB5"
;20502 DATA "FFFBFFF5"
	db $fb,$fb,$fb,$bb,$fb,$fb,$fb,$55
;20503 DATA "BBFBBBF5"
;20504 DATA "FFFBFFF5"
	db $fb,$fb,$ff,$bb,$fb,$fb,$ff,$55
;20505 DATA "BBFBFBB5"
;20506 DATA "FFFBFFF5"
	db $fb,$fb,$ff,$bb,$ff,$fb,$fb,$55
;20507 DATA "BBBBBBB5"
;20508 DATA "55555555"
	db $5b,$5b,$5b,$5b,$5b,$5b,$5b,$55
tile_64
;20600 REM 2^6="64"
;20601 DATA "99999995"
;20602 DATA "FFF9F9F5"
	db $f9,$f9,$f9,$99,$f9,$99,$f9,$55
;20603 DATA "F999F9F5"
;20604 DATA "FFF9FFF5"
	db $ff,$f9,$f9,$99,$ff,$f9,$ff,$55
;20605 DATA "F9F999F5"
;20606 DATA "FFF999F5"
	db $ff,$f9,$ff,$99,$99,$99,$ff,$55
;20607 DATA "99999995"
;20608 DATA "55555555"
	db $59,$59,$59,$59,$59,$59,$59,$55
tile_128
;20700 REM 2^7="128"
;20701 DATA "99999995"
;20702 DATA "FFF9FFF5"
	db $f9,$f9,$f9,$99,$f9,$f9,$f9,$55
;20703 DATA "99F9F9F5"
;20704 DATA "FFF9FFF5"
	db $f9,$f9,$ff,$99,$ff,$f9,$ff,$55
;20705 DATA "F999F9F5"
;20706 DATA "FFF9FFF5"
	db $ff,$f9,$f9,$99,$ff,$f9,$ff,$55
;20707 DATA "99999995"
;20708 DATA "55555555"
	db $59,$59,$59,$59,$59,$59,$59,$55
tile_256
;20800 REM 2^8="256"
;20801 DATA "11111115"
;20802 DATA "FFF1FFF5"
	db $1f,$1f,$1f,$11,$1f,$1f,$1f,$55
;20803 DATA "F111F115"
;20804 DATA "FFF1FFF5"
	db $ff,$1f,$1f,$11,$ff,$1f,$1f,$55
;20805 DATA "11F1F1F5"
;20806 DATA "FFF1FFF5"
	db $1f,$1f,$ff,$11,$ff,$1f,$ff,$55
;20807 DATA "11111115"
;20808 DATA "55555555"
	db $15,$15,$15,$15,$15,$15,$15,$55
tile_512
;20900 REM 2^9="512"
;20901 DATA "11111115"
;20902 DATA "1F1FFF15"
	db $11,$f1,$11,$f1,$f1,$f1,$11,$55
;20903 DATA "1F111F15"
;20904 DATA "1F1FFF15"
	db $11,$ff,$11,$f1,$f1,$ff,$11,$55
;20905 DATA "1F1F1115"
;20906 DATA "1F1FFF15"
	db $11,$ff,$11,$ff,$f1,$f1,$11,$55
;20907 DATA "11111115"
;20908 DATA "55555555"
	db $51,$51,$51,$51,$51,$51,$51,$55
tile_1024
;21000 REM 2^10="1024"->24
;21001 DATA "88888885"
;21002 DATA "FFF8F8F5"
	db $f8,$f8,$f8,$88,$f8,$88,$f8,$55
;21003 DATA "88F8F8F5"
;21004 DATA "FFF8FFF5"
	db $f8,$f8,$ff,$88,$ff,$f8,$ff,$55
;21005 DATA "F88888F5"
;21006 DATA "FFF888F5"
	db $ff,$f8,$f8,$88,$88,$88,$ff,$55
;21007 DATA "88888885"
;21008 DATA "55555555"
	db $58,$58,$58,$58,$58,$58,$58,$55
tile_2048
;21100 REM 2^11="2048"->48
;21101 DATA "88888885"
;21102 DATA "F8F8FFF5"
	db $f8,$88,$f8,$88,$f8,$f8,$f8,$55
;21103 DATA "F8F8F8F5"
;21104 DATA "FFF8FFF5"
	db $ff,$f8,$ff,$88,$ff,$f8,$ff,$55
;21105 DATA "88F8F8F5"
;21106 DATA "88F8FFF5"
	db $88,$88,$ff,$88,$ff,$f8,$ff,$55
;21107 DATA "88888885"
;21108 DATA "55555555"
	db $58,$58,$58,$58,$58,$58,$58,$55
tile_4096
;21200 REM 2^12="4096"->96
;21201 DATA "00000005"
;21202 DATA "FFF0FFF5"
	db $f0,$f0,$f0,$00,$f0,$f0,$f0,$55
;21203 DATA "F0F0F005"
;21204 DATA "FFF0FFF5"
	db $ff,$f0,$ff,$00,$ff,$f0,$f0,$55
;21205 DATA "00F0F0F5"
;21206 DATA "FFF0FFF5"
	db $f0,$f0,$ff,$00,$ff,$f0,$ff,$55
;21207 DATA "00000005"
;21208 DATA "55555555"
	db $50,$50,$50,$50,$50,$50,$50,$55
tile_8192
;21300 REM 2^13="8192"->92
;21301 DATA "00000005"
;21302 DATA "FFF0FFF5"
	db $f0,$f0,$f0,$00,$f0,$f0,$f0,$55
;21303 DATA "F0F000F5"
;21304 DATA "FFF0FFF5"
	db $ff,$f0,$ff,$00,$f0,$f0,$ff,$55
;21305 DATA "00F0F005"
;21306 DATA "FFF0FFF5"
	db $f0,$f0,$ff,$00,$ff,$f0,$f0,$55
;21307 DATA "00000005"
;21308 DATA "55555555"
	db $50,$50,$50,$50,$50,$50,$50,$55

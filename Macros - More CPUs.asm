; ---------------------------------------------------------------------------
; Change CPU
; ---------------------------------------------------------------------------

cpu:		macro
		if strcmp("\1","z80")
		cpu_mode:	= 1	; Z80
		opt	an+		; 1234h style numbering
		else
		cpu_mode:	= 0	; 68000 by default
		opt	an-		; $1234 style numbering
		endc
		endm

; ---------------------------------------------------------------------------
; Z80 instruction set
; ---------------------------------------------------------------------------

getzreg:	macro		; convert register to numerical value
		if strcmp("\1","a")
		zreg: = 7
		elseif strcmp("\1","b")
		zreg: = 0
		elseif strcmp("\1","c")
		zreg: = 1
		elseif strcmp("\1","d")
		zreg: = 2
		elseif strcmp("\1","e")
		zreg: = 3
		elseif strcmp("\1","h")
		zreg: = 4
		elseif strcmp("\1","l")
		zreg: = 5
		elseif strcmp("\1","(hl)")
		zreg: = 6
		else
		endc
		endm

ix:		equ 0		; allows (ix+n) to be parsed as n
iy:		equ 0


adc:		macro
		if strcmp("\1","a")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $88+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd8c
			elseif strcmp("\2","ixl")
			dc.w $dd8d
			elseif strcmp("\2","iyh")
			dc.w $fd8c
			elseif strcmp("\2","iyl")
			dc.w $fd8d
			else
				if instr("\2","(ix")	; adc a,(ix+n)
				dc.b $dd, $8e, \2
				elseif instr("\2","(iy") ; adc a,(iy+n)
				dc.b $fd, $8e, \2
				else			; adc a,n
				dc.b $ce, \2
				endc
			endc
		else
			if strcmp("\2","bc")
			dc.w $ed4a
			elseif strcmp("\2","de")
			dc.w $ed5a
			elseif strcmp("\2","hl")
			dc.w $ed6a
			else		; adc hl,sp
			dc.w $ed7a
			endc
		endc
		endm


bit:		macro
		if instr("a b c d e h l (hl) ","\2\ ")
		getzreg	\2
		dc.b $cb, $40+(\1*8)+zreg
		else
			if instr("\2","(ix")	; bit n,(ix+n)
			dc.b $dd, $cb, \2, $40+(\1*8)
			else			; bit n,(iy+n)
			dc.b $fd, $cb, \2, $40+(\1*8)
			endc
		endc
		endm


call:		macro
		if strcmp("\1","nz")
		dc.b $c4, \2&$ff, \2>>8
		elseif strcmp("\1","z")
		dc.b $cc, \2&$ff, \2>>8
		elseif strcmp("\1","nc")
		dc.b $d4, \2&$ff, \2>>8
		elseif strcmp("\1","c")
		dc.b $dc, \2&$ff, \2>>8
		elseif strcmp("\1","po")
		dc.b $e4, \2&$ff, \2>>8
		elseif strcmp("\1","pe")
		dc.b $ec, \2&$ff, \2>>8
		elseif strcmp("\1","p")
		dc.b $f4, \2&$ff, \2>>8
		elseif strcmp("\1","m")
		dc.b $fc, \2&$ff, \2>>8
		else		; call n
		dc.b $cd, \1&$ff, \1>>8
		endc
		endm

ccf:		macros
		dc.b $3f


cp:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $b8+zreg
		elseif strcmp("\1","ixh")
		dc.w $ddbc
		elseif strcmp("\1","ixl")
		dc.w $ddbd
		elseif strcmp("\1","iyh")
		dc.w $fdbc
		elseif strcmp("\1","iyl")
		dc.w $fdbd
		else
			if instr("\1","(ix")	; cp (ix+n)
			dc.b $dd, $be, \1
			elseif instr("\1","(iy") ; cp (iy+n)
			dc.b $fd, $be, \1
			else			; cp n
			dc.b $fe, \1
			endc
		endc
		endm


cpd:		macros
		dc.w $eda9


cpdr:		macros
		dc.w $edb9


cpi:		macros
		dc.w $eda1


cpir:		macros
		dc.w $edb1


cpl:		macros
		dc.b $2f


daa:		macros
		dc.b $27


dec:		macro
		if strcmp("\1","a")
		dc.b $3d
		elseif strcmp("\1","b")
		dc.b $5
		elseif strcmp("\1","c")
		dc.b $d
		elseif strcmp("\1","d")
		dc.b $15
		elseif strcmp("\1","e")
		dc.b $1d
		elseif strcmp("\1","h")
		dc.b $25
		elseif strcmp("\1","l")
		dc.b $2d
		elseif strcmp("\1","ixh")
		dc.w $dd25
		elseif strcmp("\1","ixl")
		dc.w $dd2d
		elseif strcmp("\1","iyh")
		dc.w $fd25
		elseif strcmp("\1","iyl")
		dc.w $fd2d
		elseif strcmp("\1","bc")
		dc.b $b
		elseif strcmp("\1","de")
		dc.b $1b
		elseif strcmp("\1","hl")
		dc.b $2b
		elseif strcmp("\1","ix")
		dc.w $dd2b
		elseif strcmp("\1","iy")
		dc.w $fd2b
		elseif strcmp("\1","sp")
		dc.b $3b
		else
			if instr("\1","(ix")	; dec (ix+n)
			dc.b $dd, $35, \1
			else			; dec (iy+n)
			dc.b $fd, $35, \1
			endc
		endc
		endm


di:		macros
		dc.b $f3


djnz:		macros
		dc.b $10, \1-*-2


ei:		macros
		dc.b $fb


ex:		macro
		if strcmp("\1","af")	; ex af,af'
		dc.b 8
		elseif strcmp("\1","(sp)")
			if strcmp("\2","hl")
			dc.b $e3
			elseif strcmp("\2","ix")
			dc.w $dde3
			else		; ex (sp),iy
			dc.w $fde3
			endc
		else			; ex de,hl
		dc.b $eb
		endc
		endm

exx:		macros
		dc.b $d9


halt:		macros
		dc.b $76


im:		macro
		if strcmp("\1","0")
		dc.w $ed46
		elseif strcmp("\1","1")
		dc.w $ed56
		else		; im 2
		dc.w $ed5e
		endc
		endm


in:		macro
		if strcmp("\1","a")
			if strcmp("\2","(c)")
			dc.w $ed78
			else		; in a,n
			dc.b $db, \2
			endc
		elseif strcmp("\1","b")
		dc.w $ed40
		elseif strcmp("\1","c")
		dc.w $ed48
		elseif strcmp("\1","d")
		dc.w $ed50
		elseif strcmp("\1","e")
		dc.w $ed58
		elseif strcmp("\1","h")
		dc.w $ed60
		elseif strcmp("\1","l")
		dc.w $ed68
		else		; in (c)
		dc.w $ed70
		endc
		endm


inc:		macro
		if strcmp("\1","a")
		dc.b $3c
		elseif strcmp("\1","b")
		dc.b $4
		elseif strcmp("\1","c")
		dc.b $c
		elseif strcmp("\1","d")
		dc.b $14
		elseif strcmp("\1","e")
		dc.b $1c
		elseif strcmp("\1","h")
		dc.b $24
		elseif strcmp("\1","l")
		dc.b $2c
		elseif strcmp("\1","ixh")
		dc.w $dd24
		elseif strcmp("\1","ixl")
		dc.w $dd2c
		elseif strcmp("\1","iyh")
		dc.w $fd24
		elseif strcmp("\1","iyl")
		dc.w $fd2c
		elseif strcmp("\1","bc")
		dc.b $3
		elseif strcmp("\1","de")
		dc.b $13
		elseif strcmp("\1","hl")
		dc.b $23
		elseif strcmp("\1","ix")
		dc.w $dd23
		elseif strcmp("\1","iy")
		dc.w $fd23
		elseif strcmp("\1","sp")
		dc.b $33
		else
			if instr("\1","(ix")	; dec (ix+n)
			dc.b $dd, $34, \1
			else			; dec (iy+n)
			dc.b $fd, $34, \1
			endc
		endc
		endm


ind:		macros
		dc.w $edaa


indr:		macros
		dc.w $edba


ini:		macros
		dc.w $eda2


inir:		macros
		dc.w $edb2


jp:		macro
		if strcmp("\1","nz")
		dc.b $c2, \2&$ff, \2>>8
		elseif strcmp("\1","z")
		dc.b $ca, \2&$ff, \2>>8
		elseif strcmp("\1","nc")
		dc.b $d2, \2&$ff, \2>>8
		elseif strcmp("\1","c")
		dc.b $da, \2&$ff, \2>>8
		elseif strcmp("\1","po")
		dc.b $e2, \2&$ff, \2>>8
		elseif strcmp("\1","pe")
		dc.b $ea, \2&$ff, \2>>8
		elseif strcmp("\1","p")
		dc.b $f2, \2&$ff, \2>>8
		elseif strcmp("\1","m")
		dc.b $fa, \2&$ff, \2>>8
		elseif strcmp("\1","(hl)")
		dc.b $e9
		elseif strcmp("\1","(ix)")
		dc.w $dde9
		elseif strcmp("\1","(iy)")
		dc.w $fde9
		else		; jp n
		dc.b $c3, \1&$ff, \1>>8
		endc
		endm


jr:		macro
		if strcmp("\1","nz")
		dc.b $20, \2-*-2
		elseif strcmp("\1","z")
		dc.b $28, \2-*-2
		elseif strcmp("\1","nc")
		dc.b $30, \2-*-2
		elseif strcmp("\1","c")
		dc.b $38, \2-*-2
		else		; jr n
		dc.b $18, \1-*-2
		endc
		endm


ld:		macro
		if strcmp("\1","a")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $78+zreg
			elseif strcmp("\2","i")
			dc.w $ed57
			elseif strcmp("\2","r")
			dc.w $ed5f
			elseif strcmp("\2","ixh")
			dc.w $dd7c
			elseif strcmp("\2","ixl")
			dc.w $dd7d
			elseif strcmp("\2","iyh")
			dc.w $fd7c
			elseif strcmp("\2","iyl")
			dc.w $fd7d
			elseif strcmp("\2","(bc)")
			dc.b $0a
			elseif strcmp("\2","(de)")
			dc.b $1a
			else
				if instr("\2","(ix")	; ld a,(ix+n)
				dc.b $dd, $7e, \2
				elseif instr("\2","(iy") ; ld a,(iy+n)
				dc.b $fd, $7e, \2
				else
					tmp_len: = strlen("\2")
					tmp_fc:	substr	1,1,"\2"
					tmp_lc:	substr	tmp_len,tmp_len,"\2"
					if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld a,(n)
					dc.b $3a, \2&$ff, \2>>8
					else			; ld a,n
					dc.b $3e, \2
					endc
				endc
			endc
		elseif strcmp("\1","b")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $40+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd44
			elseif strcmp("\2","ixl")
			dc.w $dd45
			elseif strcmp("\2","iyh")
			dc.w $fd44
			elseif strcmp("\2","iyl")
			dc.w $fd45
			else
				if instr("\2","(ix")	; ld b,(ix+n)
				dc.b $dd, $46, \2
				elseif instr("\2","(iy") ; ld b,(iy+n)
				dc.b $fd, $46, \2
				else			; ld b,n
				dc.b $6, \2
				endc
			endc
		elseif strcmp("\1","c")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $48+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd4c
			elseif strcmp("\2","ixl")
			dc.w $dd4d
			elseif strcmp("\2","iyh")
			dc.w $fd4c
			elseif strcmp("\2","iyl")
			dc.w $fd4d
			else
				if instr("\2","(ix")	; ld c,(ix+n)
				dc.b $dd, $4e, \2
				elseif instr("\2","(iy") ; ld c,(iy+n)
				dc.b $fd, $4e, \2
				else			; ld c,n
				dc.b $e, \2
				endc
			endc
		elseif strcmp("\1","d")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $50+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd54
			elseif strcmp("\2","ixl")
			dc.w $dd55
			elseif strcmp("\2","iyh")
			dc.w $fd54
			elseif strcmp("\2","iyl")
			dc.w $fd55
			else
				if instr("\2","(ix")	; ld d,(ix+n)
				dc.b $dd, $56, \2
				elseif instr("\2","(iy") ; ld d,(iy+n)
				dc.b $fd, $56, \2
				else			; ld d,n
				dc.b $16, \2
				endc
			endc
		elseif strcmp("\1","e")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $58+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd5c
			elseif strcmp("\2","ixl")
			dc.w $dd5d
			elseif strcmp("\2","iyh")
			dc.w $fd5c
			elseif strcmp("\2","iyl")
			dc.w $fd5d
			else
				if instr("\2","(ix")	; ld e,(ix+n)
				dc.b $dd, $5e, \2
				elseif instr("\2","(iy") ; ld e,(iy+n)
				dc.b $fd, $5e, \2
				else			; ld e,n
				dc.b $1e, \2
				endc
			endc
		elseif strcmp("\1","h")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $60+zreg
			else
				if instr("\2","(ix")	; ld h,(ix+n)
				dc.b $dd, $66, \2
				elseif instr("\2","(iy") ; ld h,(iy+n)
				dc.b $fd, $66, \2
				else			; ld h,n
				dc.b $26, \2
				endc
			endc
		elseif strcmp("\1","l")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $68+zreg
			else
				if instr("\2","(ix")	; ld l,(ix+n)
				dc.b $dd, $6e, \2
				elseif instr("\2","(iy") ; ld l,(iy+n)
				dc.b $fd, $6e, \2
				else			; ld l,n
				dc.b $2e, \2
				endc
			endc
		elseif strcmp("\1","i")
		dc.w $ed47
		elseif strcmp("\1","r")
		dc.w $ed4f
		elseif strcmp("\1","ixh")
			if instr("a b c d e ","\2\ ")
			getzreg	\2
			dc.w $dd60+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd64
			elseif strcmp("\2","ixl")
			dc.w $dd65
			else			; ld ixh,n
			dc.b $dd, $26, \2
			endc
		elseif strcmp("\1","ixl")
			if instr("a b c d e ","\2\ ")
			getzreg	\2
			dc.w $dd68+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd6c
			elseif strcmp("\2","ixl")
			dc.w $dd6d
			else			; ld ixl,n
			dc.b $dd, $2e, \2
			endc
		elseif strcmp("\1","iyh")
			if instr("a b c d e ","\2\ ")
			getzreg	\2
			dc.w $fd60+zreg
			elseif strcmp("\2","iyh")
			dc.w $fd64
			elseif strcmp("\2","iyl")
			dc.w $fd65
			else			; ld iyh,n
			dc.b $fd, $26, \2
			endc
		elseif strcmp("\1","iyl")
			if instr("a b c d e ","\2\ ")
			getzreg	\2
			dc.w $fd68+zreg
			elseif strcmp("\2","iyh")
			dc.w $fd6c
			elseif strcmp("\2","iyl")
			dc.w $fd6d
			else			; ld iyl,n
			dc.b $fd, $2e, \2
			endc
		elseif strcmp("\1","bc")
			tmp_len: = strlen("\2")
			tmp_fc:	substr	1,1,"\2"
			tmp_lc:	substr	tmp_len,tmp_len,"\2"
			if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld bc,(n)
			dc.b $ed, $4b, \2&$ff, \2>>8
			else			; ld bc,n
			dc.b $1, \2&$ff, \2>>8
			endc
		elseif strcmp("\1","de")
			tmp_len: = strlen("\2")
			tmp_fc:	substr	1,1,"\2"
			tmp_lc:	substr	tmp_len,tmp_len,"\2"
			if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld de,(n)
			dc.b $ed, $5b, \2&$ff, \2>>8
			else			; ld de,n
			dc.b $11, \2&$ff, \2>>8
			endc
		elseif strcmp("\1","hl")
			tmp_len: = strlen("\2")
			tmp_fc:	substr	1,1,"\2"
			tmp_lc:	substr	tmp_len,tmp_len,"\2"
			if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld hl,(n)
			dc.b $ed, $6b, \2&$ff, \2>>8
			else			; ld hl,n
			dc.b $21, \2&$ff, \2>>8
			endc
		elseif strcmp("\1","sp")
			if strcmp("\2","hl")
			dc.b $f9
			elseif strcmp("\2","ix")
			dc.w $ddf9
			elseif strcmp("\2","iy")
			dc.w $fdf9
			else
				tmp_len: = strlen("\2")
				tmp_fc:	substr	1,1,"\2"
				tmp_lc:	substr	tmp_len,tmp_len,"\2"
				if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld sp,(n)
				dc.b $ed, $7b, \2&$ff, \2>>8
				else			; ld sp,n
				dc.b $31, \2&$ff, \2>>8
				endc
			endc
		elseif strcmp("\1","ix")
			tmp_len: = strlen("\2")
			tmp_fc:	substr	1,1,"\2"
			tmp_lc:	substr	tmp_len,tmp_len,"\2"
			if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld ix,(n)
			dc.b $dd, $2a, \2&$ff, \2>>8
			else			; ld ix,n
			dc.b $dd, $21, \2&$ff, \2>>8
			endc
		elseif strcmp("\1","iy")
			tmp_len: = strlen("\2")
			tmp_fc:	substr	1,1,"\2"
			tmp_lc:	substr	tmp_len,tmp_len,"\2"
			if strcmp("\tmp_fc","(") & strcmp("\tmp_lc",")") ; ld iy,(n)
			dc.b $fd, $2a, \2&$ff, \2>>8
			else			; ld iy,n
			dc.b $fd, $21, \2&$ff, \2>>8
			endc
		elseif strcmp("\1","(bc)")
		dc.b 2
		elseif strcmp("\1","(de)")
		dc.b $12
		elseif strcmp("\1","(hl)")
			if instr("a b c d e h l ","\2\ ")
			getzreg	\2
			dc.b $70+zreg
			else			; ld (hl),n
			dc.b $36, \2
			endc
		else
			if instr("\1","(ix")	; ld (ix+n),?
				if instr("a b c d e h l ","\2\ ")
				getzreg	\2
				dc.b $dd, $70+zreg, \1
				else			; ld (ix+n),n
				dc.b $dd, $36, \1, \2
				endc
			elseif instr("\1","(iy") ; ld (iy+n),?
				if instr("a b c d e h l ","\2\ ")
				getzreg	\2
				dc.b $fd, $70+zreg, \1
				else			; ld (iy+n),n
				dc.b $fd, $36, \1, \2
				endc
			else			; ld n,?
				if strcmp("\2","a")
				dc.b $32, \1&$ff, \1>>8
				elseif strcmp("\2","bc")
				dc.b $ed, $43, \1&$ff, \1>>8
				elseif strcmp("\2","de")
				dc.b $ed, $53, \1&$ff, \1>>8
				elseif strcmp("\2","hl")
				dc.b $ed, $63, \1&$ff, \1>>8
				elseif strcmp("\2","sp")
				dc.b $ed, $73, \1&$ff, \1>>8
				elseif strcmp("\2","ix")
				dc.b $dd, $22, \1&$ff, \1>>8
				else			; ld (n),iy
				dc.b $fd, $22, \1&$ff, \1>>8
				endc
			endc
		endc
		endm


ldd:		macros
		dc.w $eda8


lddr:		macros
		dc.w $edb8


ldi:		macros
		dc.w $eda0


ldir:		macros
		dc.w $edb0


otdr:		macros
		dc.w $edbb


otir:		macros
		dc.w $edb3


out:		macro
		if strcmp("\1","(c)")
			if strcmp("\2","a")
			dc.w $ed79
			elseif strcmp("\2","b")
			dc.w $ed41
			elseif strcmp("\2","c")
			dc.w $ed49
			elseif strcmp("\2","d")
			dc.w $ed51
			elseif strcmp("\2","e")
			dc.w $ed59
			elseif strcmp("\2","h")
			dc.w $ed61
			elseif strcmp("\2","l")
			dc.w $ed69
			else		; out (c),0
			dc.w $ed71
			endc
		else			; out n,a
		dc.b $d3, \1
		endc
		endm


outd:		macros
		dc.w $edab


outi:		macros
		dc.w $eda3


pop:		macro
		if strcmp("\1","bc")
		dc.b $c1
		elseif strcmp("\1","de")
		dc.b $d1
		elseif strcmp("\1","hl")
		dc.b $e1
		elseif strcmp("\1","af")
		dc.b $f1
		elseif strcmp("\1","ix")
		dc.w $dde1
		else			; pop iy
		dc.w $fde1
		endc
		endm


push:		macro
		if strcmp("\1","bc")
		dc.b $c5
		elseif strcmp("\1","de")
		dc.b $d5
		elseif strcmp("\1","hl")
		dc.b $e5
		elseif strcmp("\1","af")
		dc.b $f5
		elseif strcmp("\1","ix")
		dc.w $fde5
		else			; push iy
		dc.w $fde5
		endc
		endm


res:		macro
		if instr("a b c d e h l (hl) ","\2\ ")
		getzreg	\2
		dc.b $cb, $80+(\1*8)+zreg
		else
			if instr("\2","(ix")	; res n,(ix+n)
			dc.b $dd, $cb, \2, $80+(\1*8)
			else			; res n,(iy+n)
			dc.b $fd, $cb, \2, $80+(\1*8)
			endc
		endc
		endm


ret:		macro
		if strcmp("\1","nz")
		dc.b $c0
		elseif strcmp("\1","z")
		dc.b $c8
		elseif strcmp("\1","nc")
		dc.b $d0
		elseif strcmp("\1","c")
		dc.b $d8
		elseif strcmp("\1","po")
		dc.b $e0
		elseif strcmp("\1","pe")
		dc.b $e8
		elseif strcmp("\1","p")
		dc.b $f0
		elseif strcmp("\1","m")
		dc.b $f8
		else		; ret
		dc.b $c9
		endc
		endm


reti:		macros
		dc.w $ed4d


retn:		macros
		dc.w $ed45


rl:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $10+zreg
		else
			if instr("\1","(ix")	; rl (ix+n)
			dc.b $dd, $cb, \1
				if narg = 2	; rl (ix+n),?
				getzreg	\2
				dc.b $10+zreg
				else
				dc.b $16
				endc
			else			; rl (iy+n)
			dc.b $fd, $cb, \1
				if narg = 2	; rl (iy+n),?
				getzreg	\2
				dc.b $10+zreg
				else
				dc.b $16
				endc
			endc
		endc
		endm


rla:		macros
		dc.b $17


rlc:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, zreg
		else
			if instr("\1","(ix")	; rlc (ix+n)
			dc.b $dd, $cb, \1
				if narg = 2	; rlc (ix+n),?
				getzreg	\2
				dc.b zreg
				else
				dc.b $6
				endc
			else			; rlc (iy+n)
			dc.b $fd, $cb, \1
				if narg = 2	; rlc (iy+n),?
				getzreg	\2
				dc.b zreg
				else
				dc.b $6
				endc
			endc
		endc
		endm


rlca:		macros
		dc.b $7


rld:		macros
		dc.w $ed6f


rr:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $18+zreg
		else
			if instr("\1","(ix")	; rr (ix+n)
			dc.b $dd, $cb, \1
				if narg = 2	; rr (ix+n),?
				getzreg	\2
				dc.b $18+zreg
				else
				dc.b $1e
				endc
			else			; rr (iy+n)
			dc.b $fd, $cb, \1
				if narg = 2	; rr (iy+n),?
				getzreg	\2
				dc.b $18+zreg
				else
				dc.b $1e
				endc
			endc
		endc
		endm


rra:		macros
		dc.b $1f


rrc:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $8+zreg
		else
			if instr("\1","(ix")	; rrc (ix+n)
			dc.b $dd, $cb, \1
				if narg = 2	; rrc (ix+n),?
				getzreg	\2
				dc.b $8+zreg
				else
				dc.b $e
				endc
			else			; rrc (iy+n)
			dc.b $fd, $cb, \1
				if narg = 2	; rrc (iy+n),?
				getzreg	\2
				dc.b $8+zreg
				else
				dc.b $e
				endc
			endc
		endc
		endm


rrca:		macros
		dc.b $f


rrd:		macros
		dc.w $ed67


rst:		macros
		dc.b $c7+(\1&$38)


sbc:		macro
		if strcmp("\1","a")
			if instr("a b c d e h l (hl) ","\2\ ")
			getzreg	\2
			dc.b $98+zreg
			elseif strcmp("\2","ixh")
			dc.w $dd9c
			elseif strcmp("\2","ixl")
			dc.w $dd9d
			elseif strcmp("\2","iyh")
			dc.w $fd9c
			elseif strcmp("\2","iyl")
			dc.w $fd9d
			else
				if instr("\2","(ix")	; sbc a,(ix+n)
				dc.b $dd, $9e, \2
				elseif instr("\2","(iy") ; sbc a,(iy+n)
				dc.b $fd, $9e, \2
				else			; sbc a,n
				dc.b $de, \2
				endc
			endc
		else
			if strcmp("\2","bc")
			dc.w $ed42
			elseif strcmp("\2","de")
			dc.w $ed52
			elseif strcmp("\2","hl")
			dc.w $ed62
			else		; sbc hl,sp
			dc.w $ed72
			endc
		endc
		endm


scf:		macros
		dc.b $37


set:		macro
		if instr("a b c d e h l (hl) ","\2\ ")
		getzreg	\2
		dc.b $cb, $c0+(\1*8)+zreg
		else
			if instr("\2","(ix")	; set n,(ix+n)
			dc.b $dd, $cb, \2, $c0+(\1*8)
			else			; set n,(iy+n)
			dc.b $fd, $cb, \2, $c0+(\1*8)
			endc
		endc
		endm


sla:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $20+zreg
		else
			if instr("\1","(ix")
			dc.b $dd, $cb, \1
				if narg = 2	; sla (ix+n),?
				getzreg	\2
				dc.b $20+zreg
				else		; sla (ix+n)
				dc.b $26
				endc
			else
			dc.b $fd, $cb, \1
				if narg = 2	; sla (ix+n),?
				getzreg	\2
				dc.b $20+zreg
				else		; sla (iy+n)
				dc.b $26
				endc
			endc
		endc
		endm


sll:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $30+zreg
		else
			if instr("\1","(ix")
			dc.b $dd, $cb, \1
				if narg = 2	; sll (ix+n),?
				getzreg	\2
				dc.b $30+zreg
				else		; sll (ix+n)
				dc.b $36
				endc
			else
			dc.b $fd, $cb, \1
				if narg = 2	; sll (ix+n),?
				getzreg	\2
				dc.b $30+zreg
				else		; sll (iy+n)
				dc.b $36
				endc
			endc
		endc
		endm


sra:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $28+zreg
		else
			if instr("\1","(ix")
			dc.b $dd, $cb, \1
				if narg = 2	; sra (ix+n),?
				getzreg	\2
				dc.b $28+zreg
				else		; sra (ix+n)
				dc.b $2e
				endc
			else
			dc.b $fd, $cb, \1
				if narg = 2	; sra (ix+n),?
				getzreg	\2
				dc.b $28+zreg
				else		; sra (iy+n)
				dc.b $2e
				endc
			endc
		endc
		endm


srl:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $cb, $38+zreg
		else
			if instr("\1","(ix")
			dc.b $dd, $cb, \1
				if narg = 2	; srl (ix+n),?
				getzreg	\2
				dc.b $38+zreg
				else		; srl (ix+n)
				dc.b $3e
				endc
			else
			dc.b $fd, $cb, \1
				if narg = 2	; srl (ix+n),?
				getzreg	\2
				dc.b $38+zreg
				else		; srl (iy+n)
				dc.b $3e
				endc
			endc
		endc
		endm


xor:		macro
		if instr("a b c d e h l (hl) ","\1\ ")
		getzreg	\1
		dc.b $a8+zreg
		elseif strcmp("\1","ixh")
		dc.w $ddac
		elseif strcmp("\1","ixl")
		dc.w $ddad
		elseif strcmp("\1","iyh")
		dc.w $fdac
		elseif strcmp("\1","iyl")
		dc.w $fdad
		else
			if instr("\1","(ix")	; xor (ix+n)
			dc.b $dd, $ae, \1
			elseif instr("\1","(iy") ; xor (iy+n)
			dc.b $fd, $ae, \1
			else			; xor n
			dc.b $ee, \1
			endc
		endc
		endm


db:		macros
		dc.b \_


dw:		macro
		rept narg
		dc.b \1&$ff, \1>>8
		shift
		endr
		endm

; ---------------------------------------------------------------------------
; Mixed instruction set
; ---------------------------------------------------------------------------

add:		macro
		if cpu_mode=1		; Z80
			if strcmp("\1","a")
				if instr("a b c d e h l (hl) ","\2\ ")
				getzreg	\2
				dc.b $80+zreg
				elseif strcmp("\2","ixh")
				dc.w $dd84
				elseif strcmp("\2","ixl")
				dc.w $dd85
				elseif strcmp("\2","iyh")
				dc.w $fd84
				elseif strcmp("\2","iyl")
				dc.w $fd85
				else
					if instr("\2","(ix")	; add a,(ix+n)
					dc.b $dd, $86, \2
					elseif instr("\2","(iy") ; add a,(iy+n)
					dc.b $fd, $86, \2
					else			; add a,n
					dc.b $c6, \2
					endc
				endc
			elseif strcmp("\1","hl")
				if strcmp("\2","bc")
				dc.b $9
				elseif strcmp("\2","de")
				dc.b $19
				elseif strcmp("\2","hl")
				dc.b $29
				else		; add hl,sp
				dc.b $39
				endc
			elseif strcmp("\1","ix")
				if strcmp("\2","bc")
				dc.w $dd09
				elseif strcmp("\2","de")
				dc.w $dd19
				elseif strcmp("\2","ix")
				dc.w $dd29
				else		; add ix,sp
				dc.w $dd39
				endc
			else
				if strcmp("\2","bc")
				dc.w $fd09
				elseif strcmp("\2","de")
				dc.w $fd19
				elseif strcmp("\2","iy")
				dc.w $fd29
				else		; add iy,sp
				dc.w $fd39
				endc
			endc
		else			; 68k
		axd.\0	\_
		endc
		endm


and:		macro
		if cpu_mode=1		; Z80
			if instr("a b c d e h l (hl) ","\1\ ")
			getzreg	\2
			dc.b $a0+zreg
			elseif strcmp("\1","ixh")
			dc.w $dda4
			elseif strcmp("\1","ixl")
			dc.w $dda5
			elseif strcmp("\1","iyh")
			dc.w $fda4
			elseif strcmp("\1","iyl")
			dc.w $fda5
			else
				if instr("\1","(ix")	; and (ix+n)
				dc.b $dd, $a6, \1
				elseif instr("\1","(iy") ; and (iy+n)
				dc.b $fd, $a6, \1
				else			; and n
				dc.b $e6, \1
				endc
			endc
		else			; 68k
		anx.\0	\_
		endc
		endm


neg:		macro
		if cpu_mode=1		; Z80
		dc.w $ed44
		else			; 68k
		nxg
		endc
		endm


nop:		macro
		if cpu_mode=1		; Z80
		dc.b 0
		else			; 68k
		nxp
		endc
		endm


or:		macro
		if cpu_mode=1		; Z80
			if instr("a b c d e h l (hl) ","\1\ ")
			getzreg	\1
			dc.b $b0+zreg
			elseif strcmp("\1","ixh")
			dc.w $ddb4
			elseif strcmp("\1","ixl")
			dc.w $ddb5
			elseif strcmp("\1","iyh")
			dc.w $fdb4
			elseif strcmp("\1","iyl")
			dc.w $fdb5
			else
				if instr("\1","(ix")	; or (ix+n)
				dc.b $dd, $b6, \1
				elseif instr("\1","(iy") ; or (iy+n)
				dc.b $fd, $b6, \1
				else			; or n
				dc.b $f6, \1
				endc
			endc
		else			; 68k
		ox.\0	\_
		endc
		endm


sub:		macro
		if cpu_mode=1		; Z80
			if instr("a b c d e h l (hl) ","\1\ ")
			getzreg	\2
			dc.b $90+zreg
			elseif strcmp("\1","ixh")
			dc.w $dd94
			elseif strcmp("\1","ixl")
			dc.w $dd95
			elseif strcmp("\1","iyh")
			dc.w $fd94
			elseif strcmp("\1","iyl")
			dc.w $fd95
			else
				if instr("\1","(ix")	; sub (ix+n)
				dc.b $dd, $96, \1
				elseif instr("\1","(iy") ; sub (iy+n)
				dc.b $fd, $96, \1
				else			; sub n
				dc.b $d6, \1
				endc
			endc
		else			; 68k
		sxb.\0	\_
		endc
		endm

; ---------------------------------------------------------------------------
; Restored ASM68k instruction set
; ---------------------------------------------------------------------------

adda:		macros
		axda.\0	\_

addi:		macros
		axdi.\0	\_

addq:		macros
		axdq.\0	\_

addx:		macros
		axdx.\0	\_

andi:		macros
		anxi.\0	\_

negx:		macros
		nxgx.\0	\_

ori:		macros
		oxi.\0	\_

suba:		macros
		sxba.\0	\_

subi:		macros
		sxbi.\0	\_

subq:		macros
		sxbq.\0	\_

subx:		macros
		sxbx.\0	\_
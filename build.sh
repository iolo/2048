#!/bin/bash
DIMG="2048.dsk"
BAS=(text2048 gr2048 grx2048 dgr2048 dgrx2048)
ASM=(grx dgrx)

build_bas() {
	echo "Building $1.abas..."
	a2kit verify -t atxt < $1
	a2kit delete -d ${DIMG} -f $1
	a2kit tokenize -t atxt -a 2049 < $1.abas | a2kit put -d ${DIMG} -t atok -f $1
}

build_asm() {
	echo "Building $1.s..."
	Merlin32 -V "" $1.s
	a2kit delete -d ${DIMG} -f $1
	a2kit put -d ${DIMG} -f $1 -t bin -a 6000 < $1
}

for f in "${BAS[@]}"; do
	build_bas ${f}
done

for f in "${ASM[@]}"; do
	build_asm ${f}
done

a2kit catalog -d 2048.dsk
#sa2 --d1 2048.dsk

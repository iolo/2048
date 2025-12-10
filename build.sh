#!/bin/bash
#BAS=text2048
#BAS=gr2048
#BAS=grx2048
BAS=dgr2048
a2kit verify -t atxt < ${BAS}
a2kit catalog -d 2048.dsk
a2kit delete -d 2048.dsk -f ${BAS}
# xclip -selection clipboard < ${BAS}.abas
# wl-copy < ${BAS}.abas
a2kit tokenize -t atxt -a 2049 < ${BAS}.abas | a2kit put -d 2048.dsk -t atok -f ${BAS}
a2kit catalog -d 2048.dsk
#sa2 --d1 2048.sdk

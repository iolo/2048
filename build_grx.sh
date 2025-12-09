#!/bin/bash
Merlin32 -V "" grx.s
a2kit catalog -d 2048.dsk
a2kit delete -d 2048.dsk -f grx
a2kit put -d 2048.dsk -f grx -t bin -a 6000 < grx
a2kit catalog -d 2048.dsk

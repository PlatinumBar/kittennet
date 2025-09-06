#!/bin/bash
R=$RANDOM
cat $1 | luac5.3 -s -o - - | luac5.3 -l -l -p -
cat $1 | luac5.3 -s -o /tmp/$R.lua.lco - 
xxd /tmp/$R.lua.lco

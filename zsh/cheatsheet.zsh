#!/bin/zsh

set -x

# For my own and others sanity

# Array

arr=(a b c)

# (Ie) Get index of a value in an array (0 if not found)
print ${arr[(Ie)d]}
print ${arr[(Ie)c]}

# (ie) Get index of a value in an array (array size + 1 if not found)
print ${arr[(ie)d]}
print ${arr[(ie)c]}

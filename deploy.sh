#!/bin/bash

shopt -s globstar
cd $(dirname $0)/root
rm -rf ../dist
mkdir ../dist
cp --parents $(git check-ignore **) ../dist

#!/bin/bash
# list folders into a file
ls -d */ | sed 's/\///g' > list.txt
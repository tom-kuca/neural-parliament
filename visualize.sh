#!/bin/bash
rm -rf frame_*.png;
cat | ./visualize.pl;
mencoder mf://frame_*.png -mf fps=8:type=png -ovc lavc -oac copy -o out.avi;
#firefox file:///`pwd`/frame_000000.png;

#!/usr/bin/env bash

file=$1
echo "compressing $file"

\gs -q -dNOPAUSE -dBATCH -dSAFER \
 -sDEVICE=pdfwrite \
 -dCompatibilityLevel=1.5 \
 -dPDFSETTINGS=/screen \
 -dEmbedAllFonts=true -dSubsetFonts=true \
 -dColorImageDownsampleType=/Bicubic \
 -dColorImageResolution=144 \
 -dGrayImageDownsampleType=/Bicubic \
 -dGrayImageResolution=144 \
 -dMonoImageDownsampleType=/Bicubic \
 -dMonoImageResolution=144 \
 -sOutputFile="${file%.*}-shrink.pdf" \
 "$file"

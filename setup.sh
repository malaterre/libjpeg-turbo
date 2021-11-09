#!/bin/sh -e

#set -x

# https://zpl.fi/chroma-subsampling-and-jpeg-sampling-factors/
convert -depth 8 -size 8x8 xc:white white.ppm
convert -depth 8 -size 8x8 xc:black black.ppm

echo "ref"
md5sum white.ppm
md5sum black.ppm

sampling_factors="
1x1,1x1,1x1
1x2,1x1,1x1
2x1,1x1,1x1
2x2,1x1,1x1
4x1,1x1,1x1
4x2,1x1,1x1

3x1,3x1,3x1
2x1,2x1,2x1
1x3,1x3,1x3
1x2,1x2,1x2
2x2,2x1,2x1
1x4,1x2,1x2
4x1,2x1,2x1
2x2,1x2,1x2

3x2,1x2,1x2
3x1,1x1,1x1
3x2,1x1,1x1
"
#"
#4x1,3x1,3x1
#3x2,2x1,2x1
#3x1,2x1,2x1
#2x3,2x1,2x1
#2x3,1x2,1x2
#2x4,1x1,1x1
#2x3,1x1,1x1
#1x4,1x3,1x3
#1x3,1x2,1x2
#1x4,1x1,1x1
#1x3,1x1,1x1
#"


for sampling_factor in $sampling_factors; do
 #echo $sampling_factor;
 cjpeg -sample $sampling_factor -outfile white_$sampling_factor.jpg -optimize -quality 100 white.ppm
 cjpeg -sample $sampling_factor -outfile black_$sampling_factor.jpg -optimize -quality 100 black.ppm
 djpeg -outfile white_$sampling_factor.ppm white_$sampling_factor.jpg
 djpeg -outfile black_$sampling_factor.ppm black_$sampling_factor.jpg
 jpegdump < white_$sampling_factor.jpg > white_$sampling_factor.txt 2>&1
 jpegdump < black_$sampling_factor.jpg > black_$sampling_factor.txt 2>&1
 ./bin/jpegtran -optimize -outfile white_$sampling_factor-tran.jpg -wipe 8fx8f+0+0 white_$sampling_factor.jpg
 djpeg -outfile white_$sampling_factor-tran.ppm white_$sampling_factor-tran.jpg
done

# jpeg uses a different notation:
sampling_factors2="
1x1,1x1,1x1
1x1,2x2,2x2
"

for sampling_factor in $sampling_factors2; do
  for qt in $(seq 1 7); do
    jpeg -qt $qt -s $sampling_factor -h -q 100 white.ppm white_$sampling_factor-thor-$qt.jpg
    jpeg -qt $qt -s $sampling_factor -h -q 100 black.ppm black_$sampling_factor-thor-$qt.jpg 
    djpeg -outfile white_$sampling_factor-thor-$qt.ppm white_$sampling_factor-thor-$qt.jpg # FIXME
    djpeg -outfile black_$sampling_factor-thor-$qt.ppm black_$sampling_factor-thor-$qt.jpg # FIXME
    jpegdump < white_$sampling_factor-thor-$qt.jpg > white_$sampling_factor-thor-$qt.txt 2>&1
    jpegdump < black_$sampling_factor-thor-$qt.jpg > black_$sampling_factor-thor-$qt.txt 2>&1
    ./bin/jpegtran -optimize -outfile white_$sampling_factor-thor-$qt-tran.jpg -wipe 8fx8f+0+0 white_$sampling_factor-thor-$qt.jpg
    djpeg -outfile white_$sampling_factor-thor-$qt-tran.ppm white_$sampling_factor-thor-$qt-tran.jpg
  done
done

echo "jpg"
for sampling_factor in $sampling_factors; do
  md5sum white_$sampling_factor.jpg
  md5sum black_$sampling_factor.jpg
  md5sum white_$sampling_factor-tran.jpg
done
for sampling_factor in $sampling_factors2; do
  for qt in $(seq 1 7); do
    md5sum white_$sampling_factor-thor-$qt.jpg
    md5sum black_$sampling_factor-thor-$qt.jpg
    md5sum white_$sampling_factor-thor-$qt-tran.jpg
  done
done

echo "ref ppm"
for sampling_factor in $sampling_factors; do
 md5sum white_$sampling_factor.ppm
 md5sum black_$sampling_factor.ppm
done
for sampling_factor in $sampling_factors2; do
  for qt in $(seq 1 7); do
    md5sum white_$sampling_factor-thor-$qt.ppm
    md5sum black_$sampling_factor-thor-$qt.ppm
  done
done

echo "tran ppm"
for sampling_factor in $sampling_factors; do
 md5sum white_$sampling_factor-tran.ppm
done
for sampling_factor in $sampling_factors2; do
  for qt in $(seq 1 7); do
    md5sum white_$sampling_factor-thor-$qt-tran.ppm
  done
done

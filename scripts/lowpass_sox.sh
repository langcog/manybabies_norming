#!/bin/bash
cd ../wavs/original

for f in *.wav ; do 
  echo $f
  sox "$f" "../intermediate/$f" lowpass 120 2 norm -3;
  sox "../intermediate/$f" "../filtered/$f" lowpass 120 2 norm -3;
done

for f in *.wav ; do 
  echo $f
  sox "$f" "../normed/$f" norm -3;
done

cd ../../scripts


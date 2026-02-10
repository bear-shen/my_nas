
exe: ffmpeg version 7.1-full_build-www.gyan.dev
source: 1256317107.mp4(3840x2160 hevc yuv420 8bit 333MB)

> av1_nvenc > rtx4060(laptop)
```
./ffmpeg.exe -y -i 1256317107.mp4 -c:v av1_nvenc -profile:v main10 -preset slow -tune hq -qp 35 -bf 3 -pix_fmt p010le -multipass qres -rc-lookahead 32 o.qp35.mp4
./ffmpeg.exe -y -i 1256317107.mp4 -c:v av1_nvenc -profile:v main10 -preset slow -tune hq -cq 40 -bf 3 -pix_fmt p010le -multipass qres -rc-lookahead 32 o.cq40.mp4
./ffmpeg.exe -i o.cq40.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -

./ffmpeg.exe -i o.qp70.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp65.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp60.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp55.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp50.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp45.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp40.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp35.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp30.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp27.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp25.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp22.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp20.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp17.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -
./ffmpeg.exe -i o.qp15.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -

qp size rate speed vmaf
70 576 22805 3.36 74.00
65 608 24095 3.35 74.09
60 650 25721 3.35 74.25
55 695 27529 3.35 74.37
50 748 29597 3.35 74.48
45 814 32229 3.34 74.60
40 905 35843 3.34 74.72
35 1010 40275 3.34 74.82
30 1160 46155 3.33 74.92
27 1290 51374 3.33 74.99
25 1390 55028 3.33 75.03
22 1580 62698 3.32 75.08
20 1750 69499 3.32 75.12
17 2050 81426 3.31 75.18
15 2350 93229 3.29 75.22

cq size rate speed vmaf
40 242 9821 3.34 70.66
35 363 14717 2.57 72.81
30 504 20439 2.58 73.86
27 566 22932 2.58 74.08
25 600 24317 2.58 74.15
22 969 39254 2.5 74.85
20 1100 46178 2.5 74.97
17 1390 57712 2.5 75.09
15 1610 66878 2.49 75.14
```

> av1_qsv > a380(desktop)
```
./ffmpeg.exe -y -i 1256317107.mp4 -c:v av1_qsv -profile:v main -preset slow -q:v 70 -bf 3 -pix_fmt p010le o.bv70.mp4

./ffmpeg.exe -i o.bv70.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -

qv size rate speed vmaf
70 470 18627 3.63 73.47
65 499 19784 3.63 73.63
60 534 21139 3.63 73.80
55 572 22673 3.64 74.00
50 620 24554 3.64 74.21
45 666 26385 3.63 74.34
40 722 28595 3.63 74.47
35 784 31063 3.63 74.56
30 874 34616 3.63 74.67
27 936 37055 3.62 74.72
25 986 39032 3.62 74.76
22 1093 43261 3.62 74.83
20 1170 46328 3.61 74.87
17 1322 52321  3.6 74.93
15 1464 57951 3.58 74.97
```

>libx265
```
./ffmpeg.exe -y -i 1256317107.mp4 -c:v libx265 -qp 40 -bf 3 -pix_fmt yuv420p10le o.qp40.mp4

./ffmpeg.exe -y -i 1256317107.mp4 -c:v libx265 -crf 40 -bf 3 -pix_fmt yuv420p10le o.crf40.mp4

./ffmpeg.exe -i o.qp40.mp4 -i 1256317107.mp4 -lavfi libvmaf='model=version=vmaf_v0.6.1\\:name=vmaf|version=vmaf_v0.6.1\\:name=vmaf' -f null -

qp size rate speed vmaf
40 74.255 2939.2 0.44 56.00
35 154.298 6107.6 0.375 64.76
30 296.571 11739.1 0.321 70.46
27 398.368 15768.6 0.295 72.19
25 474.998 18801.8 0.28 72.97
22 606.660 24013.3 0.261 73.71
20 713.177 28229.6 0.25 74.04
17 919.895 36412.0 0.232 74.36
15 1099.360 43515.8 0.221 74.52
12 1467.817 58100.4 0.205 74.69
10 1790.779 70884.1 0.194 74.78
7 2489.099 98525.6 0.177 74.87

crf size rate speed vmaf
40 51.889 2053.9 0.485 52.71
35 106.411 4212.1 0.423 61.99
30 214.223 8479.5 0.359 68.59
27 313.319 12402.1 0.325 71.16
25 384.930 15236.6 0.307 72.24
22 505.795 20020.8 0.285 73.25
20 596.525 23612.2 0.271 73.71
17 762.047 30164.0 0.253 74.16
15 901.488 35683.5 0.242 74.36
12 1178.802 46660.3 0.227 74.58
10 1426.405 56461.2 0.218 74.69
7 1927.887 76311.3 0.201 74.81




```


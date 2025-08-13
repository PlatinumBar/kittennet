rm -r .build
mkdir .build 2>/dev/null
#DO NOT ACCIDENTALLY COPY THE ACTUAL LINUX ROOT DIRECTORY :3
cp ./home/ ./.build/ -r #filter out stuff i dont want in the build, maybe sed out comments in the future?
tar -I "pigz -11" -C ./.build/ -cvf - $(ls .build) | base64 -w 0 | wl-copy

wl-paste
echo "thats $(wl-paste | wc -c) bytes"

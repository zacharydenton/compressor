#!/usr/bin/env bash
# converts all .flac files to .mp3 and copies them to the
# OUT directory; copies all .mp3 files to the OUT directory.

OUT="../Compressed_Music"
LAMEOPTS="--verbose -q1 --vbr-new -V0"

# first, find all .mp3s and copy them to the OUT dir
# (if they're not already there, of course)
find . -iname "*.mp3" | while read mp3;
do
        if [ ! -e "$OUT/$mp3" ]
        then
                cp --parents "$mp3" "$OUT"
        fi
done

# now, find all .flacs; decompress them to .wav; convert
# them to .mp3 using LAME; and move them to the OUT dir
find . -iname "*.flac" | while read flac;
do
        dir=`dirname "$flac"`
        file=`basename "$flac"`
        base=${file%.*} # strip the extension
        if [ ! -d "$OUT/$dir" ]
        then
                mkdir -p "$OUT/$dir"
        fi
        if [ ! -e "$OUT/$dir/$base.mp3" ]
        then 
                # decode to .wav, since lame doesn't speak .flac
                flac -dF "$flac" # decode regardless of errors
                # convert the .wav to .mp3; discard the .wav afterwards
                lame $LAMEOPTS "$dir/$base.wav" "$OUT/$dir/$base.mp3"
                rm "$dir/$base.wav"
        fi
done


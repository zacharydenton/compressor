#!/usr/bin/env bash
# converts all .flac files to .mp3 and copies them to the
# OUT directory; copies all .mp3 files to the OUT directory.

OUT="../Compressed_Music"
LAMEOPTS="--vbr-new -V0"

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
# them to .mp3 using LAME; restore their ID3 tags; move 
# them to the OUT dir; and discard the .wav afterwards
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
				# retrieve ID3 tags
				ARTIST=`metaflac "$a" --show-tag=ARTIST | sed s/.*=//g`
				TITLE=`metaflac "$a" --show-tag=TITLE | sed s/.*=//g`
				ALBUM=`metaflac "$a" --show-tag=ALBUM | sed s/.*=//g`
				GENRE=`metaflac "$a" --show-tag=GENRE | sed s/.*=//g`
				TRACKNUMBER=`metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g`
				DATE=`metaflac "$a" --show-tag=DATE | sed s/.*=//g`

                # decode to .wav, since lame doesn't speak .flac
                flac -dF "$flac" # decode regardless of errors
                # convert the .wav to .mp3; discard the .wav afterwards
                lame $LAMEOPTS "$dir/$base.wav" "$OUT/$dir/$base.mp3"
                rm "$dir/$base.wav"

				# restore ID3 tags
				id3 -t $TITLE" -T "${TRACKNUMBER:-0}" -a "$ARTIST" -A "$ALBUM" -y "$DATE" -g "${GENRE:-12}" "$OUT/$dir/$base.mp3"
        fi
done


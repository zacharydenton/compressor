#!/usr/bin/env bash
# converts all .flac files to .mp3 and copies them to the
# OUT directory; copies all .mp3 files to the OUT directory.

if [ "$#" -ne 2 ]
then
	echo "usage: $0 MUSIC_DIR OUTPUT_DIR"
	exit 1
fi

IN=$1
OUT=$2
LAMEOPTS="-V0"

# first, find all .mp3s and copy them to the OUT dir
# (if they're not already there, of course)
find "$IN" -iname "*.mp3" | while read mp3;
do
        if [ ! -e "$OUT/$mp3" ]
        then
                cp --parents "$mp3" "$OUT"
        fi
done

# now, find all .flacs; decompress them to .wav; convert
# them to .mp3 using LAME; restore their ID3 tags; move 
# them to the OUT dir; and discard the .wav afterwards
find "$IN" -iname "*.flac" | while read flac;
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

                # convert to MP3, preserving ID3 tags
                flac -c -dF "$flac" | lame $LAMEOPTS \
					--add-id3v2 --pad-id3v2 --ignore-tag-errors --tt "$TITLE" --tn "${TRACKNUMBER:-0}" --ta "$ARTIST" --tl "$ALBUM" --ty "$DATE" --tg "${GENRE:-12}" \
					- "$OUT/$dir/$base.mp3"
        fi
done


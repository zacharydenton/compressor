#!/usr/bin/env bash
# converts all .flac files to .mp3 and copies them to the
# OUT directory; copies all .mp3 files to the OUT directory.

LAMEOPTS="-V0 --quiet"

if [ "$#" -ne 2 ]
then
	echo "usage: $0 MUSIC_DIR OUTPUT_DIR"
	exit 1
fi

IN=$1
if [ ! -d "$IN" ]
then
	echo "$IN is not a directory"
	exit 1
fi

OUT=$2
if [ ~ -d "$OUT" ]
then
	mkdir "$OUT"
fi

# first, find all .mp3s and copy them to the OUT dir
# unless they are already there
find "$IN" -iname "*.mp3" | sed 's/$IN//' | while read mp3; # we only want the unique part
do
	if [ ! -e "$OUT/$mp3" ]
	then
		echo "copying $IN/$mp3 to $OUT/$mp3"
		cp --parents "$IN/$mp3" "$OUT"
	fi
done

# now, find all .flacs; decompress them to .wav; convert
# them to .mp3 using LAME; restore their ID3 tags; move 
# them to the OUT dir; and discard the .wav afterwards
find "$IN" -iname "*.flac" | sed 's/$IN//' | while read flac; # we only want the unique part
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
		echo "encoding $IN/$flac to $OUT/$dir/$base.mp3"
		flac -c -dF "$IN/$flac" | lame $LAMEOPTS \
			--add-id3v2 --pad-id3v2 --ignore-tag-errors --tt "$TITLE" --tn "${TRACKNUMBER:-0}" --ta "$ARTIST" --tl "$ALBUM" --ty "$DATE" --tg "${GENRE:-12}" \
			- "$OUT/$dir/$base.mp3"
	fi
done


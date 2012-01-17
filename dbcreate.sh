#!/bin/bash

DATE="`date +%Y.%m.%d-%H:%M`"
CATEGORIES=()

i=0
for f in *.txt
do
    CATEGORIES[$i]="${f%.txt}"
#    CATEGORIES[$i]="${CATEGORIES[$i]//\&/&amp;}"
    ((i+=1))
done

QUESTIONS=`cat *.txt | grep ^Q: | wc -l`

# HEAD
cat <<EOF
[ITEST_VERSION]
1.42
[ITEST_DB_VERSION]
1.4
[DB_NAME]
Вычислительные машины, системы и сети
[DB_DATE]
$DATE
[DB_DATE_ULSD]
false
[DB_COMMENTS]
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd"><html><head><meta name="qrichtext" content="1" /><style type="text/css">p, li { white-space: pre-wrap; }</style></head><body style=" font-family:'Sans'; font-size:10pt; font-weight:400; font-style:normal;"><p style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"></p></body></html>
[DB_QNUM]
$QUESTIONS
[DB_SNUM]
0
[DB_CNUM]
0
[DB_FLAGS]
EOF

for((i=0;i<20;i++))
do
    [ ! -z "${CATEGORIES[$i]}" ] && echo -n "+" || echo -n "-"
done
echo

for((i=0;i<20;i++))
do
    echo "[DB_F$i]"
    [ ! -z "${CATEGORIES[$i]}" ] && echo "${CATEGORIES[$i]}" || echo
done

echo "[DB_FLAGS_END]"
# End of HEAD

# The stream should be finished by "Q:"
# $1 - category number (zero by default)
function quest()
{
local QUESTION=""   # Text of question
local quecnt=0
local SELECTION=1   # Type of question
local anscnt=0      # Answers count
local ansic_arr=()
local answers=""
local category=0
local i

[ -z "$1" ] || category=$1

IFS=':'
    while read type string
    do
	case $type in
	    "*A")
		ansarr[$anscnt]="${string# }"
		((answers=$answers+(2**$anscnt)))
		((anscnt += 1))
	    ;;
	    " A"|"A")
		ansarr[$anscnt]="${string# }"
		((anscnt += 1))
	    ;;
	    "Q")
		[ ${#answers} -gt 1 ] && SELECTION=1 || SELECTION=0

		#Needed to pass 1-st question
		if [ -z "$answers" ]
		then
		    QUESTION="${string# }"
		    continue
		fi

		cat <<EOF
[Q_NAME]
$QUESTION
[Q_FLAG]
$category
[Q_GRP]

[Q_DIF]
0
[Q_TEXT]
$QUESTION
[Q_ANS]
$SELECTION
$answers
$anscnt
EOF

		for((i=0;i<anscnt;i++))
		do
		    cat <<EOF
${ansarr[$i]}
EOF
		done



		cat <<EOF
[Q_EXPL]

[Q_ICCNT]
0
0
[Q_HID]
false
[Q_SVG]
0
EOF

		# reset vars
		QUESTION="${string# }"

		anscnt=0
		SELECTION=0
		ansic_arr=()
		ansc_arr=()
		answers=""
	    ;;
	    *)
		echo "Unknown pair: \"$type:$string\"" >&2
	    ;;
	esac
	continue


    done
}

i=0
for f in *.txt
do
    FILE="${f%.txt}"
    (cat "$f" && echo "Q:") | grep -v "#" | grep -v "^[[:blank:]]*$" | quest $i
#	sed s/'"'/"\&quot;"/g | quest $i
    ((i+=1))
done

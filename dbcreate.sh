#!/bin/bash


answertab=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

QUESTIONS=`cat *.txt | grep Q: | wc -l`
CATEGORIES=`ls -1 *.txt | wc -l`


# HEAD
cat <<EOF
[ITEST_VERSION]
1.42
[ITEST_DB_VERSION]
1.4
[DB_NAME]
Вычислительные машины, системы и сети
[DB_DATE]
2011.06.26-18:07
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
    [ $i -le $CATEGORIES ] && echo -n "+" || echo -n "-"
done
echo

for((i=0;i<20;i++))
do
    echo "[DB_F$i]"
    [ $i -le $CATEGORIES ] && echo "Category $i" || echo
done

echo "[DB_FLAGS_END]"
# End of HEAD

exit
# The stream should be finished by "Q:"
# $1 - category number (zero by default)
function quest()
{
local QUESTION=""   # Text of question
local quecnt=0
local SELECTION="0" # Type of question
local anscnt=0      # Answers count
local ansic_arr=()
local answers=""
local category=0

[ -z "$1" ] || category=$1

IFS=':'
    while read type string
    do
	case $type in
	    "*A")
		ansarr[$anscnt]="${string# }"
		answers="$answers${answertab[anscnt]}"
		((anscnt += 1))
	    ;;
	    " A"|"A")
		ansarr[$anscnt]="${string# }"
		((anscnt += 1))
	    ;;
	    "Q")
		[ ${#answers} -gt 1 ] && SELECTION=1

		#Needed to pass 1-st question
		if [ -z "$answers" ]
		then
		    QUESTION="${string# }"
		    continue
		fi

		cat <<EOF
		
	  <question name="$QUESTION" flag="$category" group="" difficulty="0">
	    <text>$QUESTION</text>
		<answers selectiontype="$SELECTION" correctanswers="$answers">
EOF

		for((i=0;i<anscnt;i++))
		do
		    cat <<EOF
		    <answer name="${answertab[i]}">${ansarr[$i]}</answer>
EOF
		done



		cat <<EOF

		    <explain></explain>
		</answers>
	    <ads icnt="0" ccnt="0" hidden="false"/>
	    <images>
	    </images>
	  </question>
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
for f in common.txt
do
    FILE="${f%.txt}"
    (cat "$f" && echo "Q:") | grep -v "#" | grep -v "^[[:blank:]]*$" | quest $i
    ((i+=1))
done

cat <<EOF
	</questions>
</database>
EOF

source $(dirname $0)/utils.sh

transform () {
    if [[ $1 == "X" ]]; then
        echo "A"
    elif [[ $1 == "Y" ]]; then
        echo "B"
    else
        echo "C"
    fi
}

total=0

while read p; do
    t=""
    s=0
    r=0
    if [[ "$p" =~ ^(A|B|C).(X|Y|Z)$ ]]; then
        t=$(transform ${BASH_REMATCH[2]})
        s=$(score $t)
        r=$(result ${BASH_REMATCH[1]} $t)
        total=$(($total + $s + $r))
    fi
done < "input.txt"

echo $total
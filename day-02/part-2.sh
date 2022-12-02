source $(dirname $0)/utils.sh

transform () {
    if [[ $2 == "X" ]]; then
        case "$1" in
            A) echo "C" ;;
            B) echo "A" ;;
            C) echo "B" ;;
        esac
    elif [[ $2 == "Y" ]]; then
        echo $1
    else
        case "$1" in
            A) echo "B" ;;
            B) echo "C" ;;
            C) echo "A" ;;
        esac
    fi
}

total=0

while read p; do
    t=""
    s=0
    r=0
    if [[ "$p" =~ ^(A|B|C).(X|Y|Z)$ ]]; then
        t=$(transform ${BASH_REMATCH[1]} ${BASH_REMATCH[2]})
        s=$(score $t)
        r=$(result ${BASH_REMATCH[1]} $t)
        total=$(($total + $s + $r))
    fi
done < "input.txt"

echo $total
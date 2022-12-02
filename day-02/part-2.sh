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

score () {
    if [[ $1 == "A" ]]; then
        echo 1
    elif [[ $1 == "B" ]]; then
        echo 2
    elif [[ $1 == "C" ]]; then
        echo 3
    fi
}

result () {
    if [[ ($1 == "A" && $2 == "B") || ($1 == "B" && $2 == "C") || ($1 == "C" && $2 == "A") ]]; then
        echo 6
    elif [[ $1 == $2 ]]; then
        echo 3
    else
        echo 0
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
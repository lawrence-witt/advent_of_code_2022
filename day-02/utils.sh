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
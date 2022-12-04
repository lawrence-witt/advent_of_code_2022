import Data.Char (ord, isUpper)

main = do
    s <- readFile "input.txt"
    print(processLines (lines s) 0)

get_duplicate :: String -> String -> String -> Char
get_duplicate (x:xs) y z = if x `elem` y && x `elem` z then x else get_duplicate xs y z

get_priority :: Char -> Int
get_priority x = if isUpper x then (ord x) - 38 else (ord x) - 96

processLines :: [String] -> Int -> Int
processLines [] n = n
processLines (x:y:z:xs) n = processLines xs (n + get_priority (get_duplicate x y z))
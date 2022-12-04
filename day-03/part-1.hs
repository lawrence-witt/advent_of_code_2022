import Data.Char (ord, isUpper)

main = do
    s <- readFile "input.txt"
    print(processLines (lines s) 0)

get_duplicate :: String -> String -> Char
get_duplicate (x:xs) y = if x `elem` y then x else get_duplicate xs y

get_priority :: Char -> Int
get_priority x = if isUpper x then (ord x) - 38 else (ord x) - 96

processLines :: [String] -> Int -> Int
processLines [] y = y
processLines (x:xs) y = processLines xs t
    where 
        (s, e) = splitAt ((length x) `div` 2) x
        t = y + get_priority (get_duplicate s e)
import Utils

main = do
    s <- readFile "input.txt"
    print(processLines (lines s) 0)

get_duplicate :: String -> String -> Char
get_duplicate (x:xs) y = if x `elem` y then x else get_duplicate xs y

processLines :: [String] -> Int -> Int
processLines [] y = y
processLines (x:xs) y = processLines xs t
    where 
        (s, e) = splitAt ((length x) `div` 2) x
        t = y + get_priority (get_duplicate s e)
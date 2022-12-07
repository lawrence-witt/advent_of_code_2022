module Utils where
    import Data.Char (ord, isUpper)
    get_priority :: Char -> Int
    get_priority x = if isUpper x then (ord x) - 38 else (ord x) - 96
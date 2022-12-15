import System.Environment
import Data.List

main = do
    s     <- readFile "input.txt"
    let chall = lines s
    putStr "Solution Task 1: "
    print (evaluateGames chall)

    putStr "Solution Task 2: "
    print (evaluateGames2 chall)

-- go through all games
evaluateGames :: [String] -> Int
evaluateGames [] = 0
evaluateGames (x:xs) = evaluateGame(x) + evaluateGames(xs)

evaluateGames2 :: [String] -> Int
evaluateGames2 [] = 0
evaluateGames2 (x:xs) = evaluateGame2(x) + evaluateGames2(xs)


--evaluate one game by summing up points gained from pick and win
evaluateGame game = (evaluatePick (game !! 2)) + (evaluateWin game)

evaluateGame2 game = (evaluateWin2 game)

evaluatePick picked = case picked of 'X' -> 1
                                     'Y' -> 2
                                     'Z' -> 3

-- For challenge 1
evaluateWin game = case (game !! 0) of
                        'A' -> case (game !! 2) of
                               'X' -> 3
                               'Y' -> 6
                               'Z' -> 0
                        'B' -> case (game !! 2) of
                               'X' -> 0
                               'Y' -> 3
                               'Z' -> 6
                        'C' -> case (game !! 2) of
                               'X' -> 6
                               'Y' -> 0
                               'Z' -> 3

-- For challenge 2
evaluateWin2 game = case (game !! 0) of
                        'A' -> case (game !! 2) of
                               'X' -> 3 -- Scissors + Loss
                               'Y' -> 1 + 3 -- Rock + Draw
                               'Z' -> 2 + 6 -- Win + Paper
                        'B' -> case (game !! 2) of
                               'X' -> 1 -- Rock + Loss
                               'Y' -> 2 + 3 -- Paper + Draw
                               'Z' -> 3 + 6 -- Scissors + Win
                        'C' -> case (game !! 2) of
                               'X' -> 2 -- Paper + Loss
                               'Y' -> 3 + 3 -- Scissors + Draw
                               'Z' -> 1 + 6 -- Rock + Win



{-# OPTIONS --guardedness #-}

-- this one has main

module Calc where

open import Agda.Builtin.Char
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String
open import Data.Nat.Show
open import IO

open import Eval
open import Parse
open import Show
open import Util

main : Main
main = run (getLine >>= λ c → putStrLn (showList (showResult show) (map evalExpr (takeLine (primStringToList c)))))

-- singular version
-- main = run (getLine >>= λ c → putStrLn (showResult show (evalExpr (takeBin (primStringToList c)))))
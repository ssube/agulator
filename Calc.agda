{-# OPTIONS --guardedness #-}

-- this one has main

module Calc where

open import Agda.Builtin.Char
open import Agda.Builtin.Nat
open import Agda.Builtin.String

open import Data.Nat.Show
open import IO

open import Parse
open import Util

main : Main
main = run (putStrLn (showMaybe show (takeNat "123a456")))
module Parse where

open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

open import Util

data Token : Set where
  Digit : Nat → Token
  Delim : Char → Token
  Oper : Char → Token
  Term : Token

parseChar : Char → Token
parseChar '0' = Digit 0
parseChar '1' = Digit 1
parseChar '2' = Digit 2
parseChar '3' = Digit 3
parseChar '4' = Digit 4
parseChar '5' = Digit 5
parseChar '6' = Digit 6
parseChar '7' = Digit 7
parseChar '8' = Digit 8
parseChar '9' = Digit 9
parseChar ',' = Delim ','
parseChar '=' = Oper '='
parseChar '+' = Oper '+'
parseChar _   = Term

parseNat : Nat → List Char → Nat
parseNat a [] = a
parseNat a (x ∷ xs) with parseChar x
...                     | Digit n = parseNat ((a * 10) + n) xs
...                     | _ = a

digits : List Char
digits = primStringToList "0123456789"

takeNat : String → Maybe Nat
takeNat s with takeCons digits (primStringToList s)
...            | [] = nothing
...            | xs = just (parseNat 0 xs)

parseList₂ : String → List Nat
parseList₂ s with primStringToList s
...             | [] = []
...             | (x ∷ xs) with parseChar x
...                           | Digit n = n ∷ []
...                           | _ = []

-- old stuff...

parseList : Nat → List Char → List Nat
parseList a [] = a ∷ []
parseList a (x ∷ xs) with parseChar x
...                     | Digit n = parseList ((a * 10) + n) xs
...                     | Delim s = a ∷ parseList 0 xs
...                     | Oper o = [] -- ignore for now
...                     | Term = []

parseExpr : String → List Nat
parseExpr "" = []
parseExpr x = parseList 0 (primStringToList x)

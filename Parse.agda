module Parse where

open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

open import Data.List using (_++_; reverse)

open import Util

data Token : Set where
  Digit : Nat → Token
  Delim : Char → Token
  Oper : Char → Token
  Skip : Char → Token
  Term : Token

record Result (A : Set) : Set where
  constructor emit
  field
    res : Maybe A
    rem : List Char

showResult : {A : Set} → (A → String) → Result A → String
showResult f (emit (just r) _) = primStringAppend "result: " (f r)
showResult f (emit nothing rem) = primStringAppend "remainder: " (primStringFromList rem)

-- take consecutive occurences of a character set
takeCons : List Char → List Char → Result (List Char)
takeCons [] r = emit nothing r
takeCons _ [] = emit nothing []
takeCons cs (x ∷ xs) with (findCharIndex 0 x cs)
...                     | nothing = emit nothing (x ∷ xs)
...                     | just n with (takeCons cs xs)
...                                 | emit nothing rem = emit (just (x ∷ [])) xs
...                                 | emit (just res) rem = emit (just (x ∷ res)) rem

digits : List Char
digits = primStringToList "0123456789"

opers : List Char
opers = primStringToList "=+"

-- parse a single character into a typed token
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
parseChar ' ' = Skip ' '
parseChar _   = Term

-- parse a number from a list of characters
parseNat : Maybe Nat → List Char → Result Nat
parseNat a [] = emit a []
parseNat a (x ∷ xs) with parseChar x
...                     | Digit n = parseNat (just (((default 0 a) * 10) + n)) xs
...                     | Skip c = parseNat a xs
...                     | _ = emit nothing xs

takeNat : List Char → Result Nat
takeNat s with takeCons digits s
...            | emit nothing rem₁ = emit nothing rem₁
...            | emit (just xs) rem₁ with parseNat nothing (reverse xs)
...                                     | emit nothing rem₂ = emit nothing rem₁
...                                     | emit (just n) rem₂ = emit (just n) rem₁

takeOper : List Char → Result Token
takeOper s with takeCons opers s
...           | emit nothing rem = emit nothing rem
...           | emit (just []) rem = emit nothing rem
...           | emit (just (x ∷ xs)) rem with parseChar x
...                                         | Oper o = emit (just (Oper o)) (Data.List._++_ xs rem)
...                                         | _ = emit nothing s

data BinExpr : Set where
  bin : Token → Token → Token → BinExpr

evalBin : Result BinExpr → Result Nat
evalBin (emit nothing rem) = emit nothing rem
evalBin (emit (just (bin (Oper '+') (Digit a) (Digit b))) rem) = emit (just (a + b)) rem
evalBin (emit (just (bin _ _ _)) rem) = emit nothing rem

takeBin : List Char → Result BinExpr
takeBin s with takeNat s
...           | emit nothing rem₁ = emit nothing s
...           | emit (just res₁) rem₁ with takeOper rem₁
...                                       | emit nothing rem₂ = emit nothing rem₁
...                                       | emit (just oper) rem₂ with takeNat rem₂
...                                                                   | emit nothing rem₃ = emit nothing rem₁
...                                                                   | emit (just res₃) rem₃ = emit (just (bin oper (Digit res₁) (Digit res₃))) rem₃

takeLine : List Char → List (Result BinExpr)
takeLine s = map takeBin (split (';' ∷ []) s)

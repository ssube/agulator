module Parse where

open import Agda.Builtin.Bool
open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

open import Data.List using (_++_; reverse)
open import Data.Nat.DivMod using (_/_)

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

emit↓ : {A : Set} → A → List Char → Result A
emit↓ a rem = emit (just a) rem

emit↑ : {A : Set} → List Char → Result A
emit↑ rem = emit nothing rem

showResult : {A : Set} → (A → String) → Result A → String
showResult f (emit nothing rem) = primStringAppend "remainder: " (primStringFromList rem)
showResult f (emit (just r) []) = primStringAppend "result: " (f r)
showResult f (emit (just r) xs) = primStringAppend (primStringAppend "result: " (f r)) (primStringAppend ", remainder: " (primStringFromList xs))

-- take consecutive occurences of a character set
takeCons : List Char → List Char → Result (List Char)
takeCons _ [] = emit↑ []
takeCons [] r = emit↑ r
takeCons cs (x ∷ xs) with (findCharIndex 0 x cs)
...                     | nothing = emit↑ (x ∷ xs)
...                     | just n with (takeCons cs xs)
...                                 | emit nothing rem = emit↓ (x ∷ []) xs
...                                 | emit (just res) rem = emit↓ (x ∷ res) rem

digits : List Char
digits = primStringToList "0123456789"

opers : List Char
opers = primStringToList "-+*/"

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
parseChar '-' = Oper '-'
parseChar '+' = Oper '+'
parseChar '*' = Oper '*'
parseChar '/' = Oper '/'
parseChar ' ' = Skip ' '
parseChar _   = Term

-- parse a number from a list of characters
parseNat : Maybe Nat → List Char → Result Nat
parseNat a [] = emit a []
parseNat a (x ∷ xs) with parseChar x
...                     | Digit n = parseNat (just (((default 0 a) * 10) + n)) xs
...                     | _ = emit↑ xs

takeNat : List Char → Result Nat
takeNat s with takeCons digits s
...            | emit nothing rem₁ = emit nothing rem₁
...            | emit (just xs) rem₁ with parseNat nothing xs
...                                     | emit nothing rem₂ = emit↑ rem₁
...                                     | emit (just n) rem₂ = emit↓ n rem₁

takeOper : List Char → Result Token
takeOper s with takeCons opers s
...           | emit nothing rem = emit↑ rem
...           | emit (just []) rem = emit↑ rem
...           | emit (just (x ∷ xs)) rem with parseChar x
...                                         | Oper o = emit↓ (Oper o) (xs ++ rem)
...                                         | _ = emit↑ s

data BinExpr : Set where
  bin : Token → Token → Token → BinExpr

evalBin : Result BinExpr → Result Nat
evalBin (emit nothing rem) = emit↑ rem
evalBin (emit (just (bin (Oper '+') (Digit a) (Digit b))) rem) = emit↓ (a + b) rem
evalBin (emit (just (bin (Oper '-') (Digit a) (Digit b))) rem) = emit↓ (a - b) rem
evalBin (emit (just (bin (Oper '*') (Digit a) (Digit b))) rem) = emit↓ (a * b) rem
evalBin (emit (just (bin (Oper '/') (Digit a) (Digit b))) rem) with (b == zero)
...                                                                | false = emit↓ (a / (suc (b - 1))) rem -- todo: why tho
...                                                                | true = emit↑ rem
evalBin (emit (just (bin _ _ _)) rem) = emit↑ rem

takeBin : List Char → Result BinExpr
takeBin s with takeNat s
...           | emit nothing rem₁ = emit↑ s
...           | emit (just res₁) rem₁ with takeOper rem₁
...                                       | emit nothing rem₂ = emit↑ rem₁
...                                       | emit (just oper) rem₂ with takeNat rem₂
...                                                                   | emit nothing rem₃ = emit↑ rem₁
...                                                                   | emit (just res₃) rem₃ = emit↓ (bin oper (Digit res₁) (Digit res₃)) rem₃

takeLine : List Char → List (Result BinExpr)
takeLine s = map takeBin (map reverse (reverse (split (';' ∷ []) s)))

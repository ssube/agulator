module Parse where

open import Agda.Builtin.Bool
open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

open import Data.List using (_++_; reverse)
open import Data.Product using (_×_)

open import Util

data Token : Set where
  Digit : Nat → Token
  Delim : Char → Token
  Oper : Char → Token
  Skip : Char → Token
  Term : Token

data Expr : Set where
  BinExpr : Expr → Expr → Expr → Expr
  NatExpr : Nat → Expr
  OperExpr : Char → Expr

record Result (A : Set) : Set where
  constructor emit
  field
    val : Maybe A
    rem : List Char

-- emit a result without a value and backtrack
emit↑ : {A : Set} → List Char → Result A
emit↑ rem = emit nothing rem

-- emit a result with a value and continue parsing
emit↓ : {A : Set} → A → List Char → Result A
emit↓ a rem = emit (just a) rem

-- take consecutive occurences of a character set
takeCons : List Char → List Char → Result (List Char)
takeCons _ [] = emit↑ []
takeCons [] r = emit↑ r
takeCons cs (x ∷ xs) with (findCharIndex x cs)
...                     | nothing = emit↑ (x ∷ xs)
...                     | just n with (takeCons cs xs)
...                                 | emit nothing rem = emit↓ (x ∷ []) xs
...                                 | emit (just val) rem = emit↓ (x ∷ val) rem

takeOnce : List Char → List Char → Result Char
takeOnce _ [] = emit↑ []
takeOnce [] r = emit↑ r
takeOnce cs (x ∷ xs) with (findCharIndex x cs)
...                     | nothing = emit↑ (x ∷ xs)
...                     | just n = emit↓ x xs

-- ignore consecutive characters
ignoreCons : List Char → List Char → List Char
ignoreCons _ [] = []
ignoreCons [] r = r
ignoreCons cs xs with takeCons cs xs
...                 | emit nothing rem = rem
...                 | emit (just val) rem = rem

digits : List Char
digits = primStringToList "0123456789"

opers : List Char
opers = primStringToList "-+*/"

skips : List Char
skips = primStringToList " "

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
...                    | Digit n = parseNat (just (((default 0 a) * 10) + n)) xs
...                    | _ = emit↑ xs

takeNat : List Char → Result Expr
takeNat s with takeCons digits s
...          | emit nothing rem₁ = emit↑ rem₁
...          | emit (just xs) rem₁ with parseNat nothing xs
...                                   | emit (just n) rem₂ = emit↓ (NatExpr n) rem₁
...                                   | emit _ rem₂ = emit↑ rem₁

-- provided for completeness with the parse/take pair above, but this one is not used
parseOper : List Char → Result Token
parseOper [] = emit↑ []
parseOper (x ∷ xs) with parseChar x
...                   | Oper o = emit↓ (Oper o) xs
...                   | _ = emit↑ xs

takeOper : List Char → Result Expr
takeOper s with takeCons opers s
...           | emit nothing rem = emit↑ rem
...           | emit (just []) rem = emit↑ rem
...           | emit (just (x ∷ xs)) rem with parseChar x
...                                         | Oper o = emit↓ (OperExpr o) (xs ++ rem)
...                                         | _ = emit↑ s

-- why doesn't this version work?
-- ...           | emit (just xs) rem with parseOper xs
-- ...                                   | emit (just (Oper o)) rem₂ = emit↓ (Oper o) rem₂
-- ...                                   | emit _ rem₂ = emit↑ rem

-- a recursive parser does not structurally terminate, but since the input string is finite
-- and every take* function consumes some characters, it must eventually exhaust the input
-- string or run out of alternatives to try

{-# NON_TERMINATING #-}
takeAlt : ( List Char → Result Expr ) → ( List Char → Result Expr ) → List Char → Result Expr
takeBin : List Char → Result Expr
takeGroup : { G : Set } → ( List Char → Result G ) → List Char → Result G

takeBinGroup = takeAlt (takeGroup takeBin) takeBin
takeAny = takeAlt takeBinGroup takeNat

takeBin s with takeNat (ignoreCons skips s)
...          | emit nothing rem₁ = emit↑ s
...          | emit (just res₁) rem₁ with takeOper (ignoreCons skips rem₁)
...                                     | emit nothing rem₂ = emit↑ s
...                                     | emit (just oper) rem₂ with takeAny (ignoreCons skips rem₂)
...                                                                | emit nothing rem₃ = emit↑ s
...                                                                | emit (just res₃) rem₃ = emit↓ (BinExpr oper res₁ res₃) rem₃

takeGroup f [] = emit↑ []
takeGroup f s with takeOnce ('(' ∷ []) s
...              | emit nothing _ = emit↑ s
...              | emit _ rem with f rem
...                              | emit nothing _ = emit↑ s
...                              | emit (just r) rem₂ with takeOnce (')' ∷ []) rem₂
...                                               | emit nothing _ = emit↑ s
...                                               | emit _ rem₃ = emit↓ r rem₃

takeAlt a b s with a s
...              | emit (just r) rem₁ = emit↓ r rem₁
...              | emit nothing rem₁ with b s
...                                    | emit (just r) rem₂ = emit↓ r rem₂
...                                    | emit nothing rem₂ = emit↑ s

takeLine : List Char → List (Result Expr)
takeLine s = map takeAny (map reverse (reverse (split (';' ∷ []) s)))

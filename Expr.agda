module Expr where

open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

data Token : Set where
  Digit : Nat → Token
  Delim : Char → Token
  Oper : Char → Token
  Skip : Char → Token
  Term : Token

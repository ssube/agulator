module Eval where

open import Agda.Builtin.Bool
open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat

open import Data.Nat.DivMod using (_/_)

open import Parse

evalDiv : Nat → Nat → List Char → Result Nat
evalDiv _ 0 s = emit↑ s
evalDiv a b s = emit↓ (a / (suc (b - 1))) s -- todo: why suc-1 tho

{-# NON_TERMINATING #-}
evalExpr : Result Expr → Result Nat
evalExpr (emit nothing rem) = emit↑ rem
evalExpr (emit (just (NatExpr n)) rem) = emit↓ n rem
evalExpr (emit (just (BinExpr oe lhs rhs)) rem) with oe
...     | (OperExpr o) with evalExpr (emit↓ lhs []) | evalExpr (emit↓ rhs [])
...           | emit nothing _  | _ = emit↑ rem
...           | emit _ _        | emit nothing _ = emit↑ rem
...           | emit (just a) _ | emit (just b) _ with o
...                 | '+' = emit↓ (a + b) rem
...                 | '-' = emit↓ (a - b) rem
...                 | '*' = emit↓ (a * b) rem
...                 | '/' = evalDiv a b rem
...                 | _ = emit↑ rem
evalExpr (emit (just (BinExpr oe lhs rhs)) rem)
        | _ = emit↑ rem

-- evalExpr (emit (just (BinExpr (TokenExpr (Oper o)) lhs rhs)) rem)    | _ = emit↑ rem
evalExpr (emit (just _) rem) = emit↑ rem
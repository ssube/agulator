module Eval where

open import Agda.Builtin.Bool
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat

open import Data.Nat.DivMod using (_/_)

open import Parse

evalBin : Result BinExpr → Result Nat
evalBin (emit nothing rem) = emit↑ rem
evalBin (emit (just (bin (Oper '+') (Digit a) (Digit b))) rem) = emit↓ (a + b) rem
evalBin (emit (just (bin (Oper '-') (Digit a) (Digit b))) rem) = emit↓ (a - b) rem
evalBin (emit (just (bin (Oper '*') (Digit a) (Digit b))) rem) = emit↓ (a * b) rem
evalBin (emit (just (bin (Oper '/') (Digit a) (Digit b))) rem) with (b == zero)
...                                                                | false = emit↓ (a / (suc (b - 1))) rem -- todo: why tho
...                                                                | true = emit↑ rem
evalBin (emit (just (bin _ _ _)) rem) = emit↑ rem
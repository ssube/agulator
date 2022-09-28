data BinExpr : Set where
  binE : Token → Token → Token → BinExpr

evalBin : BinExpr → Maybe Nat
evalBin (binE (Oper '+') (Digit a) (Digit b)) = just (a + b)
evalBin (binE _ _ _) = nothing

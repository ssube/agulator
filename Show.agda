module Show where

open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.String

open import Parse

-- result to string
showResult : {A : Set} → (A → String) → Result A → String
showResult f (emit nothing rem) = primStringAppend "remainder: " (primStringFromList rem)
showResult f (emit (just r) []) = primStringAppend "result: " (f r)
showResult f (emit (just r) xs) = primStringAppend (primStringAppend "result: " (f r)) (primStringAppend ", remainder: " (primStringFromList xs))

-- append all of the items in a list
showList : {V : Set} → (V → String) → List V → String
showList f [] = ""
showList f (x ∷ []) = f x
showList f (x ∷ xs) = primStringAppend (f x) (primStringAppend ", " (showList f xs))

-- maybe to definitely a string
showMaybe : {V : Set} → (V → String) → Maybe V → String
showMaybe f nothing = "nothing"
showMaybe f (just v) = f v

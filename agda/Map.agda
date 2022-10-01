module Map where

-- not really used yet

open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String
open import Data.Nat.Show

open import Show
open import Util

record Map (K V : Set) : Set where
  constructor mapOf
  field
    keys : List K
    values : List V

showMap : {V : Set} → (V → String) → Map String V → String
showMap f m = primStringAppend "map: " (showList ident (zip (Map.keys m) (map f (Map.values m))))

findMap : Map Nat Nat → Nat → Maybe Nat
findMap m k with findIndex 0 k (Map.keys m)
...            | just n = takeIndex (Map.values m) n
...            | nothing = nothing

showNatMap : Map String Nat → String
showNatMap m = showMap show m

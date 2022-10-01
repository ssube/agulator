module Map where

-- not really used yet

record Map (K V : Set) : Set where
  constructor mapOf
  field
    keys : List K
    values : List V

showMap : {V : Set} → (V → String) → Map String V → String
showMap f m = "map: " +++ (showList ident (zip (Map.keys m) (map f (Map.values m))))

findMap : Map Nat Nat → Nat → Nat
findMap m k = takeIndex 0 (Map.values m) (findIndex 0 k (Map.keys m))

showNatMap : Map String Nat → String
showNatMap m = showMap show m

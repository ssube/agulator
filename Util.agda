module Util where

open import Agda.Builtin.Bool
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat

ident : {V : Set} → V → V
ident x = x

map : {A B : Set} → (A → B) → List A → List B
map f [] = []
map f (x ∷ []) = (f x) ∷ []
map f (x ∷ xs) = (f x) ∷ (map f xs)

zip : {V : Set} → List V → List V → List V
zip [] [] = []
zip [] (x ∷ []) = x ∷ []
zip [] (x ∷ xs) = x ∷ (zip [] xs)
zip (x ∷ []) [] = x ∷ []
zip (x ∷ []) (y ∷ []) = x ∷ y ∷ []
zip (x ∷ xs) [] = x ∷ (zip xs [])
zip (x ∷ xs) (y ∷ ys) = x ∷ y ∷ (zip xs ys)

len : {A : Set} → List A → Nat
len [] = 0
len (x ∷ xs) = suc (len xs)

filter : {A : Set} → (A → Bool) → List A → List A
filter f [] = []
filter f (x ∷ xs) with f x
...                   | true = x ∷ filter f xs
...                   | false = filter f xs

filterNothing : {A : Set} → List (Maybe A) → List A
filterNothing [] = []
filterNothing (nothing ∷ xs) = filterNothing xs
filterNothing (just x ∷ xs) = x ∷ filterNothing xs

takeIndex : {A : Set} → A → List A → Nat → A
takeIndex d [] 0 = d
takeIndex d [] (suc x) = d
takeIndex d (x ∷ xs) 0 = x
takeIndex d (x ∷ xs) (suc n) = takeIndex d xs n

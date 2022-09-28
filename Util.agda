module Util where

open import Agda.Builtin.Bool
open import Agda.Builtin.Char
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

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

findIndex : Nat → Nat → List Nat → Maybe Nat
findIndex n t [] = nothing
findIndex n t (x ∷ xs) with (t == x)
...                       | true = just n
...                       | false = findIndex (suc n) t xs

findCharIndex : Nat → Char → List Char → Maybe Nat
findCharIndex n t [] = nothing
findCharIndex n t (x ∷ xs) with primCharEquality t x
...                       | true = just n
...                       | false = findCharIndex (suc n) t xs

showList : {V : Set} → (V → String) → List V → String
showList f [] = ""
showList f (x ∷ []) = f x
showList f (x ∷ xs) = primStringAppend (f x) (primStringAppend ", " (showList f xs))

showMaybe : {V : Set} → (V → String) → Maybe V → String
showMaybe f nothing = "nothing"
showMaybe f (just v) = f v

-- take consecutive occurences of a character set
takeCons : List Char → List Char → List Char
takeCons [] _ = []
takeCons _ [] = []
takeCons cs (x ∷ xs) with (findCharIndex 0 x cs)
...                     | nothing = []
...                     | just n = x ∷ (takeCons cs xs)

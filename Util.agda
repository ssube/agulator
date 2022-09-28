module Util where

open import Agda.Builtin.Bool
open import Agda.Builtin.Char
open import Agda.Builtin.Equality
open import Agda.Builtin.List
open import Agda.Builtin.Maybe
open import Agda.Builtin.Nat
open import Agda.Builtin.String

-- given some default value and a Maybe, definitely return one of them
default : {V : Set} → V → Maybe V → V
default n nothing = n
default n (just m) = m

-- return the same thing, for functions that need a noop fn
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

-- findAny : { A : Set } → Nat → A → List A → Nat
-- findAny n t [] = n
-- findAny n t (x ∷ xs) with (t ≡ x)
-- ...                     | refl = n
-- ...                     | _ = findAny (suc n) t xs

split : List Char → List Char → List (List Char)
split = go [] []
  where
    go : List Char → List (List Char) → List Char → List Char → List (List Char)
    go acc acl delims [] = acl
    go acc acl delims (x ∷ xs) with (primCharEquality x '\n')
    ...                           | true = go [] (acc ∷ acl) delims xs
    ...                           | false = go (x ∷ acc) acl delims xs
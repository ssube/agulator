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

-- transform each element of a list
map : {A B : Set} → (A → B) → List A → List B
map f [] = []
map f (x ∷ []) = (f x) ∷ []
map f (x ∷ xs) = (f x) ∷ (map f xs)

-- combine two lists
zip : {V : Set} → List V → List V → List V
zip [] [] = []
zip xs [] = xs
zip [] ys = ys
zip (x ∷ xs) (y ∷ ys) = x ∷ y ∷ (zip xs ys)

-- get the length of a list
len : {A : Set} → List A → Nat
len [] = 0
len (x ∷ xs) = suc (len xs)

-- keep items that pass the predicate
filter : {A : Set} → (A → Bool) → List A → List A
filter f [] = []
filter f (x ∷ xs) with f x
...                   | true = x ∷ filter f xs
...                   | false = filter f xs

-- remove nothings from a list of maybes
filterNothing : {A : Set} → List (Maybe A) → List A
filterNothing [] = []
filterNothing (nothing ∷ xs) = filterNothing xs
filterNothing (just x ∷ xs) = x ∷ filterNothing xs

-- take the item at the given index
takeIndex : {A : Set} → A → List A → Nat → A
takeIndex d [] 0 = d
takeIndex d [] (suc x) = d
takeIndex d (x ∷ xs) 0 = x
takeIndex d (x ∷ xs) (suc n) = takeIndex d xs n

-- find the index of a number
findIndex : Nat → Nat → List Nat → Maybe Nat
findIndex n t [] = nothing
findIndex n t (x ∷ xs) with (t == x)
...                       | true = just n
...                       | false = findIndex (suc n) t xs

-- find the index of a character
findCharIndex : Nat → Char → List Char → Maybe Nat
findCharIndex n t [] = nothing
findCharIndex n t (x ∷ xs) with primCharEquality t x
...                       | true = just n
...                       | false = findCharIndex (suc n) t xs

-- generic find if I was smarter
{-
findAny : { A : Set } → Nat → A → List A → Nat
findAny n t [] = n
findAny n t (x ∷ xs) with (t ≡ x)
...                     | refl = n
...                     | _ = findAny (suc n) t xs
-}

split : List Char → List Char → List (List Char)
split = go [] []
  where
    go : List Char → List (List Char) → List Char → List Char → List (List Char)
    go acc acl delims [] = acc ∷ acl
    go acc acl delims (x ∷ xs) with findCharIndex 0 x delims
    ...                           | nothing = go (x ∷ acc) acl delims xs
    ...                           | _ = go [] (acc ∷ acl) delims xs
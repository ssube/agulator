data Token : Set where
  Digit : Nat → Token
  Delim : Char → Token
  Oper : Char → Token
  Term : Token

parseChar : Char → Token
parseChar '0' = Digit 0
parseChar '1' = Digit 1
parseChar '2' = Digit 2
parseChar '3' = Digit 3
parseChar '4' = Digit 4
parseChar '5' = Digit 5
parseChar '6' = Digit 6
parseChar '7' = Digit 7
parseChar '8' = Digit 8
parseChar '9' = Digit 9
parseChar ',' = Delim ','
parseChar '=' = Oper '='
parseChar '+' = Oper '+'
parseChar _   = Term

parseList : Nat → List Char → List Nat
parseList a [] = a ∷ []
parseList a (x ∷ xs) with parseChar x
...                     | Digit n = parseList ((a * 10) + n) xs
...                     | Delim s = a ∷ parseList 0 xs
...                     | Oper o = [] -- ignore for now
...                     | Term = []

parseExpr : String → List Nat
parseExpr "" = []
parseExpr x = parseList 0 (primStringToList x)

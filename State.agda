record State (V : Set) : Set where
  constructor state
  field
    globals : Map String V
    scopes : List (Map String V)

showGlobals : State Nat → String
showGlobals s = "globals: " +++ (showMap show (State.globals s))

showScopes : State Nat → String
showScopes s = "scopes: " +++ (showList (showMap show) (State.scopes s))

showState : State Nat → String
showState s = "state: " +++ ((showGlobals s) +++ (", " +++ (showScopes s)))

smap : Map String Nat
smap = mapOf ("foo" ∷ []) (4 ∷ [])

stest : State Nat
stest = state (smap) (smap ∷ [])

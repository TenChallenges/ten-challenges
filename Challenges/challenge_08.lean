import Defs_and_Lems.Hypergraph

/-- Ryser's inequality `τ(H) ≤ (r - 1)ν(H)` for `r`-partite `r`-uniform hypergraphs, `r ≥ 2`. -/
def statement_08 (r : ℕ) : Prop :=
  ∀ {V : Type*} [DecidableEq V] (H : Hypergraph V),
    2 ≤ r → Hypergraph.RyserConjectureFor H r

/-- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_8 : statement_08.{u} r := sorry

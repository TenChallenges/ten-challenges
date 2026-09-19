import Defs_and_Lems.Hadwiger

open SimpleGraph

/-- Every finite graph with Hadwiger number at most `r` is `r`-colorable. -/
def statement_01 (r : ℕ) : Prop :=
  ∀ {V : Type*} [Fintype V] (G : SimpleGraph V),
    hadwigerNumber G ≤ r → G.Colorable r

/-- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_1 : statement_01 r := sorry

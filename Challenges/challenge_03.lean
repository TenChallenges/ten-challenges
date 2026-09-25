import Defs_and_Lems.CaccettaHaggkvist

/-- The Caccetta–Häggkvist conjecture at minimum out-degree `r`. -/
def statement_03 (r : ℕ) : Prop :=
  CaccettaHaggkvistFor r

/-- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_3 : statement_03 r := sorry

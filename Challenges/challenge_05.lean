import Defs_and_Lems.ErdosHajnal

open SimpleGraph

/-- The Erdős–Hajnal conjecture for the path graph `Pᵣ`, at parameter `r`. -/
def statement_05 (r : ℕ) : Prop :=
  ErdosHajnalConjectureFor (pathGraph r)

/-- The challenge parameter. -/
def r : ℕ := sorry

/-- The Erdős–Hajnal conjecture for the path graph `Pᵣ`. -/
theorem challenge_5 : statement_05 r := sorry

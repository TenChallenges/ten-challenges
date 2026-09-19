import Defs_and_Lems.Ramsey

/-- Eventual exponential bounds for `R(t, t)`
with bases at most `(4 - √2) · 0.96^r` apart. -/
def statement_03 (r : ℕ) : Prop :=
  ∃ d₁ d₂ : ℝ, |d₁ - d₂| ≤ (4 - √2) * (0.96 : ℝ)^r ∧
    ∃ T, ∀ t ≥ T, d₁ ^ t ≤ ramseyNumber t ∧ ramseyNumber t ≤ d₂ ^ t

/-- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_3 : statement_03 r := sorry

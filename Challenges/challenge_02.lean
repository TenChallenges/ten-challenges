import Defs_and_Lems.MatroidRepresentability

/-- For every prime power `pᵐ ≤ r`, the excluded minors for
`GF(pᵐ)`-representability number at most `B` up to isomorphism. -/
def statement_02 (r B : ℕ) : Prop :=
  ∀ (p m : ℕ) [Fact p.Prime], 0 < m → p ^ m ≤ r → ExcludedMinorsAtMost p m B

/-- The challenge parameter. -/
def r : ℕ := sorry

/-- The bound on the number of excluded minors, up to isomorphism. -/
def B : ℕ := sorry

theorem challenge_2 : statement_02 r B := sorry

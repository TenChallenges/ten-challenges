import Defs_and_Lems.MatroidRepresentability

open Matroid FinMatroid

universe u

/-- The statement below says `r = pᵐ` is a prime power and
`L` lists the excluded minors for finite
`GF(pᵐ)`-representability, up to isomorphism. -/
def statement_02 (r : ℕ) (L : Finset FinMatroid) : Prop :=
  ∃ m p, ∃ _ : Fact p.Prime,
  0 < m ∧ r = p ^ m ∧
  (∀ A ∈ L, IsMatroidData A) ∧
  (∀ A ∈ L, IsExcludedMinorFor (IsGFRepresentable p m) A.decode) ∧
  (∀ A ∈ L, ∀ B ∈ L, A ≠ B → IsEmpty (A.decode ≂ B.decode)) ∧
  (∀ {β : Type u} (M : Matroid β), M.Finite →
  ¬ IsGFRepresentable p m M → ∃ A ∈ L, Nonempty (A.decode ≤i M))

/-- The challenge parameter. -/
def r : ℕ := sorry

/-- The excluded-minor list. -/
def L : Finset FinMatroid := sorry

theorem challenge_2 : statement_02.{u} r L := sorry

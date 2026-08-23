import Mathlib.Data.Finset.Card
import Mathlib.Algebra.Order.Ring.Unbundled.Rat

variable {U : Type*} [DecidableEq U]

/-- A finite family of finite sets is union-closed. -/
def IsUnionClosed (F : Finset (Finset U)) : Prop :=
  ∀ ⦃A B : Finset U⦄, A ∈ F → B ∈ F → A ∪ B ∈ F

/-- The number of members of the family containing `x`. -/
def occurrences (F : Finset (Finset U)) (x : U) : ℕ :=
  (F.filter fun A => x ∈ A).card

/-- The density of an element with respect to a finite family. -/
def density (F : Finset (Finset U)) (x : U) : ℚ :=
  (occurrences F x : ℚ) / max 1 F.card

/-- The two degenerate families excluded from the union-closed sets conjecture. -/
def Nondegenerate (F : Finset (Finset U)) : Prop :=
  F ≠ ∅ ∧ F ≠ {∅}

/-- Scaled union-closed sets conjecture for parameter `r`: every nondegenerate
finite union-closed family has an element of density at least `1/2 - 1/(r + 2)`.
The single named statement shared by the canonical theorem and the submission
signature-shim. -/
def statement_09 (r : ℕ) : Prop :=
  ∀ {U : Type*} [DecidableEq U] {F : Finset (Finset U)},
    IsUnionClosed F → Nondegenerate F →
      ∃ x, density F x ≥ (1 / 2 : ℚ) - 1 / ((r : ℚ) + 2)

/- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_9 : statement_09 r := by
  sorry

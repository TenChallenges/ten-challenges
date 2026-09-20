import Mathlib.Data.Finset.Card
import Mathlib.Algebra.Order.Ring.Unbundled.Rat

variable {U : Type*} [DecidableEq U] (F : Finset (Finset U))

/-- A finite family of finite sets is union-closed. -/
def IsUnionClosed : Prop :=
  ∀ ⦃A B : Finset U⦄, A ∈ F → B ∈ F → A ∪ B ∈ F

/-- The number of members of the family containing `x`. -/
def occurrences (x : U) : ℕ :=
  (F.filter fun A => x ∈ A).card

/-- The density of an element with respect to a finite family. -/
def density (x : U) : ℚ :=
  (occurrences F x : ℚ) / max 1 F.card

/-- The two degenerate families excluded from the union-closed sets conjecture. -/
def Nondegenerate : Prop :=
  F ≠ ∅ ∧ F ≠ {∅}

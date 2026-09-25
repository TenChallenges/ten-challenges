import Matroid.Representation.Basic
import Mathlib.FieldTheory.Finite.GaloisField

open Matroid

variable {α : Type*}

/-- Representability over the Galois field `GF(pᵐ)`. -/
def IsGFRepresentable
    (p m : ℕ) [Fact p.Prime] (M : Matroid α) : Prop :=
  ∃ (W : Type) (_ : AddCommGroup W) (_ : Module (GaloisField p m) W),
    Nonempty (M.Rep (GaloisField p m) W)

/-- `M` fails `P`, but every proper minor satisfies `P`. -/
def IsExcludedMinorFor (P : Matroid α → Prop) (M : Matroid α) : Prop :=
  ¬ P M ∧ ∀ N : Matroid α, N <m M → P N

/-- The excluded minors for `GF(pᵐ)`-representability number at most `B` up to
isomorphism: some family of at most `B` matroids on `ℕ` meets every finite
excluded minor up to isomorphism. -/
def ExcludedMinorsAtMost (p m : ℕ) [Fact p.Prime] (B : ℕ) : Prop :=
  ∃ S : Finset (Matroid ℕ), S.card ≤ B ∧
    ∀ {β : Type} (M : Matroid β), M.Finite →
      IsExcludedMinorFor (IsGFRepresentable p m) M →
      ∃ N ∈ S, Nonempty (N ≂ M)

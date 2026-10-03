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

/-- Given a prime power `pᵐ` and a number `B`, the following says that the
class of `GF(pᵐ)`-representable matroids has at most `B` excluded minors, up
to isomorphism. Equivalently, there is a set `S` of at most `B` matroids that
contains, up to isomorphism, every excluded minor for `GF(pᵐ)`-representability. -/
def ExcludedMinorsAtMost (p m : ℕ) [Fact p.Prime] (B : ℕ) : Prop :=
  ∃ S : Finset (Matroid ℕ), S.card ≤ B ∧
    ∀ {β : Type} (M : Matroid β), M.Finite →
      IsExcludedMinorFor (IsGFRepresentable p m) M →
      ∃ N ∈ S, Nonempty (N ≂ M)

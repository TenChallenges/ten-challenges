import Mathlib.Combinatorics.Matroid.Minor.Order
import Mathlib.FieldTheory.Finite.GaloisField
import Mathlib.LinearAlgebra.LinearIndependent.Defs

open Matroid

variable {α β : Type*}

/-- `M` is representable over the Galois field `GF(pᵐ)`: some assignment of
vectors to the elements of `M` makes a set independent exactly when its vectors
are linearly independent. -/
def IsGFRepresentable (p m : ℕ) [Fact p.Prime] (M : Matroid α) : Prop :=
  ∃ (W : Type) (_ : AddCommGroup W) (_ : Module (GaloisField p m) W) (v : α → W),
    ∀ I, M.Indep I ↔ LinearIndepOn (GaloisField p m) v I

/-- `M` fails `P`, but every proper minor satisfies `P`. -/
def IsExcludedMinorFor (P : Matroid α → Prop) (M : Matroid α) : Prop :=
  ¬ P M ∧ ∀ N : Matroid α, N <m M → P N

/-- `M` and `N` are isomorphic: a bijection between their ground sets carries
independent sets exactly to independent sets. -/
def Matroid.IsIso (M : Matroid α) (N : Matroid β) : Prop :=
  ∃ e : M.E ≃ N.E, ∀ I : Set M.E,
    M.Indep (Subtype.val '' I) ↔ N.Indep (Subtype.val '' (e '' I))

/-- Given a prime power `pᵐ` and a number `B`, the following says that the
class of `GF(pᵐ)`-representable matroids has at most `B` excluded minors, up
to isomorphism. Equivalently, there is a set `S` of at most `B` matroids that
contains, up to isomorphism, every excluded minor for `GF(pᵐ)`-representability. -/
def ExcludedMinorsAtMost (p m : ℕ) [Fact p.Prime] (B : ℕ) : Prop :=
  ∃ S : Finset (Matroid ℕ), S.card ≤ B ∧
    ∀ {β : Type} (M : Matroid β), M.Finite →
      IsExcludedMinorFor (IsGFRepresentable p m) M →
      ∃ N ∈ S, N.IsIso M

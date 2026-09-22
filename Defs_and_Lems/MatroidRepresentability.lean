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

/-- Finite ground-set and independence data on `ℕ`. -/
structure FinMatroid where
  ground : Finset ℕ
  indep : Finset (Finset ℕ)
deriving DecidableEq

namespace FinMatroid

/-- The independence axioms on the declared ground set. -/
def IsMatroidData (D : FinMatroid) : Prop :=
  (∅ ∈ D.indep) ∧
    (∀ J ∈ D.indep, ∀ I ∈ J.powerset, I ∈ D.indep) ∧
      (∀ I ∈ D.indep, ∀ J ∈ D.indep, I.card < J.card →
          ∃ e ∈ J \ I, insert e I ∈ D.indep) ∧
        (∀ I ∈ D.indep, I ⊆ D.ground)

instance (D : FinMatroid) : Decidable (IsMatroidData D) := by
  unfold IsMatroidData; infer_instance

/-- Decode valid independence data; use the empty matroid otherwise. -/
def decode (D : FinMatroid) : Matroid ℕ :=
  if h : IsMatroidData D then
    (IndepMatroid.ofFinset (↑D.ground) (fun I => I ∈ D.indep)
      h.1
      (fun _ J hJ hIJ => h.2.1 J hJ _ (Finset.mem_powerset.2 hIJ))
      (fun _ J _ hJ hlt => by
        obtain ⟨e, he, hins⟩ := h.2.2.1 _ ‹_› J hJ hlt
        exact ⟨e, (Finset.mem_sdiff.1 he).1, (Finset.mem_sdiff.1 he).2, hins⟩)
      (fun _ hI => Finset.coe_subset.2 (h.2.2.2 _ hI))).matroid
  else emptyOn ℕ

end FinMatroid

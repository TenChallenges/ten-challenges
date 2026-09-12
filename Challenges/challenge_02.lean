import Matroid.Representation.Basic
import Mathlib.FieldTheory.Finite.GaloisField

/-!
# Challenge 2: Excluded minors of GF(pᵐ)-representable matroids
For a prime power `r = pᵐ`, exhibit the complete list of excluded minors for
`GF(pᵐ)`-representable matroids and prove it complete.
-/

open Function Matroid

variable {α : Type*}

/- A matroid is `GF(pᵐ)`-representable if it can be represented over the
Galois field of order `p^m` (where `p` is prime). -/
def IsGFRepresentable
    (p m : ℕ) [Fact p.Prime] (M : Matroid α) : Prop :=
  ∃ (W : Type) (_ : AddCommGroup W) (_ : Module (GaloisField p m) W),
    Nonempty (M.Rep (GaloisField p m) W)

/- `M` is an excluded minor for the property `P` if `M` does not have `P`,
but every proper minor of `M` does. -/
def IsExcludedMinorFor (P : Matroid α → Prop) (M : Matroid α) : Prop :=
  ¬ P M ∧ ∀ N : Matroid α, N <m M → P N

/- A finite matroid. -/
structure FinMatroid where
  ground : Finset ℕ
  indep : Finset (Finset ℕ)
deriving DecidableEq

namespace FinMatroid

def IsMatroidData (D : FinMatroid) : Prop :=
  (∅ ∈ D.indep) ∧
    (∀ J ∈ D.indep, ∀ I ∈ J.powerset, I ∈ D.indep) ∧
      (∀ I ∈ D.indep, ∀ J ∈ D.indep, I.card < J.card →
          ∃ e ∈ J \ I, insert e I ∈ D.indep) ∧
        (∀ I ∈ D.indep, I ⊆ D.ground)

instance (D : FinMatroid) : Decidable (IsMatroidData D) := by
  unfold IsMatroidData; infer_instance

noncomputable def decode (D : FinMatroid) : Matroid ℕ :=
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

open FinMatroid

universe u

/-- Given a parameter `r` and a list `L`, the following
statement says that `r` is a prime power `r = pᵐ`
and `L` is a complete list of excluded minors
for `GF(pᵐ)`-representable matroids. -/
def statement_02 (r : ℕ) (L : Finset FinMatroid) : Prop :=
  ∃ m p, ∃ _ : Fact p.Prime,
  0 < m ∧ r = p ^ m ∧
  (∀ A ∈ L, IsMatroidData A) ∧
  (∀ A ∈ L, IsExcludedMinorFor (IsGFRepresentable p m) A.decode) ∧
  (∀ A ∈ L, ∀ B ∈ L, A ≠ B → IsEmpty (A.decode ≂ B.decode)) ∧
  (∀ {β : Type u} (M : Matroid β), M.Finite →
  ¬ IsGFRepresentable p m M → ∃ A ∈ L, Nonempty (A.decode ≤i M))

/- The challenge parameter. -/
def r : ℕ := sorry

/- The excluded-minor list. -/
def L : Finset FinMatroid := sorry

theorem challenge_2 : statement_02.{u} r L := sorry

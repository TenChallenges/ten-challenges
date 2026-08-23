import Mathlib.MeasureTheory.Measure.Lebesgue.VolumeOfBalls
import Mathlib.Order.LiminfLimsup
import Mathlib.Order.Filter.AtTopBot.Basic

/-!
# Sphere Packing — Parametrized Statement
-/

open MeasureTheory Metric Filter
open scoped ENNReal

noncomputable section

variable {d : ℕ}

/- A set of centres `C ⊆ ℝ^d` is a *unit packing* if distinct centres are at
distance at least `2` (the open unit balls around the centres are disjoint). -/
def IsUnitPacking (C : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  ∀ ⦃x⦄, x ∈ C → ∀ ⦃y⦄, y ∈ C → x ≠ y → 2 ≤ dist x y

/- The (upper) density of a packing `C`: the
`limsup` as `R → ∞` of the fraction of the ball `B(0, R)`
filled by the unit balls centered at the points of `C`. -/
def upperDensity (C : Set (EuclideanSpace ℝ (Fin d))) : ℝ≥0∞ :=
  limsup (fun R : ℝ =>
    volume ((⋃ x ∈ C, ball x 1) ∩ ball 0 R)
      / volume (ball (0 : EuclideanSpace ℝ (Fin d)) R)) atTop

/- The **sphere-packing constant** `Δ_d`: the supremum of densities over all unit
packings of `ℝ^d`. -/
def spherePackingConstant (d : ℕ) : ℝ≥0∞ :=
  ⨆ (C : Set (EuclideanSpace ℝ (Fin d))) (_ : IsUnitPacking C), upperDensity C

/- A *lattice packing*: a unit packing whose centre set is
an additive subgroup of `ℝ^d` (a lattice). -/
def IsLatticePacking (C : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  IsUnitPacking C ∧
    ∃ L : AddSubgroup (EuclideanSpace ℝ (Fin d)),
    C = (L : Set (EuclideanSpace ℝ (Fin d)))

/- The **lattice** sphere-packing constant:
the supremum of densities over unit packings that are lattices. -/
def latticePackingConstant (d : ℕ) : ℝ≥0∞ :=
  ⨆ (C : Set (EuclideanSpace ℝ (Fin d)))
  (_ : IsLatticePacking C), upperDensity C

/-- In dimension `r`, the sphere-packing constant equals the lattice
sphere-packing constant. The single named statement shared by the canonical
theorem and the submission signature-shim. -/
def statement_07 (r : ℕ) : Prop :=
  spherePackingConstant r = latticePackingConstant r

/- The challenge parameter: the dimension. -/
def r : ℕ := sorry

theorem challenge_7 : statement_07 r := sorry

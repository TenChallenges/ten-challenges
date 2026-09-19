import Mathlib.Analysis.Normed.Lp.MeasurableSpace
import Mathlib.MeasureTheory.Measure.Haar.OfBasis

open MeasureTheory Metric Filter
open scoped ENNReal

noncomputable section

variable {d : ℕ}

/-- A set of centres `C ⊆ ℝ^d` is a *unit packing* if distinct centres are at
distance at least `2` (the open unit balls around the centres are disjoint). -/
def IsUnitPacking (C : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  ∀ ⦃x⦄, x ∈ C → ∀ ⦃y⦄, y ∈ C → x ≠ y → 2 ≤ dist x y

/-- The (upper) density of a packing `C`: the `limsup` as `R → ∞` of the fraction
of the ball `B(0, R)` filled by the unit balls centred at the points of `C`. -/
def upperDensity (C : Set (EuclideanSpace ℝ (Fin d))) : ℝ≥0∞ :=
  limsup (fun R : ℝ =>
    volume ((⋃ x ∈ C, ball x 1) ∩ ball 0 R)
      / volume (ball (0 : EuclideanSpace ℝ (Fin d)) R)) atTop

/-- The **sphere-packing constant** `Δ_d`: the supremum of densities over all unit
packings of `ℝ^d`. -/
def spherePackingConstant (d : ℕ) : ℝ≥0∞ :=
  ⨆ (C : Set (EuclideanSpace ℝ (Fin d))) (_ : IsUnitPacking C), upperDensity C

/-- The **lattice** sphere-packing constant: the supremum of densities over unit
packings whose centre set is a lattice, i.e. an additive subgroup of `ℝ^d`. -/
def latticePackingConstant (d : ℕ) : ℝ≥0∞ :=
  ⨆ (L : AddSubgroup (EuclideanSpace ℝ (Fin d)))
    (_ : IsUnitPacking (L : Set (EuclideanSpace ℝ (Fin d)))),
      upperDensity (L : Set (EuclideanSpace ℝ (Fin d)))

end

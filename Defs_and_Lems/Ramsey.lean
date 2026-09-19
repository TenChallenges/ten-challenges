import Mathlib.Combinatorics.SimpleGraph.Clique
import Mathlib.Analysis.Real.Sqrt

/-- The diagonal Ramsey number `R(t, t)`. -/
noncomputable def ramseyNumber (t : ℕ) : ℕ :=
  sInf {n : ℕ | ∀ (G : SimpleGraph (Fin n)),
    (∃ s : Finset (Fin n), G.IsNClique t s) ∨
    (∃ s : Finset (Fin n), (Gᶜ).IsNClique t s)}

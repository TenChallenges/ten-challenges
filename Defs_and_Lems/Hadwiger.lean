import Mathlib.Combinatorics.SimpleGraph.Coloring.Vertex
import Defs_and_Lems.Minor

open SimpleGraph

variable {V : Type*} [Fintype V]

/-- The Hadwiger number: the largest `r` such that `K_r` is a minor of `G`. -/
noncomputable def hadwigerNumber (G : SimpleGraph V) : ℕ := by
  classical
  exact Nat.findGreatest (fun r =>
    Nonempty (Minor (completeGraph (Fin r)) G)) (Fintype.card V)

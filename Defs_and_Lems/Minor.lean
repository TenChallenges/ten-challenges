import Mathlib.Combinatorics.SimpleGraph.Basic
import Defs_and_Lems.VertexConnected

open SimpleGraph

variable {V W : Type*} [Fintype V]

namespace SimpleGraph

/-- The data witnessing that `H` is a minor of `G`, as simple graphs. -/
structure Minor (H : SimpleGraph W) (G : SimpleGraph V) where
  /-- The branch sets of the minor.

  Seeing the minor as a quotient graph, `branchSet w` is exactly the fiber of `w` under the quotient
  map. -/
  branchSet : W → Set V
  /-- The branch sets are pairwise disjoint. -/
  pairwise_disjoint_branchSet : Pairwise fun w₁ w₂ ↦ Disjoint (branchSet w₁) (branchSet w₂)
  /-- Each branch set is connected (in particular nonempty). -/
  connectedOn_branchSet (w : W) : G.ConnectedOn (branchSet w)
  /-- Adjacency in the minor induce adjacency between some points of the corresponding branch set.
  -/
  exists_mem_branchSet_of_adj ⦃w₁ w₂ : W⦄ :
    H.Adj w₁ w₂ → ∃ v₁ ∈ branchSet w₁, ∃ v₂ ∈ branchSet w₂, G.Adj v₁ v₂

end SimpleGraph

/-- K₅ -/
abbrev K5 := completeGraph (Fin 5)

/-- K₃,₃ -/
abbrev K33 := completeBipartiteGraph (Fin 3) (Fin 3)

/-
Planarity via Wagner's theorem: a finite graph is planar iff it has
neither a `K₅` nor a `K₃,₃` minor.
-/
def SimpleGraph.IsWagnerPlanar (G : SimpleGraph V) : Prop :=
  ¬ Nonempty (Minor K5 G) ∧ ¬ Nonempty (Minor K33 G)

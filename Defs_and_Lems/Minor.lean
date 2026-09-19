import Mathlib.Data.Set.Card
import Mathlib.Combinatorics.SimpleGraph.Coloring.Vertex

namespace SimpleGraph

variable {V W : Type*}

/-- More than `k` vertices, remaining connected after deleting fewer than `k`. -/
def IsVertexConnected (k : ℕ) (G : SimpleGraph V) : Prop :=
  k < ENat.card V ∧ ∀ ⦃s : Set V⦄, s.encard < k → (G.induce sᶜ).Connected

/-- The data witnessing that `H` is a minor of `G`, as simple graphs. -/
structure Minor (H : SimpleGraph W) (G : SimpleGraph V) where
  /-- The branch sets of the minor.

  Seeing the minor as a quotient graph, `branchSet w` is exactly the fiber of `w` under the quotient
  map. -/
  branchSet : W → Set V
  /-- The branch sets are pairwise disjoint. -/
  pairwise_disjoint_branchSet : Pairwise fun w₁ w₂ ↦ Disjoint (branchSet w₁) (branchSet w₂)
  /-- Each branch set is connected (in particular nonempty). -/
  connectedOn_branchSet (w : W) : (G.induce (branchSet w)).Connected
  /-- Adjacency in the minor induce adjacency between some points of the corresponding branch set.
  -/
  exists_mem_branchSet_of_adj ⦃w₁ w₂ : W⦄ :
    H.Adj w₁ w₂ → ∃ v₁ ∈ branchSet w₁, ∃ v₂ ∈ branchSet w₂, G.Adj v₁ v₂

/-- The Hadwiger number: the largest `r` such that `K_r` is a minor of `G`. -/
noncomputable def hadwigerNumber [Fintype V] (G : SimpleGraph V) : ℕ := by
  classical
  exact Nat.findGreatest (fun r =>
    Nonempty (Minor (completeGraph (Fin r)) G)) (Fintype.card V)

/-- K₅ -/
abbrev K5 := completeGraph (Fin 5)

/-- K₃,₃ -/
abbrev K33 := completeBipartiteGraph (Fin 3) (Fin 3)

/-- Planarity via Wagner's criterion: no `K₅` or `K₃,₃` minor. -/
def IsWagnerPlanar (G : SimpleGraph V) : Prop :=
  ¬ Nonempty (Minor K5 G) ∧ ¬ Nonempty (Minor K33 G)

end SimpleGraph

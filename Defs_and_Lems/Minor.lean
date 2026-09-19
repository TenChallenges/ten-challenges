import Mathlib.Data.Set.Card
import Mathlib.Combinatorics.SimpleGraph.Walk.Basic

namespace SimpleGraph

variable {V : Type*} (G : SimpleGraph V) (s : Set V)

/-- Two vertices `u` and `v` are reachable in a graph `G` on `s`
if there exists a walk from `u` to
`v` in `G` whose vertices all lie within `s`. -/
def ReachableOn (u v : V) : Prop := ∃ w : G.Walk u v, ∀ ⦃x⦄, x ∈ w.support → x ∈ s

/-- Any two vertices of `s` are joined by a walk within `s`. -/
def PreconnectedOn : Prop := ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → G.ReachableOn s x y

/-- A graph `G` is connected on a set `s` if `s` is nonempty and any two vertices of `s` are
reachable on `s`. -/
def ConnectedOn : Prop := s.Nonempty ∧ G.PreconnectedOn s

/-- More than `k` vertices, remaining connected after deleting fewer than `k`. -/
def IsVertexConnected (k : ℕ) (G : SimpleGraph V) : Prop :=
  k < ENat.card V ∧ ∀ ⦃s : Set V⦄, s.encard < k → G.ConnectedOn sᶜ

end SimpleGraph

open SimpleGraph

variable {V W : Type*}

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

/-- Planarity via Wagner's criterion: no `K₅` or `K₃,₃` minor. -/
def SimpleGraph.IsWagnerPlanar (G : SimpleGraph V) : Prop :=
  ¬ Nonempty (Minor K5 G) ∧ ¬ Nonempty (Minor K33 G)

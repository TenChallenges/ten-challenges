import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Combinatorics.SimpleGraph.Bipartite
import Mathlib.Combinatorics.SimpleGraph.Maps
import Mathlib.Data.Real.Basic
import Mathlib.Data.Set.Card
import Mathlib.SetTheory.Cardinal.Finite

/-!
# Shared definitions for Sidorenko's conjecture

Used by both `challenge_04` (specific `r`) and `challenge_04_univ` (∀r):
homomorphism density, the Sidorenko inequality, and the bounded-side
bipartiteness predicate live here.
-/

open SimpleGraph

/-- The homomorphism density `t(H, G)`: the number of graph homomorphisms
`H → G` (adjacency-preserving maps), divided by `|V(G)| ^ |V(H)|`. -/
noncomputable def homDensity {W V : Type*} [Fintype W] [Fintype V]
    (H : SimpleGraph W) (G : SimpleGraph V) : ℝ :=
  (Nat.card {f : W → V // ∀ ⦃a b : W⦄, H.Adj a b → G.Adj (f a) (f b)} : ℝ) /
    (Fintype.card V : ℝ) ^ Fintype.card W

/-- Sidorenko's inequality for a (bipartite) graph `H` over `G`, in normalized
homomorphism-density form: `t(H, G) ≥ t(K₂, G) ^ e(H)`, where `t(K₂, G)` is the
edge density (the homomorphism density of the single edge `K₂`) and `e(H)` is
the number of edges of `H`. -/
def SidorenkoFor {W V : Type*} [Fintype W] [Fintype V]
    (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  homDensity H G ≥ homDensity (completeGraph (Fin 2)) G ^ Nat.card H.edgeSet

/-- `H` is *bipartite with sides bounded by `k`*: it admits a bipartition
`V(H) = X ∪ Y` (Mathlib's `IsBipartiteWith`, i.e. `X`, `Y` disjoint and every
edge runs between them) covering all vertices, with `|X| ≤ k` and `|Y| ≤ k`. -/
def BipartiteBoundedBy {W : Type*} (H : SimpleGraph W) (k : ℕ) : Prop :=
  ∃ X Y : Set W,
    H.IsBipartiteWith X Y ∧ X ∪ Y = Set.univ ∧ X.ncard ≤ k ∧ Y.ncard ≤ k

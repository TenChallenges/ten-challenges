import Mathlib.Combinatorics.SimpleGraph.Bipartite
import Mathlib.Data.Real.Basic

open SimpleGraph

variable {W V : Type*} [Fintype W] [Fintype V]

/-- The homomorphism density `t(H, G)`: the number of
graph homomorphisms `H → G`, divided by `|V(G)| ^ |V(H)|`. -/
noncomputable def homDensity (H : SimpleGraph W) (G : SimpleGraph V) : ℝ :=
  (Nat.card {f : W → V // ∀ ⦃a b : W⦄, H.Adj a b → G.Adj (f a) (f b)} : ℝ) /
    (Fintype.card V : ℝ) ^ Fintype.card W

/-- Sidorenko's inequality for a graph `H` over `G`,
in normalized homomorphism-density form: `t(H, G) ≥ t(K₂, G) ^ e(H)`. -/
def SidorenkoFor (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  homDensity H G ≥ homDensity (completeGraph (Fin 2)) G ^ Nat.card H.edgeSet

/-- `H` is *bipartite with sides bounded by `k`*: it admits
a bipartition `V(H) = X ∪ Y`, with `|X| ≤ k` and `|Y| ≤ k`. -/
def BipartiteBoundedBy (H : SimpleGraph W) (k : ℕ) : Prop :=
  ∃ X Y : Set W,
    H.IsBipartiteWith X Y ∧ X ∪ Y = Set.univ ∧ X.ncard ≤ k ∧ Y.ncard ≤ k

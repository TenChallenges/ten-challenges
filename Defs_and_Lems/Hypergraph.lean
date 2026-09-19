import Mathlib.Order.Lattice.Nat

/-- A finite hypergraph with edges contained in its vertex set. -/
structure Hypergraph (α : Type*) where
  vertices : Finset α
  edges : Set (Finset α)
  edges_subset_vertices : ∀ e ∈ edges, e ⊆ vertices

variable {V : Type*} [DecidableEq V] (H : Hypergraph V)

namespace Hypergraph

/-- An `r`-uniform hypergraph has every edge of cardinality `r`. -/
def IsUniform (r : ℕ) : Prop :=
  ∀ e ∈ H.edges, e.card = r

/-- An `r`-partite hypergraph has its vertices partitioned into `r` parts, and
every edge meets every part in exactly one vertex. -/
def IsPartite (r : ℕ) : Prop :=
  ∃ parts : Fin r → Finset V,
    (∀ v : V, v ∈ H.vertices ↔ ∃ i : Fin r, v ∈ parts i) ∧
      (∀ i j : Fin r, i ≠ j → Disjoint (parts i) (parts j)) ∧
        (∀ e ∈ H.edges, ∀ i : Fin r, (parts i ∩ e).card = 1)

/-- A vertex cover is a set of vertices meeting every edge. -/
def IsVertexCover (C : Finset V) : Prop :=
  C ⊆ H.vertices ∧ ∀ e ∈ H.edges, ∃ v ∈ C, v ∈ e

/-- A matching is a finite set of pairwise disjoint edges. -/
def IsMatching (M : Finset (Finset V)) : Prop :=
  (∀ e ∈ M, e ∈ H.edges) ∧
    ∀ e₁ ∈ M, ∀ e₂ ∈ M, e₁ ≠ e₂ → Disjoint e₁ e₂

/-- The cover number `τ(H)`: the least cardinality of a vertex cover, as an
`sInf` over the achievable cover cardinalities (`0` if no cover exists). -/
noncomputable def coverNumber : ℕ :=
  sInf {n | ∃ C : Finset V, H.IsVertexCover C ∧ C.card = n}

/-- The matching number `ν(H)`: the largest size of a matching, as an `sSup`
over the achievable matching sizes. -/
noncomputable def matchingNumber : ℕ :=
  sSup {n | ∃ M : Finset (Finset V), H.IsMatching M ∧ M.card = n}

/-- Ryser's hypergraph conjecture for a fixed value of `r`. -/
def RyserConjectureFor (r : ℕ) : Prop :=
  H.IsUniform r → H.IsPartite r → H.coverNumber ≤ (r - 1) * H.matchingNumber

end Hypergraph

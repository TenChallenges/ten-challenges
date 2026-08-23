import Mathlib.Data.Finset.Card
import Mathlib.Order.Lattice.Nat

/-
Ryser's hypergraph conjecture for the chosen `r` (with `2 ≤ r`):
every `r`-partite `r`-uniform hypergraph satisfies
`coverNumber <= (r - 1) * matchingNumber`, where the cover number `τ` is the
least size of a vertex cover and the matching number `ν` is the largest size
of a matching (canonical `sInf`/`sSup` values over the achievable sizes).

For `r = 2` this is a classical theorem of König, and for `r = 3` it was
proved by Aharoni. The hypothesis `2 <= r` is necessary: for `r = 1` the
bound reads `tau <= 0`, which already fails for the single-vertex
single-edge hypergraph (where `tau = nu = 1`).

Under the `IsUniform`/`IsPartite` hypotheses (with `2 <= r`) both invariants
are attained: the vertex set is a cover (each edge meets part `0`), and the
empty matching plus the powerset bound make the matching-size set nonempty
and bounded. So the statement below coincides with the witness-level
phrasing about minimum covers and maximum matchings.
-/

structure Hypergraph (α : Type*) where
  vertices : Finset α
  edges : Set (Finset α)
  edges_subset_vertices : ∀ e ∈ edges, e ⊆ vertices

variable {V : Type*} [DecidableEq V] (H : Hypergraph V)

namespace Hypergraph

/- An `r`-uniform hypergraph has every edge of cardinality `r`. -/
def IsUniform (r : ℕ) : Prop :=
  ∀ {e : Finset V}, e ∈ H.edges -> e.card = r

/-
An `r`-partite hypergraph has its vertices partitioned into `r` parts, and
every edge meets every part in exactly one vertex.
-/
def IsPartite (r : ℕ) : Prop :=
  exists parts : Fin r -> Finset V,
    (∀ v : V, v ∈ H.vertices <-> exists i : Fin r, v ∈ parts i) ∧
      (∀ i j : Fin r, i ≠ j -> Disjoint (parts i) (parts j)) ∧
        (∀ {e : Finset V}, e ∈ H.edges ->
          ∀ i : Fin r, ((parts i) ∩ e).card = 1)

/- A vertex cover is a set of vertices meeting every edge. -/
def IsVertexCover (C : Finset V) : Prop :=
  C ⊆ H.vertices ∧
    ∀ {e : Finset V}, e ∈ H.edges -> exists v : V, v ∈ C ∧ v ∈ e

/- A matching is a finite set of pairwise disjoint edges. -/
def IsMatching (M : Finset (Finset V)) : Prop :=
  (∀ {e : Finset V}, e ∈ M -> e ∈ H.edges) ∧
    ∀ {e1 : Finset V}, e1 ∈ M ->
      ∀ {e2 : Finset V}, e2 ∈ M -> e1 ≠ e2 -> Disjoint e1 e2

/- The cover number `τ(H)`: the least cardinality of a vertex cover, as an
`sInf` over the achievable cover cardinalities (`0` if no cover exists). -/
noncomputable def coverNumber : ℕ :=
  sInf {n | exists C : Finset V, H.IsVertexCover C ∧ C.card = n}

/- The matching number `ν(H)`: the largest size of a matching, as an `sSup`
over the achievable matching sizes. -/
noncomputable def matchingNumber : ℕ :=
  sSup {n | exists M : Finset (Finset V), H.IsMatching M ∧ M.card = n}

/- Ryser's hypergraph conjecture for a fixed value of `r`. -/
def RyserConjectureFor (r : ℕ) : Prop :=
  H.IsUniform r ->
    H.IsPartite r ->
      H.coverNumber <= (r - 1) * H.matchingNumber

end Hypergraph

universe u

/-- Ryser's hypergraph conjecture for a fixed parameter `r`, quantified over every
hypergraph (with the necessary `2 ≤ r` hypothesis). The single named statement
shared by the canonical theorem and the submission signature-shim. -/
def statement_08 (r : ℕ) : Prop :=
  ∀ {V : Type u} [DecidableEq V] (H : Hypergraph V),
    2 ≤ r → Hypergraph.RyserConjectureFor H r

/- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_8 : statement_08.{u} r := by
  sorry

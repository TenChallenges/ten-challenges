import Mathlib.Combinatorics.Digraph.Basic
import Mathlib.Data.Set.Card
import Mathlib.Logic.Equiv.Fin.Rotate

namespace Digraph

variable {V : Type*} (G : Digraph V)

/-- The out-degree of `v`: the number of out-neighbours of `v`. -/
noncomputable def outDegree (v : V) : ℕ := {w | G.Adj v w}.ncard

/-- A directed cycle of length `ℓ`: `ℓ` distinct vertices, each joined by an arc
to the next one, cyclically. -/
def HasCycleOfLength (ℓ : ℕ) : Prop :=
  ∃ f : Fin ℓ → V, Function.Injective f ∧ ∀ i, G.Adj (f i) (f (finRotate ℓ i))

end Digraph

/-- The Caccetta–Häggkvist conjecture at minimum out-degree `r`: every loopless
digraph on `n ≥ 1` vertices in which every vertex has out-degree at least `r` has
a directed cycle of length at most `⌈n / r⌉`, i.e. of some length `ℓ` with
`ℓ * r < n + r`. -/
def CaccettaHaggkvistFor (r : ℕ) : Prop :=
  0 < r → ∀ {V : Type} [Fintype V] [Nonempty V] (G : Digraph V),
    (∀ v, ¬ G.Adj v v) → (∀ v, r ≤ G.outDegree v) →
      ∃ ℓ, 2 ≤ ℓ ∧ ℓ * r < Fintype.card V + r ∧ G.HasCycleOfLength ℓ

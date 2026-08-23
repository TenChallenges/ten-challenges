import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.SetTheory.Cardinal.Basic

/-!
# Shared definitions for the Unfriendly Partition Conjecture
-/

universe u

open scoped Cardinal

variable {V : Type u} (G : SimpleGraph V)

/- Neighbours of `v` mapped to value `b` by `f`. -/
def NeighColored {β : Type*} (f : V → β)
    (v : V) (b : β) : Type u := ↥(G.neighborSet v ∩ f ⁻¹' {b})

/- A partial partition `f : V → Option Bool` is unfriendly at `v` when `v` is assigned
some colour `b` and has at least as many neighbours assigned the opposite colour
`!b` as assigned `b`. -/
def UnfriendlyAt (f : V → Option Bool)
    (v : V) : Prop :=
  ∃ b : Bool, f v = some b ∧
    #(NeighColored G f v (some b)) ≤ #(NeighColored G f v (some (!b)))

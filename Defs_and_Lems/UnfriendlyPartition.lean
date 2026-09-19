import Mathlib.SetTheory.Ordinal.Basic
import Mathlib.Combinatorics.SimpleGraph.Basic

/-!
# Shared definitions for the Unfriendly Partition Conjecture
-/

universe u v

open scoped Cardinal

variable {V : Type u} (G : SimpleGraph V)

/-- Neighbours of `v` mapped to value `b` by `f`. -/
def NeighColored {β : Type*} (f : V → β)
    (v : V) (b : β) : Type u := ↥(G.neighborSet v ∩ f ⁻¹' {b})

/-- `v` is coloured, with at least as many neighbours of the opposite colour as of its own. -/
def UnfriendlyAt (f : V → Option Bool)
    (v : V) : Prop :=
  ∃ b : Bool, f v = some b ∧
    #(NeighColored G f v (some b)) ≤ #(NeighColored G f v (some (!b)))

/-- The empty partial partition. -/
def emptyPartition (V : Type u) : V → Option Bool :=
  fun _ => none

/-- Only finitely many vertices are assigned a colour. -/
def HasFiniteDomain {V : Type u} (f : V → Option Bool) : Prop :=
  {v : V | f v ≠ none}.Finite

/-- `g` extends `f` when all assignments already made by `f` are preserved. -/
def Extends {V : Type u} (f g : V → Option Bool) : Prop :=
  ∀ v b, f v = some b → g v = some b

/-- A finite extension of `f` that is unfriendly at the challenged vertex `v`. -/
def IsLegalResponse {V : Type u} (G : SimpleGraph V)
    (f g : V → Option Bool) (v : V) : Prop :=
  Extends f g ∧ HasFiniteDomain g ∧ UnfriendlyAt G g v

/-- Partitioner wins from `(f, α)`, by recursion on the ordinal clock `α`. -/
def PartitionerWins {V : Type u} (G : SimpleGraph V)
    (f : V → Option Bool) (α : Ordinal.{v}) : Prop :=
  ∀ v : V, ∀ β : Ordinal.{v}, β < α →
    ∃ g : V → Option Bool,
      IsLegalResponse G f g v ∧ PartitionerWins G g β
termination_by α

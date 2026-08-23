import Mathlib.SetTheory.Ordinal.Basic
import Defs_and_Lems.UnfriendlyPartition

universe u v

/- The empty partial partition. -/
def emptyPartition (V : Type u) : V → Option Bool :=
  fun _ => none

/- A partial partition has finite domain when its set of assigned vertices is
finite. -/
def HasFiniteDomain {V : Type u} (f : V → Option Bool) : Prop :=
  {v : V | f v ≠ none}.Finite

/-- `g` extends `f` when all assignments already made by `f` are preserved. -/
def Extends {V : Type u} (f g : V → Option Bool) : Prop :=
  ∀ v b, f v = some b → g v = some b

/- A legal response by Partitioner from position `f` to the challenged
vertex `v`: a finite partial partition `g` extending `f` which is unfriendly at `v`. -/
def IsLegalResponse {V : Type u} (G : SimpleGraph V)
    (f g : V → Option Bool) (v : V) : Prop :=
  Extends f g ∧ HasFiniteDomain g ∧ UnfriendlyAt G g v

/- Partitioner has a winning strategy in the partitioning game from position
`(f, α)`. Defined inductively over `α`. -/
def PartitionerWins {V : Type u} (G : SimpleGraph V)
    (f : V → Option Bool) (α : Ordinal.{v}) : Prop :=
  ∀ v : V, ∀ β : Ordinal.{v}, β < α →
    ∃ g : V → Option Bool,
      IsLegalResponse G f g v ∧ PartitionerWins G g β
termination_by α

/- Scaled Unfriendly Partition Conjecture for a fixed ordinal parameter `r`: on
every countable graph, Partitioner has a winning strategy in the
`r`-partitioning game.  -/
def statement_10 (r : Ordinal.{v}) : Prop :=
  ∀ {V : Type u}, Countable V -> ∀ G : SimpleGraph V,
    PartitionerWins G (emptyPartition V) r

/- The challenge parameter -/
def r : Ordinal.{v} := sorry

theorem challenge_10 :
    statement_10.{u, v} r := by
  sorry

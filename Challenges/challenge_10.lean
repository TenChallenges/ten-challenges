import Defs_and_Lems.UnfriendlyPartition

universe u v

/-- Partitioner wins the `r`-partitioning game on every countable graph. -/
def statement_10 (r : Ordinal.{v}) : Prop :=
  ∀ {V : Type u}, Countable V -> ∀ G : SimpleGraph V,
    PartitionerWins G (emptyPartition V) r

/-- The challenge parameter. -/
def r : Ordinal.{v} := sorry

theorem challenge_10 :
    statement_10.{u, v} r := sorry

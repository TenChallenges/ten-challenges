import Defs_and_Lems.AlphaWQO

/-!
# Better-Quasi-Ordering of
# Finite Graphs under Minor Relation
-/

def statement_06 (r : Ordinal) : Prop :=
  if r % 2 = 0
  then IsAlphaWQO PlanarGraph.MinorLE (r / 2)
  else IsAlphaWQO FiniteGraph.MinorLE (r / 2)

def r : Ordinal.{0} := sorry

theorem challenge_6 : statement_06 r := sorry

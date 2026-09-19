import Defs_and_Lems.AlphaWQO

/-- `(r / 2)`-WQO under minors:
planar graphs when `r % 2 = 0`,
all finite graphs otherwise. -/
def statement_06 (r : Ordinal) : Prop :=
  if r % 2 = 0
  then IsAlphaWQO PlanarGraph.MinorLE (r / 2)
  else IsAlphaWQO FiniteGraph.MinorLE (r / 2)

/-- The challenge parameter. -/
def r : Ordinal.{0} := sorry

theorem challenge_6 : statement_06 r := sorry

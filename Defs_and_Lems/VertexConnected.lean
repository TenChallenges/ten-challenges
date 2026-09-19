import Defs_and_Lems.Minor

/-- Compatibility name for archived submissions. -/
abbrev SimpleGraph.ConnectedOn {V : Type*} (G : SimpleGraph V) (s : Set V) : Prop :=
  (G.induce s).Connected

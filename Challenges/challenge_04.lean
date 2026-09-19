import Defs_and_Lems.Sidorenko

open SimpleGraph

/-- Sidorenko's inequality for bipartite graphs with at most `r` vertices in each side. -/
def statement_04 (r : ℕ) : Prop :=
  ∀ {W V : Type} [Fintype W] [Fintype V] [Nonempty V]
    (H : SimpleGraph W) (G : SimpleGraph V),
    BipartiteBoundedBy H r → SidorenkoFor H G

/-- The challenge parameter. -/
def r : ℕ := sorry

theorem challenge_4 : statement_04 r := sorry

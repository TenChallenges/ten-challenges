import Mathlib.Combinatorics.SimpleGraph.Hasse
import Mathlib.Analysis.SpecialFunctions.Pow.Real

open SimpleGraph

/-- A graph `G` is `H`-free if no induced subgraph of `G` is isomorphic to `H`. -/
def SimpleGraph.IsHFree {V W : Type*} (G : SimpleGraph V) (H : SimpleGraph W) : Prop :=
  ¬ ∃ S : Set V, Nonempty (G.induce S ≃g H)

/-- The Erdős–Hajnal conjecture for a fixed forbidden graph `H`: there is `c_H > 0`
such that every finite `H`-free graph `G` has a clique or an independent set of
size at least `|V(G)|^c_H`. -/
def ErdosHajnalConjectureFor {W : Type*} (H : SimpleGraph W) : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ {V : Type} [Fintype V] (G : SimpleGraph V), G.IsHFree H →
      ∃ s : Finset V, (G.IsClique s ∨ Gᶜ.IsClique s) ∧
        (s.card : ℝ) ≥ (Fintype.card V : ℝ) ^ c

/-- The Erdős–Hajnal conjecture for the path graph `P_r`, at parameter `r`. -/
def statement_05 (r : ℕ) : Prop :=
  ErdosHajnalConjectureFor (pathGraph r)

def r : ℕ := sorry  -- The challenge parameter

/-- The Erdős–Hajnal conjecture for the path graph `P_r`. -/
theorem challenge_5 : statement_05 r := sorry

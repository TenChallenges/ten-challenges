import Mathlib.Combinatorics.SimpleGraph.Hasse
import Mathlib.Analysis.SpecialFunctions.Pow.Real

open SimpleGraph

variable {V W : Type*} [Fintype W] (H : SimpleGraph W)

/-- A graph `G` is `H`-free if no induced subgraph of `G` is isomorphic to `H`. -/
def SimpleGraph.IsHFree {V : Type*} (G : SimpleGraph V) (H : SimpleGraph W) : Prop :=
  ¬ ∃ (S : Set V), Nonempty (G.induce S ≃g H)

/-- The Erdős–Hajnal conjecture for a fixed forbidden graph `H`:
    there exists `c_H > 0` such that every finite `H`-free graph G
    has a clique or independent set of size at least `|V(G)|^c_H`. -/
def ErdosHajnalConjectureFor : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ {V : Type} [Fintype V] (G : SimpleGraph V), G.IsHFree H →
    ∃ (t : ℕ) (s : Finset V),
      (G.IsNClique t s ∨ Gᶜ.IsNClique t s) ∧
      (t : ℝ) ≥ (Fintype.card V : ℝ) ^ (c : ℝ)

/-- The Erdős–Hajnal conjecture for the path graph `P_r`, at parameter `r`. -/
def statement_05 (r : ℕ) : Prop :=
  ErdosHajnalConjectureFor (pathGraph r)

def r : ℕ := sorry  -- The challenge parameter

/-- The Erdős–Hajnal conjecture for the path graph `P_r`. -/
theorem challenge_5 : statement_05 r := sorry

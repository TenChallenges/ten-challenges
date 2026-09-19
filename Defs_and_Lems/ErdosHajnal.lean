import Mathlib.Combinatorics.SimpleGraph.Hasse
import Mathlib.Analysis.SpecialFunctions.Pow.Real

open SimpleGraph

/-- The Erdős–Hajnal conjecture for a fixed forbidden graph `H`: there is `c_H > 0`
such that every finite `H`-free graph `G` has a clique or an independent set of
size at least `|V(G)|^c_H`. -/
def ErdosHajnalConjectureFor {W : Type*} (H : SimpleGraph W) : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ {V : Type} [Fintype V] (G : SimpleGraph V), ¬ H ⊴ G →
      ∃ s : Finset V, (G.IsClique s ∨ Gᶜ.IsClique s) ∧
        (s.card : ℝ) ≥ (Fintype.card V : ℝ) ^ c

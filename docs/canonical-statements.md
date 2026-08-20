# Canonical theorem statements per challenge

For the v1.5 verification pipeline (axiom-ban + signature shim) to work,
each `Challenges/challenge_NN.lean` needs:

- A fixed canonical theorem signature the CI can check against
- A consistent theorem name (so the shim can reference it)
- (For parametrized problems) a `def r : ℕ := sorry` the user fills in

This document proposes what each of the 10 files should look like.
**Please review the math** before I draft Lean. I'm working from the
short descriptions in `automated_compile/src/data/problems.ts` and the
existing partial code; some statements are guesses where the existing
file is empty or skeletal.

## Audit summary

| # | File | Current state | Action needed |
|---|---|---|---|
| 1 | `challenge_01.lean` | ✅ Ready: `def r; theorem challenge_1 (G : SimpleGraph V) : hadwigerNumber G ≤ r → G.Colorable (r + 1) := sorry` | No change |
| 2 | `challenge_02.lean` | ⚠️ Only defs, no `theorem` | **Add canonical theorem (see §2 below)** |
| 3 | `challenge_03.lean` | ⚠️ Theorem named `ramsey_bounds`, not `challenge_3` | **Rename** |
| 4 | `challenge_04.lean` | ❌ Empty file | **Write from scratch** |
| 5 | `challenge_05.lean` | ⚠️ Has all defs, missing the theorem | **Add canonical theorem** |
| 6 | `challenge_06.lean` | ❌ Empty file | **Write from scratch** |
| 7 | `challenge_07.lean` | ⚠️ Three theorems, no `def r`, no `challenge_7` name | **Pick canonical + standardize** |
| 8 | `challenge_08.lean` | ⚠️ Has all defs (`RyserConjectureFor`), no `def r`, no `challenge_8` | **Add `def r` and theorem** |
| 9 | `challenge_09.lean` | ✅ Ready | No change |
| 10 | `challenge_10.lean` | ✅ Ready | No change |

Universal variants (`challenge_NN_univ.lean`) are mostly in good shape
already — patterns from those inform what I propose below.

## Standard shape

Every `Challenges/challenge_NN.lean` should end with:

```lean
def r : ℕ := sorry  -- The challenge parameter (user replaces with their value)

theorem challenge_N <signature> := sorry  -- User replaces sorry with proof
```

Above that line is the canonical preamble: imports, helper defs, and
problem-specific structures (already trusted; the user may not modify
these for the purposes of the leaderboard).

## §2 — challenge_02 (GF(pʳ)-representable matroids)

Existing defs:
- `IsGFRepresentable (p r : ℕ) [Fact p.Prime] (M : Matroid α) : Prop`
- `IsExcludedMinorFor (P : Matroid α → Prop) (M : Matroid α) : Prop`
- `CompleteExcludedMinorList (P : Matroid α → Prop) (L : Set (Matroid α)) : Prop`

**Proposed canonical theorem:**

The user picks `p` and `r` (the field size) and provides a list `L` of
matroids, then proves `L` is a complete list of excluded minors:

```lean
def p : ℕ := sorry  -- Prime characteristic
instance : Fact p.Prime := ⟨sorry⟩  -- Proof that p is prime
def r : ℕ := sorry  -- Field extension degree (so field is GF(p^r))
def L : Set (Matroid α) := sorry  -- The excluded minor list

theorem challenge_2 :
    CompleteExcludedMinorList (IsGFRepresentable p r) (L (α := α)) := sorry
```

**Question for you:**
- The form has *one* `r` parameter, but this problem needs both `p` (prime) and `r` (exponent). How should the submission form handle this? I'd suggest: have the user encode the parameter as `"p=2,r=1"` in the form, and the workflow parses both.

## §3 — challenge_03 (Ramsey Numbers, rename)

Existing theorem at the bottom:

```lean
theorem ramsey_bounds : ∃ d₁ d₂ : ℝ, |d₁ - d₂| ≤ (4 - √2) * (0.9 : ℝ)^r ∧
    ∀ᶠ t in atTop, d₁ ^ t ≤ ramseyNumber t ∧ ramseyNumber t ≤ d₂ ^ t := sorry
```

**Proposed change:** rename `ramsey_bounds` → `challenge_3`. The rest stays. The current `def r : ℕ := 1` should become `def r : ℕ := sorry` so users supply their `r`.

## §4 — challenge_04 (Sidorenko for bounded-side bipartite graphs)

The parameter `r` bounds the cardinality of each side of a bipartition of
`H`. The canonical theorem asserts Sidorenko's density inequality for every
such finite bipartite graph `H` and every nonempty finite host graph `G`.

```lean
def statement_04 (r : ℕ) : Prop :=
  ∀ {W V : Type} [Fintype W] [Fintype V] [Nonempty V]
    (H : SimpleGraph W) (G : SimpleGraph V),
    BipartiteBoundedBy H r → SidorenkoFor H G

def r : ℕ := sorry

theorem challenge_4 : statement_04 r := sorry
```

## §5 — challenge_05 (Erdős-Hajnal)

Existing defs (file is nearly complete): `SimpleGraph.IsHFree`,
`ErdosHajnalConjectureFor`, `def r : ℕ := sorry`,
`ErdosHajnalConjectureForPaths`.

**Proposed: just add the theorem at the bottom:**

```lean
theorem challenge_5 : ErdosHajnalConjectureForPaths := sorry
```

## §6 — challenge_06 (BQO of Finite Graphs)

The file is empty. Better-Quasi-Ordering is a strengthening of
Well-Quasi-Ordering with sophisticated combinatorial structure. Mathlib
has `WellFoundedLT` etc. but not BQO.

**Proposed canonical theorem (very tentative — please confirm):**

```lean
import Mathlib.Combinatorics.SimpleGraph.Minor  -- if it exists
import Mathlib.Order.WellFoundedSet

/-- A sequence is bad in a quasi-order ≤ if no later element is ≥ an earlier one. -/
def IsBadSequence {α : Type*} (le : α → α → Prop) (f : ℕ → α) : Prop :=
  ∀ i j, i < j → ¬ le (f i) (f j)

/-- A quasi-order is BQO if it has no bad sequence indexed by a barrier.
    (Definition is more involved; this is the WQO weakening for sketch purposes.) -/
def IsBQO {α : Type*} (le : α → α → Prop) : Prop := sorry

def r : ℕ := sorry

theorem challenge_6 :
    IsBQO (fun (G H : SimpleGraph (Fin r)) => H.IsMinor G) := sorry
```

**Questions:**
- BQO has a precise barrier-based definition. I sketched WQO; the actual BQO is stronger. Want me to write the full barrier definition?
- Should the parameter `r` constrain vertex count, or is the universal version (`challenge_6_univ`) the only meaningful version?

## §7 — challenge_07 (The Sphere Packing Problem)

Rota's Basis Conjecture (the previous occupant of this slot) was retired here
because its parametrized "scaled weakening" form is already resolved in the
literature (Bucić–Kwan–Pokrovskiy–Sudakov); it lives on in ProofBench as `P024`.
This slot now hosts the **sphere-packing problem**, which is genuinely open.

Canonical theorem (`challenge_7`), universal over the dimension `d`:

```lean
def IsUnitPacking (C : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  ∀ ⦃x⦄, x ∈ C → ∀ ⦃y⦄, y ∈ C → x ≠ y → 2 ≤ dist x y
-- upperDensity C, spherePackingConstant d, latticePackingConstant d as in the file

theorem challenge_7 : ∀ (d : ℕ), spherePackingConstant d = latticePackingConstant d := sorry
```

The statement asks whether lattice packings are always optimal (Δ_d = Δ_dᴸ). It
holds in every solved dimension (`d ∈ {1, 2, 3, 8, 24}`, largest known `24`) and
is open in general. `challenge_07.lean` fixes the dimension via `def d`; the
universal version quantifies over all `d`.

## §8 — challenge_08 (Ryser's Hypergraph Conjecture)

Existing defs match `challenge_09.lean` and `challenge_08_univ.lean` —
all the structure (`Hypergraph`, `IsUniform`, `IsPartite`, …,
`RyserConjectureFor`) is in the file. Missing: `def r` and a top-level
`theorem challenge_8`.

**Proposed:** add at the bottom, mirroring `challenge_09.lean`:

```lean
def r : ℕ := sorry

theorem challenge_8 : RyserConjectureFor.{u} r := sorry
```

(The existing `Hypergraph` namespace in challenge_08.lean would need to
end before this declaration, or the theorem moves inside the namespace.)

---

## Next steps

1. **You review §2–§8** above and reply with:
   - For each "open question", an answer or "your call"
   - Any signature changes you want
   - For challenges where you'd rather write the canonical statement yourself, just tell me to skip
2. **Once approved**, I (or you) edit the `Challenges/*.lean` files to match.
3. **Then** I write the per-problem signature-shim generator and add it to
   the CI workflow on `lean-challenges-submissions`.

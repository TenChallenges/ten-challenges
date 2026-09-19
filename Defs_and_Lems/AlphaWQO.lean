import Mathlib.SetTheory.Ordinal.Arithmetic
import Defs_and_Lems.Minor

open SimpleGraph Ordinal

universe u

/-- A quasi-order is well-quasi-ordered when every infinite sequence
contains an increasing pair. -/
def IsWQO {Q : Type u} (le : Q → Q → Prop) : Prop :=
  ∀ f : ℕ → Q, ∃ i j : ℕ, i < j ∧ le (f i) (f j)

/-- Level `o` of the cumulative hierarchy over `Q`: `VStar Q 0 = Q`,
`VStar Q (succ o)` is the nonempty subsets of `VStar Q o`, and at a limit
`o` it is the disjoint union of all lower levels. -/
noncomputable def VStar (Q : Type u) (o : Ordinal.{u}) : Type u :=
  Ordinal.limitRecOn o
    Q
    (fun _ ih => {S : Set ih // S.Nonempty})
    (fun o _ ih => Σ i : o.ToType, ih (Ordinal.typein (α := o.ToType) (· < ·) i)
      (Ordinal.typein_lt_self i))

/-- Level zero is the base quasi-order. -/
theorem VStar_zero (Q : Type u) : VStar Q 0 = Q :=
  Ordinal.limitRecOn_zero ..

/-- Successor levels consist of nonempty subsets of the preceding level. -/
theorem VStar_succ (Q : Type u) (o : Ordinal.{u}) :
    VStar Q (Order.succ o) = {S : Set (VStar Q o) // S.Nonempty} :=
  Ordinal.limitRecOn_add_one ..

/-- Limit levels are disjoint unions of the preceding levels. -/
theorem VStar_limit (Q : Type u) {o : Ordinal.{u}} (h : Order.IsSuccLimit o) :
    VStar Q o = Σ i : o.ToType, VStar Q (Ordinal.typein (α := o.ToType) (· < ·) i) :=
  Ordinal.limitRecOn_limit _ _ _ _ h

/-- The Nash–Williams game relation `≤*`, as a *heterogeneous* relation
comparing an element of level `a` with an element of level `b`.

A limit-level element is identified with its underlying lower-level element
(the disjoint union is transparent), so `≤*` unwraps limit tags for free; at
successor levels it is the `∀`-Player-I / `∃`-Player-II lift, and at level
`0` it bottoms out in `le`. Well-founded because every unwrap/descent
strictly decreases the ordinal level on the side it acts on. -/
noncomputable def leStar {Q : Type u} (le : Q → Q → Prop) (a : Ordinal.{u}) :
    VStar Q a → ∀ b : Ordinal.{u}, VStar Q b → Prop :=
  Ordinal.limitRecOn (motive := fun a => VStar Q a → ∀ b : Ordinal.{u}, VStar Q b → Prop) a
    -- a = 0 : X is in Q, Player I cannot move; recurse on b (Player II descends).
    (fun X b => Ordinal.limitRecOn (motive := fun b => VStar Q b → Prop) b
      (fun Y => le (cast (VStar_zero Q) X) (cast (VStar_zero Q) Y))
      (fun β ibh Y => ∃ y ∈ (cast (VStar_succ Q β) Y).val, ibh y)
      (fun β hb ibh Y =>
        let Y' := cast (VStar_limit Q hb) Y
        ibh (Ordinal.typein (α := β.ToType) (· < ·) Y'.1) (Ordinal.typein_lt_self _) Y'.2))
    -- a = succ α : Player I picks x ∈ X, then Player II answers from b.
    (fun α ih X b => Ordinal.limitRecOn (motive := fun b => VStar Q b → Prop) b
      (fun Y => ∀ x ∈ (cast (VStar_succ Q α) X).val, ih x 0 Y)
      (fun β _ Y => ∀ x ∈ (cast (VStar_succ Q α) X).val,
        ∃ y ∈ (cast (VStar_succ Q β) Y).val, ih x β y)
      (fun β hb ibh Y =>
        let Y' := cast (VStar_limit Q hb) Y
        ibh (Ordinal.typein (α := β.ToType) (· < ·) Y'.1) (Ordinal.typein_lt_self _) Y'.2))
    -- a limit : X is a disjoint-union
    (fun a ha iha X =>
      let X' := cast (VStar_limit Q ha) X
      iha (Ordinal.typein (α := a.ToType) (· < ·) X'.1) (Ordinal.typein_lt_self _) X'.2)

/-- `(Q, le)` is `α`-well-quasi-ordered when level `α` of
 the cumulative hierarchy over `Q` is well-quasi-ordered under `≤*`. -/
def IsAlphaWQO {Q : Type u} (le : Q → Q → Prop) (a : Ordinal.{u}) : Prop :=
  IsWQO (fun X Y : VStar Q a => leStar le a X a Y)

/-- A finite simple graph, given as a graph on `Fin n` for some `n`. Every finite
graph is isomorphic to one of this form, and the minor relation is invariant under
isomorphism, so nothing is lost; the payoff is that `FiniteGraph : Type`, which keeps
the ordinal parameter of the challenge in universe `0`. -/
def FiniteGraph : Type := Σ n : ℕ, SimpleGraph (Fin n)

/-- The minor order on finite graphs. -/
def FiniteGraph.MinorLE (G H : FiniteGraph) : Prop :=
  Nonempty (Minor G.2 H.2)

/-- A finite planar simple graph. -/
def PlanarGraph : Type :=
  {G : FiniteGraph // G.2.IsWagnerPlanar}

/-- The minor order on finite planar graphs. -/
def PlanarGraph.MinorLE (G H : PlanarGraph) : Prop :=
  FiniteGraph.MinorLE G.val H.val

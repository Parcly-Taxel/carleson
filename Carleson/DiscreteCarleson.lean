import Carleson.Forest
-- import Carleson.Proposition2
-- import Carleson.Proposition3

open MeasureTheory Measure NNReal Metric Complex Set Function BigOperators Bornology
open scoped ENNReal
open Classical -- We use quite some `Finset.filter`
noncomputable section


open scoped ShortVariables
variable {X : Type*} {a : ℕ} {q : ℝ} {K : X → X → ℂ} {σ₁ σ₂ : X → ℤ} {F G : Set X}
  [MetricSpace X] [ProofData a q K σ₁ σ₂ F G] [TileStructure Q D κ S o]

def aux𝓒 (k : ℕ) : Set (Grid X) :=
  {i : Grid X | ∃ j : Grid X, i ≤ j ∧ 2 ^ (- (k : ℤ)) * volume (j : Set X) < volume (G ∩ j) }

/-- The partition `𝓒(G, k)` of `Grid X` by volume, given in (5.1.1) and (5.1.2).
Note: the `G` is fixed with properties in `ProofData`. -/
def 𝓒 (k : ℕ) : Set (Grid X) :=
  aux𝓒 (k + 1) \ aux𝓒 k

/-- The definition `𝔓(k)` given in (5.1.3). -/
def TilesAt (k : ℕ) : Set (𝔓 X) := 𝓘 ⁻¹' 𝓒 k

def aux𝔐 (k n : ℕ) : Set (𝔓 X) :=
  {p ∈ TilesAt k | 2 ^ (- (n : ℤ)) * volume (𝓘 p : Set X) < volume (E₁ p) }

/-- The definition `𝔐(k, n)` given in (5.1.4) and (5.1.5). -/
def 𝔐 (k n : ℕ) : Set (𝔓 X) := maximals (·≤·) (aux𝔐 k n)

/-- The definition `dens'_k(𝔓')` given in (5.1.6). -/
def dens' (k : ℕ) (P' : Set (𝔓 X)) : ℝ≥0∞ :=
  ⨆ p' ∈ P', ⨆ (l : ℝ≥0), ⨆ (_hl : 2 ≤ l),
  ⨆ (p : 𝔓 X) (_h1p : p ∈ TilesAt k) (_h2p : smul l p' ≤ smul l p),
  l ^ (- (a : ℤ)) * volume (E₂ l p) / volume (𝓘 p : Set X)

def auxℭ (k n : ℕ) : Set (𝔓 X) :=
  { p ∈ TilesAt k | 2 ^ (4 * a - n) < dens' k {p} }

/-- The partition `ℭ(k, n)` of `𝔓(k)` by density, given in (5.1.7). -/
def ℭ (k n : ℕ) : Set (𝔓 X) :=
  { p ∈ TilesAt k | dens' k {p} ∈ Ioc (2 ^ (4 * a - n)) (2 ^ (4 * a - (n + 1))) }

/-- The subset `𝔅(p)` of `𝔐(k, n)`, given in (5.1.8). -/
def 𝔅 (k n : ℕ) (p : 𝔓 X) : Set (𝔓 X) :=
  { m ∈ 𝔐 k n | smul 100 p ≤ smul 1 m }

def preℭ₁ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ k n | 2 ^ j ≤ (Finset.univ.filter (· ∈ 𝔅 k n p)).card }

/-- The subset `ℭ₁(k, n, j)` of `ℭ(k, n)`, given in (5.1.9).
Together with `𝔏₀(k, n)` this forms a partition. -/
def ℭ₁ (k n j : ℕ) : Set (𝔓 X) :=
  preℭ₁ k n j \ preℭ₁ k n (j + 1)

/-- The subset `𝔏₀(k, n, j)` of `ℭ(k, n)`, given in (5.1.10). -/
def 𝔏₀ (k n : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ k n | 𝔅 k n p = ∅ }

/-- `𝔏₁(k, n, j, l)` consists of the minimal elements in `ℭ₁(k, n, j)` not in
  `𝔏₁(k, n, j, l')` for some `l' < l`. Defined near (5.1.11). -/
def 𝔏₁ (k n j l : ℕ) : Set (𝔓 X) :=
  minimals (·≤·) (ℭ₁ k n j \ ⋃ (l' < l), 𝔏₁ k n j l')

/-- The subset `ℭ₂(k, n, j)` of `ℭ₁(k, n, j)`, given in (5.1.13).
To check: the current definition assumes that `𝔏₁ k n j (Z * (n + 1)) = ∅`,
otherwise we need to add an upper bound. -/
def ℭ₂ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₁ k n j \ ⋃ (l ≤ Z * (n + 1)), 𝔏₁ k n j l

/-- The subset `𝔘₁(k, n, j)` of `ℭ₁(k, n, j)`, given in (5.1.14). -/
def 𝔘₁ (k n j : ℕ) : Set (𝔓 X) :=
  { u ∈ ℭ₁ k n j | ∀ p ∈ ℭ₁ k n j, 𝓘 u < 𝓘 p → Disjoint (ball_(u) (𝒬 u) 100) (ball_(p) (𝒬 p) 100) }

/-- The subset `𝔏₂(k, n, j)` of `ℭ₂(k, n, j)`, given in (5.1.15). -/
def 𝔏₂ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ₂ k n j | ¬ ∃ u ∈ 𝔘₁ k n j, 𝓘 p ≠ 𝓘 u ∧ smul 2 p ≤ smul 1 u }

/-- The subset `ℭ₃(k, n, j)` of `ℭ₂(k, n, j)`, given in (5.1.16). -/
def ℭ₃ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₂ k n j \ 𝔏₂ k n j

/-- `𝔏₃(k, n, j, l)` consists of the maximal elements in `ℭ₃(k, n, j)` not in
  `𝔏₃(k, n, j, l')` for some `l' < l`. Defined near (5.1.17). -/
def 𝔏₃ (k n j l : ℕ) : Set (𝔓 X) :=
  maximals (·≤·) (ℭ₃ k n j \ ⋃ (l' < l), 𝔏₃ k n j l')

/-- The subset `ℭ₄(k, n, j)` of `ℭ₃(k, n, j)`, given in (5.1.19).
To check: the current definition assumes that `𝔏₃ k n j (Z * (n + 1)) = ∅`,
otherwise we need to add an upper bound. -/
def ℭ₄ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₃ k n j \ ⋃ (l : ℕ), 𝔏₃ k n j l

/-- The subset `𝓛(u)` of `Grid X`, given near (5.1.20).
Note: It seems to also depend on `n`. -/
def 𝓛 (n : ℕ) (u : 𝔓 X) : Set (Grid X) :=
  { i : Grid X | i ≤ 𝓘 u ∧ s i + Z * (n + 1) + 1 = 𝔰 u ∧ ¬ ball (c i) (8 * D ^ s i) ⊆ 𝓘 u }

/-- The subset `𝔏₄(k, n, j)` of `ℭ₄(k, n, j)`, given near (5.1.22).
Todo: we may need to change the definition to say that `p`
is at most the least upper bound of `𝓛 n u` in `Grid X`. -/
def 𝔏₄ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ₄ k n j | ∃ u ∈ 𝔘₁ k n j, (𝓘 p : Set X) ⊆ ⋃ (i ∈ 𝓛 (X := X) n u), i }

/-- The subset `ℭ₅(k, n, j)` of `ℭ₄(k, n, j)`, given in (5.1.23). -/
def ℭ₅ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₄ k n j \ 𝔏₄ k n j

/-- The set $\mathcal{P}_{F,G}$, defined in (5.1.24). -/
def highDensityTiles : Set (𝔓 X) :=
  { p : 𝔓 X | 2 ^ (2 * a + 5) * volume F / volume G ≤ dens₂ {p} }

/-- The exceptional set `G₁`, defined in (5.1.25). -/
def G₁ : Set X := ⋃ (p : 𝔓 X) (_ : p ∈ highDensityTiles), 𝓘 p

/-- The set `A(λ, k, n)`, defined in (5.1.26). -/
def setA (l k n : ℕ) : Set X :=
  {x : X | l * 2 ^ (n + 1) < ∑ p ∈ Finset.univ.filter (· ∈ 𝔐 (X := X) k n),
    (𝓘 p : Set X).indicator 1 x }

lemma setA_subset_iUnion_𝓒 {l k n : ℕ} :
    setA (X := X) l k n ⊆ ⋃ i ∈ 𝓒 (X := X) k, ↑i := fun x mx ↦ by
  simp_rw [setA, mem_setOf, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id,
    Finset.filter_filter] at mx
  replace mx := (zero_le _).trans_lt mx
  rw [Finset.card_pos] at mx
  obtain ⟨p, hp⟩ := mx
  simp_rw [Finset.mem_filter, Finset.mem_univ, true_and, 𝔐] at hp
  rw [mem_iUnion₂]; use 𝓘 p, ?_, hp.2
  have hp' : p ∈ aux𝔐 k n := mem_of_mem_of_subset hp.1 (maximals_subset ..)
  rw [aux𝔐, mem_setOf, TilesAt, mem_preimage] at hp'
  exact hp'.1

lemma setA_subset_setA {l k n : ℕ} : setA (X := X) (l + 1) k n ⊆ setA l k n := by
  refine setOf_subset_setOf.mpr fun x hx ↦ ?_
  calc
    _ ≤ _ := by gcongr; omega
    _ < _ := hx

lemma measurable_setA {l k n : ℕ} : MeasurableSet (setA (X := X) l k n) :=
  measurableSet_lt measurable_const (Finset.measurable_sum _ fun _ _ ↦
    Measurable.indicator measurable_one coeGrid_measurable)

/-- Finset of cubes in `setA`. Appears in the proof of Lemma 5.2.5. -/
def MsetA (l k n : ℕ) : Finset (Grid X) := Finset.univ.filter fun j ↦ (j : Set X) ⊆ setA l k n

/-- The set `G₂`, defined in (5.1.27). -/
def G₂ : Set X := ⋃ (n : ℕ) (k < n), setA (2 * n + 6) k n

/-- The set `G₃`, defined in (5.1.28). -/
def G₃ : Set X := ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3) (p ∈ 𝔏₄ (X := X) k n j), 𝓘 p

/-- The set `G'`, defined below (5.1.28). -/
def G' : Set X := G₁ ∪ G₂ ∪ G₃

/-- The set `𝔓₁`, defined in (5.1.30). -/
def 𝔓₁ : Set (𝔓 X) := ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3), ℭ₅ k n j

variable {k n j l : ℕ} {p p' : 𝔓 X} {x : X}

/-! ## Section 5.2 and Lemma 5.1.1 -/

/-- Lemma 5.2.1 -/
lemma first_exception : volume (G₁ : Set X) ≤ 2 ^ (- 4 : ℤ) * volume G := by
  sorry

/-- Lemma 5.2.2 -/
lemma dense_cover (k : ℕ) : volume (⋃ i ∈ 𝓒 (X := X) k, (i : Set X)) ≤ 2 ^ (k + 1) * volume G := by
  let M : Finset (Grid X) :=
    Finset.univ.filter fun j ↦ (2 ^ (-(k + 1 : ℕ) : ℤ) * volume (j : Set X) < volume (G ∩ j))
  have s₁ : ⋃ i ∈ 𝓒 (X := X) k, (i : Set X) ⊆ ⋃ i ∈ M, ↑i := by
    simp_rw [𝓒]; intro q mq; rw [mem_iUnion₂] at mq ⊢; obtain ⟨i, hi, mi⟩ := mq
    rw [aux𝓒, mem_diff, mem_setOf] at hi; obtain ⟨j, hj, mj⟩ := hi.1
    use j, ?_, mem_of_mem_of_subset mi hj.1
    simpa [M] using mj
  let M' := Grid.maxCubes M
  have s₂ : ⋃ i ∈ M, (i : Set X) ⊆ ⋃ i ∈ M', ↑i := iUnion₂_mono' fun i mi ↦ by
    obtain ⟨j, mj, hj⟩ := Grid.exists_maximal_supercube mi; use j, mj, hj.1
  calc
    _ ≤ volume (⋃ i ∈ M', (i : Set X)) := measure_mono (s₁.trans s₂)
    _ ≤ ∑ i ∈ M', volume (i : Set X) := measure_biUnion_finset_le M' _
    _ ≤ 2 ^ (k + 1) * ∑ j ∈ M', volume (G ∩ j) := by
      rw [Finset.mul_sum]; refine Finset.sum_le_sum fun i hi ↦ ?_
      replace hi : i ∈ M := Finset.mem_of_subset (Finset.filter_subset _ M) hi
      simp_rw [M, Finset.mem_filter, Finset.mem_univ, true_and] at hi
      rw [← ENNReal.rpow_intCast, show (-(k + 1 : ℕ) : ℤ) = (-(k + 1) : ℝ) by simp,
        mul_comm, ← ENNReal.lt_div_iff_mul_lt (by simp) (by simp), ENNReal.div_eq_inv_mul,
        ← ENNReal.rpow_neg, neg_neg] at hi
      exact_mod_cast hi.le
    _ = 2 ^ (k + 1) * volume (⋃ j ∈ M', G ∩ j) := by
      congr; refine (measure_biUnion_finset (fun _ mi _ mj hn ↦ ?_) (fun _ _ ↦ ?_)).symm
      · exact ((Grid.maxCubes_pairwiseDisjoint mi mj hn).inter_right' G).inter_left' G
      · exact measurableSet_G.inter coeGrid_measurable
    _ ≤ _ := mul_le_mul_left' (measure_mono (iUnion₂_subset fun _ _ ↦ inter_subset_left)) _

/-- Lemma 5.2.3 -/
lemma pairwiseDisjoint_E1 : (𝔐 (X := X) k n).PairwiseDisjoint E₁ := fun p mp p' mp' h ↦ by
  change Disjoint _ _
  contrapose! h
  have h𝓘 := (Disjoint.mono (E₁_subset p) (E₁_subset p')).mt h
  wlog hs : s (𝓘 p') ≤ s (𝓘 p) generalizing p p'
  · rw [disjoint_comm] at h h𝓘; rw [not_le] at hs; rw [this p' mp' p mp h h𝓘 hs.le]
  obtain ⟨x, ⟨-, mxp⟩, ⟨-, mxp'⟩⟩ := not_disjoint_iff.mp h
  rw [mem_preimage] at mxp mxp'
  have l𝓘 := Grid.le_def.mpr ⟨(fundamental_dyadic hs).resolve_right (disjoint_comm.not.mpr h𝓘), hs⟩
  have sΩ := (relative_fundamental_dyadic l𝓘).resolve_left <| not_disjoint_iff.mpr ⟨_, mxp', mxp⟩
  exact (eq_of_mem_maximals mp' (mem_of_mem_of_subset mp (maximals_subset ..)) ⟨l𝓘, sΩ⟩).symm

/-- Lemma 5.2.4 -/
lemma dyadic_union (hx : x ∈ setA l k n) : ∃ i : Grid X, x ∈ i ∧ (i : Set X) ⊆ setA l k n := by
  let M : Finset (𝔓 X) := Finset.univ.filter (fun p ↦ p ∈ 𝔐 k n ∧ x ∈ 𝓘 p)
  simp_rw [setA, mem_setOf, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id,
    Finset.filter_filter] at hx ⊢
  obtain ⟨b, memb, minb⟩ := M.exists_min_image 𝔰 (Finset.card_pos.mp (zero_le'.trans_lt hx))
  simp_rw [M, Finset.mem_filter, Finset.mem_univ, true_and] at memb minb
  use 𝓘 b, memb.2; intro c mc; rw [mem_setOf]
  refine hx.trans_le (Finset.card_le_card fun y hy ↦ ?_)
  simp_rw [Finset.mem_filter, Finset.mem_univ, true_and] at hy ⊢
  exact ⟨hy.1, mem_of_mem_of_subset mc (Grid.le_of_mem_of_mem (minb y hy) memb.2 hy.2).1⟩

lemma iUnion_MsetA_eq_setA : ⋃ i ∈ MsetA (X := X) l k n, ↑i = setA (X := X) l k n := by
  ext x
  simp_rw [mem_iUnion₂, MsetA, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor <;> intro mx
  · obtain ⟨j, mj, lj⟩ := mx; exact mem_of_mem_of_subset lj mj
  · obtain ⟨j, mj, lj⟩ := dyadic_union mx; use j, lj, mj

/-- Equation (5.2.7) in the proof of Lemma 5.2.5. -/
lemma john_nirenberg_aux1 {L : Grid X} (mL : L ∈ Grid.maxCubes (MsetA l k n))
    (mx : x ∈ setA (l + 1) k n) (mx₂ : x ∈ L) : 2 ^ (n + 1) ≤
    ∑ q ∈ Finset.univ.filter (fun q ↦ q ∈ 𝔐 (X := X) k n ∧ 𝓘 q ≤ L),
      (𝓘 q : Set X).indicator 1 x := by
  -- LHS of equation (5.2.6) is strictly greater than `(l + 1) * 2 ^ (n + 1)`
  rw [setA, mem_setOf, ← Finset.sum_filter_add_sum_filter_not (p := fun p' ↦ 𝓘 p' ≤ L),
    Finset.filter_filter, Finset.filter_filter] at mx
  -- Rewrite second sum of RHS of (5.2.6) so that it sums over tiles `q` satisfying `L < 𝓘 q`
  nth_rw 2 [← Finset.sum_filter_add_sum_filter_not (p := fun p' ↦ Disjoint (𝓘 p' : Set X) L)] at mx
  rw [Finset.filter_filter, Finset.filter_filter] at mx
  have mid0 : ∑ q ∈ Finset.univ.filter
      (fun p' ↦ (p' ∈ 𝔐 k n ∧ ¬𝓘 p' ≤ L) ∧ Disjoint (𝓘 p' : Set X) L),
      (𝓘 q : Set X).indicator 1 x = 0 := by
    simp_rw [Finset.sum_eq_zero_iff, indicator_apply_eq_zero, imp_false, Finset.mem_filter,
      Finset.mem_univ, true_and]
    rintro y ⟨-, dj⟩
    exact disjoint_right.mp dj mx₂
  rw [mid0, zero_add] at mx
  have req :
      Finset.univ.filter (fun p' ↦ (p' ∈ 𝔐 k n ∧ ¬𝓘 p' ≤ L) ∧ ¬Disjoint (𝓘 p' : Set X) L) =
      Finset.univ.filter (fun p' ↦ p' ∈ 𝔐 k n ∧ L < 𝓘 p') := by
    ext q
    simp_rw [Finset.mem_filter, Finset.mem_univ, true_and, and_assoc, and_congr_right_iff]
    refine fun _ ↦ ⟨fun h ↦ ?_, ?_⟩
    · apply lt_of_le_of_ne <| (le_or_ge_or_disjoint.resolve_left h.1).resolve_right h.2
      by_contra k; subst k; simp at h
    · rw [Grid.lt_def, Grid.le_def, not_and_or, not_le]
      exact fun h ↦ ⟨Or.inr h.2, not_disjoint_iff.mpr ⟨x, mem_of_mem_of_subset mx₂ h.1, mx₂⟩⟩
  rw [req] at mx
  -- The new second sum of RHS is at most `l * 2 ^ (n + 1)`
  set Q₁ := Finset.univ.filter (fun q ↦ q ∈ 𝔐 (X := X) k n ∧ 𝓘 q ≤ L)
  set Q₂ := Finset.univ.filter (fun q ↦ q ∈ 𝔐 (X := X) k n ∧ L < 𝓘 q)
  have Ql : ∑ q ∈ Q₂, (𝓘 q : Set X).indicator 1 x ≤ l * 2 ^ (n + 1) := by
    by_cases h : IsMax L
    · rw [Grid.isMax_iff] at h
      have : Q₂ = ∅ := by
        ext y; simp_rw [Q₂, Finset.mem_filter, Finset.mem_univ, true_and, Finset.not_mem_empty,
          iff_false, not_and, h, Grid.lt_def, not_and_or, not_lt]
        exact fun _ ↦ Or.inr (Grid.le_topCube).2
      simp [this]
    have Lslq : ∀ q ∈ Q₂, L.succ ≤ 𝓘 q := fun q mq ↦ by
      simp_rw [Q₂, Finset.mem_filter, Finset.mem_univ, true_and] at mq
      exact Grid.succ_le_of_lt mq.2
    have Lout : ¬(L.succ : Set X) ⊆ setA (X := X) l k n := by
      by_contra! hs
      rw [Grid.maxCubes, Finset.mem_filter] at mL
      apply absurd _ h
      exact Grid.max_of_le_succ
        (mL.2 L.succ (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hs⟩) Grid.le_succ).symm.le
    rw [not_subset_iff_exists_mem_not_mem] at Lout
    obtain ⟨x', mx', nx'⟩ := Lout
    calc
      _ = ∑ q ∈ Q₂, (𝓘 q : Set X).indicator 1 x' := by
        refine Finset.sum_congr rfl fun q mq ↦ ?_
        simp only [indicator, Pi.one_apply,
          mem_of_mem_of_subset mx₂ (Grid.le_succ.trans (Lslq q mq)).1,
          mem_of_mem_of_subset mx' (Lslq q mq).1]
      _ ≤ ∑ q ∈ Finset.univ.filter (fun q ↦ q ∈ 𝔐 (X := X) k n),
          (𝓘 q : Set X).indicator 1 x' := by
        refine Finset.sum_le_sum_of_subset ?_
        simp_rw [Q₂, ← Finset.filter_filter]
        apply Finset.filter_subset
      _ ≤ l * 2 ^ (n + 1) := by rwa [setA, mem_setOf_eq, not_lt] at nx'
  -- so the (unchanged) first sum of RHS is at least `2 ^ (n + 1)`
  rw [add_one_mul] at mx; omega

/-- Equation (5.2.11) in the proof of Lemma 5.2.5. -/
lemma john_nirenberg_aux2 {L : Grid X} (mL : L ∈ Grid.maxCubes (MsetA l k n)) :
    2 * volume (setA (X := X) (l + 1) k n ∩ L) ≤ volume (L : Set X) := by
  let Q₁ := Finset.univ.filter (fun q ↦ q ∈ 𝔐 (X := X) k n ∧ 𝓘 q ≤ L)
  have Q₁m : ∀ i ∈ Q₁, Measurable ((𝓘 i : Set X).indicator (1 : X → ℝ≥0∞)) := fun _ _ ↦
    Measurable.indicator measurable_one coeGrid_measurable
  have e528 : ∑ q ∈ Q₁, volume (E₁ q) ≤ volume (L : Set X) :=
    calc
      _ = volume (⋃ q ∈ Q₁, E₁ q) := by
        refine (measure_biUnion_finset (fun p mp q mq hn ↦ ?_) (fun _ _ ↦ ?_)).symm
        · simp_rw [Finset.mem_coe, Q₁, Finset.mem_filter] at mp mq
          exact pairwiseDisjoint_E1 mp.2.1 mq.2.1 hn
        · exact (coeGrid_measurable.inter measurableSet_G).inter
            (SimpleFunc.measurableSet_preimage ..)
      _ ≤ volume (⋃ q ∈ Q₁, (𝓘 q : Set X)) := measure_mono (iUnion₂_mono fun q _ ↦ E₁_subset q)
      _ ≤ _ := by
        apply measure_mono (iUnion₂_subset fun q mq ↦ ?_)
        simp_rw [Q₁, Finset.mem_filter] at mq; exact mq.2.2.1
  have e529 : ∑ q ∈ Q₁, volume (𝓘 q : Set X) ≤ 2 ^ n * volume (L : Set X) :=
    calc
      _ ≤ ∑ q ∈ Q₁, 2 ^ n * volume (E₁ q) := by
        refine Finset.sum_le_sum fun q mq ↦ ?_
        simp_rw [Q₁, Finset.mem_filter, 𝔐, maximals, aux𝔐, mem_setOf] at mq
        replace mq := mq.2.1.1.2
        rw [← ENNReal.rpow_intCast, show (-(n : ℕ) : ℤ) = (-n : ℝ) by simp, mul_comm,
          ← ENNReal.lt_div_iff_mul_lt (by simp) (by simp), ENNReal.div_eq_inv_mul,
          ← ENNReal.rpow_neg, neg_neg] at mq
        exact_mod_cast mq.le
      _ ≤ _ := by rw [← Finset.mul_sum]; exact mul_le_mul_left' e528 _
  rw [← ENNReal.mul_le_mul_left (a := 2 ^ n) (by simp) (by simp), ← mul_assoc, ← pow_succ]
  calc
    _ = ∫⁻ x in setA (X := X) (l + 1) k n ∩ L, 2 ^ (n + 1) := (setLIntegral_const _ _).symm
    _ ≤ ∫⁻ x in setA (X := X) (l + 1) k n ∩ L, ∑ q ∈ Q₁, (𝓘 q : Set X).indicator 1 x := by
      refine setLIntegral_mono (by simp) (Finset.measurable_sum Q₁ Q₁m) fun x ⟨mx, mx₂⟩ ↦ ?_
      have : 2 ^ (n + 1) ≤ ∑ q ∈ Q₁, (𝓘 q : Set X).indicator 1 x := john_nirenberg_aux1 mL mx mx₂
      have lcast : (2 : ℝ≥0∞) ^ (n + 1) = ((2 ^ (n + 1) : ℕ) : ℝ).toNNReal := by
        rw [toNNReal_coe_nat, ENNReal.coe_natCast]; norm_cast
      have rcast : ∑ q ∈ Q₁, (𝓘 q : Set X).indicator (1 : X → ℝ≥0∞) x =
          (((∑ q ∈ Q₁, (𝓘 q : Set X).indicator (1 : X → ℕ) x) : ℕ) : ℝ).toNNReal := by
        rw [toNNReal_coe_nat, ENNReal.coe_natCast, Nat.cast_sum]; congr!; simp [indicator]
      rw [lcast, rcast, ENNReal.coe_le_coe]
      exact Real.toNNReal_le_toNNReal (Nat.cast_le.mpr this)
    _ ≤ ∫⁻ x, ∑ q ∈ Q₁, (𝓘 q : Set X).indicator 1 x := setLIntegral_le_lintegral _ _
    _ = ∑ q ∈ Q₁, ∫⁻ x, (𝓘 q : Set X).indicator 1 x := lintegral_finset_sum _ Q₁m
    _ = ∑ q ∈ Q₁, volume (𝓘 q : Set X) := by
      congr!; exact lintegral_indicator_one coeGrid_measurable
    _ ≤ _ := e529

/-- Lemma 5.2.5 -/
lemma john_nirenberg : volume (setA (X := X) l k n) ≤ 2 ^ (k + 1 - l : ℤ) * volume G := by
  induction l with
  | zero =>
    calc
      _ ≤ volume (⋃ i ∈ 𝓒 (X := X) k, (i : Set X)) := measure_mono setA_subset_iUnion_𝓒
      _ ≤ _ := by
        rw [← ENNReal.rpow_intCast, show (k + 1 - (0 : ℕ) : ℤ) = (k + 1 : ℝ) by simp]
        exact_mod_cast dense_cover k
  | succ l ih =>
    suffices 2 * volume (setA (X := X) (l + 1) k n) ≤ volume (setA (X := X) l k n) by
      rw [← ENNReal.mul_le_mul_left (a := 2) (by simp) (by simp), ← mul_assoc]; apply this.trans
      convert ih using 2; nth_rw 1 [← zpow_one 2, ← ENNReal.zpow_add (by simp) (by simp)]
      congr 1; omega
    calc
      _ = 2 * ∑ L ∈ Grid.maxCubes (MsetA (X := X) l k n),
          volume (setA (X := X) (l + 1) k n ∩ L) := by
        congr; rw [← measure_biUnion_finset]
        · congr; ext x; constructor <;> intro h
          · obtain ⟨L', mL'⟩ := dyadic_union h
            have := mem_of_mem_of_subset mL'.1 (mL'.2.trans setA_subset_setA)
            rw [← iUnion_MsetA_eq_setA, mem_iUnion₂] at this
            obtain ⟨M, mM, lM⟩ := this
            obtain ⟨L, mL, lL⟩ := Grid.exists_maximal_supercube mM
            rw [mem_iUnion₂]; use L, mL
            exact ⟨mem_of_mem_of_subset mL'.1 mL'.2, mem_of_mem_of_subset lM lL.1⟩
          · rw [mem_iUnion₂] at h; obtain ⟨i, _, mi₂⟩ := h; exact mem_of_mem_inter_left mi₂
        · exact fun i mi j mj hn ↦
            ((Grid.maxCubes_pairwiseDisjoint mi mj hn).inter_left' _).inter_right' _
        · exact fun _ _ ↦ measurable_setA.inter coeGrid_measurable
      _ ≤ ∑ L ∈ Grid.maxCubes (MsetA (X := X) l k n), volume (L : Set X) := by
        rw [Finset.mul_sum]; exact Finset.sum_le_sum fun L mL ↦ john_nirenberg_aux2 mL
      _ = _ := by
        rw [← measure_biUnion_finset Grid.maxCubes_pairwiseDisjoint (fun _ _ ↦ coeGrid_measurable)]
        congr; ext x; constructor <;> intro h
        · rw [mem_iUnion₂] at h; obtain ⟨i, mi₁, mi₂⟩ := h
          simp only [Grid.maxCubes, Finset.mem_filter, MsetA, Finset.mem_univ, true_and] at mi₁
          exact mem_of_mem_of_subset mi₂ mi₁.1
        · obtain ⟨L', mL'⟩ := dyadic_union h
          have := mem_of_mem_of_subset mL'.1 mL'.2
          rw [← iUnion_MsetA_eq_setA, mem_iUnion₂] at this
          obtain ⟨M, mM, lM⟩ := this
          obtain ⟨L, mL, lL⟩ := Grid.exists_maximal_supercube mM
          rw [mem_iUnion₂]; use L, mL, mem_of_mem_of_subset lM lL.1

/-- An equivalence used in the proof of `second_exception`. -/
def secondExceptionSupportEquiv :
    (support fun n : ℕ ↦ if k < n then (2 : ℝ≥0∞) ^ (-2 * (n - k - 1) : ℤ) else 0) ≃
    support fun n' : ℕ ↦ (2 : ℝ≥0∞) ^ (-2 * n' : ℤ) where
  toFun n := by
    obtain ⟨n, _⟩ := n; use n - k - 1
    rw [mem_support, neg_mul, ← ENNReal.rpow_intCast]; simp
  invFun n' := by
    obtain ⟨n', _⟩ := n'; use n' + k + 1
    simp_rw [mem_support, show k < n' + k + 1 by omega, ite_true, neg_mul, ← ENNReal.rpow_intCast]
    simp
  left_inv n := by
    obtain ⟨n, mn⟩ := n
    rw [mem_support, ne_eq, ite_eq_right_iff, Classical.not_imp] at mn
    simp only [Subtype.mk.injEq]; omega
  right_inv n' := by
    obtain ⟨n', mn'⟩ := n'
    simp only [Subtype.mk.injEq]; omega

/-- Lemma 5.2.6 -/
lemma second_exception : volume (G₂ (X := X)) ≤ 2 ^ (-4 : ℤ) * volume G := by
  calc
    _ ≤ ∑' (n : ℕ), volume (⋃ (k < n), setA (X := X) (2 * n + 6) k n) := measure_iUnion_le _
    _ = ∑' (n : ℕ), volume (⋃ (k : ℕ), if k < n then setA (X := X) (2 * n + 6) k n else ∅) := by
      congr!; exact iUnion_eq_if _
    _ ≤ ∑' (n : ℕ) (k : ℕ), volume (if k < n then setA (X := X) (2 * n + 6) k n else ∅) := by
      gcongr; exact measure_iUnion_le _
    _ = ∑' (k : ℕ) (n : ℕ), if k < n then volume (setA (X := X) (2 * n + 6) k n) else 0 := by
      rw [ENNReal.tsum_comm]; congr!; split_ifs <;> simp
    _ ≤ ∑' (k : ℕ) (n : ℕ), if k < n then 2 ^ (k - 5 - 2 * n : ℤ) * volume G else 0 := by
      gcongr; split_ifs
      · convert john_nirenberg using 3; omega
      · rfl
    _ = ∑' (k : ℕ), 2 ^ (-k - 7 : ℤ) * volume G * ∑' (n' : ℕ), 2 ^ (-2 * n' : ℤ) := by
      congr with k -- n' = n - k - 1; n = n' + k + 1
      have rearr : ∀ n : ℕ, (k - 5 - 2 * n : ℤ) = (-k - 7 + (-2 * (n - k - 1)) : ℤ) := by omega
      conv_lhs =>
        enter [1, n]
        rw [rearr, ENNReal.zpow_add (by simp) (by simp), ← mul_rotate,
          ← mul_zero (volume G * 2 ^ (-k - 7 : ℤ)), ← mul_ite]
      rw [ENNReal.tsum_mul_left, mul_comm (volume G)]; congr 1
      refine Equiv.tsum_eq_tsum_of_support secondExceptionSupportEquiv fun ⟨n, mn⟩ ↦ ?_
      simp_rw [secondExceptionSupportEquiv, Equiv.coe_fn_mk, neg_mul]
      rw [mem_support, ne_eq, ite_eq_right_iff, Classical.not_imp] at mn
      simp_rw [mn.1, ite_true]; congr; omega
    _ ≤ ∑' (k : ℕ), 2 ^ (-k - 7 : ℤ) * volume G * 2 ^ (2 : ℤ) := by
      gcongr
      rw [ENNReal.sum_geometric_two_pow_neg_two, zpow_two]; norm_num
      rw [← ENNReal.coe_ofNat, ← Real.toNNReal_ofNat, ENNReal.coe_le_coe]; norm_num
    _ = 2 ^ (-6 : ℤ) * volume G * 2 ^ (2 : ℤ) := by
      simp_rw [mul_assoc, ENNReal.tsum_mul_right]; congr
      conv_lhs => enter [1, k]; rw [sub_eq_add_neg, ENNReal.zpow_add (by simp) (by simp)]
      nth_rw 1 [ENNReal.tsum_mul_right, ENNReal.sum_geometric_two_pow_neg_one,
        ← zpow_one 2, ← ENNReal.zpow_add] <;> simp
    _ = _ := by rw [← mul_rotate, ← ENNReal.zpow_add] <;> simp

/-- Lemma 5.2.7 -/
lemma top_tiles : ∑ m ∈ Finset.univ.filter (· ∈ 𝔐 (X := X) k n), volume (𝓘 m : Set X) ≤
    2 ^ (n + k + 3) * volume G := by
  sorry

/-- Lemma 5.2.8 -/
lemma tree_count : ∑ u ∈ Finset.univ.filter (· ∈ 𝔘₁ (X := X) k n j), (𝓘 u : Set X).indicator 1 x ≤
    2 ^ (9 * a - j) * ∑ m ∈ Finset.univ.filter (· ∈ 𝔐 (X := X) k n), (𝓘 m : Set X).indicator 1 x
    := by
  sorry

variable (X) in
/-- The constant in Lemma 5.2.9, with value `D ^ (1 - κ * Z * (n + 1))` -/
def C5_2_9 [ProofData a q K σ₁ σ₂ F G] (n : ℕ) : ℝ≥0 := D ^ (1 - κ * Z * (n + 1))

/-- Lemma 5.2.9 -/
lemma boundary_exception {u : 𝔓 X} (hu : u ∈ 𝔘₁ k n l) :
  volume (⋃ i ∈ 𝓛 (X := X) n u, (i : Set X)) ≤ C5_2_9 X n * volume (𝓘 u : Set X) := by
  sorry

/-- Lemma 5.2.10 -/
lemma third_exception : volume (G₃ (X := X)) ≤ 2 ^ (- 4 : ℤ) * volume G := by
  sorry

/-- Lemma 5.1.1 -/
lemma exceptional_set : volume (G' : Set X) ≤ 2 ^ (- 2 : ℤ) * volume G :=
  sorry

/-! ## Section 5.3 -/

/-! Note: the lemmas 5.3.1-5.3.3 are in `TileStructure`. -/

/-- Lemma 5.3.4 -/
lemma ordConnected_tilesAt : OrdConnected (TilesAt k : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  simp_rw [TilesAt, mem_preimage, 𝓒, mem_diff, aux𝓒, mem_setOf] at mp mp'' ⊢
  constructor
  · obtain ⟨J, hJ, _⟩ := mp''.1
    use J, mp'.2.1.trans hJ
  · push_neg at mp ⊢
    exact fun J hJ ↦ mp.2 J (mp'.1.1.trans hJ)

/-- Lemma 5.3.5 -/
lemma ordConnected_C : OrdConnected (ℭ k n : Set (𝔓 X)) := by
  sorry

/-- Lemma 5.3.6 -/
lemma ordConnected_C1 : OrdConnected (ℭ₁ k n j : Set (𝔓 X)) := by
  sorry

/-- Lemma 5.3.7 -/
lemma ordConnected_C2 : OrdConnected (ℭ₂ k n j : Set (𝔓 X)) := by
  sorry

/-- Lemma 5.3.8 -/
lemma ordConnected_C3 : OrdConnected (ℭ₃ k n j : Set (𝔓 X)) := by
  sorry

/-- Lemma 5.3.9 -/
lemma ordConnected_C4 : OrdConnected (ℭ₄ k n j : Set (𝔓 X)) := by
  sorry

/-- Lemma 5.3.10 -/
lemma ordConnected_C5 : OrdConnected (ℭ₅ k n j : Set (𝔓 X)) := by
  sorry

/-- Lemma 5.3.11 -/
lemma dens1_le_dens' {P : Set (𝔓 X)} (hP : P ⊆ TilesAt k) :
    dens₁ P ≤ dens' k P := by
  sorry

/-- Lemma 5.3.12 -/
lemma dens1_le {A : Set (𝔓 X)} (hA : A ⊆ ℭ k n) : dens₁ A ≤ 2 ^ (4 * a - n + 1) := by
  sorry

/-! ## Section 5.4 and Lemma 5.1.2 -/

/-- The constant used in Lemma 5.1.2, with value `2 ^ (235 * a ^ 3) / (q - 1) ^ 4` -/
def C5_1_2 (a : ℝ) (q : ℝ≥0) : ℝ≥0 := 2 ^ (235 * a ^ 3) / (q - 1) ^ 4

lemma C5_1_2_pos : C5_1_2 a nnq > 0 := sorry

lemma forest_union {f : X → ℂ} (hf : ∀ x, ‖f x‖ ≤ F.indicator 1 x) :
  ∫⁻ x in G \ G', ‖∑ p ∈ Finset.univ.filter (· ∈ 𝔓₁), T p f x‖₊ ≤
    C5_1_2 a nnq * volume G ^ (1 - q⁻¹) * volume F ^ q⁻¹  := by
  sorry


/-- The constant used in Lemma 5.1.3, with value `2 ^ (210 * a ^ 3) / (q - 1) ^ 5` -/
def C5_1_3 (a : ℝ) (q : ℝ≥0) : ℝ≥0 := 2 ^ (210 * a ^ 3) / (q - 1) ^ 5

lemma C5_1_3_pos : C5_1_3 a nnq > 0 := sorry

lemma forest_complement {f : X → ℂ} (hf : ∀ x, ‖f x‖ ≤ F.indicator 1 x) :
  ∫⁻ x in G \ G', ‖∑ p ∈ Finset.univ.filter (· ∉ 𝔓₁), T p f x‖₊ ≤
    C5_1_2 a nnq * volume G ^ (1 - q⁻¹) * volume F ^ q⁻¹  := by
  sorry


/-! We might want to develop some API about partitioning a set.
But maybe `Set.PairwiseDisjoint` and `Set.Union` are enough.
Related, but not quite useful: `Setoid.IsPartition`. -/

-- /-- `u` is partitioned into subsets in `C`. -/
-- class Set.IsPartition {α ι : Type*} (u : Set α) (s : Set ι) (C : ι → Set α) : Prop :=
--   pairwiseDisjoint : s.PairwiseDisjoint C
--   iUnion_eq : ⋃ (i ∈ s), C i = u


/-- The constant used in Proposition 2.0.2,
which has value `2 ^ (440 * a ^ 3) / (q - 1) ^ 5` in the blueprint. -/
def C2_0_2 (a : ℝ) (q : ℝ≥0) : ℝ≥0 := C5_1_2 a q + C5_1_2 a q

lemma C2_0_2_pos : C2_0_2 a nnq > 0 := sorry

theorem discrete_carleson :
    ∃ G', Measurable G' ∧ 2 * volume G' ≤ volume G ∧
    ∀ f : X → ℂ, Measurable f → (∀ x, ‖f x‖ ≤ F.indicator 1 x) →
    ∫⁻ x in G \ G', ‖∑ p, T p f x‖₊ ≤
    C2_0_2 a nnq * volume G ^ (1 - q⁻¹) * volume F ^ q⁻¹ := by sorry

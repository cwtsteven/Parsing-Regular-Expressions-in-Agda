{-
  Here the Language and its operations are defined according to:
    The Theory of Parsing, Translation and Compiling (Vol. 1 : Parsing)
    Section 0.2: Set of Strings
      by Alfred V. Aho and Jeffery D. Ullman

  Steven Cheung
  Version 15-03-2016
-}
open import Util
module Language (Σ : Set)(dec : DecEq Σ) where

open import Data.List
open import Relation.Binary.PropositionalEquality
open import Relation.Nullary
open import Data.Product hiding (Σ)
open import Data.Nat

open import Subset renaming (Ø to Øˢ ; ⟦_⟧ to ⟦_⟧ˢ ; _⋃_ to _⋃ˢ_)

open ≡-Reasoning

-- Set of strings over Σ
-- section 0.2.2: Languages
Σ* : Set
Σ* = List Σ

-- Decidable Equality of Σ*
DecEq-Σ* : (u v : Σ*) → Dec (u ≡ v)
DecEq-Σ* = DecEq-List dec 


-- Language as a subset of Σ*
-- section 0.2.2: Languages
Language : Set₁
Language = Subset Σ*

-- Null set
Ø : Language
Ø = Øˢ

-- Set of empty string
⟦ε⟧ : Language
⟦ε⟧ = ⟦ [] ⟧ˢ

-- Set of single alphabet
⟦_⟧ : Σ → Language
⟦ a ⟧ = ⟦ a ∷ [] ⟧ˢ


{- Here we define some operations on languages -}

-- Union
-- section 0.2.3: Operations on Languages
infix 11 _⋃_
_⋃_ : Language → Language → Language
L₁ ⋃ L₂ = L₁ ⋃ˢ L₂

-- Concatenation
-- section 0.2.3: Operations on Languages
infix 12 _•_
_•_ : Language → Language → Language
L₁ • L₂ = λ w → Σ[ u ∈ Σ* ] Σ[ v ∈ Σ* ] (u ∈ L₁ × v ∈ L₂ × w ≡ u ++ v)

-- Closure
-- section 0.2.3: Operations on Languages
infix 11 _^_
_^_ : Language → ℕ → Language
L ^ zero    = ⟦ε⟧
L ^ (suc n) = L • (L ^ n)

infix 13 _⋆
_⋆ : Language → Language
L ⋆ = λ w → Σ[ n ∈ ℕ ] w ∈ L ^ n
  

{- Here we define the set of alphabet containing ε -}

module Σ-with-ε where

  -- Set of alphabet with ε
  data Σᵉ : Set where
    E : Σᵉ
    α : Σ → Σᵉ

  -- Set of strings over Σᵉ
  Σᵉ* : Set
  Σᵉ* = List Σᵉ


  -- Transform a word over Σᵉ to a word over Σ*
  toΣ* : Σᵉ* → Σ*
  toΣ* []         = []
  toΣ* (E   ∷ xs) = toΣ* xs
  toΣ* (α a ∷ xs) = a ∷ toΣ* xs

  -- Decidable Equality of Σᵉ
  DecEq-Σᵉ : DecEq Σ → DecEq Σᵉ
  DecEq-Σᵉ dec E     E      = yes refl
  DecEq-Σᵉ dec E     (α  _) = no (λ ())
  DecEq-Σᵉ dec (α a) E      = no (λ ())
  DecEq-Σᵉ dec (α a) (α  b) with dec a b
  DecEq-Σᵉ dec (α a) (α .a) | yes refl = yes refl
  DecEq-Σᵉ dec (α a) (α  b) | no ¬a≡b  = no  (λ p → ¬σa≡σb ¬a≡b p)
    where
      lem : {a b : Σ} → α a ≡ α b → a ≡ b
      lem refl = refl
      ¬σa≡σb : ¬ (a ≡ b) → ¬ (α a ≡ α b)
      ¬σa≡σb ¬a≡b σa≡σb = ¬a≡b (lem σa≡σb)
  
  -- Lemmas on Σᵉ
  Σᵉ*-lem₁ : ∀ w u
             → toΣ* w ++ toΣ* u ≡ toΣ* (w ++ u)
  Σᵉ*-lem₁ []         ys = refl   
  Σᵉ*-lem₁ (α a ∷ xs) ys = cong (λ xs → a ∷ xs) (Σᵉ*-lem₁ xs ys)
  Σᵉ*-lem₁ (E   ∷ xs) ys = Σᵉ*-lem₁ xs ys
  
  
  Σᵉ*-lem₂ : ∀ w
             → toΣ* (w ∷ʳ E) ≡ toΣ* w
  Σᵉ*-lem₂ []         = refl
  Σᵉ*-lem₂ (α a ∷ xs) = cong (λ xs → a ∷ xs) (Σᵉ*-lem₂ xs)
  Σᵉ*-lem₂ (E   ∷ xs) = Σᵉ*-lem₂ xs
  
  
  Σᵉ*-lem₃ : ∀ w u uᵉ v vᵉ vᵉ₁
             → w ≡ u ++ v
             → u ≡ toΣ* uᵉ
             → v ≡ toΣ* vᵉ
             → toΣ* vᵉ ≡ toΣ* vᵉ₁
             → w ≡ toΣ* (uᵉ ++ E ∷ vᵉ₁)
  Σᵉ*-lem₃ w u uᵉ v vᵉ vᵉ₁ w≡uv u≡uᵉ v≡vᵉ v≡vᵉ₁
    = begin
      w                         ≡⟨ w≡uv ⟩
      u ++ v                    ≡⟨ cong (λ u → u ++ v) u≡uᵉ ⟩
      toΣ* uᵉ ++ v              ≡⟨ cong (λ v → toΣ* uᵉ ++ v) v≡vᵉ ⟩
      toΣ* uᵉ ++ toΣ* vᵉ        ≡⟨ cong (λ v → toΣ* uᵉ ++ v) v≡vᵉ₁ ⟩
      toΣ* uᵉ ++ toΣ* (E ∷ vᵉ₁) ≡⟨ Σᵉ*-lem₁ uᵉ (E ∷ vᵉ₁) ⟩
      toΣ* (uᵉ ++ E ∷ vᵉ₁)
      ∎
  
  
  Σᵉ*-lem₄ : ∀ wᵉ uᵉ vᵉ
             → wᵉ ≡ uᵉ ++ E ∷ vᵉ
             → toΣ* wᵉ ≡ toΣ* uᵉ ++ toΣ* vᵉ
  Σᵉ*-lem₄ wᵉ uᵉ vᵉ wᵉ≡uv
    = begin
      toΣ* wᵉ             ≡⟨ cong toΣ* wᵉ≡uv ⟩
      toΣ* (uᵉ ++ E ∷ vᵉ) ≡⟨ sym (Σᵉ*-lem₁ uᵉ (E ∷ vᵉ)) ⟩
      toΣ* uᵉ ++ toΣ* vᵉ
      ∎
  
  
  Σᵉ*-lem₅ : ∀ w u v uᵉ vᵉ
             → w ≡ u ++ v
             → u ≡ toΣ* uᵉ
             → v ≡ toΣ* vᵉ
             → toΣ* vᵉ ≡ []
             → w ≡ toΣ* uᵉ
  Σᵉ*-lem₅ w u v uᵉ vᵉ w≡uv u≡uᵉ v≡vᵉ v≡[]
    = begin
      w            ≡⟨ w≡uv ⟩
      u ++ v       ≡⟨ cong (λ v → u ++ v) v≡vᵉ ⟩
      u ++ toΣ* vᵉ ≡⟨ cong (λ v → u ++ v) v≡[] ⟩
      u ++ []      ≡⟨ List-lem₂ u ⟩
      u            ≡⟨ u≡uᵉ ⟩
      toΣ* uᵉ
      ∎
      

  Σᵉ*-lem₇ : ∀ w u v uᵉ vᵉ
             → w ≡ u ++ v
             → u ≡ toΣ* uᵉ
             → v ≡ toΣ* vᵉ
             → w ≡ toΣ* (uᵉ ++ E ∷ E ∷ vᵉ)
  Σᵉ*-lem₇ w u v uᵉ vᵉ w≡uv u≡uᵉ v≡vᵉ
    = begin
      w                            ≡⟨ w≡uv ⟩
      u ++ v                       ≡⟨ cong (λ u → u ++ v) u≡uᵉ ⟩
      toΣ* uᵉ ++ v                 ≡⟨ cong (λ v → toΣ* uᵉ ++ v) v≡vᵉ ⟩
      toΣ* uᵉ ++ toΣ* vᵉ           ≡⟨ cong (λ v → toΣ* uᵉ ++ v) refl ⟩
      toΣ* uᵉ ++ toΣ* (E ∷ vᵉ)     ≡⟨ cong (λ v → toΣ* uᵉ ++ v) refl ⟩
      toΣ* uᵉ ++ toΣ* (E ∷ E ∷ vᵉ) ≡⟨ Σᵉ*-lem₁ uᵉ (E ∷ E ∷ vᵉ) ⟩
      toΣ* (uᵉ ++ E ∷ E ∷ vᵉ)
      ∎


  Σᵉ*-lem₈ : ∀ wᵉ uᵉ vᵉ
             → wᵉ ≡ uᵉ ++ vᵉ
             → toΣ* wᵉ ≡ toΣ* uᵉ ++ toΣ* vᵉ
  Σᵉ*-lem₈ wᵉ uᵉ vᵉ w≡uv
    = begin
      toΣ* wᵉ            ≡⟨ cong toΣ* w≡uv ⟩ 
      toΣ* (uᵉ ++ vᵉ)    ≡⟨ sym (Σᵉ*-lem₁ uᵉ vᵉ) ⟩ 
      toΣ* uᵉ ++ toΣ* vᵉ
      ∎

open Σ-with-ε public

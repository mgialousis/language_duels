# Greek Verb Conjugation Class Categorization Fixes

**Date:** 2026-01-30

## Summary

Fixed incorrect verb conjugation class categorization in grammar files based on standard Modern Greek grammar classification system.

## Greek Verb Conjugation Classes

Modern Greek verbs are categorized into three main conjugation classes:

### Class A (Unaccented -ω)
- **Characteristics:** Verbs ending in -ω without accent on final syllable
- **Frequency:** ~75% of all Greek verbs
- **Examples:** βλέπω (see), γράφω (write), παίρνω (take), πίνω (drink), έχω (have)
- **Pattern:** -ω, -εις, -ει, -ουμε, -ετε, -ουν(ε)

### Class B1 (Accented -ώ/-άω with "α")
- **Characteristics:** Verbs ending in -ώ or -άω with accent on final syllable; "α" appears in endings
- **Frequency:** ~15% of Greek verbs
- **Examples:** χτυπώ/χτυπάω (hit), αγαπώ (love), ρωτώ (ask), μιλώ (speak)
- **Pattern:** -ώ/-άω, -άς, -ά/-άει, -άμε/-ούμε, -άτε, -ούν(ε)/-άν(ε)

### Class B2 (Accented -ώ with "ει")
- **Characteristics:** Verbs ending in -ώ with accent on final syllable; "ει" appears in endings
- **Frequency:** ~10% of Greek verbs
- **Examples:** θεωρώ (consider), μπορώ (can), φορώ (wear), κρατώ (hold)
- **Pattern:** -ώ, -είς, -εί, -ούμε, -είτε, -ούν(ε)

## Changes Made

### 1. a1_g08_present_tense_regular.json
**Issue:** Labeled χτυπώ as "A' Class" when it's actually B1
**Fix:**
- Changed title from "A' Class (Active Voice)" to "B1 Class (Active Voice)"
- Updated description to explain B1 characteristics (accented -ώ/-άω with 'α' in endings)
- Added rules explaining how to recognize B1 verbs
- Updated table title to include "Verb Family: B1"
- Added tip listing other common B1 verbs

### 2. a1_g09_present_tense_common_irregular.json
**Issue:** File name says "common_irregular" but content correctly describes B2 class (θεωρώ)
**Fix:**
- Changed title from "B' Class" to "B2 Class (Active Voice)"
- Updated description to explain B2 characteristics (accented -ώ with 'ει' in endings)
- Added rules explaining how to recognize B2 verbs and the 'ει' pattern
- Updated table title to include "Verb Family: B2"
- Added tip listing other common B2 verbs
- **Note:** File should be renamed to `a1_g09_present_tense_b2_active.json` for consistency

### 3. a1_g10_present_tense_irregular.json
**Issue:** Mixed truly irregular verbs (πάω, τρώω, λέω, έρχομαι, γίνομαι) with A class regular verbs (βλέπω, παίρνω, πίνω, έχω)
**Fix:**
- Updated description to clarify it covers both irregular and important A class verbs
- Added explanation of A class pattern (75% of Greek verbs)
- Added rules distinguishing irregular verbs from A class verbs
- Updated all table titles to show verb family:
  - πάω → "Verb Family: IRREGULAR"
  - τρώω → "Verb Family: IRREGULAR"
  - λέω → "Verb Family: IRREGULAR"
  - βλέπω → "Verb Family: A CLASS"
  - παίρνω → "Verb Family: A CLASS"
  - πίνω → "Verb Family: A CLASS"
  - έρχομαι → "Verb Family: IRREGULAR"
  - έχω → "Verb Family: A CLASS"
  - γίνομαι → "Verb Family: IRREGULAR"

### 4. a1_g11_present_tense_passive_a.json
**Issue:** Labeled χτυπιέμαι as "A' Class Passive" when it's B1 passive (from B1 active χτυπώ)
**Fix:**
- Changed title from "A' Class (Passive Voice)" to "B1 Class (Passive Voice)"
- Updated description to explain B1 passive comes from B1 active verbs
- Added rule showing B1 active → passive transformation
- Updated table title to include "Verb Family: B1 Passive"

### 5. a1_g12_present_tense_passive_b.json
**Issue:** Labeled as "B' Class Passive" - should be "B2 Class Passive" for clarity
**Fix:**
- Changed title from "B' Class (Passive Voice)" to "B2 Class (Passive Voice)"
- Updated description to explain B2 passive comes from B2 active verbs
- Added rule showing B2 active → passive transformation with note about 'ει'
- Updated table title to include "Verb Family: B2 Passive"

## Benefits for Students

1. **Clear Verb Family Labels:** Every verb example now shows which conjugation family it belongs to
2. **Recognition Patterns:** Students learn how to identify verb classes by accent and endings
3. **Consistent Terminology:** Uses B1/B2 instead of ambiguous "B' class" or "irregular"
4. **Explicit Relationships:** Shows how passive forms relate to active voice verb classes
5. **Common Examples:** Lists other verbs in each family for practice

## Sources

- [Greek Verbs for Beginners - Omilo](https://omilo.com/greek-verbs-for-beginners/)
- [Modern Greek Grammar - Wikipedia](https://en.wikipedia.org/wiki/Modern_Greek_grammar)
- [Appendix:Greek verbs - Wiktionary](https://en.wiktionary.org/wiki/Appendix:Greek_verbs)

## Next Steps (Recommendations)

1. **Rename file:** Consider renaming `a1_g09_present_tense_common_irregular.json` to `a1_g09_present_tense_b2_active.json` for consistency
2. **Create A class lesson:** Consider creating a dedicated A class lesson since it's 75% of Greek verbs
3. **Separate irregular verbs:** Consider separating truly irregular verbs from a1_g10 into their own lesson
4. **Add verb class metadata:** Consider adding a "verbClass" field to the JSON structure for programmatic filtering

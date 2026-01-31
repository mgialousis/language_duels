# New Grammar Lessons Created

**Date:** 2026-01-31
**Created By:** Grammar Categorization Fix
**Updated:** 2026-01-31 - Restructured to fix naming conflicts

## Summary

Created **3 critical missing grammar lessons** for present tense verb conjugation to complete the Greek verb classification system.

**Note:** The original a1_g13 (A class active) was moved to a1_g08 to resolve naming conflicts. The g13 slot now contains the new B1 active lesson.

## Complete Present Tense Verb Coverage

You now have **8 present tense lessons** covering all verb types:

### Active Voice:
1. **A Class** (a1_g08) - γράφω type | Unaccented -ω (75% of verbs!)
2. **B2 Class** (a1_g09) - θεωρώ type | Accented -ώ with "ει" endings
3. **Irregular + A Class** (a1_g10) - πάω, τρώω, λέω, βλέπω, έχω
4. **B1 Class** (a1_g13) ✨ **NEW** - χτυπώ type | Accented -ώ/-άω with "α" endings

### Passive Voice:
5. **B1 Passive** (a1_g11) - χτυπιέμαι type | -ιέμαι, -ιέσαι, -ιέται
6. **B2 Passive** (a1_g12) - θεωρούμαι type | -ούμαι, -είσαι, -είται
7. **A Class Passive** (a1_g14) ✨ **NEW** - γράφομαι type | -ομαι, -εσαι, -εται (Most common!)

### Special:
8. **Deponent Verbs** (a1_g15) ✨ **NEW** - φοβάμαι, κοιμάμαι | Passive form only, no active

---

## New Lessons Details

### 📚 Lesson a1_g08: A Class Active Voice (MOVED FROM g13)

**File:** `a1_g08_present_tense_regular.json`

**Why Critical:** A class represents **75% of all Greek verbs** - this is the default conjugation pattern!

**Characteristics:**
- Verbs ending in unaccented -ω
- Pattern: -ω, -εις, -ει, -ουμε/-ομε, -ετε, -ουν(ε)
- Recognition: NO accent on final -ω

**Example Verbs:**
- γράφω (write) → γράφω, γράφεις, γράφει, γράφουμε, γράφετε, γράφουν
- διαβάζω (read)
- ακούω (hear)
- μαθαίνω (learn)
- ανοίγω (open)
- κλείνω (close)

**Content Includes:**
- 2 conjugation tables (γράφω, διαβάζω)
- 3 usage examples
- 7 exercises (fill-in-blank, multiple choice, full conjugation)
- Clear explanation of A class recognition
- List of common A class verbs

**Note:** This content was originally created as a1_g13 but moved to g08 to match the "regular" filename.

---

### 📚 Lesson a1_g13: B1 Class Active Voice (NEW)

**File:** `a1_g13_present_tense_b1_active.json`

**Why Critical:** B1 class represents **15% of Greek verbs** and includes many high-frequency verbs for emotions and actions!

**Characteristics:**
- Verbs ending in accented -ώ/-άω with 'α' in endings
- Pattern: -ώ/-άω, -άς, -ά, -άμε/-ούμε, -άτε, -ούν(ε)
- Recognition: Accent on final syllable + 'α' in 2nd/3rd person singular

**Example Verbs:**
- χτυπώ (hit/knock) → χτυπώ, χτυπάς, χτυπά, χτυπάμε, χτυπάτε, χτυπούν
- αγαπώ (love)
- μιλώ (speak)
- φορώ (wear)
- κρατώ (hold)
- περνώ (pass)

**Content Includes:**
- 3 conjugation tables (χτυπώ, αγαπώ, μιλώ)
- 4 usage examples
- 7 exercises (fill-in-blank, multiple choice, full conjugation)
- Clear explanation of B1 class recognition
- List of common B1 class verbs

---

### 📚 Lesson a1_g14: A Class Passive Voice

**File:** `a1_g14_present_tense_a_class_passive.json`

**Why Critical:** This was the BIGGEST gap! Most passive verbs follow this pattern (Group 1 passive).

**Characteristics:**
- Formed from A class active verbs
- Pattern: -ομαι, -εσαι, -εται, -όμαστε, -εστε, -ονται
- Formation: Remove -ω, add -ομαι

**Example Verbs:**
- γράφω → γράφομαι (I am written / I enroll)
- πλένω → πλένομαι (I wash myself) - reflexive meaning
- χτενίζω → χτενίζομαι (I comb my hair)

**Content Includes:**
- 2 conjugation tables (γράφομαι, πλένομαι)
- 3 usage examples
- 7 exercises
- Explanation of passive/reflexive meanings
- Formation rules from active to passive

**Key Learning Points:**
- Many A class passive verbs have reflexive meanings
- This is the most common passive pattern in Greek
- Active → Passive transformation is systematic

---

### 📚 Lesson a1_g15: Deponent Verbs

**File:** `a1_g15_present_tense_deponent.json`

**Why Critical:** Essential high-frequency verbs that students MUST learn. These have NO active form.

**Characteristics:**
- Exist ONLY in passive form (-μαι)
- Have active meaning despite passive form
- Group 2B passive classification

**Example Verbs:**
- φοβάμαι (I fear) - NOT "I am feared"
- κοιμάμαι (I sleep)
- θυμάμαι (I remember)
- έρχομαι (I come) - irregular
- γίνομαι (I become) - irregular

**Content Includes:**
- 3 conjugation tables (φοβάμαι, κοιμάμαι, θυμάμαι)
- 4 usage examples
- 8 exercises including matching
- Clear explanation of deponent concept
- Common vs irregular deponents

**Key Learning Points:**
- Deponent verbs are among the most frequent in Greek
- They use passive endings but express active meaning
- Should be memorized as vocabulary items

---

## Updated Files

### Grammar Index Updated
**File:** `assets/data/grammar/grammar_index.json`

Updated lesson structure:
- a1_g08 (order 8) - A class active - Prerequisites: a1_g01_verb_to_be
- a1_g13 (order 13) - B1 class active - Prerequisites: a1_g08_present_tense_regular
- a1_g14 (order 14) - A class passive - Prerequisites: a1_g08_present_tense_regular
- a1_g15 (order 15) - Deponent verbs - Prerequisites: a1_g10_present_tense_irregular

---

## Verb Classification System Complete

### Active Voice Coverage:
✅ **A Class** (75%) - γράφω, διαβάζω, ακούω [a1_g13]
✅ **B1 Class** (15%) - χτυπώ, αγαπώ, μιλώ [a1_g08]
✅ **B2 Class** (10%) - θεωρώ, μπορώ, φορώ [a1_g09]
✅ **Irregular** - πάω, τρώω, λέω, έρχομαι [a1_g10]

### Passive Voice Coverage:
✅ **A Class Passive** (Most common) - γράφομαι, πλένομαι [a1_g14]
✅ **B1 Passive** - χτυπιέμαι, αγαπιέμαι [a1_g11]
✅ **B2 Passive** - θεωρούμαι [a1_g12]
✅ **Deponent** (Passive only) - φοβάμαι, κοιμάμαι [a1_g15]

---

## Student Benefits

1. **Complete Coverage:** All major verb conjugation patterns now covered
2. **Systematic Learning:** Clear progression from A → B1 → B2 → Irregular
3. **Verb Family Labels:** Every verb shows which family it belongs to
4. **Recognition Patterns:** Students learn how to identify verb classes
5. **No More Gaps:** The critical A class (75% of verbs) is no longer missing

---

## Validation

All files validated successfully:
- ✅ a1_g08_present_tense_regular.json - Valid JSON (A class active)
- ✅ a1_g13_present_tense_b1_active.json - Valid JSON (B1 class active)
- ✅ a1_g14_present_tense_a_class_passive.json - Valid JSON (A class passive)
- ✅ a1_g15_present_tense_deponent.json - Valid JSON (Deponent verbs)
- ✅ grammar_index.json - Valid JSON

---

## Next Steps (Optional Improvements)

1. **File Renaming:** Consider renaming `a1_g09_present_tense_common_irregular.json` to `a1_g09_present_tense_b2_active.json` for consistency

2. **Reorganize a1_g10:** Consider splitting the mixed irregular/A class lesson into:
   - Pure irregular verbs (πάω, τρώω, λέω, έρχομαι, γίνομαι)
   - More A class practice verbs

3. **Add Verb Class Filter:** Consider adding a "verbClass" field to JSON for programmatic filtering by class

4. **Cross-References:** Add explicit links between active and passive lessons for the same class

---

## Technical Notes

- All lessons follow the existing grammar lesson structure
- Include romanization for pronunciation help
- Provide English literal translations and Catalan translations
- Include multiple exercise types: fillBlank, multipleChoice, conjugation, matching
- Tables show full conjugation patterns
- Examples include highlights for pedagogical purposes
- Acceptable answer variants included for flexibility

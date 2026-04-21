# searchfor

> **Universal search utility for Stata datasets** — find any text, number, or pattern across all (or selected) variables in one command.

[![Stata version](https://img.shields.io/badge/Stata-14%2B-blue)](https://www.stata.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/yourusername/searchfor)](https://github.com/yourusername/searchfor/releases)

---

## Why searchfor?

Stata's built-in `lookfor` only searches **variable names and labels** — it cannot tell you whether a specific value actually exists anywhere in your data.

`searchfor` fills that gap:

| Feature | `lookfor` | `searchfor` |
|---|---|---|
| Searches variable names | ✅ | ✅ |
| Searches variable labels | ✅ | ✅ |
| Searches actual **values** | ❌ | ✅ |
| Reports hit counts | ❌ | ✅ |
| Reports observation numbers | ❌ | ✅ |
| Searches value labels | ❌ | ✅ |
| Stores results in `r()` | ❌ | ✅ |

---

## Installation

### From GitHub (recommended)

```stata
net install searchfor, from("https://raw.githubusercontent.com/yourusername/searchfor/main/")
```

### Manual

Download `searchfor.ado` and `searchfor.sthlp`, then copy both files to your personal ado directory:

```stata
sysdir           // shows your PERSONAL ado path
```

---

## Quick start

```stata
sysuse auto, clear
searchfor Toyota
```

**Sample output:**

```
──────────────────────────────────────────────────────────────────────────────
  SEARCHFOR  |  Query: "Toyota"   |  Obs in scope: 74   |  Variables to search: 12
──────────────────────────────────────────────────────────────────────────────
              Variable        Type                   Label    Hits  % Match
  ────────────────────────────────────────────────────────────────────────────
                  make       str18           Make and Model       2    2.7%
    └─ Obs: 52, 53
──────────────────────────────────────────────────────────────────────────────
  √ Matched: 1 var(s)   |   Total hits: 2   |   Searched: 12 var(s)   |   Scope: 74 obs
──────────────────────────────────────────────────────────────────────────────
```

---

## Syntax

```stata
searchfor term [if] [in] [, options]
```

### Options

| Option | Description |
|---|---|
| `vars(varlist)` | Search only these variables (default: all) |
| `casesensitive` | Case-sensitive matching (default: insensitive) |
| `exactmatch` | Whole value must equal term (no partial match) |
| `trim` | Trim whitespace before matching |
| `vallabel` | Search numeric variables via their value labels |
| `nostring` | Skip string variables |
| `nonumeric` | Skip numeric variables |
| `nolist` | Suppress observation number listing |
| `maxlist(#)` | Max obs numbers shown per variable (default: 10) |
| `noheader` | Suppress the banner header |
| `wide` | 100-character wide output |

---

## Examples

```stata
* Basic text search
sysuse auto, clear
searchfor Toyota

* Case-sensitive
searchfor Toyota, casesensitive

* Exact match
searchfor "Toyota Celica", exactmatch

* Search a number
searchfor 22

* Search in specific variables
searchfor 22, vars(mpg price weight)

* Search value labels in numeric variables
sysuse nlsw88, clear
searchfor nurse, vallabel

* Combine with if/in
sysuse auto, clear
searchfor Toyota if foreign == 0
searchfor Toyota in 1/40

* String variables only
searchfor a, nonumeric

* Trim whitespace before matching
searchfor "Widget A", exactmatch trim

* Loop over multiple terms
foreach brand in Toyota Honda Buick {
    searchfor `brand', noheader
}

* Use returned values programmatically
searchfor Toyota
display r(total_hits)
display "`r(matched_vars)'"
```

---

## Returned results (`r()`)

After running `searchfor`, the following are stored in `r()`:

| Name | Type | Description |
|---|---|---|
| `r(total_hits)` | scalar | Total matching observations across all variables |
| `r(vars_matched)` | scalar | Number of variables with at least one match |
| `r(vars_searched)` | scalar | Number of variables searched |
| `r(N_scope)` | scalar | Observations in scope (after `if`/`in`) |
| `r(matched_vars)` | macro | Space-separated list of matched variable names |
| `r(hit_counts)` | macro | Space-separated hit counts (same order as `matched_vars`) |
| `r(search_term)` | macro | The search term as supplied |

---

## How matching works

| Scenario | Behaviour |
|---|---|
| String term + string variable | Partial match using `strpos()` (case-insensitive by default) |
| Number term + numeric variable | Exact equality (`var == term`) |
| String term + numeric variable | Partial match on `string(var)` |
| Any term + numeric variable (with `vallabel`) | Partial match on decoded value label |

---

## Output colour guide

- 🟢 **Green** — fewer than 50% of in-scope observations matched  
- 🟡 **Yellow** — more than 50% matched (possibly a widespread value)  
- 🔴 **Red** — 100% of observations matched (constant variable)

---

## Requirements

- Stata **14** or later
- No external dependencies

---

## Comparison with similar commands

| Command | Purpose |
|---|---|
| `lookfor` | Searches variable names and labels only |
| `ds` | Lists variables by type/properties |
| `codebook` | Summarises variable content |
| `findname` | Advanced variable search by properties |
| **`searchfor`** | **Searches actual data values across all variables** |

---

## Contributing

Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/yourusername/searchfor/issues).

Pull requests are appreciated. Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Open a pull request

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

## Citation

If you use `searchfor` in published research, please cite:

```
Your Name (2026). searchfor: Universal search utility for Stata datasets.
Available at: https://github.com/yourusername/searchfor
```

---

## Changelog

### v1.1.0 (2026-04-21)
- Added `vallabel` option for searching numeric variables via value labels
- Added `nostring` / `nonumeric` type filters
- Added `noheader` option for loop-friendly output
- Added `wide` option for wider terminals
- Colour-coded hit counts (green / yellow / red)
- All results returned in `r()`

### v1.0.0
- Initial release

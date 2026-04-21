/* ============================================================================
   searchfor — Example / Demo Script
   ============================================================================
   This file demonstrates every major feature of the searchfor command.
   Run it inside Stata with:  do example.do
   ============================================================================ */

clear all
set more off

* --------------------------------------------------------------------------
*  INSTALL (uncomment one of the lines below the first time you use it)
* --------------------------------------------------------------------------
* net install searchfor, from("https://raw.githubusercontent.com/ranaredoan/searchfor/main/")
* cap ado uninstall searchfor        // re-install cleanly
* net install searchfor, ...

* --------------------------------------------------------------------------
*  PART 1 — Basic string search (auto dataset)
* --------------------------------------------------------------------------
sysuse auto, clear

di as result _newline "{bf:── EXAMPLE 1: Basic string search ──}"
searchfor Toyota

di as result _newline "{bf:── EXAMPLE 2: Case-sensitive search ──}"
searchfor toyota                       // 0 hits — wrong case
searchfor toyota, casesensitive        // still 0 — term is lowercase
searchfor Toyota, casesensitive        // 2 hits

di as result _newline "{bf:── EXAMPLE 3: Exact match ──}"
searchfor "Toyota Celica", exactmatch  // matches exactly "Toyota Celica" only
searchfor Toyota                       // partial — matches all Toyota models

di as result _newline "{bf:── EXAMPLE 4: Restrict to specific variables ──}"
searchfor 22, vars(mpg rep78 gear_ratio)

di as result _newline "{bf:── EXAMPLE 5: Numeric search ──}"
searchfor 3                            // searches all vars for value == 3

di as result _newline "{bf:── EXAMPLE 6: Suppress obs listing ──}"
searchfor a, nolist

di as result _newline "{bf:── EXAMPLE 7: Show up to 25 obs numbers ──}"
searchfor a, maxlist(25)

di as result _newline "{bf:── EXAMPLE 8: Limit to string variables only ──}"
searchfor a, nostring                  // skips string vars — searches numeric
searchfor a, nonumeric                 // skips numeric vars — searches strings

di as result _newline "{bf:── EXAMPLE 9: if/in conditions ──}"
searchfor Toyota if foreign == 0       // domestic cars only
searchfor Toyota in 1/40               // first 40 observations

di as result _newline "{bf:── EXAMPLE 10: Wide output ──}"
searchfor Toyota, wide

* --------------------------------------------------------------------------
*  PART 2 — Value label search (nlsw88 dataset)
* --------------------------------------------------------------------------
sysuse nlsw88, clear

di as result _newline "{bf:── EXAMPLE 11: Search numeric variables via value labels ──}"
searchfor nurse, vallabel              // finds occupation = "Nurse"
searchfor Clerical, vallabel           // finds occupation = "Clerical"

* --------------------------------------------------------------------------
*  PART 3 — Programmatic use (r() results)
* --------------------------------------------------------------------------
sysuse auto, clear

di as result _newline "{bf:── EXAMPLE 12: Using r() return values ──}"
searchfor Toyota, noheader

display ""
display "Returned results:"
display "  r(total_hits)   = " r(total_hits)
display "  r(vars_matched) = " r(vars_matched)
display "  r(vars_searched)= " r(vars_searched)
display "  r(search_term)  = `r(search_term)'"
display "  r(matched_vars) = `r(matched_vars)'"
display "  r(hit_counts)   = `r(hit_counts)'"

* --------------------------------------------------------------------------
*  PART 4 — Loop over multiple search terms
* --------------------------------------------------------------------------
sysuse auto, clear

di as result _newline "{bf:── EXAMPLE 13: Loop over multiple terms ──}"
foreach brand in Toyota Buick Honda VW {
    searchfor `brand', noheader
}

* --------------------------------------------------------------------------
*  PART 5 — Trim whitespace and combined options
* --------------------------------------------------------------------------
* Create a toy dataset with messy strings
clear
input str30 product  float price  str20 category
"  Widget A "  9.99   "  Electronics"
" Gadget B"   19.99   "Toys "
"Widget C  "   4.99   "Electronics"
"  gadget d"  14.99   "Toys"
" WIDGET E "  24.99   "Electronics"
end
label var product  "Product name (may have spaces)"
label var price    "Unit price (USD)"
label var category "Product category"

di as result _newline "{bf:── EXAMPLE 14: trim option ──}"
searchfor Widget                       // finds only exact-embedded "Widget"
searchfor Widget, trim                 // same result (no spaces mid-string)
searchfor widget                       // case-insensitive → finds "Widget" too

di as result _newline "{bf:── EXAMPLE 15: exactmatch with trim ──}"
searchfor "Widget A", exactmatch       // misses "  Widget A " (leading spaces)
searchfor "Widget A", exactmatch trim  // trims then matches → hits

* --------------------------------------------------------------------------
*  DONE
* --------------------------------------------------------------------------
display as result _newline "Example script complete."

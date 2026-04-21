*! version 1.1.0  21apr2026
*! searchfor — Universal search utility for Stata datasets
*! Searches any text, number, or pattern across all (or selected) variables
*! GitHub: https://github.com/yourusername/searchfor
*! Author : Your Name  <you@email.com>

program define searchfor, rclass
    version 14.0

    syntax anything(name=term id="search term" equalok) [if] [in] [,  ///
        Vars(varlist)         /// restrict search to specific variables
        CASEsensitive         /// case-sensitive matching (default: insensitive)
        EXACTmatch            /// whole value must equal term (no partial match)
        NOList                /// suppress observation-number listing
        MAXlist(integer 10)   /// max obs numbers shown per variable (default 10)
        TRIM                  /// trim whitespace before matching string values
        VALlabel              /// also search numeric variables via value labels
        NOString              /// skip string variables
        NONumeric             /// skip numeric variables
        NOHEAder              /// suppress the header banner
        Wide                  /// 100-char wide output instead of 78
    ]

    // =========================================================================
    // 0.  SETUP & VALIDATION
    // =========================================================================
    marksample touse, novarlist
    quietly count if `touse'
    if r(N) == 0 {
        display as error "No observations satisfy the if/in condition."
        exit 2000
    }
    local N_obs = r(N)

    // Resolve variable list
    if `"`vars'"' == "" {
        unab vars : _all
    }

    // Apply type filters
    if "`nostring'`nonumeric'" != "" {
        local fvars ""
        foreach v of local vars {
            local vt : type `v'
            local is_s = (substr("`vt'", 1, 3) == "str")
            if "`nostring'"  != "" &  `is_s' continue
            if "`nonumeric'" != "" & !`is_s' continue
            local fvars `fvars' `v'
        }
        local vars `fvars'
    }

    if "`vars'" == "" {
        display as error "No variables remain after applying type filter."
        exit 498
    }

    local nvars_searched = wordcount("`vars'")

    // Output width
    local W = cond("`wide'" != "", 100, 78)

    // Is the search term a valid number?
    local is_num_term = (real(`"`term'"') < .)

    // Temp variable: observation row number (created once, used for all vars)
    tempvar obs_n str_rep
    quietly generate long `obs_n' = _n

    // =========================================================================
    // 1.  HEADER
    // =========================================================================
    if "`noheader'" == "" {
        display ""
        display as text "{hline `W'}"
        display as result "  {bf:SEARCHFOR}  " ///
            as text "{c |}" ///
            "  Query: " as input `""`term'""' ///
            as text "   {c |}  Obs in scope: " as result "`N_obs'" ///
            as text "   {c |}  Variables to search: " as result "`nvars_searched'"
        display as text "{hline `W'}"

        local col_var  = 20
        local col_type = 10
        local col_lbl  = 24
        local col_hits =  6
        local col_pct  =  7

        display as text ///
            "  " %`col_var's  "Variable"  ///
            "  " %`col_type's "Type"       ///
            "  " %-`col_lbl's "Label"      ///
            "  " %`col_hits's "Hits"       ///
            "  " %`col_pct's  "% Match"
        display as text "  {hline `=`W'-2'}"
    }

    // =========================================================================
    // 2.  SEARCH LOOP
    // =========================================================================
    local n_found    = 0
    local n_total    = 0
    local r_vars     = ""
    local r_counts   = ""

    foreach v of local vars {
        local vtype  : type `v'
        local vlabel : variable label `v'
        local is_str = (substr("`vtype'", 1, 3) == "str")

        // Shorten label for display
        if length(`"`vlabel'"') > 23 {
            local vdisp = substr(`"`vlabel'"', 1, 22) + char(8230)
        }
        else {
            local vdisp `"`vlabel'"'
        }

        // -----------------------------------------------------------------
        // Build match condition
        // -----------------------------------------------------------------
        local mcond ""

        if `is_str' {
            // ---------- String variable ----------
            local mval = cond("`trim'" != "", "lower(trim(`v'))", "lower(`v')")
            local lterm = `"lower(`"`term'"')"'
            if "`casesensitive'" != "" {
                local mval = cond("`trim'" != "", "trim(`v')", "`v'")
                local lterm = `"`"`term'"'"'
            }

            if "`exactmatch'" != "" {
                local mcond `"`mval' == `lterm'"'
            }
            else {
                local mcond `"strpos(`mval', `lterm') > 0"'
            }
        }
        else {
            // ---------- Numeric variable ----------
            if `is_num_term' {
                // Numeric search in numeric variable: equality
                local numterm = real(`"`term'"')
                local mcond "`v' == `numterm'"
            }
            else if "`vallabel'" != "" {
                // Search decoded value labels
                quietly cap drop `str_rep'
                quietly decode `v', gen(`str_rep')
                if _rc == 0 {
                    local mval = cond("`casesensitive'" != "", "`str_rep'", "lower(`str_rep')")
                    local lterm = cond("`casesensitive'" != "", `"`"`term'"'"', `"lower(`"`term'"')"')
                    if "`exactmatch'" != "" {
                        local mcond `"`mval' == `lterm'"'
                    }
                    else {
                        local mcond `"strpos(`mval', `lterm') > 0"'
                    }
                }
            }
            else {
                // Non-numeric term vs numeric var — try string(var) representation
                local mval = "string(`v')"
                if "`exactmatch'" != "" {
                    local mcond `"string(`v') == `"`term'"'"'
                }
                else {
                    local mcond `"strpos(string(`v'), `"`term'"') > 0"'
                }
            }
        }

        if `"`mcond'"' == "" continue

        // Count matches (fast vectorised Stata operation)
        quietly count if (`mcond') & `touse'
        local nmatch = r(N)
        if `nmatch' == 0 continue

        // -----------------------------------------------------------------
        // Record & display
        // -----------------------------------------------------------------
        local ++n_found
        local n_total = `n_total' + `nmatch'
        local r_vars   `r_vars' `v'
        local r_counts `r_counts' `nmatch'

        local pct_raw = `nmatch' / `N_obs' * 100
        local pct : display %5.1f `pct_raw'

        // Colour: red if all obs match, yellow if >50%, green otherwise
        if `pct_raw' >= 100   local crow "err"
        else if `pct_raw' > 50 local crow "input"
        else                   local crow "result"

        display as result ///
            "  " %20s "`v'" ///
            as text ///
            "  " %10s "`vtype'" ///
            "  " %-24s `"`vdisp'"' ///
            "  " as `crow' %6.0f `nmatch' ///
            as text "  " as `crow' %6s "`pct'%"

        // Observation numbers listing
        if "`nolist'" == "" {
            quietly levelsof `obs_n' if (`mcond') & `touse', local(obs_list)
            // Build comma-separated list, capped at maxlist
            local disp_obs ""
            local cnt = 0
            foreach o of local obs_list {
                local ++cnt
                if `cnt' == 1        local disp_obs "`o'"
                else if `cnt' <= `maxlist' local disp_obs "`disp_obs', `o'"
                else                 continue, break
            }
            if `nmatch' > `maxlist' {
                local extra = `nmatch' - `maxlist'
                local disp_obs "`disp_obs'  {c hor}  (+`extra' more)"
            }
            display as text "    {c BLC}{c -} Obs: " as result "`disp_obs'"
        }
    }

    // =========================================================================
    // 3.  FOOTER / SUMMARY
    // =========================================================================
    display as text "  {hline `=`W'-2'}"

    if `n_found' == 0 {
        display as error "  No matches found" ///
            as text " for " as input `""`term'""' ///
            as text " across `nvars_searched' variable(s)."
    }
    else {
        local star = cond(`n_found' > 0, "{bf:{res}√{txt}}", "")
        display as text "  `star' Matched: " ///
            as result "`n_found'" as text " var(s)" ///
            as text "   {c |}   Total hits: " ///
            as result "`n_total'" ///
            as text "   {c |}   Searched: " ///
            as result "`nvars_searched'" as text " var(s)" ///
            as text "   {c |}   Scope: " ///
            as result "`N_obs'" as text " obs"
    }
    display as text "{hline `W'}"
    display ""

    // =========================================================================
    // 4.  RETURN VALUES
    // =========================================================================
    return scalar total_hits    = `n_total'
    return scalar vars_matched  = `n_found'
    return scalar vars_searched = `nvars_searched'
    return scalar N_scope       = `N_obs'
    return local  matched_vars  `r_vars'
    return local  hit_counts    `r_counts'
    return local  search_term   `"`term'"'

end
// end of searchfor.ado

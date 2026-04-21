{smcl}
{* *! version 1.1.0  21apr2026}{...}
{viewerjumpto "Syntax"      "searchfor##syntax"     }{...}
{viewerjumpto "Description" "searchfor##description"}{...}
{viewerjumpto "Options"     "searchfor##options"    }{...}
{viewerjumpto "Returns"     "searchfor##returns"    }{...}
{viewerjumpto "Examples"    "searchfor##examples"   }{...}
{viewerjumpto "Output"      "searchfor##output"     }{...}
{viewerjumpto "Author"      "searchfor##author"     }{...}

{title:Title}

{phang}
{bf:searchfor} {hline 2} Universal search utility for Stata datasets.
Search any text, number, or pattern across all or selected variables.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:searchfor}
{it:term}
{ifin}
[{cmd:,}
{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Variable selection}
{synopt:{opt v:ars(varlist)}}restrict search to {it:varlist} (default: all variables){p_end}
{synopt:{opt nostr:ing}}skip string variables{p_end}
{synopt:{opt nonum:eric}}skip numeric variables{p_end}

{syntab:Matching behaviour}
{synopt:{opt case:sensitive}}case-sensitive string matching (default: case-insensitive){p_end}
{synopt:{opt exact:match}}whole value must equal {it:term}; no partial matching{p_end}
{synopt:{opt trim}}trim leading/trailing whitespace before matching{p_end}
{synopt:{opt val:label}}for numeric variables, search within their value labels{p_end}

{syntab:Output control}
{synopt:{opt nol:ist}}suppress the listing of matching observation numbers{p_end}
{synopt:{opt maxl:ist(#)}}max observation numbers shown per variable (default: {bf:10}){p_end}
{synopt:{opt noh:eader}}suppress the banner header{p_end}
{synopt:{opt wide}}use 100-character wide output instead of 78{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:searchfor} scans every variable in the active dataset (or a specified
subset) and reports which variables contain the search {it:term}, how many
observations match, what percentage of in-scope observations that represents,
and — by default — the exact observation (row) numbers where matches occur.

{pstd}
{it:term} can be:

{p2colset 9 30 30 2}
{p2col:{it:text / string}}partial or exact match against string variables{p_end}
{p2col:{it:number}}exact equality against numeric variables{p_end}
{p2col:{it:text (in numeric var)}}partial match against {cmd:string(}{it:var}{cmd:)} or
value labels (with {opt vallabel}){p_end}
{p2colreset}{...}

{pstd}
All results are also stored in {cmd:r()} for programmatic use after the call.

{marker options}{...}
{title:Options}

{dlgtab:Variable selection}

{phang}
{opt vars(varlist)} specifies the variables to search. If omitted, all
variables in the dataset are searched.

{phang}
{opt nostring} excludes string variables from the search.

{phang}
{opt nonumeric} excludes numeric variables from the search.

{dlgtab:Matching behaviour}

{phang}
{opt casesensitive} makes string comparisons case-sensitive.  By default
{cmd:searchfor} applies {cmd:lower()} to both the variable values and the
search term before comparing.

{phang}
{opt exactmatch} requires the entire stored value to equal {it:term}.  Without
this option, {cmd:searchfor} performs substring (partial) matching using
{cmd:strpos()}.

{phang}
{opt trim} applies {cmd:trim()} to string values before matching, removing
leading and trailing white space.

{phang}
{opt vallabel} instructs {cmd:searchfor} to decode numeric variables and search
within their value labels.  This is useful when the underlying numeric codes
are not informative but the labels contain meaningful text.

{dlgtab:Output control}

{phang}
{opt nolist} suppresses the line showing matching observation numbers.  Only
the summary row per variable is printed.

{phang}
{opt maxlist(#)} sets the maximum number of observation numbers displayed per
variable.  If more observations match than {it:#}, the display shows the first
{it:#} numbers followed by a count of additional matches.  Default is {bf:10}.

{phang}
{opt noheader} suppresses the banner at the top of the output.  Useful when
{cmd:searchfor} is called repeatedly inside a loop.

{phang}
{opt wide} widens the output to 100 characters.  Helpful when variable labels
are long or when using a wide terminal.

{marker returns}{...}
{title:Stored results}

{pstd}
{cmd:searchfor} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(total_hits)}}total number of matching observations across all variables{p_end}
{synopt:{cmd:r(vars_matched)}}number of variables that contain at least one match{p_end}
{synopt:{cmd:r(vars_searched)}}number of variables that were searched{p_end}
{synopt:{cmd:r(N_scope)}}number of observations in scope (after if/in){p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(matched_vars)}}space-separated list of variables with matches{p_end}
{synopt:{cmd:r(hit_counts)}}space-separated hit counts (aligned with {cmd:r(matched_vars)}){p_end}
{synopt:{cmd:r(search_term)}}the search term as supplied{p_end}

{marker output}{...}
{title:Output layout}

{pstd}
The output table contains five columns:

{p2colset 5 22 22 2}
{p2col:{bf:Variable}}variable name{p_end}
{p2col:{bf:Type}}storage type (e.g. {it:str20}, {it:float}, {it:int}){p_end}
{p2col:{bf:Label}}variable label (truncated if long){p_end}
{p2col:{bf:Hits}}number of observations where the term was found{p_end}
{p2col:{bf:% Match}}percentage of in-scope observations that match{p_end}
{p2colreset}{...}

{pstd}
Below each variable row, observation numbers are listed (unless {opt nolist}
is specified or {opt maxlist(0)} is used).

{pstd}
Colour coding of hit counts:{break}
{c -(}{bf:green}{c )-}  fewer than 50% of obs matched{break}
{c -(}{bf:yellow}{c )-}  more than 50% of obs matched{break}
{c -(}{bf:red}{c )-}  100% of obs matched

{marker examples}{...}
{title:Examples}

{pstd}Search all variables for the text "Toyota":{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. searchfor Toyota}{p_end}

{pstd}Case-sensitive search:{p_end}
{phang2}{cmd:. searchfor Toyota, casesensitive}{p_end}

{pstd}Exact match only:{p_end}
{phang2}{cmd:. searchfor "Toyota Celica", exactmatch}{p_end}

{pstd}Search for a number across all variables:{p_end}
{phang2}{cmd:. searchfor 22}{p_end}

{pstd}Restrict search to specific variables:{p_end}
{phang2}{cmd:. searchfor 22, vars(price mpg weight)}{p_end}

{pstd}Search numeric variables via value labels:{p_end}
{phang2}{cmd:. sysuse nlsw88, clear}{p_end}
{phang2}{cmd:. searchfor nurse, vallabel}{p_end}

{pstd}Combine with if/in:{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. searchfor Toyota if foreign == 0}{p_end}

{pstd}Suppress obs listing, show only summary:{p_end}
{phang2}{cmd:. searchfor Toyota, nolist}{p_end}

{pstd}Show up to 20 matching obs numbers:{p_end}
{phang2}{cmd:. searchfor a, maxlist(20)}{p_end}

{pstd}Use returned results programmatically:{p_end}
{phang2}{cmd:. searchfor Toyota}{p_end}
{phang2}{cmd:. display r(total_hits)}{p_end}
{phang2}{cmd:. display "`r(matched_vars)'"}{p_end}

{pstd}Loop over a list of terms:{p_end}
{phang2}{cmd:. foreach word in Toyota Buick Honda {c -(}}{p_end}
{phang2}{cmd:.     searchfor `word', noheader}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

{pstd}Search only string variables for a pattern:{p_end}
{phang2}{cmd:. searchfor "Man", nonumeric trim}{p_end}

{marker author}{...}
{title:Author}

{pstd}
Md. Redoan Hossain Bhuiyan{break}
Dhaka, Bangladesh{break}
{browse "https://github.com/ranaredoan/searchfor":https://github.com/ranaredoan/searchfor}{break}
redoanhossain630@gmail.com

{pstd}
Bug reports and feature requests are welcome via the GitHub issue tracker.

{title:Also see}

{psee}
{help datareport}, {help gencodebook}, {help biascheck}, {help optcounts}
{p_end}

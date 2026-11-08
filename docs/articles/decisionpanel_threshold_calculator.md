# Decision Panel Threshold Calculator (p_t)

> **Not yet released in meddecide.** This article documents
> `decisionpanel`, which is not part of the meddecide 1.0.4 release. It
> is documented here ahead of a future release, so the options, defaults
> and output described below are subject to change and the analysis will
> not appear in your jamovi menu yet. For the analyses that ship today
> see the [meddecide articles
> index](https://www.serdarbalci.com/meddecide/articles/).

## Purpose (Clinician-Friendly)

Use your own harm/benefit assumptions to calculate the threshold
probability p_t at which you would switch from “no treatment” to
“treat”. Then read the Decision Curve at that p_t.

Formula: p_t = harm_false_positive / (harm_false_positive +
benefit_true_positive)

Tips: Only the ratio matters; you can measure “harm” and “benefit” in
any consistent units (risk, cost, discomfort, etc.).

## Quick Calculator

\
`# Enter your assumptions`\
`harm_false_positive``   ``<-`` ``1``   ``# e.g., biopsy harm units`\
`benefit_true_positive`` ``<-`` ``4``   ``# e.g., benefit units of early treatment`\
\
`# Basic validation`\
[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(``harm_false_positive`` ``>=`` ``0``)`\
[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(``benefit_true_positive`` ``>`` ``0``)`\
\
`# Threshold probability p_t = harm / (harm + benefit)`\
`p_t`` ``<-`` ``harm_false_positive`` ``/`` ``(``harm_false_positive`` ``+`` ``benefit_true_positive``)`\
\
[`cat`](https://rdrr.io/r/base/cat.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Recommended threshold p_t = %.2f (%.0f%%)\n"``, ``p_t``, ``100`` ``*`` ``p_t``)``)`

## Sensitivity Check (Optional)

\
`# Explore how p_t changes if benefit varies`\
`benefit_seq`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``2``, ``3``, ``4``, ``6``, ``8``)`\
`pt_seq`` ``<-`` ``harm_false_positive`` ``/`` ``(``harm_false_positive`` ``+`` ``benefit_seq``)`\
\
`result`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``benefit_true_positive ``=`` ``benefit_seq``,`\
`                     p_t ``=`` `[`round`](https://rdrr.io/r/base/Round.html)`(``pt_seq``, ``2``)``,`\
`                     p_t_pct ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`[`round`](https://rdrr.io/r/base/Round.html)`(``100``*``pt_seq``)``, ``"%"``)``)`\
`result`

## Next Steps

- In jamovi, open the `meddecide` menu \> Decision Panel \> Decision
  Curve, set a threshold range that includes your p_t (e.g., 0.20), and
  pick the strategy with the highest net benefit at that p_t.
- See also: `decisionpanel_clinician_guide.md` and `START-HERE.md`.

## Visualizing p_t vs Benefit

\
`benefit_seq`` ``<-`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``1``, ``10``, by ``=`` ``1``)`\
`pt_seq`` ``<-`` ``harm_false_positive`` ``/`` ``(``harm_false_positive`` ``+`` ``benefit_seq``)`\
`df`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``benefit_true_positive ``=`` ``benefit_seq``,`\
`                 p_t ``=`` ``pt_seq``)`\
\
`if`` ``(`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"ggplot2"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`  `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
`  `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``df``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``benefit_true_positive``, y ``=`` ``p_t``)``)`` ``+`\
`    `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``color ``=`` ``"#2C7FB8"``, linewidth ``=`` ``1``)`` ``+`\
`    `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(``color ``=`` ``"#2C7FB8"``)`` ``+`\
`    `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` ``scales``::`[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`\
`    `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``x ``=`` ``"Benefit of a True Positive (units)"``,`\
`         y ``=`` ``"Threshold probability p_t"``,`\
`         title ``=`` ``"Threshold p_t decreases as benefit increases"``,`\
`         subtitle ``=`` ``"p_t = harm_false_positive / (harm_false_positive + benefit_true_positive)"``)`` ``+`\
`    `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`\
`}`

## Visualizing p_t vs Harm (benefit fixed)

\
`# Fix the benefit and vary harm`\
`benefit_true_positive`` ``<-`` ``if`` ``(``!`[`exists`](https://rdrr.io/r/base/exists.html)`(``"benefit_true_positive"``)``)`` ``4`` ``else`` ``benefit_true_positive`\
`harm_seq`` ``<-`` `[`seq`](https://rdrr.io/r/base/seq.html)`(``0``, ``10``, by ``=`` ``1``)`\
`pt_seq_harm`` ``<-`` ``harm_seq`` ``/`` ``(``harm_seq`` ``+`` ``benefit_true_positive``)`\
`df_harm`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(``harm_false_positive ``=`` ``harm_seq``,`\
`                      p_t ``=`` ``pt_seq_harm``)`\
\
`if`` ``(`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``"ggplot2"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`  `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`\
`  `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``df_harm``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``harm_false_positive``, y ``=`` ``p_t``)``)`` ``+`\
`    `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``color ``=`` ``"#D95F02"``, linewidth ``=`` ``1``)`` ``+`\
`    `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(``color ``=`` ``"#D95F02"``)`` ``+`\
`    `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` ``scales``::`[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`\
`    `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``x ``=`` ``"Harm of a False Positive (units)"``,`\
`         y ``=`` ``"Threshold probability p_t"``,`\
`         title ``=`` ``"Threshold p_t increases as harm increases"``,`\
`         subtitle ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"Benefit fixed at "``, ``benefit_true_positive``, ``" units"``)``)`` ``+`\
`    `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`\
`}`

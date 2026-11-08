# Evidence for the 2026-11-08 meddecide 1.1.4 review

These files describe fresh runs against the local 1.1.4 source/archive. The
statistical probe definitions were reused from the umbrella repository's
`development-scripts/audit_*_2026-10-21.R` scripts; their historical comment dates
do not date the current evidence. Synthetic fixtures contain no patient data.

## Authoritative checks

From the meddecide root, with an isolated library at
`/private/tmp/meddecide-release-20261108/lib`:

```r
.libPaths(c("/private/tmp/meddecide-release-20261108/lib", .libPaths()))
testthat::test_local(".", load_package = "installed", reporter = "summary")
rcmdcheck::rcmdcheck(
  path = ".", args = c("--no-manual", "--no-build-vignettes"),
  build_args = "--no-build-vignettes", error_on = "never"
)
```

The library was populated with `R CMD INSTALL --no-multiarch --library=<path> .`.
The installed tests passed 1,226 assertions; `rcmdcheck.log` records a clean check.
The installed test CSV is the testthat result dataframe with its nested `result`
column removed for serialization. The initial generic `test_dir()` diagnostic
run used the wrong lookup environment for private classes and is not the release
test verdict.

From the umbrella root:

```sh
python3 -u tools/release_gate.py --root ../meddecide
node /private/tmp/meddecide-release-20261108/compile.mjs \
  /Library/Frameworks/R.framework/Versions/4.6/Resources/library/jmvtools/node_modules/jamovi-compiler
```

Compiler work was confined to disposable copies. All 15 regenerated headers
matched and UI files were unchanged. `source-sha256.json` freezes the reviewed
code/schema/metadata, while `inventory.json` records completeness and umbrella drift.

## Numerical probes and adaptations

The exact executed R scripts, compiler driver and native harness are preserved in
`scripts/`. Their local paths intentionally identify the checkout and disposable
working directory used in this run. Recreate those paths or adjust paths only when
reproducing elsewhere; preserve numerical expectations and seeds.

| File | Meaning / adaptation |
|---|---|
| cross-analysis-matrix.csv | Current run of the cross-analysis oracle; added the now-required `validationNegative = NULL` and the current grouped path for the agreement sample-size table. 216 PASS, 17 INFO, three supported-contract differences. |
| decisioncurve-matrix.csv | Raw historical extractor run: 170 PASS, 25 flags, one excluded simulation section. Preserved to expose harness drift. |
| decisioncurve-adapted-matrix.csv | The HTML notice extractor additionally strips the current severity prefix. No numerical expected value changed. 191 PASS, four remaining flags: two spelling checks and two unsupported case-control-transport comparisons. |
| kappaSizeFixedN-matrix.csv | Independent cell/root checks, `AUDIT_QUICK=1`: 164 PASS, 14 INFO. The original quick mode suppressed CSV output; only that output guard was removed. Coverage simulation was not run. |
| lassologistic-matrix.csv | Independent FISTA/KKT and performance probes. Replaced the obsolete suitability HTML-content access with native-table result cells. 83 PASS; one missed table-footnote check and one residual-optimism simulation flag; two desktop/native checks outside this script. |
| nogoldstandard-matrix.csv | Independent latent/MAP/rule estimates, identifiability, bootstrap and dependence simulations, plus executable vignette. 132 PASS, zero failures. Two unsupported harness/design checks. |

Commands used for the corresponding frozen scripts:

```sh
Rscript --vanilla cross-analysis.R
AUDIT_SIM=0 Rscript --vanilla decisioncurve-oracle-adapted.R
AUDIT_QUICK=1 Rscript --vanilla kappaSizeFixedN-oracle.R
Rscript --vanilla lassologistic-oracle.R
Rscript --vanilla nogoldstandard-oracle.R
```

The five final matrices contain 786 passing rows. That total includes numerical,
property, simulation and some textual/static rows; it is **not** 786 independent
clinical validations. The complete flag interpretation is in the release report.
Historical `CITED` rows carried by an oracle do not imply that every citation was
independently reverified in this session.

## Native archive

The existing `meddecide_1.1.4.jmo` was extracted to the disposable working directory.
Its bundled libraries were loaded by jamovi's own R, jmvcore and RProtoBuf.

```sh
/Applications/jamovi.app/Contents/Frameworks/R.framework/Versions/4.6/Resources/Rscript \
  --vanilla engine_lifecycle.R
```

`engine_lifecycle.csv` contains 106 observations across 15 analyses, including
valid-result serialization, `.save()`/`.load()`, alternative settings, recovery
and redraw from image state with the data removed. The final harness adds DCA to
the historical fixture list. Some cycles labeled “invalid” in the inherited
harness actually switch between two valid settings.

Four rejected reruns preserve old result content. That is consistent with the
current error-overlay policy and is not classified as a fresh successful result.
Every recovery comparison returned to the original valid tables/text. The harness
catches rejection before the desktop engine's error-overlay handling; its raw
`running/FALSE/FALSE` status text must not be interpreted as GUI acceptance.
No new desktop screenshots, save/reopen inspection, exported-PDF inspection or
cross-platform build was performed.

Archive SHA-256:
`e00d73113e9d84c8afd01fe2780e0f957d44be70d6ce1b4e4a850d7d8fd92106`.

## Documentation

`doc-api.csv` records named-argument/required-argument scanning of parsable R
fences; it has no mismatch rows. This is a static check, not execution of every
displayed example. Several comprehensive articles deliberately disable execution
or require data from the umbrella checkout. The no-gold-standard oracle executes
that vignette; the new fixed-N and methods articles include executable examples.

The standard pkgdown build initially failed on external metadata/cache access.
A local preview was attempted with public-metadata lookups disabled, then the
normal repository build was retried with network/cache access. The normal repository build completed successfully, rendering all 19 articles,
references, home, NEWS and indexes; `pkgdown-network.log` records it. The final
kappa refresh is recorded separately. Deliberately unevaluated articles remain
unevaluated; see the release report. A local
site build does not publish the website.

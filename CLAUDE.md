# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### R Package Development
```bash
# Standard development workflow
devtools::load_all()        # Load package for testing
devtools::document()        # Update documentation and NAMESPACE
devtools::test()           # Run all tests
devtools::check()          # Comprehensive package check
devtools::build()          # Build package tarball
devtools::install()        # Install package locally

# Single test execution
testthat::test_file("tests/testthat/test-decision.R")
```

### Documentation and Website
```bash
# Generate documentation site
pkgdown::build_site()
pkgdown::build_site_github_pages()

# Manual pages only
devtools::document()
```

### jamovi Module Development
- jamovi module files in `jamovi/` directory define UI and analysis structure
- Module version must match package version in both `DESCRIPTION` and `jamovi/0000.yaml`
- JavaScript files in `jamovi/js/` handle dynamic UI behavior
- Module builds to `.jmo` format for jamovi installation

## Architecture Overview

### Dual-Purpose Package Structure
This is both an R package and a jamovi module:
- **R Package**: Standard R functions in `R/` directory
- **jamovi Module**: UI definitions in `jamovi/*.yaml` files
- **Shared Code**: Same R functions serve both interfaces

### Core Components
- **Medical Decision Analysis**: Functions for sensitivity, specificity, PPV, NPV calculations
- **ROC Analysis**: ROC curves, AUC, optimal cutpoint determination  
- **Reliability Assessment**: Cohen's Kappa, Fleiss' Kappa, interrater agreement
- **Sample Size Calculations**: Power analysis and confidence interval approaches
- **Visualization**: Fagan nomograms, ROC plots using ggplot2

### File Organization Pattern
Functions follow consistent naming:
- `*.b.R`: Backend computation functions (called by jamovi)
- `*.h.R`: Helper/utility functions
- `jamovi/*.a.yaml`: Analysis definitions (what the analysis does)
- `jamovi/*.r.yaml`: Results definitions (output structure)
- `jamovi/*.u.yaml`: UI definitions (input controls)
- `jamovi/js/*.js`: JavaScript for dynamic UI behavior

### Key Dependencies
- `jmvcore`: jamovi integration framework
- `pROC`, `cutpointr`: ROC analysis
- `irr`, `epiR`: Statistical analysis
- `ggplot2`: Visualization
- `R6`: Object-oriented class system

## Development Workflow

1. **Code Changes**: Modify functions in `R/` directory
2. **Documentation**: Use roxygen2 comments, run `devtools::document()`
3. **Testing**: Add tests in `tests/testthat/`, run `devtools::test()`
4. **jamovi Updates**: Modify `.yaml` files in `jamovi/` for UI changes
5. **Version Sync**: Update version in both `DESCRIPTION` and `jamovi/0000.yaml`
6. **Pre-commit**: Always run `devtools::check()` before committing

## Data and Examples

Example datasets in `inst/extdata/`:
- `decision_example.csv`: Basic medical decision analysis
- `roc_example.csv`: ROC curve analysis  
- `agreement_example.csv`: Interrater reliability

Access via: `system.file("extdata", "filename.csv", package = "meddecide")`

## CI/CD Pipeline

GitHub Actions automatically:
- Runs R CMD check on multiple platforms
- Deploys pkgdown documentation to GitHub Pages
- Skips builds for "WIP" commits
- Website deploys to: https://www.serdarbalci.com/meddecide/
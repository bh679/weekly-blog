# Weekly Blog

## Project Overview

- **Repo:** [`bh679/weekly-blog`](https://github.com/bh679/weekly-blog)
- **Type:** Automated blog — GitHub Actions generates weekly markdown posts
- **Purpose:** AI-generated summaries of development activity across all of Brennan's projects

## Project Structure

- `README.md` — repo description and blog index
- `posts/` — weekly blog post markdown files (`YYYY-MM-DD.md`)
- `state.json` — cross-project state snapshot for weekly diffing
- `.github/workflows/weekly-blog.yml` — scheduled workflow
- `.github/scripts/fetch-all-data.sh` — cross-project data collection

## Commit & Versioning Rules

- **Version format:** V.MM.PPPP (same as other bh679 projects)
- **Commit messages:** `<type>: <short description>`
- Blog post commits use: `blog: weekly update YYYY-MM-DD`

## Git Hooks

- **pre-commit (version check):** Enforces V.MM.PPPP version bumps on every commit
  - Source: `~/Projects/Claude Templates/standards/hooks/pre-commit-version-check.sh`
  - Install: `cp ~/Projects/Claude\ Templates/standards/hooks/pre-commit-version-check.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`
  - Not tracked by git — must be installed locally per clone

## Rules

- No manual edits to generated blog posts — they are overwritten each week
- `state.json` is managed by the workflow — do not edit manually
- `README.md` index is auto-updated by the workflow

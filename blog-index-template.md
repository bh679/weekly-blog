# Blog Index Page Template

This template governs how the `Home.md` wiki page is structured. The blog index IS the Home page for this wiki (no separate Development-Blog page).

## Page Structure

```markdown
# Development Blog

AI-generated weekly summaries of development activity across all of Brennan's projects. Published every Monday at 10:00 AM UTC via GitHub Actions.

## [Blog Post Title](/bh679/weekly-blog/wiki/Blog:-Title-Slug)
YYYY-MM-DD — All Projects
1-2 sentence abstract describing the key changes this week.

<!-- New posts are added above this line by the blogging agent -->
```

## Rules

- The blog index is the wiki Home page (`Home.md`), NOT a separate Development-Blog page
- Each post entry uses an **H2 heading** with a markdown link: `## [Blog Post Title](/bh679/weekly-blog/wiki/Blog:-Title-Slug)`
- The URL path is `/bh679/weekly-blog/wiki/Blog:-<Title-Slug>` — an absolute path to the wiki page
- The link display text is the blog post title (no date, no subtitle)
- Below the heading: the date and project name on one line (e.g. `2026-02-23 — All Projects`)
- Below that: a 1-2 sentence abstract
- New posts are added **above** the `<!-- New posts are added above this line -->` comment
- Newest posts appear first (reverse chronological order)
- Do NOT use `[[wiki-link]]` syntax for blog post links — it doesn't work reliably in H2 headings

---

## Self-Blog Index Page Format

The self-blog index (`Self-Blog:-Weekly-Blog-Index.md`) is a separate wiki page that tracks changes to the weekly-blog repo itself (workflow updates, prompt changes, new templates, schema changes, etc.).

### Page header (written once on creation, never changed)

```markdown
# Weekly Blog — Development Log

Changes to the workflow, templates, and tooling that generate this automated blog.
Updated automatically every Monday.

<!-- New posts are added above this line -->
```

### Per-entry format

```markdown
## [Post Title](/bh679/weekly-blog/wiki/Self-Blog:-Title-Slug)
YYYY-MM-DD — Weekly Blog
1-2 sentence abstract describing what changed in the weekly-blog repo this week.
```

### Rules

- Entries added above `<!-- New posts are added above this line -->`, newest first
- Date label is `Weekly Blog` (not `All Projects`)
- Post filenames use `Self-Blog:-` prefix (not `Blog:-`)
- Do NOT use `[[wiki-link]]` syntax in H2 links — use absolute markdown links

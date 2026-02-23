# Blog Index Page Template

This template governs how the `Home.md` wiki page is structured. The blog index IS the Home page for this wiki (no separate Development-Blog page).

## Page Structure

```markdown
# Development Blog

AI-generated weekly summaries of development activity across all of Brennan's projects. Published every Monday at 10:00 AM UTC via GitHub Actions.

## [[Blog:-Title-Slug|Blog Post Title]]
YYYY-MM-DD — All Projects
1-2 sentence abstract describing the key changes this week.

<!-- New posts are added above this line by the blogging agent -->
```

## Rules

- The blog index is the wiki Home page (`Home.md`), NOT a separate Development-Blog page
- Each post entry uses an **H2 heading** with a wiki-link: `## [[Blog:-Title-Slug|Blog Post Title]]`
- The wiki-link target is the blog post filename without `.md` (e.g. `Blog:-AutoClaude-Launches-and-Chess-Gets-User-Accounts`)
- The link display text is the blog post title (no date)
- Below the heading: the date and project name on one line (e.g. `2026-02-23 — All Projects`)
- Below that: a 1-2 sentence abstract
- New posts are added **above** the `<!-- New posts are added above this line -->` comment
- Newest posts appear first (reverse chronological order)

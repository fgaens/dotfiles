---
name: bear-note
description: Create notes in the Bear app (macOS) from markdown content via its x-callback-url scheme. Use when the user asks to "create a bear note", "save this to Bear", "make a Bear note out of this", or otherwise capture content into Bear.
metadata: {"clawdbot":{"emoji":"🐻","requires":{"bins":["python3","open"]}}}
---

# Bear Note

Create a note in the [Bear](https://bear.app/) app on macOS by triggering its
`bear://x-callback-url/create` URL with `open`.

## The one thing that matters: encoding

Bear's x-callback-url expects **percent-encoding** (spaces → `%20`). The common
mistake is using form-encoding (`urllib.parse.urlencode`, which encodes spaces as
`+`) — that produces a note full of literal `+` signs and broken layout.

**Always encode with `urllib.parse.quote(text, safe='')`** and build the URL by hand.

## How to create a note

1. Write the note's markdown to a temp file (use a heredoc so quotes/backticks are
   preserved literally — do NOT pipe through a shell that interpolates).
2. Run the helper, which percent-encodes the file and opens the Bear URL.

```bash
cat > /tmp/bear_note.md << 'NOTE_EOF'
# My Note Title

#tag1 #tag2

Body content in **markdown**. Backticks `like this` and lists all work.
NOTE_EOF

python3 "$HOME/.claude/skills/bear-note/create_note.py" /tmp/bear_note.md
rm -f /tmp/bear_note.md
```

The helper reads the file (or stdin), percent-encodes it, and opens the note.

## Note conventions

- The **first markdown `# heading` becomes the Bear note title** — always start with one.
- Bear treats `#word` as a **tag**. Put tags on their own line near the top.
  Watch out: any `#`-prefixed token in body text (including markdown `##` headings)
  is fine — Bear only treats single-`#` words as tags, but be deliberate about
  hashtags you don't intend as tags.
- Markdown (headings, bold, lists, code spans/blocks, links) renders natively.

## Helper options

`create_note.py` supports passing a title and tags explicitly instead of relying on
the markdown's first heading:

```bash
# From a file
python3 create_note.py note.md

# From stdin
echo "# Title\n\nbody" | python3 create_note.py -

# Explicit title + tags + don't steal focus
python3 create_note.py note.md --title "My Title" --tags "fednot,architecture" --no-open
```

## x-callback-url reference

`bear://x-callback-url/create` parameters (all values must be percent-encoded):

| param       | meaning                                                      |
|-------------|--------------------------------------------------------------|
| `title`     | note title (else taken from first `#` heading in `text`)     |
| `text`      | note body (markdown)                                         |
| `tags`      | comma-separated tags (alternative to inline `#tags`)         |
| `open_note` | `no` to create without opening the note                     |
| `new_window`| `yes`/`no` (macOS)                                           |
| `pin`       | `yes`/`no` — pin to top of the list                         |

Other useful endpoints: `bear://x-callback-url/search?term=...`,
`bear://x-callback-url/open-note?title=...`.

## Verifying

`open` returns immediately (it just hands the URL to Bear); a `0` exit means the URL
was dispatched, not that the note is visually correct. If the user reports broken
layout, the cause is almost always form-encoding (`+` everywhere) — re-run with
`quote`.

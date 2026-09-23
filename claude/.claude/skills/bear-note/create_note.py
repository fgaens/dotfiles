#!/usr/bin/env python3
"""Create a Bear note from markdown, using correct percent-encoding.

Usage:
    create_note.py <file.md> [--title T] [--tags a,b] [--no-open] [--pin]
    create_note.py -            # read markdown from stdin
"""
import argparse
import subprocess
import sys
import urllib.parse


def main() -> int:
    parser = argparse.ArgumentParser(description="Create a Bear note from markdown.")
    parser.add_argument("source", help="Path to a markdown file, or '-' for stdin.")
    parser.add_argument("--title", help="Note title (defaults to first '# heading').")
    parser.add_argument("--tags", help="Comma-separated tags.")
    parser.add_argument("--no-open", action="store_true",
                        help="Create the note without opening/focusing it.")
    parser.add_argument("--pin", action="store_true", help="Pin the note to the top.")
    args = parser.parse_args()

    if args.source == "-":
        text = sys.stdin.read()
    else:
        with open(args.source, encoding="utf-8") as handle:
            text = handle.read()

    params = [("text", text)]
    if args.title:
        params.append(("title", args.title))
    if args.tags:
        params.append(("tags", args.tags))
    if args.no_open:
        params.append(("open_note", "no"))
    if args.pin:
        params.append(("pin", "yes"))

    query = "&".join(
        f"{key}={urllib.parse.quote(value, safe='')}" for key, value in params
    )
    url = f"bear://x-callback-url/create?{query}"

    subprocess.run(["open", url], check=True)
    print("Bear note created.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""
Format raw Crawl4AI JSON output into structured Markdown for research reports.

Usage:
    python format-crawl4ai-output.py --input raw_crawl.json --output formatted.md
    python format-crawl4ai-output.py --input raw_crawl.json --format table
    cat raw_crawl.json | python format-crawl4ai-output.py --format markdown
"""

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


def load_input(input_path: str | None) -> dict | list:
    """Load JSON from file or stdin."""
    if input_path:
        with open(input_path, "r", encoding="utf-8") as f:
            return json.load(f)
    else:
        return json.load(sys.stdin)


def flatten_nested(data: Any, prefix: str = "") -> dict:
    """Flatten nested dictionaries for table rendering."""
    items = {}
    if isinstance(data, dict):
        for k, v in data.items():
            new_key = f"{prefix}.{k}" if prefix else k
            if isinstance(v, dict):
                items.update(flatten_nested(v, new_key))
            elif isinstance(v, list):
                items[new_key] = "; ".join(str(i) for i in v)
            else:
                items[new_key] = str(v) if v is not None else ""
    return items


def format_as_markdown(data: dict | list, title: str = "Crawl4AI Extracted Data") -> str:
    """Convert extracted data to structured Markdown."""
    lines = [
        f"# {title}",
        f"",
        f"**Formatted**: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        f"",
    ]

    if isinstance(data, dict) and "extracted_content" in data:
        # Raw CrawlResult format
        meta = data.get("metadata", {})
        if meta:
            lines.append("## Page Metadata")
            lines.append("")
            for k, v in meta.items():
                lines.append(f"- **{k}**: {v}")
            lines.append("")

        content = data["extracted_content"]
        if isinstance(content, str):
            try:
                content = json.loads(content)
            except json.JSONDecodeError:
                lines.append("## Extracted Content")
                lines.append("")
                lines.append(content)
                return "\n".join(lines)

        data = content

    if isinstance(data, list):
        lines.append("## Extracted Items")
        lines.append("")
        for i, item in enumerate(data, 1):
            if isinstance(item, dict):
                lines.append(f"### Item {i}")
                lines.append("")
                for k, v in item.items():
                    if isinstance(v, list):
                        lines.append(f"**{k}**:")
                        for li in v:
                            lines.append(f"  - {li}")
                    elif isinstance(v, dict):
                        lines.append(f"**{k}**:")
                        for dk, dv in v.items():
                            lines.append(f"  - {dk}: {dv}")
                    else:
                        lines.append(f"- **{k}**: {v}")
                lines.append("")
            else:
                lines.append(f"- {item}")
    elif isinstance(data, dict):
        lines.append("## Extracted Data")
        lines.append("")
        for k, v in data.items():
            if isinstance(v, list):
                lines.append(f"### {k}")
                lines.append("")
                for item in v:
                    if isinstance(item, dict):
                        for ik, iv in item.items():
                            lines.append(f"- **{ik}**: {iv}")
                        lines.append("")
                    else:
                        lines.append(f"- {item}")
                lines.append("")
            elif isinstance(v, dict):
                lines.append(f"### {k}")
                lines.append("")
                for dk, dv in v.items():
                    lines.append(f"- **{dk}**: {dv}")
                lines.append("")
            else:
                lines.append(f"- **{k}**: {v}")

    return "\n".join(lines)


def format_as_table(data: dict | list) -> str:
    """Convert extracted data to a Markdown table."""
    if isinstance(data, dict) and "extracted_content" in data:
        content = data["extracted_content"]
        if isinstance(content, str):
            try:
                content = json.loads(content)
            except json.JSONDecodeError:
                return f"Cannot tabulate non-JSON content:\n{content[:500]}"
        data = content

    if isinstance(data, list) and len(data) > 0 and isinstance(data[0], dict):
        flat_rows = [flatten_nested(item) for item in data]
        all_keys = []
        for row in flat_rows:
            for k in row:
                if k not in all_keys:
                    all_keys.append(k)

        lines = []
        header = "| " + " | ".join(all_keys) + " |"
        separator = "| " + " | ".join("---" for _ in all_keys) + " |"
        lines.append(header)
        lines.append(separator)

        for row in flat_rows:
            values = [row.get(k, "") for k in all_keys]
            # Truncate long values for table readability
            values = [v[:80] + "..." if len(v) > 80 else v for v in values]
            lines.append("| " + " | ".join(values) + " |")

        return "\n".join(lines)
    else:
        return "Data is not a list of objects; cannot render as table. Use --format markdown instead."


def format_as_json(data: dict | list) -> str:
    """Pretty-print JSON."""
    if isinstance(data, dict) and "extracted_content" in data:
        content = data["extracted_content"]
        if isinstance(content, str):
            try:
                content = json.loads(content)
            except json.JSONDecodeError:
                return content
        return json.dumps(content, indent=2, ensure_ascii=False)
    return json.dumps(data, indent=2, ensure_ascii=False)


def main():
    parser = argparse.ArgumentParser(
        description="Format Crawl4AI JSON output into structured Markdown."
    )
    parser.add_argument("--input", "-i", help="Input JSON file (default: stdin)")
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")
    parser.add_argument(
        "--format", "-f",
        choices=["markdown", "table", "json"],
        default="markdown",
        help="Output format (default: markdown)"
    )
    parser.add_argument("--title", "-t", default="Crawl4AI Extracted Data", help="Report title")
    args = parser.parse_args()

    data = load_input(args.input)

    if args.format == "markdown":
        output = format_as_markdown(data, title=args.title)
    elif args.format == "table":
        output = format_as_table(data)
    elif args.format == "json":
        output = format_as_json(data)
    else:
        output = format_as_markdown(data, title=args.title)

    if args.output:
        Path(args.output).write_text(output, encoding="utf-8")
        print(f"Written to {args.output}")
    else:
        print(output)


if __name__ == "__main__":
    main()

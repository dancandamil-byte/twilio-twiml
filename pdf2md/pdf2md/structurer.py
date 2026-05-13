"""Text structuring module - converts raw text to Markdown."""

import re
from typing import Dict, List, Optional

from .table_detector import detect_tables, format_markdown_table


def structure_text(text: str, font_metadata: Optional[List[Dict]] = None) -> str:
    """Convert raw text to structured Markdown.

    Uses heuristics for headings, lists, tables, and inline formatting.
    """
    lines = text.split("\n")
    # Detect tables first
    tables = detect_tables(lines)
    table_line_set = set()
    for table in tables:
        for i in range(table["start_line"], table["end_line"] + 1):
            table_line_set.add(i)

    result_lines = []
    i = 0
    while i < len(lines):
        if i in table_line_set:
            # Find the table that contains this line
            for table in tables:
                if table["start_line"] == i:
                    md_table = format_markdown_table(table["parsed_rows"])
                    result_lines.append("")
                    result_lines.append(md_table)
                    result_lines.append("")
                    i = table["end_line"] + 1
                    break
            else:
                i += 1
        else:
            line = lines[i]
            font_info = _get_font_info_for_line(i, font_metadata)
            processed = _process_line(line, font_info)
            result_lines.append(processed)
            i += 1

    return "\n".join(result_lines)


def detect_heading(line: str, font_info: Optional[Dict] = None) -> Optional[str]:
    """Detect if a line is a heading based on ALL CAPS or font size.

    Returns the Markdown heading string or None.
    """
    stripped = line.strip()
    if not stripped:
        return None

    # Check font metadata for heading detection
    if font_info:
        size = font_info.get("size", 12)
        if size >= 18:
            return f"# {stripped}"
        elif size >= 14:
            return f"## {stripped}"

    # Check ALL CAPS (at least 3 characters, mostly alpha)
    alpha_chars = [c for c in stripped if c.isalpha()]
    if (
        len(alpha_chars) >= 3
        and stripped == stripped.upper()
        and any(c.isalpha() for c in stripped)
    ):
        return f"# {stripped}"

    return None


def detect_numbered_paragraph(line: str) -> Optional[str]:
    """Detect and preserve numbered paragraph formatting.

    Matches patterns like '1. text', '2) text', '10. text', etc.
    """
    match = re.match(r"^(\s*)(\d+)([.\)]) (.+)$", line)
    if match:
        indent = match.group(1)
        number = match.group(2)
        separator = match.group(3)
        text = match.group(4)
        if separator == ")":
            separator = "."
        return f"{indent}{number}. {text}"
    return None


def apply_inline_formatting(line: str, font_info: Optional[Dict] = None) -> str:
    """Apply bold/italic markers based on font metadata."""
    if not font_info:
        return line

    flags = font_info.get("flags", 0)
    # PyMuPDF flags: bit 0 = superscript, bit 1 = italic, bit 2 = serif,
    # bit 3 = monospace, bit 4 = bold
    is_bold = bool(flags & (1 << 4))
    is_italic = bool(flags & (1 << 1))

    stripped = line.strip()
    if not stripped:
        return line

    if is_bold and is_italic:
        return f"***{stripped}***"
    elif is_bold:
        return f"**{stripped}**"
    elif is_italic:
        return f"*{stripped}*"

    return line


def _process_line(line: str, font_info: Optional[Dict] = None) -> str:
    """Process a single line through heading, list, and formatting detection."""
    # Check for heading
    heading = detect_heading(line, font_info)
    if heading:
        return heading

    # Check for numbered paragraph
    numbered = detect_numbered_paragraph(line)
    if numbered:
        return numbered

    # Apply inline formatting
    formatted = apply_inline_formatting(line, font_info)
    return formatted


def _get_font_info_for_line(
    line_idx: int, font_metadata: Optional[List[Dict]] = None
) -> Optional[Dict]:
    """Get font info for a specific line index from metadata."""
    if not font_metadata or line_idx >= len(font_metadata):
        return None
    return font_metadata[line_idx]

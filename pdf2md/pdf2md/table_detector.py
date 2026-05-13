"""Table detection and formatting module."""

import re
from typing import List, Optional, Tuple


def detect_tables(text_lines: List[str]) -> List[dict]:
    """Detect tables in text based on consistent multi-space column patterns.

    Returns a list of table blocks with start_line, end_line, and parsed_rows.
    """
    tables = []
    i = 0
    while i < len(text_lines):
        columns = _split_columns(text_lines[i])
        if columns and len(columns) >= 2:
            # Found potential table start
            start = i
            rows = [columns]
            i += 1
            while i < len(text_lines):
                cols = _split_columns(text_lines[i])
                if cols and len(cols) >= 2:
                    rows.append(cols)
                    i += 1
                else:
                    break
            # Need at least 2 rows for a table
            if len(rows) >= 2:
                tables.append({
                    "start_line": start,
                    "end_line": i - 1,
                    "parsed_rows": rows,
                })
        else:
            i += 1
    return tables


def _split_columns(line: str) -> Optional[List[str]]:
    """Split a line into columns based on multi-space or tab separation.

    Returns None if the line does not appear to have columns.
    """
    if not line or not line.strip():
        return None
    # Split by 2+ spaces or tabs
    parts = re.split(r"  {2,}|\t+", line.strip())
    parts = [p.strip() for p in parts if p.strip()]
    if len(parts) >= 2:
        return parts
    return None


def format_markdown_table(rows: List[List[str]]) -> str:
    """Format parsed rows as a Markdown table with header separator.

    The first row is treated as the header.
    """
    if not rows:
        return ""
    # Normalize column count
    max_cols = max(len(row) for row in rows)
    normalized = []
    for row in rows:
        padded = row + [""] * (max_cols - len(row))
        normalized.append(padded)

    # Calculate column widths
    col_widths = []
    for col_idx in range(max_cols):
        width = max(len(row[col_idx]) for row in normalized)
        col_widths.append(max(width, 3))

    # Build table
    lines = []
    # Header
    header = "| " + " | ".join(
        normalized[0][i].ljust(col_widths[i]) for i in range(max_cols)
    ) + " |"
    lines.append(header)
    # Separator
    separator = "| " + " | ".join(
        "-" * col_widths[i] for i in range(max_cols)
    ) + " |"
    lines.append(separator)
    # Data rows
    for row in normalized[1:]:
        data_line = "| " + " | ".join(
            row[i].ljust(col_widths[i]) for i in range(max_cols)
        ) + " |"
        lines.append(data_line)

    return "\n".join(lines)

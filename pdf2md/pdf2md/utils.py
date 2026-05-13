"""Utility functions for pdf2md."""

import os
from pathlib import Path
from typing import List


def ensure_directory(path: str) -> None:
    """Create output directory if it does not exist."""
    os.makedirs(path, exist_ok=True)


def get_pdf_files(input_path: str) -> List[str]:
    """Return a list of PDF file paths from either a file or directory input."""
    path = Path(input_path)
    if path.is_file() and path.suffix.lower() == ".pdf":
        return [str(path)]
    elif path.is_dir():
        return sorted(
            str(p) for p in path.rglob("*.pdf")
        )
    return []


def output_path_for(pdf_path: str, output_dir: str) -> str:
    """Compute the .md output path for a given PDF file."""
    pdf_name = Path(pdf_path).stem
    return str(Path(output_dir) / f"{pdf_name}.md")

"""Main conversion orchestration module."""

import os
from typing import Optional

from .extractor import extract_native_text, extract_ocr_text, is_scanned_pdf
from .structurer import structure_text
from .utils import ensure_directory, get_pdf_files, output_path_for


def convert_pdf(
    pdf_path: str,
    output_dir: str,
    lang: str = "spa",
    dpi: int = 300,
    force: bool = False,
    verbose: bool = False,
) -> Optional[str]:
    """Convert a single PDF to Markdown.

    Returns the output path on success, None if skipped.
    """
    out_path = output_path_for(pdf_path, output_dir)

    # Skip if output exists and not forcing
    if os.path.exists(out_path) and not force:
        if verbose:
            print(f"Skipping (already exists): {out_path}")
        return None

    ensure_directory(output_dir)

    if verbose:
        print(f"Processing: {pdf_path}")

    # Determine extraction method
    scanned = is_scanned_pdf(pdf_path)

    if scanned:
        if verbose:
            print("  Detected scanned PDF, using OCR...")
        pages = extract_ocr_text(pdf_path, lang=lang, dpi=dpi)
    else:
        if verbose:
            print("  Detected native text PDF...")
        pages = extract_native_text(pdf_path)

    # Structure and combine pages
    md_parts = []
    for page_data in pages:
        text = page_data.get("text", "")
        spans = page_data.get("spans", [])
        font_metadata = _build_font_metadata(text, spans) if spans else None
        md = structure_text(text, font_metadata)
        md_parts.append(md)

    markdown = "\n\n---\n\n".join(md_parts)

    # Write output
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(markdown)

    if verbose:
        print(f"  Output: {out_path}")

    return out_path


def convert_batch(
    input_path: str,
    output_dir: str,
    lang: str = "spa",
    dpi: int = 300,
    force: bool = False,
    verbose: bool = False,
) -> dict:
    """Convert one or multiple PDFs to Markdown.

    Returns a summary dict with converted, skipped, and failed counts.
    """
    pdf_files = get_pdf_files(input_path)
    results = {"converted": 0, "skipped": 0, "failed": 0, "total": len(pdf_files)}

    for pdf_file in pdf_files:
        try:
            result = convert_pdf(pdf_file, output_dir, lang, dpi, force, verbose)
            if result:
                results["converted"] += 1
            else:
                results["skipped"] += 1
        except Exception as e:
            results["failed"] += 1
            if verbose:
                print(f"  Error processing {pdf_file}: {e}")

    return results


def _build_font_metadata(text: str, spans: list) -> list:
    """Build per-line font metadata from spans.

    Returns a list of font info dicts, one per line of text.
    For each line, picks the dominant span (by character count) as the
    representative font metadata.
    """
    lines = text.split("\n")
    metadata = []
    span_idx = 0
    for line in lines:
        if span_idx < len(spans):
            # Collect all spans that contribute to this line
            line_spans = []
            consumed = 0
            while span_idx < len(spans) and consumed < len(line):
                line_spans.append(spans[span_idx])
                consumed += len(spans[span_idx].get("text", ""))
                span_idx += 1
            # Pick the dominant span by character count
            if line_spans:
                dominant = max(line_spans, key=lambda s: len(s.get("text", "")))
                metadata.append(dominant)
            else:
                metadata.append(None)
        else:
            metadata.append(None)
    return metadata

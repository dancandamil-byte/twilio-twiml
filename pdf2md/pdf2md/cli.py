"""CLI interface for pdf2md."""

import click

from . import __version__
from .converter import convert_batch


@click.group()
@click.version_option(version=__version__, prog_name="pdf2md")
def main():
    """pdf2md - Convert PDF files to Markdown."""
    pass


@main.command()
@click.argument("input_path")
@click.option(
    "--output", "-o",
    default="./output/",
    help="Output directory for Markdown files.",
    show_default=True,
)
@click.option(
    "--lang", "-l",
    default="spa",
    help="Language for OCR processing.",
    show_default=True,
)
@click.option(
    "--dpi",
    default=300,
    type=int,
    help="DPI for image conversion (OCR mode).",
    show_default=True,
)
@click.option(
    "--force",
    is_flag=True,
    default=False,
    help="Overwrite existing output files.",
)
@click.option(
    "--verbose", "-v",
    is_flag=True,
    default=False,
    help="Enable verbose output.",
)
def convert(input_path, output, lang, dpi, force, verbose):
    """Convert PDF file(s) to Markdown.

    INPUT_PATH can be a single PDF file or a directory containing PDFs.
    """
    results = convert_batch(input_path, output, lang, dpi, force, verbose)

    click.echo(f"\nConversion complete:")
    click.echo(f"  Total files: {results['total']}")
    click.echo(f"  Converted:   {results['converted']}")
    click.echo(f"  Skipped:     {results['skipped']}")
    click.echo(f"  Failed:      {results['failed']}")

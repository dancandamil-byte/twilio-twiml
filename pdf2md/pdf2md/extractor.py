"""PDF text extraction module with native and OCR support."""

from typing import Dict, List, Optional

import fitz  # PyMuPDF
from PIL import Image, ImageEnhance, ImageFilter


def is_scanned_pdf(pdf_path: str) -> bool:
    """Check if a PDF is scanned (image-based) by examining text content.

    If the average characters per page is less than 50, the PDF is considered scanned.
    """
    doc = fitz.open(pdf_path)
    total_chars = 0
    num_pages = len(doc)
    if num_pages == 0:
        doc.close()
        return True
    for page in doc:
        text = page.get_text("text")
        total_chars += len(text.strip())
    doc.close()
    avg_chars = total_chars / num_pages
    return avg_chars < 50


def extract_native_text(pdf_path: str) -> List[Dict]:
    """Extract text with font metadata using PyMuPDF.

    Returns a list of page data, each containing blocks with text and font info.
    """
    doc = fitz.open(pdf_path)
    pages = []
    for page in doc:
        blocks = page.get_text("dict", flags=fitz.TEXT_PRESERVE_WHITESPACE)["blocks"]
        page_data = {"text": "", "spans": []}
        page_text_parts = []
        for block in blocks:
            if block.get("type") != 0:
                continue
            for line in block.get("lines", []):
                line_text_parts = []
                for span in line.get("spans", []):
                    text = span.get("text", "")
                    font_info = {
                        "text": text,
                        "size": span.get("size", 12),
                        "flags": span.get("flags", 0),
                        "font": span.get("font", ""),
                    }
                    page_data["spans"].append(font_info)
                    line_text_parts.append(text)
                page_text_parts.append("".join(line_text_parts))
        page_data["text"] = "\n".join(page_text_parts)
        pages.append(page_data)
    doc.close()
    return pages


def preprocess_image(pil_image: Image.Image) -> Image.Image:
    """Enhance image for better OCR results."""
    # Convert to grayscale
    image = pil_image.convert("L")
    # Enhance contrast
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(1.5)
    # Apply sharpening
    image = image.filter(ImageFilter.SHARPEN)
    return image


def extract_ocr_text(
    pdf_path: str, lang: str = "spa", dpi: int = 300
) -> List[Dict]:
    """Extract text from scanned PDF using OCR.

    Converts pages to images, preprocesses them, and runs Tesseract OCR.
    """
    from pdf2image import convert_from_path
    import pytesseract

    images = convert_from_path(pdf_path, dpi=dpi)
    pages = []
    for image in images:
        processed = preprocess_image(image)
        text = pytesseract.image_to_string(processed, lang=lang)
        pages.append({"text": text, "spans": []})
    return pages

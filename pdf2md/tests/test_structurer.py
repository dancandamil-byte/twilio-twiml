"""Unit tests for the structurer module."""

import pytest

from pdf2md.structurer import (
    apply_inline_formatting,
    detect_heading,
    detect_numbered_paragraph,
    structure_text,
)


class TestDetectHeading:
    def test_all_caps_detected_as_heading(self):
        result = detect_heading("INTRODUCTION")
        assert result == "# INTRODUCTION"

    def test_all_caps_with_spaces(self):
        result = detect_heading("CHAPTER ONE")
        assert result == "# CHAPTER ONE"

    def test_short_caps_not_heading(self):
        # Less than 3 alpha characters
        result = detect_heading("AB")
        assert result is None

    def test_mixed_case_not_heading(self):
        result = detect_heading("This is a normal line")
        assert result is None

    def test_large_font_as_h1(self):
        font_info = {"size": 20, "flags": 0}
        result = detect_heading("Title Text", font_info)
        assert result == "# Title Text"

    def test_medium_font_as_h2(self):
        font_info = {"size": 15, "flags": 0}
        result = detect_heading("Subtitle", font_info)
        assert result == "## Subtitle"

    def test_normal_font_no_heading(self):
        font_info = {"size": 12, "flags": 0}
        result = detect_heading("Normal text", font_info)
        assert result is None

    def test_empty_line(self):
        result = detect_heading("")
        assert result is None


class TestDetectNumberedParagraph:
    def test_dot_format(self):
        result = detect_numbered_paragraph("1. First item")
        assert result == "1. First item"

    def test_parenthesis_format(self):
        result = detect_numbered_paragraph("2) Second item")
        assert result == "2. Second item"

    def test_double_digit(self):
        result = detect_numbered_paragraph("10. Tenth item")
        assert result == "10. Tenth item"

    def test_not_numbered(self):
        result = detect_numbered_paragraph("Regular text line")
        assert result is None

    def test_indented_numbered(self):
        result = detect_numbered_paragraph("  3. Indented item")
        assert result == "  3. Indented item"


class TestApplyInlineFormatting:
    def test_bold_from_flags(self):
        # Flag bit 4 = bold (value 16)
        font_info = {"flags": 16, "size": 12}
        result = apply_inline_formatting("Bold text", font_info)
        assert result == "**Bold text**"

    def test_italic_from_flags(self):
        # Flag bit 1 = italic (value 2)
        font_info = {"flags": 2, "size": 12}
        result = apply_inline_formatting("Italic text", font_info)
        assert result == "*Italic text*"

    def test_bold_italic_from_flags(self):
        # Both bold (16) and italic (2) = 18
        font_info = {"flags": 18, "size": 12}
        result = apply_inline_formatting("Bold italic", font_info)
        assert result == "***Bold italic***"

    def test_no_formatting_without_metadata(self):
        result = apply_inline_formatting("Plain text")
        assert result == "Plain text"

    def test_normal_flags_no_formatting(self):
        font_info = {"flags": 0, "size": 12}
        result = apply_inline_formatting("Normal text", font_info)
        assert result == "Normal text"


class TestStructureText:
    def test_all_caps_becomes_heading(self):
        text = "INTRODUCTION\nThis is the first paragraph."
        result = structure_text(text)
        assert "# INTRODUCTION" in result
        assert "This is the first paragraph." in result

    def test_numbered_list_preserved(self):
        text = "1. First\n2. Second\n3. Third"
        result = structure_text(text)
        assert "1. First" in result
        assert "2. Second" in result
        assert "3. Third" in result

    def test_regular_text_unchanged(self):
        text = "This is a normal paragraph with no special formatting."
        result = structure_text(text)
        assert "This is a normal paragraph with no special formatting." in result

    def test_mixed_content(self):
        text = "TITLE\nSome body text.\n1. First item\n2. Second item"
        result = structure_text(text)
        assert "# TITLE" in result
        assert "Some body text." in result
        assert "1. First item" in result
        assert "2. Second item" in result

    def test_with_font_metadata_bold(self):
        text = "Important line"
        font_metadata = [{"flags": 16, "size": 12, "text": "Important line"}]
        result = structure_text(text, font_metadata)
        assert "**Important line**" in result

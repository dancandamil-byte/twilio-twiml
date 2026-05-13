"""Unit tests for the table_detector module."""

import pytest

from pdf2md.table_detector import detect_tables, format_markdown_table


class TestDetectTables:
    def test_multi_space_columns_detected(self):
        lines = [
            "Name        Age    City",
            "Alice       30     New York",
            "Bob         25     London",
        ]
        tables = detect_tables(lines)
        assert len(tables) == 1
        assert tables[0]["start_line"] == 0
        assert tables[0]["end_line"] == 2
        assert len(tables[0]["parsed_rows"]) == 3

    def test_single_column_not_detected(self):
        lines = [
            "This is a single column of text.",
            "Another line of plain text.",
            "Yet another line here.",
        ]
        tables = detect_tables(lines)
        assert len(tables) == 0

    def test_tab_separated_columns(self):
        lines = [
            "Column1\tColumn2\tColumn3",
            "Data1\tData2\tData3",
        ]
        tables = detect_tables(lines)
        assert len(tables) == 1
        assert len(tables[0]["parsed_rows"]) == 2

    def test_mixed_content_table_in_middle(self):
        lines = [
            "Introduction text here.",
            "Name        Age    City",
            "Alice       30     New York",
            "More text after the table.",
        ]
        tables = detect_tables(lines)
        assert len(tables) == 1
        assert tables[0]["start_line"] == 1
        assert tables[0]["end_line"] == 2

    def test_empty_lines_not_table(self):
        lines = ["", "", ""]
        tables = detect_tables(lines)
        assert len(tables) == 0


class TestFormatMarkdownTable:
    def test_basic_table(self):
        rows = [
            ["Name", "Age", "City"],
            ["Alice", "30", "New York"],
            ["Bob", "25", "London"],
        ]
        result = format_markdown_table(rows)
        lines = result.split("\n")
        assert len(lines) == 4  # header + separator + 2 data rows
        assert "|" in lines[0]
        assert "---" in lines[1]
        assert "Alice" in lines[2]
        assert "Bob" in lines[3]

    def test_header_separator_present(self):
        rows = [
            ["A", "B"],
            ["1", "2"],
        ]
        result = format_markdown_table(rows)
        lines = result.split("\n")
        # Second line should be separator
        assert all(c in "-| " for c in lines[1])

    def test_empty_rows(self):
        result = format_markdown_table([])
        assert result == ""

    def test_uneven_columns_padded(self):
        rows = [
            ["Name", "Age", "City"],
            ["Alice", "30"],
        ]
        result = format_markdown_table(rows)
        lines = result.split("\n")
        # Should still have 3 columns in all rows
        assert lines[2].count("|") == lines[0].count("|")

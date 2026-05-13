"""Unit tests for the utils module."""

import os
import tempfile

import pytest

from pdf2md.utils import ensure_directory, get_pdf_files, output_path_for


class TestEnsureDirectory:
    def test_creates_directory(self, tmp_path):
        target = str(tmp_path / "new_dir" / "sub_dir")
        ensure_directory(target)
        assert os.path.isdir(target)

    def test_existing_directory_no_error(self, tmp_path):
        target = str(tmp_path / "existing")
        os.makedirs(target)
        ensure_directory(target)  # Should not raise
        assert os.path.isdir(target)


class TestGetPdfFiles:
    def test_single_pdf_file(self, tmp_path):
        pdf = tmp_path / "test.pdf"
        pdf.write_text("dummy")
        result = get_pdf_files(str(pdf))
        assert result == [str(pdf)]

    def test_non_pdf_file_returns_empty(self, tmp_path):
        txt = tmp_path / "test.txt"
        txt.write_text("dummy")
        result = get_pdf_files(str(txt))
        assert result == []

    def test_directory_with_pdfs(self, tmp_path):
        (tmp_path / "a.pdf").write_text("dummy")
        (tmp_path / "b.pdf").write_text("dummy")
        (tmp_path / "c.txt").write_text("dummy")
        result = get_pdf_files(str(tmp_path))
        assert len(result) == 2
        assert all(f.endswith(".pdf") for f in result)

    def test_directory_recursive(self, tmp_path):
        sub = tmp_path / "subdir"
        sub.mkdir()
        (tmp_path / "top.pdf").write_text("dummy")
        (sub / "nested.pdf").write_text("dummy")
        result = get_pdf_files(str(tmp_path))
        assert len(result) == 2

    def test_empty_directory(self, tmp_path):
        result = get_pdf_files(str(tmp_path))
        assert result == []

    def test_nonexistent_path(self):
        result = get_pdf_files("/nonexistent/path")
        assert result == []


class TestOutputPathFor:
    def test_basic_output(self):
        result = output_path_for("/some/dir/document.pdf", "/output")
        assert result == "/output/document.md"

    def test_preserves_stem(self):
        result = output_path_for("my-file.pdf", "./output/")
        assert "my-file.md" in result

    def test_different_output_dir(self):
        result = output_path_for("input.pdf", "/tmp/results")
        assert result == "/tmp/results/input.md"

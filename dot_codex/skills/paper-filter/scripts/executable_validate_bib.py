#!/usr/bin/env python3
"""Validate paper-filter BibTeX output without third-party dependencies."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ENTRY_START = re.compile(r"@([A-Za-z]+)\s*\{\s*([^,\s]+)\s*,", re.MULTILINE)
FIELD_START = re.compile(r"([A-Za-z][A-Za-z0-9_-]*)\s*=\s*")


def consume_braced(text: str, start: int) -> tuple[str, int]:
    depth = 0
    escaped = False
    for index in range(start, len(text)):
        char = text[index]
        if escaped:
            escaped = False
            continue
        if char == "\\":
            escaped = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[start + 1 : index], index + 1
    raise ValueError("unterminated braced value")


def consume_quoted(text: str, start: int) -> tuple[str, int]:
    escaped = False
    for index in range(start + 1, len(text)):
        char = text[index]
        if escaped:
            escaped = False
            continue
        if char == "\\":
            escaped = True
        elif char == '"':
            return text[start + 1 : index], index + 1
    raise ValueError("unterminated quoted value")


def parse_fields(body: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    cursor = 0
    while cursor < len(body):
        while cursor < len(body) and (body[cursor].isspace() or body[cursor] == ","):
            cursor += 1
        if cursor >= len(body):
            break
        match = FIELD_START.match(body, cursor)
        if not match:
            raise ValueError(f"cannot parse field near {body[cursor:cursor + 40]!r}")
        name = match.group(1).lower()
        cursor = match.end()
        if cursor >= len(body):
            raise ValueError(f"missing value for {name}")
        if body[cursor] == "{":
            value, cursor = consume_braced(body, cursor)
        elif body[cursor] == '"':
            value, cursor = consume_quoted(body, cursor)
        else:
            end = cursor
            while end < len(body) and body[end] not in ",\n":
                end += 1
            value, cursor = body[cursor:end].strip(), end
        fields[name] = value.strip()
    return fields


def parse_entries(text: str) -> list[tuple[str, str, dict[str, str]]]:
    entries: list[tuple[str, str, dict[str, str]]] = []
    cursor = 0
    while True:
        match = ENTRY_START.search(text, cursor)
        if not match:
            break
        entry_type = match.group(1).lower()
        key = match.group(2)
        body_start = match.end()
        depth = 1
        escaped = False
        index = body_start
        while index < len(text):
            char = text[index]
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    body = text[body_start:index]
                    entries.append((entry_type, key, parse_fields(body)))
                    cursor = index + 1
                    break
            index += 1
        else:
            raise ValueError(f"unterminated entry {key}")
    return entries


def plain_words(value: str) -> list[str]:
    value = re.sub(r"\\[%&#$_{}]", " ", value)
    value = re.sub(r"[{}\\]", " ", value)
    return re.findall(r"[A-Za-z0-9][A-Za-z0-9'./+-]*", value)


def validate(path: Path, expected_year: str | None) -> tuple[list[str], list[str], int]:
    errors: list[str] = []
    warnings: list[str] = []
    try:
        entries = parse_entries(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, ValueError) as exc:
        return [str(exc)], [], 0

    if not entries:
        return ["no BibTeX entries found"], [], 0

    keys: set[str] = set()
    dois: set[str] = set()
    suspicious = ("[missing]", "* Work done", "<scp>", "</scp>", "�", "\\textbackslash")

    for entry_type, key, fields in entries:
        if key in keys:
            errors.append(f"{key}: duplicate citation key")
        keys.add(key)

        required = ["author", "title", "year", "doi", "url", "abstract", "logline"]
        required.append("booktitle" if entry_type == "inproceedings" else "journal")
        for field in required:
            if not fields.get(field):
                errors.append(f"{key}: missing {field}")

        doi = fields.get("doi", "").lower().removeprefix("https://doi.org/")
        if doi:
            if doi in dois:
                errors.append(f"{key}: duplicate DOI {doi}")
            dois.add(doi)

        if expected_year and fields.get("year", "").strip("{} ") != expected_year:
            errors.append(f"{key}: year does not match {expected_year}")

        pages = fields.get("pages", "")
        if re.search(r"\d-\d", pages) and not re.search(r"\d--\d", pages):
            warnings.append(f"{key}: page range should use --")

        abstract = fields.get("abstract", "")
        abstract_words = plain_words(abstract)
        if len(abstract_words) < 50:
            warnings.append(f"{key}: abstract is suspiciously short ({len(abstract_words)} words)")
        if any(marker.lower() in abstract.lower() for marker in suspicious):
            warnings.append(f"{key}: abstract contains extraction debris")

        logline = fields.get("logline", "")
        logline_words = plain_words(logline)
        if not 12 <= len(logline_words) <= 45:
            warnings.append(f"{key}: logline has {len(logline_words)} words; target 12--45")
        if re.match(r"(?i)\s*(this (paper|work|study)|we|the authors)\b", logline):
            warnings.append(f"{key}: logline uses weak framing")
        terminal = re.findall(r"[.!?](?=\s|$)", logline)
        if len(terminal) != 1 or not re.search(r"[.!?]\s*$", logline):
            warnings.append(f"{key}: logline should be exactly one sentence")

        url = fields.get("url", "").lower()
        if url and not (url.endswith(".pdf") or "/pdf/" in url or "download=pdf" in url):
            warnings.append(f"{key}: URL does not look like a direct PDF")

    return errors, warnings, len(entries)


def self_test() -> int:
    sample = """@inproceedings{Example2025,
  author = {A. Researcher and B. Scientist},
  title = {{A Protected Acronym}},
  booktitle = {Proceedings of Example},
  year = {2025},
  pages = {1--10},
  doi = {10.0000/example},
  url = {https://example.org/paper.pdf},
  abstract = {This deliberately long sample abstract contains enough words to exercise the parser and validator without triggering the short abstract warning. It describes a computer science research contribution, its methodology, its evaluation, and its principal findings using clear prose suitable for bibliographic metadata and automated validation in this self test case.},
  logline = {Static analysis finds 100 vulnerable workflows while preserving enough context for experts to assess the result.}
}
"""
    entries = parse_entries(sample)
    assert len(entries) == 1
    assert entries[0][1] == "Example2025"
    assert entries[0][2]["doi"] == "10.0000/example"
    print("self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bibfile", nargs="?", type=Path)
    parser.add_argument("--year", help="require every entry to use this publication year")
    parser.add_argument("--strict", action="store_true", help="treat warnings as failures")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        return self_test()
    if args.bibfile is None:
        parser.error("bibfile is required unless --self-test is used")

    errors, warnings, count = validate(args.bibfile, args.year)
    for message in errors:
        print(f"ERROR: {message}", file=sys.stderr)
    for message in warnings:
        print(f"WARNING: {message}", file=sys.stderr)
    print(f"validated {count} entries: {len(errors)} errors, {len(warnings)} warnings")
    return 1 if errors or (args.strict and warnings) else 0


if __name__ == "__main__":
    raise SystemExit(main())

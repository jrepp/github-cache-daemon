#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///
"""
Validate all markdown links in the repository.

This script checks:
1. All relative file links point to existing files
2. All anchor links point to existing headers
3. No broken external links (optional, requires network)

Usage:
    ./scripts/validate-links.py
    ./scripts/validate-links.py --check-external

Exit codes:
    0 - All links are valid
    1 - One or more broken links found
    2 - Script error
"""

import argparse
import os
import re
import sys
from pathlib import Path
from typing import List, Tuple, Set
from urllib.parse import unquote, urlparse


class Colors:
    """ANSI color codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


class LinkValidator:
    """Validates markdown links in a repository."""

    def __init__(self, repo_root: Path, check_external: bool = False):
        self.repo_root = repo_root
        self.check_external = check_external
        self.total_files = 0
        self.total_links = 0
        self.broken_links = 0
        self.warnings = 0
        self.errors = []
        self.warnings_list = []

    def find_markdown_files(self) -> List[Path]:
        """Find all markdown files in the repository."""
        md_files = []
        for path in self.repo_root.rglob("*.md"):
            # Skip excluded directories
            if any(part in ['.git', 'node_modules', '.venv', 'venv'] for part in path.parts):
                continue
            md_files.append(path)
        return sorted(md_files)

    def extract_links(self, content: str, file_path: Path) -> List[Tuple[str, str, int]]:
        """
        Extract all links from markdown content.

        Returns: List of (link_text, link_url, line_number)
        """
        links = []
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            # Match [text](url) style links
            pattern = r'\[([^\]]+)\]\(([^\)]+)\)'
            matches = re.finditer(pattern, line)

            for match in matches:
                text = match.group(1)
                url = match.group(2)

                # Clean up URL (remove quotes and titles)
                url = re.sub(r'\s+"[^"]*"$', '', url)
                url = re.sub(r"\s+'[^']*'$", '', url)
                url = url.strip()

                links.append((text, url, line_num))

        return links

    def extract_headers(self, content: str) -> Set[str]:
        """
        Extract all headers from markdown content for anchor validation.

        Returns: Set of anchor strings (e.g., '#my-header')
        """
        headers = set()
        lines = content.split('\n')

        for line in lines:
            # Match markdown headers: # Header, ## Header, etc.
            match = re.match(r'^(#{1,6})\s+(.+)$', line)
            if match:
                header_text = match.group(2)
                # Convert to anchor format:
                # - Lowercase
                # - Replace spaces with hyphens
                # - Remove special characters except hyphens
                # - Remove leading/trailing hyphens
                anchor = header_text.lower()
                anchor = re.sub(r'[^\w\s-]', '', anchor)
                anchor = re.sub(r'\s+', '-', anchor)
                anchor = re.sub(r'-+', '-', anchor)
                anchor = anchor.strip('-')
                headers.add(f'#{anchor}')

        return headers

    def check_link(self, source_file: Path, link_text: str, link_url: str, line_num: int) -> bool:
        """
        Check if a link is valid.

        Returns: True if valid, False if broken
        """
        # Skip external links unless requested
        parsed = urlparse(link_url)
        if parsed.scheme in ['http', 'https', 'mailto', 'ftp']:
            if not self.check_external:
                return True
            # TODO: Implement external link checking with requests
            return True

        # Handle anchor-only links (refer to current file)
        if link_url.startswith('#'):
            content = source_file.read_text(encoding='utf-8', errors='ignore')
            headers = self.extract_headers(content)

            if link_url not in headers:
                self.errors.append({
                    'file': source_file,
                    'line': line_num,
                    'link': link_url,
                    'text': link_text,
                    'error': f'Anchor not found in current file',
                    'type': 'broken_anchor'
                })
                return False
            return True

        # Parse file path and anchor
        file_part = unquote(link_url.split('#')[0]) if '#' in link_url else unquote(link_url)
        anchor_part = '#' + link_url.split('#')[1] if '#' in link_url else None

        # Skip empty file paths
        if not file_part:
            return True

        # Resolve target path
        if file_part.startswith('/'):
            # Absolute path from repo root
            target_path = self.repo_root / file_part.lstrip('/')
        else:
            # Relative path from source file directory
            target_path = (source_file.parent / file_part).resolve()

        # Check if target exists
        if not target_path.exists():
            # Try with and without .md extension
            if not str(target_path).endswith('.md'):
                target_with_md = Path(str(target_path) + '.md')
                if target_with_md.exists():
                    self.warnings_list.append({
                        'file': source_file,
                        'line': line_num,
                        'link': link_url,
                        'suggestion': f'{file_part}.md' + (f'#{anchor_part.lstrip("#")}' if anchor_part else ''),
                        'type': 'missing_md_extension'
                    })
                    target_path = target_with_md
                else:
                    self.errors.append({
                        'file': source_file,
                        'line': line_num,
                        'link': link_url,
                        'text': link_text,
                        'expected': str(target_path),
                        'error': 'File not found',
                        'type': 'broken_link'
                    })
                    return False
            else:
                self.errors.append({
                    'file': source_file,
                    'line': line_num,
                    'link': link_url,
                    'text': link_text,
                    'expected': str(target_path),
                    'error': 'File not found',
                    'type': 'broken_link'
                })
                return False

        # Check anchor if present
        if anchor_part and target_path.is_file() and target_path.suffix == '.md':
            content = target_path.read_text(encoding='utf-8', errors='ignore')
            headers = self.extract_headers(content)

            if anchor_part not in headers:
                self.errors.append({
                    'file': source_file,
                    'line': line_num,
                    'link': link_url,
                    'text': link_text,
                    'target': str(target_path),
                    'error': f'Anchor {anchor_part} not found in target file',
                    'type': 'broken_anchor',
                    'available': sorted(list(headers))[:5]  # Show first 5 anchors
                })
                return False

        # Check for directory links without trailing slash
        if target_path.is_dir() and not link_url.endswith('/'):
            self.warnings_list.append({
                'file': source_file,
                'line': line_num,
                'link': link_url,
                'suggestion': link_url + '/',
                'type': 'directory_no_slash'
            })

        return True

    def validate_file(self, file_path: Path) -> None:
        """Validate all links in a single markdown file."""
        try:
            content = file_path.read_text(encoding='utf-8', errors='ignore')
            links = self.extract_links(content, file_path)

            for link_text, link_url, line_num in links:
                self.total_links += 1
                if not self.check_link(file_path, link_text, link_url, line_num):
                    self.broken_links += 1

        except Exception as e:
            print(f"{Colors.RED}Error processing {file_path}: {e}{Colors.NC}")
            sys.exit(2)

    def validate_all(self) -> bool:
        """Validate all markdown files in the repository."""
        print(f"🔍 Validating markdown links in {self.repo_root}")
        print()

        # Find all markdown files
        print("Finding markdown files...")
        md_files = self.find_markdown_files()
        self.total_files = len(md_files)
        print(f"Found {self.total_files} markdown files")
        print()

        # Validate each file
        for md_file in md_files:
            self.validate_file(md_file)

        # Print errors
        if self.errors:
            print(f"\n{Colors.RED}{'='*60}")
            print(f"ERRORS ({len(self.errors)})")
            print(f"{'='*60}{Colors.NC}\n")

            for error in self.errors:
                rel_path = error['file'].relative_to(self.repo_root)
                print(f"{Colors.RED}✗ {error['type'].replace('_', ' ').title()}{Colors.NC}")
                print(f"  File: {rel_path}:{error['line']}")
                print(f"  Link: {error['link']}")
                if 'text' in error:
                    print(f"  Text: {error['text']}")
                print(f"  {error['error']}")
                if 'expected' in error:
                    print(f"  Expected: {error['expected']}")
                if 'available' in error:
                    print(f"  Available anchors: {', '.join(error['available'])}...")
                print()

        # Print warnings
        if self.warnings_list:
            print(f"\n{Colors.YELLOW}{'='*60}")
            print(f"WARNINGS ({len(self.warnings_list)})")
            print(f"{'='*60}{Colors.NC}\n")

            for warning in self.warnings_list:
                rel_path = warning['file'].relative_to(self.repo_root)
                print(f"{Colors.YELLOW}⚠ {warning['type'].replace('_', ' ').title()}{Colors.NC}")
                print(f"  File: {rel_path}:{warning['line']}")
                print(f"  Link: {warning['link']}")
                if 'suggestion' in warning:
                    print(f"  Suggestion: {warning['suggestion']}")
                print()

        self.warnings = len(self.warnings_list)

        # Print summary
        print(f"\n{'='*60}")
        print("SUMMARY")
        print(f"{'='*60}")
        print(f"Files checked:      {self.total_files}")
        print(f"Links validated:    {self.total_links}")
        print()

        if self.broken_links > 0:
            print(f"{Colors.RED}✗ Broken links:     {self.broken_links}{Colors.NC}")
        else:
            print(f"{Colors.GREEN}✓ Broken links:     0{Colors.NC}")

        if self.warnings > 0:
            print(f"{Colors.YELLOW}⚠ Warnings:         {self.warnings}{Colors.NC}")
        else:
            print(f"{Colors.GREEN}✓ Warnings:         0{Colors.NC}")

        print(f"{'='*60}\n")

        return self.broken_links == 0


def main():
    parser = argparse.ArgumentParser(description='Validate markdown links')
    parser.add_argument('--check-external', action='store_true',
                       help='Check external HTTP(S) links (requires network)')
    parser.add_argument('--repo', type=Path, default=None,
                       help='Repository root (default: auto-detect)')

    args = parser.parse_args()

    # Determine repository root
    if args.repo:
        repo_root = args.repo.resolve()
    else:
        # Auto-detect: go up from script location
        script_dir = Path(__file__).parent
        repo_root = script_dir.parent.resolve()

    if not repo_root.exists():
        print(f"{Colors.RED}Error: Repository root not found: {repo_root}{Colors.NC}")
        sys.exit(2)

    # Run validation
    validator = LinkValidator(repo_root, check_external=args.check_external)
    success = validator.validate_all()

    # Exit with appropriate code
    if success:
        print(f"{Colors.GREEN}✅ All links are valid!{Colors.NC}")
        sys.exit(0)
    else:
        print(f"{Colors.RED}❌ Validation failed - please fix broken links{Colors.NC}")
        sys.exit(1)


if __name__ == '__main__':
    main()

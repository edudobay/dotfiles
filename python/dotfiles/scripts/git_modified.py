#!/usr/bin/env python3

import os, sys, re, subprocess, argparse
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, List, Tuple, Iterable
from tabulate import tabulate
from itertools import chain
from dotfiles.scripts import git_allrepos

CONFIG_NAME = 'repo-roots.default'

def get_repo_roots() -> List[Path]:
    cmd = subprocess.run(['git', 'config', CONFIG_NAME], capture_output=True, text=True)

    return [
        Path(os.path.expanduser(line))
        for line in cmd.stdout.splitlines()
        if line
    ]

@dataclass
class BranchReport:
    repo: Path
    branch: str
    upstream: Optional[str]
    ahead: Optional[int]
    behind: Optional[int]
    gone: bool
    dirty: bool

    def __lt__(self, other):
        if isinstance(other, BranchReport):
            return self.repo < other.repo
        raise NotImplemented

    def is_in_sync_with_upstream(self) -> bool:
        return (
            self.upstream is not None
            and not self.gone
            and (self.ahead is None or self.ahead == 0)
            and (self.behind is None or self.behind == 0)
        )

    def is_default_branch(self) -> bool:
        return (
            self.upstream is not None
            and self.upstream.endswith(self.branch)
            and self.branch in ('main', 'master')  # TODO
        )

class PorcelainV2Parser:

    # 1: changed
    # 2: renamed or copied
    # u: unmerged
    PREFIX_INDICATES_CHANGES = re.compile(r"^(1|2|u) ")

    AHEAD_BEHIND_PATTERN = re.compile(r"^\+(?P<ahead>\d+) -(?P<behind>\d+)$")

    HEADER_HEAD = 'branch.head'
    HEADER_UPSTREAM = 'branch.upstream'
    HEADER_AHEAD_BEHIND = 'branch.ab'

    def read_header(self, line: str) -> Optional[Tuple[str, str]]:
        if line.startswith('# '):
            try:
                header, value = line.removeprefix('# ').split(' ', 1)
                return header, value
            except ValueError:
                return None

    def loads(self, data: str, repo: Path) -> Optional[BranchReport]:
        lines = data.splitlines()

        headers = {}
        dirty = False
        for line in lines:
            if self.PREFIX_INDICATES_CHANGES.match(line) is not None:
                dirty = True

            header = self.read_header(line)
            if header is not None:
                headers[header[0]] = header[1]

        gone = (
            self.HEADER_UPSTREAM in headers
            and self.HEADER_AHEAD_BEHIND not in headers
        )

        ahead = 0
        behind = 0
        m = self.AHEAD_BEHIND_PATTERN.match(headers.get(self.HEADER_AHEAD_BEHIND, ''))
        if m is not None:
            ahead = int(m.group('ahead'))
            behind = int(m.group('behind'))

        return BranchReport(
            repo=repo,
            branch=headers.get(self.HEADER_HEAD),
            upstream=headers.get(self.HEADER_UPSTREAM),
            ahead=ahead,
            behind=behind,
            gone=gone,
            dirty=dirty,
        )

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'root_dirs', nargs='*',
        help=f"""
            One or more directories where repositores are located.
            If absent, the git configuration '{CONFIG_NAME}' will be used.
        """
    )
    parser.add_argument(
        '-d', '--include-dirty',
        action='store_true',
        help="""
            Include dirty repositories: those where the checked out branch is not
            the main branch and/or is not in sync with its upstream branch.
        """
    )
    args = parser.parse_args()

    root_dirs = args.root_dirs or get_repo_roots()
    if not root_dirs:
        print(
            f"error: no root directory given and no default git config {CONFIG_NAME} found",
            file=sys.stderr,
        )
        sys.exit(1)

    repos = chain.from_iterable(
        git_allrepos.find_child_repos(root_dir, max_depth=0)
        for root_dir in root_dirs
    )

    parser = PorcelainV2Parser()
    results = []
    for repo_dir in repos:
        repo_dir = Path(repo_dir)
        cmd = subprocess.run(['git', 'status', '--porcelain=v2', '--branch'], cwd=repo_dir, capture_output=True, text=True)

        report = parser.loads(cmd.stdout, repo_dir)
        if report is None:
            print('UNKNOWN', repo_dir, repr(cmd.stdout))
            continue

        score = report.ahead + report.behind

        is_dirty = not (
            report.is_in_sync_with_upstream()
            and report.is_default_branch()
        )
        include_result = args.include_dirty or is_dirty

        if include_result:
            results.append((score, report))

    results.sort(reverse=True)
    def as_table(results: Iterable[BranchReport]):
        yield "NAME", "BRANCH", "STATUS"

        for _, r in results:
            branch_msg = r.branch
            if r.upstream:
                branch_msg = f'{branch_msg}...{r.upstream}'

            indicators = []
            if r.ahead > 0:
                indicators.append(f'↑{r.ahead}')
            if r.behind > 0:
                indicators.append(f'↓{r.behind}')
            if r.gone:
                indicators.append('gone')
            if r.dirty:
                indicators.append('*')

            yield r.repo.name, branch_msg, ' '.join(indicators)

    print(tabulate(
        list(as_table(results)),
        headers="firstrow",
        tablefmt="plain",
    ))

if __name__ == "__main__":
    main()

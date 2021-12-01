#!/usr/bin/env python3

import os, sys, re, subprocess, argparse
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, List
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

header_pattern = re.compile(r"""
    ^\#\#\ 
    (?P<branch>.+?)
    (?:\.\.\.(?P<upstream>.+?))?
    (?:\ \[(?P<ahead_behind>.+)\])?
    $
""", re.X)

ahead_behind_pattern = re.compile(r"""
    (?: ahead\ (?P<ahead>\d+))
    |
    (?: behind\ (?P<behind>\d+))
    |
    (?P<gone>gone)
""", re.X)

@dataclass
class BranchReport:
    repo: Path
    branch: str
    upstream: Optional[str]
    ahead: Optional[int]
    behind: Optional[int]
    gone: bool

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

    results = []
    for repo_dir in repos:
        repo_dir = Path(repo_dir)
        cmd = subprocess.run(['git', 'status', '--porcelain', '--branch'], cwd=repo_dir, capture_output=True, text=True)
        lines = cmd.stdout.splitlines()

        modified = header_pattern.match(lines[0])
        if modified is None:
            print('UNKNOWN', repo_dir, repr(lines[0]))
            continue
        ahead = 0
        behind = 0
        gone = False
        if m := modified.group('ahead_behind'):
            groups = m.split(', ')
            for g in groups:
                m2 = ahead_behind_pattern.match(g)
                if m2 is None:
                    print('NO MATCH:', lines[0], file=sys.stderr)
                elif a := m2.group('ahead'):
                    ahead = int(a)
                elif b := m2.group('behind'):
                    behind = int(b)
                elif m2.group('gone') == 'gone':
                    gone = True

        report = BranchReport(
            repo = repo_dir,
            branch = modified.group('branch'),
            upstream = modified.group('upstream'),
            ahead = ahead,
            behind = behind,
            gone = gone,
        )

        score = ahead + behind

        is_dirty = not (
            report.is_in_sync_with_upstream()
            and report.is_default_branch()
        )
        include_result = args.include_dirty or is_dirty

        if include_result:
            results.append((score, report))

    results.sort(reverse=True)
    def as_table(results):
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

            yield r.repo.name, branch_msg, ' '.join(indicators)

    print(tabulate(
        list(as_table(results)),
        headers="firstrow",
        tablefmt="plain",
    ))

if __name__ == "__main__":
    main()

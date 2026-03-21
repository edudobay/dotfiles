#!/usr/bin/env python3

from argparse import ArgumentParser, Namespace
import os
import subprocess

def is_git_repo(entry):
    from os.path import join, isdir
    return isdir(entry) and isdir(join(entry, '.git'))

class ProcessUncleanExit(Exception): pass

def parse():
    parser = ArgumentParser()

    parser.add_argument(
        '--depth', '-d', type=int, default=0, metavar='N',
        help='scan recursively into up to N subdirectory levels [default: 0]'
    )
    parser.add_argument(
        '--null', '-0', action='store_true', dest='null_separator',
        help='separate entries by NUL (\\0) instead of newline'
    )

    parser.add_argument(
        'directories', nargs='*', default=['.'], metavar='DIR',
        help='directories where to start scanning [default: .]'
    )

    args = parser.parse_args()
    return args

def candidates_from(root, max_depth=0):
    from os.path import realpath, join, isdir

    for d in os.listdir(root):
        d = realpath(join(root, d))

        if is_git_repo(d):
            yield d

        elif max_depth > 0 and isdir(d):
            yield from candidates_from(d, max_depth - 1)

def find_child_repos(root, max_depth):
    return sorted(candidates_from(root, max_depth))

def main():
    try:
        args = parse()
        separator = '\0' if args.null_separator else '\n'

        for root in args.directories:
            dirs = find_child_repos(root, args.depth)

            for subdir in dirs:
                print(subdir, end=separator)
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()

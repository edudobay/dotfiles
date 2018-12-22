#!/usr/bin/env python3
"""
password_generator
------------------

Generate random passwords based on user-given parameters.
"""

import random
from functools import reduce
from typing import *

DEFAULT_LENGTH = 16
SYMBOLS_DEFAULT = r'\/!@#$%&*-+_=~^.,:;()[]{}<>'

def _sets_union(sets: Sequence[Set]) -> Set:
    return reduce(set.union, sets, set())

def generate_password(length: int, allowed_char_sets: List[Set]):
    pool = list(_sets_union(allowed_char_sets))
    sets_count = len(allowed_char_sets)
    start = [random.choice(s) for s in allowed_char_sets]
    remainder = [random.choice(pool) for _ in range(length)]
    password = start + remainder
    random.shuffle(password)
    return ''.join(password)

def get_allowed_char_sets(args):
    from string import ascii_uppercase, ascii_lowercase, digits
    output = []
    if args.all or args.upper:
        output.append(ascii_uppercase)
    if args.all or args.lower:
        output.append(ascii_lowercase)
    if args.all or args.digits:
        output.append(digits)
    if args.all or args.symbols:
        output.append(args.symbols_list)
    if not output:
        raise ValueError('at least one character set must be included')
    return output

def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Generate random strings that can be used as passwords or secret keys.')

    parser.add_argument('-L', '--length', type=int, default=DEFAULT_LENGTH,
        help='Set length of generated password')
    parser.add_argument('-u', '--upper', action='store_true',
        help='Include uppercase letters (A-Z)')
    parser.add_argument('-l', '--lower', action='store_true',
        help='Include lowercase letters (a-z)')
    parser.add_argument('-d', '--digits', action='store_true',
        help='Include digits 0-9')
    parser.add_argument('-s', '--symbols', action='store_true',
        help='Include symbols')
    parser.add_argument('-S', '--symbols-list', default=SYMBOLS_DEFAULT,
        help='Change the symbols that can be used')
    parser.add_argument('-a', '--all', action='store_true',
        help='Include all of the above items')
    parser.add_argument('-c', '--count', type=int, metavar='N', default=1,
        help='Generate N passwords using the same parameters')

    args = parser.parse_args()
    allowed_char_sets = get_allowed_char_sets(args)
    for _ in range(args.count):
        print(generate_password(args.length, allowed_char_sets))

if __name__ == '__main__':
    main()

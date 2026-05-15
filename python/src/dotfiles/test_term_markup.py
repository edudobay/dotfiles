from dotfiles.term_markup import to_ansi

R = '\x1b[31m'
B = '\x1b[34m'
RST = '\x1b[0m'


def test_single_color():
    assert to_ansi('<fg=red>hello</>') == f'{R}hello{RST}'


def test_two_colors():
    assert to_ansi('<fg=blue>8m</> foo <fg=red>-</>') == f'{B}8m{RST} foo {R}-{RST}'


def test_no_markup():
    assert to_ansi('plain text') == 'plain text'


def test_unknown_color_left_intact():
    assert to_ansi('<fg=purple>x</>') == f'<fg=purple>x{RST}'


def test_nested_resets():
    assert to_ansi('<fg=red>a</><fg=blue>b</>') == f'{R}a{RST}{B}b{RST}'

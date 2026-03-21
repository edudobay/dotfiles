import re

## TODO:
## - add option for auto-closing open "tags"

COLOR_CODES = {
    'red': 1,
    'green': 2,
    'yellow': 3,
    'blue': 4,
    'magenta': 5,
    'cyan': 6,
    'white': 7,
}

_RE_FORMATTING = re.compile(r"""
    \# (?P<type0>b|B|f|g) |
    \# (?:
        (?P<type1>F|G) \( (?P<color>\w+) \)
    )
""", re.X)

def formatting_repl():
    def single_attribute(m):
        type0, type1, color = m.groups()
        if type0:
            if type0 == 'B': # bold on
                return '1'
            elif type0 == 'b': # bold off
                return '22'
            elif type0 == 'f': # default FG color
                return '39'
            elif type0 == 'g': # default BG color
                return '49'
        elif type1:
            if type1 == 'F': # FG color
                return '3' + str(COLOR_CODES[color])
            elif type1 == 'G': # BG color
                return '4' + str(COLOR_CODES[color])

    def attributes(m):
        attr = single_attribute(m)
        if attr is None:
            return m.group(0)
        else:
            return '\033[' + attr + 'm'

    return attributes

def format(s):
    return _RE_FORMATTING.sub(formatting_repl(), s)

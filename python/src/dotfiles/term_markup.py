import re


COLOR_CODES = {
    'red': 1,
    'green': 2,
    'yellow': 3,
    'blue': 4,
    'magenta': 5,
    'cyan': 6,
    'white': 7,
}

_OPEN = re.compile(r'<fg=([a-z]+)>')
_CLOSE = re.compile(r'</>')
_RESET = '\x1b[0m'


def to_ansi(text: str) -> str:
    def replace_open(m: re.Match) -> str:
        color = m.group(1)
        if color == 'gray':
            return '\x1b[90m'
        code = COLOR_CODES.get(color)
        if code is None:
            return m.group(0)
        return f'\x1b[3{code}m'

    text = _OPEN.sub(replace_open, text)
    text = _CLOSE.sub(_RESET, text)
    return text

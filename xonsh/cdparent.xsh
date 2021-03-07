import re
from xonsh.dirstack import cd as _original_cd

_DOTS_PATTERN = re.compile(r'^\.{3,}')

def _cd(args, stdin=None):
    if not args or (match := _DOTS_PATTERN.match(args[0])) is None:
         return _original_cd(args, stdin=stdin)

    dots = match.group(0)
    levels = len(dots) - 1
    dots_path = '/'.join('..' for _ in range(levels))
    arg0 = args[0].replace(dots, dots_path)
    args = [arg0] + args[1:]
    return _original_cd(args, stdin=stdin)

aliases['cd'] = _cd
aliases['..'] = 'cd ..'

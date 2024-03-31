import sys

if sys.platform == 'linux':
    aliases['ls'] = 'ls --color=auto --group-directories-first'

aliases['l'] = 'ls -F'
aliases['ll'] = 'ls -lh'
aliases['la'] = 'ls -lAh'

aliases['rm'] = 'rm -i'
aliases['cp'] = 'cp -i'
aliases['mv'] = 'mv -i'

aliases['-'] = 'cd -'

aliases['ag'] = 'ag --hidden'

aliases['ip4'] = 'ip -4 addr'

aliases['vim'] = 'nvim'

# TODO
aliases['tb'] = '$XONSH_SHOW_TRACEBACK = not $XONSH_SHOW_TRACEBACK'

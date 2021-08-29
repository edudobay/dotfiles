import importlib
import pkgutil
import os
import subprocess


def find_available_console_scripts():
    commands_path = __path__  # type: ignore  # mypy issue #1422

    modules = (
        importlib.import_module("dotfiles.scripts.%s" % module_info.name)
        for module_info in pkgutil.iter_modules(commands_path)
    )

    def script_name(module):
        return module.__name__.split('.')[-1].replace('_', '-')

    def callable_name(module):
        return module.__name__ + ":main"

    return [
        f"{script_name(module)} = {callable_name(module)}"
        for module in modules
        if hasattr(module, "main") and callable(getattr(module, "main"))
    ]


def find_version() -> str:
    """
    Version will be date of last commit, in YYYYMMDD format.
    """
    cmd = subprocess.run(
        ['git', 'log', '-n1', '--format=%cs'],
        cwd=os.path.dirname(__file__),
        capture_output=True,
        text=True,
    )
    date = cmd.stdout.strip()
    return date.replace('-', '')

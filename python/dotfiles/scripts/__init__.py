import importlib
import pkgutil
import os
import subprocess


def find_available_console_scripts():
    commands_path = __path__  # type: ignore  # mypy issue #1422

    modules = list(pkgutil.iter_modules(commands_path))

    def script_name(module_name):
        return module_name.replace('_', '-')

    def callable_name(module_name):
        return f'dotfiles.scripts.{module_name}:main'

    # TODO: Find a way to introspect modules without really importing them?
    return [
        f"{script_name(module.name)} = {callable_name(module.name)}"
        for module in modules
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

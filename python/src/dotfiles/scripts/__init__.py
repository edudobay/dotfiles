import os
import subprocess


def find_version() -> str:
    """
    Version will be date of last commit, in YYYYMMDD format.
    """
    try:
        cmd = subprocess.run(
            ['git', 'log', '-n1', '--format=%cs'],
            cwd=os.path.dirname(__file__),
            capture_output=True,
            text=True,
            check=True,
        )
    except FileNotFoundError as e:
        raise RuntimeError(f"Could not determine version from Git: {e}") from e

    date = cmd.stdout.strip()
    return date.replace('-', '')

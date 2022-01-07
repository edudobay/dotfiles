#!/usr/bin/env python3
import os, subprocess, sys, re, pathlib, fnmatch, textwrap
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List, Optional

cache_dir = pathlib.Path.home() / '.cache/dotfiles'
cache_file = cache_dir / 'php_versions.sh'
cache_dir.mkdir(parents=True, exist_ok=True)

RE_VERSION_MAJOR_MINOR = re.compile(r'^(\d+)\.(\d+)\.')

@dataclass
class PhpInterpreter:
    path: pathlib.Path
    version: str

    @property
    def directory(self) -> pathlib.Path:
        return self.path.parent

    def matches_version(self, constraint: str) -> bool:
        return fnmatch.fnmatch(self.version, constraint)

    def major_minor_version(self) -> str:
        m = RE_VERSION_MAJOR_MINOR.match(self.version)
        if m is None:
            raise ValueError(self.version)

        return '%s.%s' % (m.group(1), m.group(2))

    def short_alias(self) -> str:
        return self.major_minor_version().replace('.', '')


def examine_interpreter(path: pathlib.Path) -> PhpInterpreter:
    proc = subprocess.run(
        [path, '-r', 'echo PHP_VERSION;'],
        capture_output=True,
        check=True,
    )

    version = proc.stdout.decode('ascii').strip()
    return PhpInterpreter(path, version)


def find_available_php_interpreters() -> List[PhpInterpreter]:
    versions = ['7.2', '7.4', '8.0', '8.1']

    dirs = (
        '/usr/local/opt/php@{version}/bin',
        '/opt/php{version_short}/bin',
        '/usr/bin',
        '/usr/local/bin',
    )

    interpreters = []

    for version in versions:
        version_short = version.replace('.', '')

        for dir in dirs:
            dir = pathlib.Path(dir.format(version=version, version_short=version_short))
            php_exec = dir / 'php'

            if not os.access(php_exec, os.X_OK):
                continue

            try:
                interpreter = examine_interpreter(php_exec)
            except:
                continue

            if not interpreter.matches_version(version + '.*'):
                continue

            interpreters.append(interpreter)

    return interpreters


def find_composer_path() -> Optional[pathlib.Path]:
    proc = subprocess.run(['which', 'composer'], capture_output=True, text=True)
    path = proc.stdout.trim()
    if not path:
        return None

    return pathlib.Path(path)


def switch_main_version(version):
    for interpreter in find_available_php_interpreters():
        if (
            version == interpreter.major_minor_version() or 
            version == interpreter.short_alias() or 
            version == interpreter.version
        ):
            found = interpreter
            break
    else:
        print(f'version not found: {version}')
        sys.exit(2)

    path = os.get_exec_path()
    # TODO: Manipulate the path correctly
    path.insert(0, str(found.directory))
    print(':'.join(path))


def warmup_interpreter_cache():
    items = []
    found_versions = set()

    composer_path = os.getenv('COMPOSER_BIN')
    if not composer_path:
        composer_path = find_composer_path()
    
    for interpreter in find_available_php_interpreters():
        version = interpreter.major_minor_version()
        if version in found_versions: continue
        found_versions.add(version)

        alias = interpreter.short_alias()
        items.append(f'PHP_DIRS[{alias}]={interpreter.path}\n')

        if composer_path:
            items.append(f"alias composer{alias}='{interpreter.path} {composer_path}'\n")

    expires = datetime.now() + timedelta(hours=24)
    data = textwrap.dedent(f'''\
        [[ $(date +%s) -gt {expires:%s} ]] && return
        PHP_DIRS=()
    ''') + ''.join(items)

    sys.stdout.write(data)

    with open(cache_dir / 'php_versions.sh', 'w') as stream:
        stream.write(data)


if __name__ == "__main__":
    cmd, *args = sys.argv[1:]
    if cmd == 'init':
        warmup_interpreter_cache()
    elif cmd == 'switch':
        switch_main_version(*args)

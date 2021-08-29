from setuptools import setup
from dotfiles.scripts import find_available_console_scripts, find_version

setup(
    version=find_version(),
    entry_points={
        'console_scripts': find_available_console_scripts(),
    },
)

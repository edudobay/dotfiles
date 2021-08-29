from setuptools import setup
from dotfiles.scripts import find_available_console_scripts

setup(
    entry_points={
        'console_scripts': find_available_console_scripts(),
    },
)

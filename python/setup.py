from setuptools import setup
from dotfiles.scripts import find_version

setup(
    version=find_version(),
)

#!/usr/bin/env python3
"""
Manage linking of dotfiles from the home directory to a dotfiles directory
"""

# TODO: My naming of 'source' and 'target' is awfully confusing. Need to think
# of something better.

import os, sys, subprocess
from term_color import format as term_format
from stat import S_ISDIR
from ast import literal_eval
from contextlib import contextmanager

DEFAULT_SETTINGS = {
    'HOME': os.path.expanduser('~'),
    'DOTROOT': os.path.expanduser('~/dotfiles'),
    'CONFIG_FILE': os.path.expanduser('~/.config/dotify.conf'),

    # if True, file names in the command lines indicate the source files
    # instead of target files
    'input.source_names': False,

    # whether the source file should have the leading dot trimmed, so that e.g.
    # $HOME/.zshrc -> $DOTROOT/zshrc
    'source.trim_leading_dot': True,

    # whether an existing target should be moved to the source folder and
    # symlinked to the source file thus newly created
    'source.create_from_existing_target': False,

    # whether the created symlinks should use a relative path when possible,
    # e.g. if $DOTROOT is $HOME/dotfiles, this option determines whether the
    # symlink value is "dotfiles/filename" or "$HOME/dotfiles/filename"
    'symlink.use_relative_path': True,
}

## Exceptions

class DotifyException(Exception):
    def __init__(self, *args):
        self.message, *_ = args

class ExistingTargetError(DotifyException):
    """Raised when a target that was to be created already exists"""

class NoSourceError(DotifyException):
    """Raised when the source file for a symlink doesn't exist"""

## Output generation

def explain(msg):
    print(term_format(msg))

def error(*args, **kwargs):
    print('error:', *args, file=sys.stderr, **kwargs)

## Essential filesystem operations

@contextmanager
def create_locked(filename, mode):
    fd = None
    try:
        fd = os.open(filename, os.O_CREAT | os.O_EXCL | os.O_WRONLY, mode)
        os.lockf(fd, os.F_LOCK, 0)
        yield fd
    finally:
        if not fd is None:
            os.close(fd)

def symlink(src, dst, target_is_directory=False, *args, **kwargs):
    """Wrapper around os.symlink that prints a message upon success"""
    os.symlink(src, dst, target_is_directory, *args, **kwargs)
    explain("#Bcreated symlink #F(yellow){dst}#f to #F(yellow){src}#f#b".format(src=src, dst=dst))

def mv(src, dst):
    """Safe move/rename that avoids overwrites and race conditions. Arguments
    are interpreted like in os.rename.
    """
    # Can raise:
    #   FileExistsError      when trying to rename a file to an existing file
    #   IsADirectoryError    when trying to rename a file to an existing dir
    #   NotADirectoryError   when trying to rename a dir to an existing file
    #   OSError#ENOTEMPTY    when trying to rename a dir to an existing dir
    stat_info = os.stat(src)
    is_dir = S_ISDIR(stat_info.st_mode)
    if is_dir:
        os.rename(src, dst)
    else:
        with create_locked(dst, stat_info.st_mode):
            os.rename(src, dst)
    explain("#Bmoved #F(yellow){src}#f to #F(yellow){dst}#f#b".format(src=src, dst=dst))

def create_file(filename, mode=0o666):
    """Create a file if it doesn't exist, do nothing if it exists.

    umask will be flagged out of mode."""
    try:
        fd = os.open(filename, os.O_CREAT | os.O_EXCL, 0o666)
        os.close(fd)
        explain("#Bcreated file #F(yellow){filename}#f#b".format(filename=filename))
    except FileExistsError:
        pass

## Filename manipulation

def transform_target_to_source_name(filename, trim_leading_dot=True):
    # strip the leading dot
    dirname, basename = os.path.split(filename)
    if trim_leading_dot and basename.startswith('.'):
        basename = basename[1:]
        return os.path.join(dirname, basename)
    return filename # unmodified

def transform_source_to_target_name(filename, trim_leading_dot=True):
    # strip the leading dot
    dirname, basename = os.path.split(filename)
    if trim_leading_dot:
        basename = '.' + basename
        return os.path.join(dirname, basename)
    return filename # unmodified

## Our routines

def link(target, source,
        create_from_existing_target=False,
        use_relative_path=True):
    """Create a symbolic link to `source` named `target`. If `target` exists and
    `create_from_existing_target` is True, it is moved to `source` and then
    linked. Otherwise, an ExistingTargetError is raised if the target already
    exists. If the source does not exist, NoSourceError is raised.

    If `use_relative_path` is True, the symlink points to a calculated relative
    path. Otherwise it points to `source` which should be an absolute path.
    """
    # source lies within DOTROOT
    # target lies in HOME but not in DOTROOT
    if os.path.exists(source) and os.path.lexists(target):
        raise ExistingTargetError("target and source already exist")
    elif os.path.lexists(target):
        if os.path.islink(target):
            raise ExistingTargetError("target is already a symlink")
        elif create_from_existing_target:
            mv(target, source)
        else:
            raise ExistingTargetError("target file already exists")
    elif not os.path.exists(source):
        raise NoSourceError("source file does not exist")

    # we should use realpath --base-from=${os.path.dirname(target)} ${source}
    if use_relative_path:
        source_path = os.path.relpath(source, os.path.dirname(target))
    else:
        source_path = source

    symlink(source_path, target)

def link_item(target, settings):
    if settings['input.source_names']:
        source = target
        target = transform_source_to_target_name(source,
                settings['source.trim_leading_dot'])
        source = os.path.abspath(os.path.join(settings['DOTROOT'], source)) \
            if not os.path.isabs(source) else source
    else:
        source = os.path.abspath(os.path.join(settings['DOTROOT'],
            transform_target_to_source_name(target,
                    settings['source.trim_leading_dot'])))

    link(target, source,
        create_from_existing_target=settings['source.create_from_existing_target'],
        use_relative_path=settings['symlink.use_relative_path'])

## Read settings

def settings_from_cmdline(args):
    # return only the settings with keys starting with a '$', stripping the '$'
    return {key[1:]: value
        for key, value in vars(args).items()
        if key.startswith('$')}

def settings_from_config_file(args, settings):
    filename = getattr(args, '$CONFIG_FILE')

    try:
        with open(filename) as stream:
            data = literal_eval(stream.read())
    except FileNotFoundError:
        return {}

    if not isinstance(data, dict):
        raise ValueError("invalid syntax in config file")

    return data

## Command line logic

def build_cmdline_parser():
    # Arguments with 'dest' starting with a '$' will be stored as settings
    import argparse
    parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS,
        description="""Manage a directory of dotfiles and links pointing to
        within it from the home folder. Each dotfile resides in the directory
        known as the 'source' and can be symlinked to a 'target' within the
        user's home folder.
        """)

    parser.add_argument('-c', '--config', metavar='FILE',
        dest='$CONFIG_FILE', default=DEFAULT_SETTINGS['CONFIG_FILE'],
        help="location of the configuration file")
    parser.add_argument('-d', '--dotroot', metavar='DIR', dest='$DOTROOT',
        help="location of the dotfiles directory")
    parser.add_argument('-A', '--absolute-symlink',
        action='store_true', dest='$symlink.use_relative_path',
        help="point symlinks to absolute paths instead of relative")
    parser.add_argument('-D', '--no-trim-dot',
        action='store_false', dest='$source.trim_leading_dot',
        help="don't trim the leading dot in source file names")

    subparsers = parser.add_subparsers(title='subcommands')

    subparser = subparsers.add_parser('link',
        description="""Create symbolic links within the home directory to files
        within the dotfiles directory. The default is to provide the names of
        the symlinks (the 'targets'), but with the -S option their targets (in
        the 'source' directory) may be given instead.
        """,
        help='link dotfiles in the home directory to the dotfiles directory')
    subparser.add_argument('target', nargs='+',
        help='name of a target file in the home directory')
    subparser.add_argument('-C', '--create-source',
        action='store_true', dest='$source.create_from_existing_target',
        help="create source file from existing target file")
    subparser.add_argument('-S', '--source-names',
        action='store_true', dest='$input.source_names',
        help="file names are source names instead of target names")
    subparser.set_defaults(func=main_link)

    return parser

def main_link(args, settings):
    for target in args.target:
        try:
            link_item(target, settings)
        except OSError as e:
            if e.errno in (os.errno.EEXIST, os.errno.ENOTEMPTY, os.errno.ENOTDIR,
                    os.errno.EISDIR):
                error('source exists: for', target)
                raise
        except DotifyException as e:
            error(e.message + ':', target)

def main(args=None):
    # args defaults to None to get parameters from sys.argv; but we leave it
    # open to make testing easier
    parser = build_cmdline_parser()
    args = parser.parse_args(args)

    # dispatch to the appropriate subcommand
    if 'func' in args:
        settings = {}
        settings.update(DEFAULT_SETTINGS)
        settings.update(settings_from_config_file(args, settings))
        settings.update(settings_from_cmdline(args))

        args.func(args, settings)
    else:
        parser.print_usage()

if __name__ == '__main__':
    main()

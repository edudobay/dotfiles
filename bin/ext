#!/usr/bin/python3
"""
Helper for extracting files from archives

The main goal was to make it easier to extract a lot of files without cluttering
the current directory; so this script will by default extract each archive to a
separate directory.
"""
from __future__ import print_function

import sys
import os
import stat
import subprocess
import re
import argparse

def error(*args, **kwargs):
    print('error:', *args, file=sys.stderr, **kwargs)

def check_path(dirname):
    path = os.path.abspath(dirname)
    try:
        mode = os.stat(path).st_mode
        if not stat.S_ISDIR(mode):
            error('{}: not a directory'.format(dirname))
            return False
    except OSError:
        # directory doesn't exist
        try:
            os.makedirs(path)
        except OSError:
            error('output directory {} cannot be created'.format(dirname))
            return False

    return True

def check_subdir(subdir, pardir):
    files = os.listdir(subdir)
    # create temporary name in case destination name already exists or is equal to parent dir
    tmpname = os.path.join(pardir, os.path.basename(subdir) + '_contents')
    if len(files) == 1:
        os.rename(os.path.join(subdir, files[0]), tmpname)
        os.rmdir(subdir)
        os.rename(tmpname, os.path.join(pardir, files[0]))
        return files[0]
    else:
        return None

def main():
    parser = argparse.ArgumentParser(description=\
        "Extract an archive.")
    parser.add_argument('-O', metavar='DIR', dest='destdir',
        help="destination directory for extracted files")
    parser.add_argument('-n', dest='create_subdir', action='store_false',
        help="do not create a separate directory for each archive's contents")
    parser.add_argument('-s', dest='force_subdir', action='store_true',
        help="force creating a separate directory for each archive's contents, "
        "even if archive contains a master folder")
    parser.add_argument('archive', nargs='+',
        help="archive(s) to extract")

    args = parser.parse_args()

    multipart = {}
    cwd = os.path.abspath('.')
    destdir = args.destdir

    errors = []

    if destdir is not None:
        if not check_path(args.destdir):
            sys.exit(1)
        destdir = os.path.abspath(destdir)
    else:
        destdir = cwd

    for archive in args.archive:
        command = []
        name, ext = os.path.splitext(os.path.basename(archive))
        dest = os.path.join(destdir, name) if args.create_subdir \
            else destdir
        change_cwd = None

        if ext == '.zip':
            command = ['unzip',
                '-d', dest,
                archive]

        elif ext == '.rar':
            m = re.search(r'\.part(\d+)$', name)
            if m:
                n = len(m.group(0)) + len('.rar')
                base = archive[:-n]

                if multipart.has_key(base):
                    continue
                else:
                    multipart[base] = archive

            change_cwd = dest
            archive_path = os.path.abspath(os.path.join(cwd, archive))
            command = ['unrar', 'x',
                archive_path]

        elif archive.endswith('.tar.bz2') or archive.endswith('.tar.gz') or archive.endswith('.tgz'):
            command = ['tar', '-C', dest, '-xaf', archive]

        else:
            print('unrecognized archive type:', archive, file=sys.stderr)
            errors.append(archive)
            continue

        if not check_path(dest):
            errors.append(archive)
            continue

        # run command and print status message

        print('\033[1;37m' "==>", ' '.join(command), '\033[0;39m')
        if change_cwd is not None:
            print('(wd now: {})'.format(change_cwd))
        proc = subprocess.Popen(command, cwd=change_cwd)
        if proc.wait() != 0:
            print('\033[1;31m' "extraction failed for archive:", archive, '\033[0;39m')
            errors.append(archive)
        else:
            newname = None
            if not args.force_subdir:
                newname = check_subdir(dest, destdir)
            print('\033[1;32m' "archive extracted:", archive, '\033[0;39m')
            if newname is not None:
                print('==> contents:', newname)

    if errors:
        error("extraction failed for files:")
        for archive in errors:
            print('  ', archive, sep='', file=sys.stderr)

if __name__ == "__main__":
    main()

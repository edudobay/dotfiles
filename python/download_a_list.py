"""
Download and keep synchronized a list of files from different sources.
"""
import os
import sys
import re

__all__ = [
    'Asset', 'Database' 'ParseError',
]

from urllib.parse import urlparse
from email.utils import formatdate, parsedate_to_datetime

try:
    import requests
except ImportError:
    raise NotImplementedError
    # TODO
    # import urllib.request

def print_error(*args):
    print('\033[31m', end='', file=sys.stderr)
    print(*args, end='\033[39m\n', file=sys.stderr)

class ParseError:
    def __init__(self, linenr, message):
        self.linenr = int(linenr)
        self.message = message

    def __str__(self):
        return 'line %d: %s' % (self.linenr, self.message)

    def __repr__(self):
        return 'ParseError(line=%d, message=%r)' % (self.linenr, self.message)

class Asset:
    def __init__(self, source, target=None, dir=None):
        source_url = urlparse(source)
        self.source = source
        self.original_target = target

        if self.original_target is None:
            *_, path_last = source_url.path.strip('/').split('/')
            target = path_last

            # TODO: check
            if not target:
                raise ValueError

        self.target = target
        if dir is None:
            self.target_path = self.target
        else:
            self.target_path = os.path.join(dir, self.target)

    def download(self):
        download_file(self.source, self.target_path)

    def update(self):
        mtime = os.path.getmtime(self.target_path)
        download_file(self.source, self.target_path, if_modified_since=mtime)

class Database:

    RE_LINE = re.compile(r'''
        (?:
          (?P<target>   # target filename
           \S+)
          \s+
        )?
        (?P<source>   # source URL
         http[s]?://(?:.+)
        )
        $
    ''', re.VERBOSE)

    def __init__(self, path, assets_dir):
        self.path = path
        self.assets_dir = assets_dir
        self.load(self.path)

    def load(self, path):
        try:
            with open(path) as stream:
                self.parse_stream(stream)
        except FileNotFoundError:
            self.load_blank()

    def load_blank(self):
        self.assets = []

    def save(self, path=None):
        if path is None:
            path = self.path
        with open(path, 'w') as stream:
            self.write_stream(stream, self.assets)

    def parse_stream(self, stream):
        assets = []
        errors = []

        for linenr, line in enumerate(stream, start=1):
            if line.startswith('#'): continue

            line = line.strip()
            m = self.RE_LINE.match(line)
            if m is None:
                errors.append(ParseError(linenr, 'invalid syntax'))

            source, target = m.group('source', 'target')
            asset = Asset(source, target, dir=self.assets_dir)
            assets.append(asset)

        self.assets = assets
        for error in errors:
            print(error, file=sys.stderr)

    def write_stream(self, stream, assets):
        for asset in assets:
            if asset.original_target:
                line = asset.original_target + '\t' + asset.source
            else:
                line = asset.source

            print(line, file=stream)

    def download_all(self, update=False, redownload=False):
        for asset in self.assets:
            exists = os.path.isfile(asset.target_path)

            if exists and not (update or redownload):
                print('Skipping %s' % asset.target)
                continue

            elif exists:
                if update:
                    print('Updating %s' % asset.target)
                    asset.update()

                elif redownload:
                    print('Redownloading %s' % asset.target)
                    asset.download()

            else:
                print('Downloading %s' % asset.target)
                asset.download()

def timestamp_to_rfc1123(seconds):
    return formatdate(timeval=seconds, localtime=False, usegmt=True)

def datetime_from_rfc1123(string):
    return parsedate_to_datetime(string)

def download_file(url, filename, if_modified_since=None):
    """
    if_modified_since (optional) -- None or a timestamp expressed in
        seconds since the epoch
    """
    headers = {}
    if if_modified_since:
        headers['If-Modified-Since'] = timestamp_to_rfc1123(if_modified_since)

    try:
        r = requests.get(url, headers=headers)
    # TODO Improve error handling
    except requests.exceptions.ConnectionError as e:
        deeper_error = e.args[0]
        print_error('Connection error: %s - %s' % (deeper_error, url))
        return

    if r.status_code == requests.codes.OK:  # 200
        with open(filename, 'wb') as stream:
            stream.write(r.content)

        # If 'Last-Modified' is set, set it as the modification time of the
        # file we wrote
        if 'Last-Modified' in r.headers:
            mtime = datetime_from_rfc1123(r.headers['Last-Modified']).timestamp()
            os.utime(filename, (mtime, mtime))

    elif r.status_code == requests.codes.NOT_MODIFIED:  # 304
        # No action...
        print('... File is up to date:', filename)
        return

    else:
        print_error('HTTP Error: %d %s - %s' % (r.status_code, r.reason, url))



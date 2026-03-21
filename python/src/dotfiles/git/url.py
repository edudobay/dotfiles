import re
from urllib.parse import urlsplit, SplitResult

RE_SCP_URL = re.compile(r"""
    ^
    (?P<netloc>[^:/]+)  # no slashes before the first colon
    :
    (?P<path>.*)
    $
""", re.X)


def make_url(scheme: str = '', netloc: str = '', path: str = '', query: str = '',
             fragment: str = '') -> SplitResult:
    return SplitResult(scheme, netloc, path, query, fragment)


def parse_git_url(url):
    """
    Parse repository URLs recognized by Git.

    References:
    - https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols 
    - https://git-scm.com/docs/git-clone#_git_urls
    """
    parsed = urlsplit(url)
    if parsed.scheme:
        return parsed

    # If the URL has no scheme, it must be a local file or a SSH url with SCP-like syntax

    if (match := RE_SCP_URL.match(url)) is None:
        # Local file — leave it without a scheme
        return parsed

    # SSH url: convert to traditional ssh:// syntax
    netloc = match.group('netloc')
    path = match.group('path')
    resolved_url = f"ssh://{netloc}/{path}"

    return urlsplit(resolved_url)

import pytest
from dotfiles.git.url import parse_git_url, make_url

@pytest.mark.parametrize("input,expected_url", [
    ('ssh://git@github.com/example/repo.git',
     make_url(scheme='ssh', netloc='git@github.com', path='/example/repo.git')),
    ('git@github.com:example/repo.git',
     make_url(scheme='ssh', netloc='git@github.com', path='/example/repo.git')),
    ('bob@example.net:/src/repos/repo.git',
     make_url(scheme='ssh', netloc='bob@example.net', path='//src/repos/repo.git')),
    ('https://token:a1b2c3d4@gitlab.com/myorg/files.git',
     make_url(scheme='https', netloc='token:a1b2c3d4@gitlab.com', path='/myorg/files.git')),
    ('/home/potato/repos/octopus.git',
     make_url(path='/home/potato/repos/octopus.git')),
    ('file:///home/potato/repos/octopus.git',
     make_url(scheme='file', path='/home/potato/repos/octopus.git')),
    ('./foo:bar',
     make_url(path='./foo:bar')),
    ('foo:bar',
     make_url(scheme='foo', path='bar')),
])
def test_parse_urls(input, expected_url):
    assert parse_git_url(input) == expected_url

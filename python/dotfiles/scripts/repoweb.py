#!/usr/bin/env python3

import argparse
import sys
import subprocess
import re
import urllib.parse
from dotfiles.git.url import parse_git_url
from dotfiles.utils.inject import injector
from dataclasses import dataclass
from enum import Enum
from functools import cached_property, wraps


def git(args):
    proc = subprocess.run(
        ['git'] + args,
        check=True,
        capture_output=True,
        encoding=sys.getdefaultencoding(),
    )

    return proc.stdout


def browse(url):
    proc = subprocess.run(
        [get_browser(), url],
        check=True,
    )


def get_browser():
    if sys.platform == 'linux':
        return 'xdg-open'
    return 'open'


class Platform(Enum):
    GitLab = 'gitlab'
    GitHub = 'github'


class PlatformRegistry:
    command_handlers = {}
    handler_factories = {}

    @classmethod
    def register(cls, platform: Platform):
        def wrap(f):
            cls.handler_factories[platform] = f
            return f

        return wrap

    @classmethod
    def command_handler_for(cls, platform: Platform):
        if platform in cls.command_handlers:
            return cls.command_handlers[platform]

        if not platform in cls.handler_factories:
            raise KeyError(f"Platform not mapped: {platform}")

        cls.command_handlers[platform] = cls.handler_factories[platform]()
        return cls.command_handlers[platform]


@dataclass
class RemoteRepository:
    fetch_url: str
    web_url: str
    platform: Platform


@dataclass
class Context:
    args: argparse.Namespace
    remote: RemoteRepository

    @classmethod
    def from_args(cls, args):
        remote_url = get_remote_url(args.remote)
        remote = resolve_remote_repository(remote_url)

        return cls(args=args, remote=remote)

    @cached_property
    def injector(self):
        return injector(dict(
            context=self,
            args=self.args,
            remote=self.remote,
        ))

    @property
    def platform(self) -> Platform:
        return self.remote.platform

    def call(self, callable):
        return self.injector(callable)

    def resolve_command_handler(self) -> 'open_url_command':
        args = self.args
        if callable(args.command) or isinstance(args.command, open_url_command):
            return args.command

        handler = args.command
        if isinstance(args.command, str):
            handler = getattr(Commands, handler)

        if isinstance(handler, Commands):
            handler = PlatformRegistry.command_handler_for(self.platform)
            return handler.run(args.command)



def get_remote_url(remote_name):
    stdout = git(['remote', 'get-url', remote_name])
    return stdout.strip()


def resolve_remote_repository(remote_url: str) -> RemoteRepository:
    url = parse_git_url(remote_url)

    # TODO: This is platform-dependent
    base_url = f'https://{url.hostname}'

    if url.hostname == 'gitlab.com':
        platform = Platform.GitLab
    elif url.hostname == 'github.com':
        platform = Platform.GitHub
    else:
        # TODO: Support specifying the platform via command-line or configuration file
        # For example, map "salsa.debian.org" as a GitLab host
        raise ValueError(f"Host currently not supported: {url.hostname}")

    # The URL to the repository
    path = url.path.lstrip('/').rstrip('/').removesuffix('.git')
    web_url = urllib.parse.urljoin(base_url, path + '/')

    return RemoteRepository(
        fetch_url=remote_url,
        web_url=web_url,
        platform=platform,
    )


def get_current_branch():
    stdout = git(['rev-parse', '--abbrev-ref', 'HEAD'])
    branch_name = stdout.strip()
    return branch_name


def resolve_ref(ref):
    if ref is None or not ref:
        return get_current_branch()
    else:
        return ref


def resolve_ref_as_commit(ref) -> str:
    return git(['rev-parse', ref]).strip()


class open_url_command:
    def __init__(self, path=None, *, url=None):
        def default_url_factory(remote: RemoteRepository, context: Context) -> str:
            return urllib.parse.urljoin(remote.web_url, context.call(path_factory))

        if int(path is None) + int(url is None) != 1:
            raise ValueError('exactly one of path, url must be provided')

        if path is not None:
            path_factory = path if callable(path) else lambda: path
            url_factory = default_url_factory
        else:
            url_factory = url if callable(url) else lambda: url

        self._url_factory = url_factory

    def get_url(self, context):
        return context.call(self._url_factory)

    def print_url(self, context):
        print(self.get_url(context))

    def visit_url(self, context):
        url = self.get_url(context)
        print(url)
        browse(url)


def query_string(params: dict) -> str:
    query = urllib.parse.urlencode({k: v for k, v in params.items() if v is not None})
    if query:
        return '?' + query
    return ''


class Commands(Enum):
    create_new_repo = object()
    view_issues = object()
    new_issue = object()
    view_merge_requests = object()
    view_pipelines = object()
    view_any = object()
    view_tree = object()
    view_commit = object()
    view_branches = object()
    view_settings = object()
    create_merge_request = object()


class PlatformCommands:
    def __init__(self): pass

    def run(self, command: Commands):
        return getattr(self, command.name)


@PlatformRegistry.register(Platform.GitLab)
class GitLabCommands(PlatformCommands):
    create_new_repo = open_url_command(url='https://gitlab.com/projects/new')
    view_issues = open_url_command('-/issues')
    new_issue = open_url_command('-/issues/new')
    view_merge_requests = open_url_command(lambda args: '-/merge_requests' +
                                           query_string({'state': args.state}))
    view_pipelines = open_url_command('-/pipelines')
    view_any = open_url_command(lambda args: args.page.lstrip('/'))
    view_tree = open_url_command(lambda args: '-/tree/' + resolve_ref(args.ref))
    view_commit = open_url_command(
        lambda args: '-/commit/' + resolve_ref_as_commit(resolve_ref(args.ref))
    )
    view_branches = open_url_command('-/branches')

    def _create_settings_path(args):
        page = re.sub(r'[ -_/]+', '_', args.page.lower())

        pages = {
            'general': 'edit',
            'integrations': '-/settings/integrations',
            'webhooks': '-/hooks',
            'access_tokens': '-/settings/access_tokens',
            'repository': '-/settings/repository',
            'ci_cd': '-/settings/ci_cd',
            'monitor': '-/settings/operations',
            'operations': '-/settings/operations',
            'pages': 'pages',
            'packages': '-/settings/packages_and_registries',
            'registries': '-/settings/packages_and_registries',
            'packages_and_registries': '-/settings/packages_and_registries',
        }

        return pages[page]

    view_settings = open_url_command(_create_settings_path)

    def _create_merge_request_path(args):
        params = {
            'merge_request[source_branch]': args.source_branch or get_current_branch(),
            'merge_request[target_branch]': args.target_branch,
        }

        return 'merge_requests/new' + query_string(params)

    create_merge_request = open_url_command(_create_merge_request_path)


@PlatformRegistry.register(Platform.GitHub)
class GitHubCommands(PlatformCommands):
    @staticmethod
    def _issue_state_query(state) -> str:
        return {
            'closed': 'is:closed',
            'merged': 'is:merged',
            'open': 'is:open',
        }[state]

    def _create_settings_path(args):
        page = re.sub(r'[ -_/]+', '_', args.page.lower())

        pages = {
            'main': 'settings',
            'general': 'settings',
            'options': 'settings',
            'access': 'settings/access',
            'security': 'settings/security_analysis',
            'security_analysis': 'settings/security_analysis',
            'branches': 'settings/branches',
            'webhooks': 'settings/hooks',
            'hooks': 'settings/hooks',
            'notifications': 'settings/notifications',
            'integrations': 'settings/installations',
            'deploy_keys': 'settings/keys',
            'keys': 'settings/keys',
            'actions': 'settings/actions',
            'environments': 'settings/environments',
            'secrets': 'settings/secrets/actions',
            'pages': 'settings/pages',
            'moderation': 'settings/interaction_limits',
        }

        return pages[page]

    def _create_merge_request_path(args):
        source_branch = args.source_branch or get_current_branch()
        target_branch = args.target_branch

        return f'compare/{target_branch}...{source_branch}'

    create_new_repo = open_url_command('/new')
    view_issues = open_url_command('issues')
    new_issue = open_url_command('issues/new')
    view_merge_requests = open_url_command(
        lambda args: 'pulls' + query_string({'q': GitHubCommands._issue_state_query(args.state)}))
    view_pipelines = open_url_command('actions')
    view_any = open_url_command(lambda args: args.page.lstrip('/'))
    view_tree = open_url_command(lambda args: 'tree/' + resolve_ref(args.ref))
    view_commit = open_url_command(
        lambda args: 'commit/' + resolve_ref_as_commit(resolve_ref(args.ref))
    )
    view_branches = open_url_command('branches')
    view_settings = open_url_command(_create_settings_path)
    create_merge_request = open_url_command(_create_merge_request_path)


def main_handler(args):
    context = Context.from_args(args)

    handler = context.resolve_command_handler()

    if args.print_only:
        handler.print_url(context)
    else:
        handler.visit_url(context)


def make_subparser(command_handler, *aliases, help, extra_defaults=None):
    main_name, *aliases = aliases

    if extra_defaults is None:
        extra_defaults = {}

    def _subparser_factory(self, subparsers):
        parser = subparsers.add_parser(
            main_name,
            aliases=aliases,
            help=help,
        )

        parser.set_defaults(command=command_handler, **extra_defaults)

        return parser

    return _subparser_factory


def subparser_builder(*args, **kwargs):
    def inner(subparser_configurator):
        @wraps(subparser_configurator)
        def configure_subparser(self, subparsers):
            parser = make_subparser(*args, **kwargs)(self, subparsers)
            subparser_configurator(self, parser)
        return configure_subparser
    return inner


class CliParserBuilder:
    subparser_new_repo = make_subparser(
        Commands.create_new_repo, 'repo-new', 'repo',
        help='Open a page to create a new repository',
    )

    @subparser_builder(
        Commands.view_any, 'go',
        help='Open any repository page given by its path',
    )
    def subparser_go(self, parser):
        parser.add_argument(
            'page', nargs='?', default='',
            help='Specify a custom plain path below the repository URL'
        )

    @subparser_builder(
        Commands.view_tree, 'tree',
        help='Open the repository file tree for a given ref (branch, commit, tag)',
    )
    def subparser_tree(self, parser):
        parser.add_argument(
            'ref', nargs='?', default=None,
            help='Select a ref (default: current branch, or commit if detached)'
        )

    @subparser_builder(
        Commands.view_commit, 'commit',
        help='Open the repository commit view for a given ref (branch, commit, tag)',
    )
    def subparser_commit(self, parser):
        parser.add_argument(
            'ref', nargs='?', default=None,
            help='Select a ref (default: current branch, or commit if detached)'
        )

    @subparser_builder(
        Commands.view_settings, 'settings',
        help='Open one of the repository settings pages',
    )
    def subparser_settings(self, parser):
        parser.add_argument('page')

    subparser_view_issues = make_subparser(
        Commands.view_issues, 'issues',
        help='Open the issues view',
    )

    subparser_new_issue = make_subparser(
        Commands.new_issue, 'issue', 'issue-new',
        help='Open a page to create a new issue',
    )

    subparser_repo = make_subparser(
        Commands.view_any, 'repo', 'browse',
        help='Open the main repository page',
        extra_defaults={'page': ''},
    )

    subparser_branches = make_subparser(
        Commands.view_branches, 'branches',
        help='Open the repository branches page',
    )

    @subparser_builder(
        Commands.view_merge_requests, 'prs', 'mrs',
        help='Open the merge requests view',
    )
    def subparser_view_merge_requests(self, parser):
        group = parser.add_mutually_exclusive_group()
        group.add_argument('--closed', help='show only closed merge requests',
                           dest='state', action='store_const', const='closed')
        group.add_argument('--merged', help='show only merged merge requests',
                           dest='state', action='store_const', const='merged')
        group.add_argument('--open', help='show only open merge requests',
                           dest='state', action='store_const', const='opened')

    subparser_view_pipelines = make_subparser(
        Commands.view_pipelines, 'pipelines',
        help='Open the pipelines view',
    )

    @subparser_builder(
        Commands.create_merge_request, 'pr', 'mr', 'pull', 'merge',
        help='Create a merge request',
    )
    def subparser_pr(self, parser):
        parser.add_argument(
            '-t',
            '--target',
            dest='target_branch',
            help='set the target branch (defaults to master)',
        )

        parser.add_argument(
            'source_branch',
            nargs='?',
            help='set the source branch (defaults to currently checked out branch)',
        )

    def add_subparsers(self, parser):
        subparsers = parser.add_subparsers(
            help='sub-command help',
        )
        for factory in self._get_subparser_factories():
            factory(subparsers)

    def build(self):
        parser = argparse.ArgumentParser(
            description='Open GitLab pages on your web browser'
        )

        parser.add_argument(
            '-p',
            '--print-only',
            action='store_true',
            help="don't open a browser; only print URLs to standard output",
        )

        parser.add_argument(
            '-r',
            '--remote',
            default='origin',
            help='set the remote that should be used (defaults to origin)',
        )
        # TODO: default to first remote (as returned by `git remote`) if `origin`
        # does not exist or is not a GitLab repo

        self.add_subparsers(parser)

        return parser

    def _get_subparser_factories(self):
        return [
            getattr(self, method_name)
            for method_name in dir(self)
            if method_name.startswith('subparser_')
        ]

def main():
    parser = CliParserBuilder().build()
    args = parser.parse_args()

    if not 'command' in args:
        parser.print_usage()
        sys.exit(1)

    main_handler(args)


if __name__ == '__main__':
    main()

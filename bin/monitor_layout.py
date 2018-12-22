#!/usr/bin/env python3

import argparse
import itertools
import os
import re
import subprocess
import sys

import unittest

KNOWN_OUTPUTS = ['hdmi', 'internal']

# --- test helpers ---

class ParameterizedTestFunWrapper:
    def __init__(self, wrapped_fun, args, kwargs):
        self.wrapped_fun = wrapped_fun
        self.args = args
        self.kwargs = kwargs

def parameterized(*args, **kwargs):
    def wrapper(f):
        return ParameterizedTestFunWrapper(f, args, kwargs)

    return wrapper

def parameterized_expand(cls):

    def get_parameterized_wrappers(cls):
        for attr_name in dir(cls):
            attr = getattr(cls, attr_name)
            if isinstance(attr, ParameterizedTestFunWrapper):
                yield attr

    def build_test_name(fun_name, parameters):
        return '%s_%s' % (fun_name, parameters[0])

    for wrapper in get_parameterized_wrappers(cls):
        wrapped_fun = wrapper.wrapped_fun
        fun_name = wrapped_fun.__name__

        for parameters in wrapper.args:
            test_name = build_test_name(fun_name, parameters)
            if len(parameters) > 1:
                # first parameter is test name
                parameters = parameters[1:]

            wrapper_fun = lambda _self: wrapped_fun(_self, *parameters)
            setattr(cls, test_name, wrapper_fun)

    return cls

# --- production code ---

class OutputRef:
    def __init__(self, name):
        self.name = name

    def __eq__(self, other):
        return isinstance(other, type(self)) and self.name == other.name

    def __hash__(self):
        return hash((self.name,))

    def __repr__(self):
        return 'OutputRef(name=%r)' % self.name

class OutputSpec:
    class Relative:
        def __init__(self, other):
            if not isinstance(other, OutputRef):
                raise TypeError('must be an OutputRef: %r' % other)
            self.other = other

        def __eq__(self, other):
            return isinstance(other, type(self)) and self.other == other.other

        def __hash__(self):
            return hash(self.other)

        def __repr__(self):
            return '%s(%r)' % (type(self).__qualname__, self.other)

    class Above(Relative): pass
    class Below(Relative): pass
    class LeftOf(Relative): pass
    class RightOf(Relative): pass

    Off = 'OFF'

    On = 'ON'

def spec_find_word(spec, word):
    def normalize_word(word):
        return re.sub(r'[^a-z]', '', word.strip().lower())

    normalized_word = normalize_word(word)

    for index, spec_word in enumerate(map(normalize_spec_word, spec)):
        if spec_word == normalized_word:
            return index

    return None

def parse_spec(spec, output_aliases):
    if len(spec) == 0:
        return []

    def output(output_name):
        if output_name not in output_aliases:
            raise KeyError('output not recognized: %r' % output_name)
        return OutputRef(output_aliases[output_name])


    if len(spec) == 1:
        output_name, = spec
        return [
            (output(output_name), OutputSpec.On),
        ]

    if spec[1] == 'above':
        output_name, _, relative_to_output = spec
        return [
            (output(output_name), OutputSpec.Above(output(relative_to_output))),
        ]

    if spec[1] == 'below':
        output_name, _, relative_to_output = spec
        return [
            (output(output_name), OutputSpec.Below(output(relative_to_output))),
        ]

    if spec[1].lower() == 'left' and spec[2].lower() == 'of':
        spec = spec[:1] + ['leftof'] + spec[3:]

    if spec[1] == 'leftof':
        output_name, _, relative_to_output = spec
        return [
            (output(output_name), OutputSpec.LeftOf(output(relative_to_output))),
        ]

    if spec[1].lower() == 'right' and spec[2].lower() == 'of':
        spec = spec[:1] + ['rightof'] + spec[3:]

    if spec[1] == 'rightof':
        output_name, _, relative_to_output = spec
        return [
            (output(output_name), OutputSpec.RightOf(output(relative_to_output))),
        ]

def expand_specs(specs, known_outputs):
    if not specs:
        return []

    def implicit_outputs(output, spec):
        if isinstance(spec, OutputSpec.Relative):
            return [output, spec.other]

        return []

    expanded_specs = list(specs)

    known_outputs = frozenset(OutputRef(name) for name in known_outputs)

    explicitly_wanted_outputs = frozenset(output for (output, spec) in specs if spec == OutputSpec.On)
    implicitly_wanted_outputs = frozenset(itertools.chain.from_iterable(
        implicit_outputs(output, spec) for (output, spec) in specs
    ))

    wanted_outputs = explicitly_wanted_outputs | implicitly_wanted_outputs

    outputs_to_disable = known_outputs - wanted_outputs
    outputs_to_enable = implicitly_wanted_outputs - explicitly_wanted_outputs

    expanded_specs += [(output, OutputSpec.On) for output in outputs_to_enable]
    expanded_specs += [(output, OutputSpec.Off) for output in outputs_to_disable]

    return expanded_specs

def group_specs(specs):
    grouped = itertools.groupby(
        sorted(specs, key=lambda output_spec: output_spec[0].name),
        key=lambda output_spec: output_spec[0]
    )
    return [(output, set(specs for (output, specs) in output_specs)) for (output, output_specs) in grouped]

def xrandr_relative_switch(spec):
    return {
        OutputSpec.Above: '--above',
        OutputSpec.Below: '--below',
        OutputSpec.LeftOf: '--left-of',
        OutputSpec.RightOf: '--right-of',
    }[type(spec)]

def build_xrandr_commands(grouped_specs):
    if not grouped_specs:
        return []

    command = ['xrandr']

    for (output, output_specs) in grouped_specs:
        command += ['--output', output.name]

        for spec in output_specs:
            if isinstance(spec, OutputSpec.Relative):
                command += [xrandr_relative_switch(spec), spec.other.name]
            elif spec == OutputSpec.On:
                command += ['--auto']
            elif spec == OutputSpec.Off:
                command += ['--off']
            else:
                raise ValueError('invalid spec: %r' % spec)

    return [command]

def grep_start(lines, pattern):
    if not isinstance(pattern, re.Pattern):
        pattern = re.compile(pattern)

    for line in lines:
        match = pattern.match(line)
        if match is not None:
            yield (match, line)

def query_connected_outputs():
    proc = subprocess.run(['xrandr'], encoding='utf-8', capture_output=True, check=True)

    outputs = [
        match.group(1)
        for (match, _) in grep_start(proc.stdout.splitlines(), r'([a-zA-Z0-9_-]+) connected')
    ]

    return outputs

def friendly_output_names(outputs):
    hdmi_re = re.compile(r'HDMI-?(\d+)', re.IGNORECASE)
    lvds_re = re.compile(r'LVDS-?(\d+)', re.IGNORECASE)
    edp_re = re.compile(r'eDP-?(\d+)', re.IGNORECASE)

    aliases = {}

    def found_output(output, alias, generic_alias):
        aliases[alias] = output

        if generic_alias not in aliases:
            aliases[generic_alias] = output

    def match_hdmi_alias(output):
        match = hdmi_re.match(output)
        if match is not None:
            index = match.group(1)
            found_output(output, 'hdmi' + index, 'hdmi')
            return True

    def match_internal_alias(output):
        match = lvds_re.match(output)
        if match is not None:
            index = match.group(1)
            found_output(output, 'lvds' + index, 'internal')
            return True
        
        match = edp_re.match(output)
        if match is not None:
            index = match.group(1)
            found_output(output, 'edp' + index, 'internal')
            return True

    for output in outputs:
        match_hdmi_alias(output) or \
            match_internal_alias(output)

    return aliases

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('spec', nargs='+')

    args = parser.parse_args()

    available_outputs = query_connected_outputs()
    output_aliases = friendly_output_names(available_outputs)

    known_outputs = set(available_outputs) & set(output_aliases.values())

    for command in build_xrandr_commands(
            group_specs(
                expand_specs(
                    parse_spec(args.spec, output_aliases),
                    known_outputs
                )
            )
    ):
        subprocess.run(command, check=True)

# --- test suite ---

@parameterized_expand
class SpecParseTestCase(unittest.TestCase):
    output_aliases = {'hdmi': 'HDMI1', 'internal': 'LVDS1'}

    def test_empty_spec(self):
        self.assertEqual([], parse_spec([], self.output_aliases))

    def test_spec_with_only_hdmi_output(self):
        self.assertEqual(
            [(OutputRef('HDMI1'), OutputSpec.On)],
            parse_spec(['hdmi'], self.output_aliases))

    def test_spec_with_only_internal_output(self):
        self.assertEqual(
            [(OutputRef('LVDS1'), OutputSpec.On)],
            parse_spec(['internal'], self.output_aliases))

    def test_spec_with_hdmi_above_internal(self):
        self.assertEqual(
            [(OutputRef('HDMI1'), OutputSpec.Above(OutputRef('LVDS1')))],
            parse_spec('hdmi above internal'.split(), self.output_aliases))

    def test_spec_with_internal_below_hdmi(self):
        self.assertEqual(
            [(OutputRef('LVDS1'), OutputSpec.Below(OutputRef('HDMI1')))],
            parse_spec('internal below hdmi'.split(), self.output_aliases))

    @parameterized(
        ['hdmi left-of internal'],
        ['hdmi leftof internal'],
        ['hdmi leftOf internal'],
        ['hdmi left of internal'],
    )
    def test_spec_leftof(self, spec):
        self.assertEqual(
            [(OutputRef('HDMI1'), OutputSpec.LeftOf(OutputRef('LVDS1')))],
            parse_spec(spec.split(), self.output_aliases))


    @parameterized(
        ['hdmi right-of internal'],
        ['hdmi rightof internal'],
        ['hdmi rightOf internal'],
        ['hdmi right of internal'],
    )
    def test_spec_rightof(self, spec):
        self.assertEqual(
            [(OutputRef('HDMI1'), OutputSpec.RightOf(OutputRef('LVDS1')))],
            parse_spec(spec.split(), self.output_aliases))

@parameterized_expand
class SpecExpandTestCase(unittest.TestCase):
    known_outputs = ['hdmi', 'internal']

    def test_empty_spec_expanded_is_still_empty(self):
        self.assertEqual([], expand_specs([], self.known_outputs))

    @parameterized(
        ['hdmi only',
            [(OutputRef('hdmi'), OutputSpec.On)],
            [(OutputRef('hdmi'), OutputSpec.On),
             (OutputRef('internal'), OutputSpec.Off)]],
        ['hdmi above internal',
            [(OutputRef('hdmi'), OutputSpec.Above(OutputRef('internal')))],
            [(OutputRef('hdmi'), OutputSpec.On),
             (OutputRef('hdmi'), OutputSpec.Above(OutputRef('internal'))),
             (OutputRef('internal'), OutputSpec.On)]]
    )
    def test_expand(self, specs, expanded):
        self.assertEqual(set(expanded), set(expand_specs(specs, self.known_outputs)))

@parameterized_expand
class SpecGroupTestCase(unittest.TestCase):
    @parameterized(
        ['hdmi only',
            [(OutputRef('hdmi'), OutputSpec.On),
             (OutputRef('internal'), OutputSpec.Off)],
            [(OutputRef('hdmi'), {OutputSpec.On}),
             (OutputRef('internal'), {OutputSpec.Off})]],
         
        ['hdmi above internal',
            [(OutputRef('hdmi'), OutputSpec.On),
             (OutputRef('hdmi'), OutputSpec.Above(OutputRef('internal'))),
             (OutputRef('internal'), OutputSpec.On)],
            [(OutputRef('hdmi'), {OutputSpec.On, OutputSpec.Above(OutputRef('internal'))}),
             (OutputRef('internal'), {OutputSpec.On})]]
    )
    def test_group(self, expanded, grouped):
        self.assertEqual(grouped, group_specs(expanded))

@parameterized_expand
class XrandrCommandBuilderTestCase(unittest.TestCase):
    def test_empty_spec_yields_no_command(self):
        self.assertEqual([], build_xrandr_commands([]))

    @parameterized(
        ['hdmi above internal', 
            [(OutputRef('hdmi'), [OutputSpec.On, OutputSpec.Above(OutputRef('internal'))]),
             (OutputRef('internal'), [OutputSpec.On])],
            'xrandr --output hdmi --auto --above internal --output internal --auto'],
        ['hdmi left of internal', 
            [(OutputRef('hdmi'), [OutputSpec.On, OutputSpec.LeftOf(OutputRef('internal'))]),
             (OutputRef('internal'), [OutputSpec.On])],
            'xrandr --output hdmi --auto --left-of internal --output internal --auto'],
        ['hdmi', 
            [(OutputRef('hdmi'), [OutputSpec.On]),
             (OutputRef('internal'), [OutputSpec.Off])],
            'xrandr --output hdmi --auto --output internal --off'],
    )
    def test_command(self, specs, command):
        self.assertEqual([command.split()], build_xrandr_commands(specs))

# --- end test suite ---

if __name__ == '__main__':
    main()

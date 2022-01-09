import pytest
from dotfiles.utils.inject import injector

injectables = {
    'arg1': object(),
    'arg2': object(),
}

def func_accepts_arg1(arg1):
    assert arg1 is injectables['arg1']

def func_accepts_arg2(arg2):
    assert arg2 is injectables['arg2']
    return 42

def func_accepts_arg1_and_arg2(arg2, arg1):
    assert arg1 is injectables['arg1']
    assert arg2 is injectables['arg2']
    return -1

def func_accepts_nothing():
    pass

def func_accepts_positional_args(*args):
    assert len(args) == 0

lambda_accepts_nothing = lambda: 'nothing returned'
lambda_accepts_arg1_and_arg2 = lambda arg1, arg2: func_accepts_arg1_and_arg2(arg2, arg1)


@pytest.mark.parametrize("callable,expected_return", [
    (func_accepts_arg1, None),
    (func_accepts_arg2, 42),
    (func_accepts_arg1_and_arg2, -1),
    (func_accepts_nothing, None),
    (func_accepts_positional_args, None),
    (lambda_accepts_nothing, 'nothing returned'),
    (lambda_accepts_arg1_and_arg2, -1),
])
def test_inject_one(callable, expected_return):
    result = injector(injectables)(callable)
    assert result == expected_return

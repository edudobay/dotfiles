import importlib.machinery
import importlib.util
import os
import stat
import sys
import pytest


class ScriptModule(pytest.Module):
    def _getobj(self):
        module_name = self.path.name.replace("-", "_")
        loader = importlib.machinery.SourceFileLoader(module_name, str(self.path))
        spec = importlib.util.spec_from_loader(module_name, loader)
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        loader.exec_module(module)
        return module


def _is_python_executable(file_path) -> bool:
    """Return True if file is executable and its shebang interpreter contains 'python'."""
    mode = os.stat(file_path).st_mode
    if not (mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)):
        return False
    try:
        with open(file_path, "rb") as f:
            line = f.readline(512)
    except OSError:
        return False
    if not line.startswith(b"#!"):
        return False

    # Don't support Python 2 scripts.
    if any(b"python2" in word.split(b"/")[-1] for word in line[2:].split()):
        return False

    return any(b"python" in word.split(b"/")[-1] for word in line[2:].split())


def pytest_collect_file(parent, file_path):
    # test_*.py files are handled by pytest natively; only intervene for
    # extensionless executables whose shebang points at a Python interpreter.
    if file_path.suffix == "" and _is_python_executable(file_path):
        return ScriptModule.from_parent(parent, path=file_path)

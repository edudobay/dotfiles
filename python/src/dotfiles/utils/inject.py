import inspect

class injector:
    def __init__(self, injectables: dict):
        self.injectables = injectables

    def __call__(self, target):
        signature = inspect.signature(target)
        accepts = set(signature.parameters.keys())
        available = set(self.injectables.keys())

        args = {}
        for arg in (accepts & available):
            args[arg] = self.injectables[arg]

        bound = signature.bind(**args)
        return target(*bound.args, **bound.kwargs)

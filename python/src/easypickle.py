import pickle

def from_pickle(filename):
    with open(filename, 'rb') as stream:
        return pickle.load(stream)

def to_pickle(obj, filename):
    with open(filename, 'wb') as stream:
        pickle.dump(obj, stream)


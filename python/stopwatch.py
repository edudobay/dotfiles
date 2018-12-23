import time

class StopWatch:
    def __init__(self):
        self.duration = -time.time()

    def stop(self):
        self.duration += time.time()
        return self.duration

    def check(self):
        return (self.duration + time.time())


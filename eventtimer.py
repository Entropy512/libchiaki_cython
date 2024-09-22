from time import clock_gettime_ns, CLOCK_MONOTONIC

class EventTimer:
    def __init__(self):
        self.starttime = None
        self.periodic = False
        self.duration = 0.0
    
    # Oneshot if periodic is False, repeating if True, defaults to oneshot
    # Duration in seconds, converted to nanoseconds internally
    def start(self, duration, periodic=False):
        self.starttime = clock_gettime_ns(CLOCK_MONOTONIC)
        self.periodic = periodic
        self.duration = int(duration * 1e9)
    
    def stop(self):
        self.starttime = None
        self.periodic = False
        self.duration = 0.0

    def check(self):
        #Always return false if not running.
        #TODO:  Consider making this an exception since we shouldn't be checking expired oneshots
        if(self.starttime is None):
            return False
        else:
            if(clock_gettime_ns(CLOCK_MONOTONIC) >= self.starttime + self.duration):
                self.starttime += self.duration
                if(not self.periodic):
                    self.stop()
                return True
            else:
                return False
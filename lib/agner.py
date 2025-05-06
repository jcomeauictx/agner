from __future__ import print_function
import glob
import os
import sys
import logging
import subprocess
from argparse import ArgumentParser
from _tkinter import TclError

logging.basicConfig(level=logging.DEBUG if __debug__ else logging.WARNING)

THIS_DIR = os.path.dirname(os.path.realpath(__file__))

def filter_match(tests, test, subtest):
    # Somewhat ropey 'wildcard' matching
    if not tests: return True
    for match in tests:
        if match == '%s.%s' % (test, subtest): return True
        if match == '%s.*' % (test,): return True
    return False

def iteritems(some_dict):
    '''
    use items() where available
    '''
    try:
        return some_dict.items()
    except AttributeError:
        return some_dict.iteritems()

def iterkeys(some_dict):
    '''
    use keys() where available
    '''
    try:
        return some_dict.keys()
    except AttributeError:
        return some_dict.iterkeys()

def split(string_or_bytes, delimiter):
    '''
    split string_or_bytes whether delimiter is either
    '''
    try:
        return string_or_bytes.split(delimiter)
    except TypeError:
        if hasattr(string_or_bytes, 'encode'):
            return string_or_bytes.split(delimiter.decode())
        else:
            return string_or_bytes.split(delimiter.encode())

class Test(object):
    def __init__(self, name, runner, plotter):
        self.name = name
        self.runner = runner
        self.plotter = plotter


class Agner(object):
    def __init__(self):
        self._tests = {}
        self._cur_test = None

    def tests(self):
        return self._tests.keys()

    def subtests(self, test):
        return self._tests[test].keys()

    def add_tests(self, name, module):
        self._cur_test = name
        self._tests[name] = {}
        module.add_tests(self)
        self._cur_test = None

    def add_test(self, name, runner, plotter):
        self._tests[self._cur_test][name] = Test(name, runner, plotter)

    def run_tests(self, tests):
        results = {}
        for test, subtests in iteritems(self._tests):
            results[test] = {}
            for subtest, tester in iteritems(subtests):
                if not filter_match(tests, test, subtest): continue
                print("Running %s.%s ..." % (test, subtest))
                results[test][subtest] = tester.runner()
        return results

    def plot_results(self, results, tests, alternative, callback=None):
        import matplotlib.pyplot as plt
        for test, subtests in iteritems(results):
            for subtest, result in iteritems(subtests):
                if not filter_match(tests, test, subtest): continue
                tester = self._tests[test][subtest]
                tester.plotter(result, alternative)
                if callback:
                    callback(test, subtest)
        

def run_test(test, counters, init_once="", init_each="", repetitions=3, procs=1):
    os.chdir(os.path.join(THIS_DIR, "..", "src"))
    sys.stdout.flush()
    check_call(["make", "-s", "out/a64.o"])

    with open("out/counters.inc", "w") as cf:
        [cf.write("    DD %d\n" % counter) for counter in counters]

    with open("out/test.inc", "w") as tf:
        tf.write(test)

    with open("out/init_once.inc", "w") as init_f:
        init_f.write(init_once)

    with open("out/init_each.inc", "w") as init_f:
        init_f.write(init_each)

    check_call([
        "nasm", "-f", "elf64", 
        "-l", "out/b64.lst",
        "-I", "out/",
        "-o", "out/b64.o",
        "-D", "REPETITIONS=%d" % repetitions,
        "-D", "NUM_THREADS=%d" % procs,
        "PMCTestB64.nasm"])
    check_call(["g++", "-z", "noexecstack", "-o", "out/test", "out/a64.o", "out/b64.o", "-lpthread"])
    result = check_output(["out/test"])
    results = []
    header = None
    for line in split(result, "\n"):
        line = line.strip()
        if not line or b'No matching counter' in line:
            continue
        splitted = split(line, ",")
        if not header:
            header = splitted
            logging.debug('setting header to %r, discarding result %r',
                          header, splitted)
        else:
            logging.debug('header: %r, splitted: %r', header, splitted)
            try:
                results.append(dict(zip(header, [int(x) for x in splitted])))
            except ValueError as problem:
                logging.error(problem)
                results.append([0, 0])
    return results


class MergeError(RuntimeError):
    pass


def merge_results(previous, new, threshold=0.15):
    if previous == None: return new
    if len(previous) != len(new):
        raise RuntimeError("Badly sized results")
    for index in range(len(previous)):
        prev_item = previous[index]
        new_item = new[index]
        for key in iterkeys(prev_item):
            if key in new_item:
                delta = abs(prev_item[key] - new_item[key])
                delta_ratio = delta / float(prev_item[key])
                print(key, delta_ratio)
                if delta_ratio > threshold:
                    logging.error("Unable to get a stable merge for %r", key)  # TODO better
        for key in iterkeys(new_item):
            if key not in prev_item:
                prev_item[key] = new_item[key]
    return previous


def print_test(*args, **kwargs):
    results = run_test(*args, **kwargs)
    for result in results:
        print(result)

def check_call(*args, **kwargs):
    '''
    use subprocess `check_call` but show what's going on
    '''
    logging.debug('call: %s', args)
    return subprocess.check_call(*args, **kwargs)

def check_output(*args, **kwargs):
    '''
    use subprocess `check_call` but show what's going on
    '''
    logging.debug('call: %s', args)
    return subprocess.check_output(*args, **kwargs)
# vim: tabstop=8 expandtab softtabstop=4 shiftwidth=4

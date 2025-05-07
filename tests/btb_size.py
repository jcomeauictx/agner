#!/usr/bin/env python

from __future__ import print_function
import os
import sys

THIS_DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.extend([THIS_DIR, os.path.dirname(THIS_DIR)])

from lib.agner import *

def btb_size_test(name, num_branches, align):
    test_code = """
%macro OneJump 0
jmp %%next
align {align}
%%next:
%endmacro

jmp BtbLoop
align 4 * 1024 * 1024; align to a 4MB boundary
BtbLoop:
%rep {num_branches}
OneJump
%endrep

%rep 64
nop
%endrep
""".format(num_branches=num_branches, align=align)
    r = run_test(test_code, [1, 410, 403, 404], repetitions=100)
    return min(r, key=lambda x: x.get('BaClrAny', sys.maxsize))

def plot(xs, ys, result, name, index):
    import numpy as np
    import matplotlib.pyplot as plt

    if index:
        ax = plt.subplot(2, 2, index)
    else:
        ax = plt.subplot(1, 1, 1)
    try:
        ax.set_yscale('log', basey=2)
    except TypeError:
        ax.set_yscale('log', base=2)
    plt.title(name)
    
    plt.xlabel("Branch count")
    plt.ylabel("Branch alignment")
    ax.xaxis.set_ticks(xs)
    xs = np.array(xs + [xs[-1] + 1])
    ys = np.array(ys + [ys[-1] * 2])
    xx, yy = np.meshgrid(xs, ys)
    result = np.array(result)
    plt.pcolor(xx, yy, result)
    plt.colorbar()


def btb_test(nums, aligns, name):
    resteer = []
    early = []
    late = []
    core = []
    for align in aligns:
        resteer.append([])
        early.append([])
        late.append([])
        core.append([])
        for num in nums:
            res = btb_size_test("BTB size test %d branches aligned on %d" % (num, align), num, align)
            logging.debug('num: %r, res: %r', num, res)
            exp = num * 100.0 # number of branches under test
            resteer[-1].append(res.get('BaClrAny', sys.maxsize) / exp)
            early[-1].append(res.get('BaClrEly', sys.maxsize) / exp)
            late[-1].append(res.get('BaClrL8', sys.maxsize) / exp)
            core[-1].append(res.get('Core cyc', sys.maxsize) / exp)
    return {'resteer': resteer, 'early': early, 'late': late, 'core': core}


def btb_plot(nums, aligns, name, results, alt):
    import matplotlib.pyplot as plt
    try:
        fig = plt.figure()
    except TclError as failed:
        logging.fatal('Failed plt.figure(): %s', failed)
        sys.exit(1)
    locs, labels = plt.xticks()
    plt.setp(labels, rotation=90)
    plt.title(name)
    try:
        fig.canvas.set_window_title(name)
    except AttributeError:
        fig.canvas.manager.set_window_title(name)
    if alt:
        plot(nums, aligns, results['resteer'], "Front-end re-steers", 0)
    else:
        plot(nums, aligns, results['resteer'], "Front-end re-steers", 1)
        plot(nums, aligns, results['early'], "Early clears", 2)
        plot(nums, aligns, results['late'], "Late clears", 3)
        plot(nums, aligns, results['core'], "Core cycles/branch", 4)


def add_test(agner, nums, aligns, name):
    test = lambda: btb_test(nums, aligns, name)
    plot = lambda results, alt : btb_plot(nums, aligns, name, results, alt)
    agner.add_test(name, test, plot)


def add_tests(agner):
    # attempt to find total size
    add_test(agner, range(512, 9000, 512), [2, 4, 8, 16, 32, 64], "Total size")

    # attempt to find set bits
    add_test(agner, [3, 4, 5], [2**x for x in range(1, 24)],  "Bits in set")

    # attempt to find number of ways : large leaps to ensure we hit the same set every time
    add_test(agner, range(1,12), [2**x for x in range(1, 21)], "Number of ways")

    # attempt to find number of addr bits : two branches very spread
    add_test(agner, [2], [2**x for x in range(6, 28)], "Number of address bits for set")
# vim: tabstop=8 expandtab softtabstop=4 shiftwidth=4

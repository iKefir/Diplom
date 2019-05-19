#! /usr/bin/env python
# -*- coding: utf-8 -*-

# The very top caller. No one else can call him and he calls everyone (at least at this folder)

import subprocess
import os.path
import phase_transition_check
import bin_search

newpath='../IOHProfiler/Results/IOHExperimenter'
f_id = [2, 1]
ua = ['stat'] # 'stat', 'ab'
fitness = ['stat'] # 'stat', 'bi', 'pm'
restarts = [100]
# dimensions = [10]
dimensions = [10,   20,   30,   40,   50,   60,   70,   80,   90,
              100,  200,  300,  400,  500,  600,  700,  800,  900]
              # 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]

if __name__ == '__main__':
    for fun_id in f_id:
        for r in restarts:
            for d in dimensions:
                for f in fitness:
                    for alg in ua:
                        bin_search.main(fun_id, r, d, newpath, f, alg)

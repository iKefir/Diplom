#! /usr/bin/env python
# -*- coding: utf-8 -*-

# The very top caller. No one else can call him and he calls everyone (at least at this folder)

import subprocess
import os.path
import phase_transition_check
import bin_search

newpath='../IOHProfiler/Results/Experimentation'
f_id = [2]
ua = ['stat'] # 'stat', 'ab'
fitness = ['bi'] # 'stat', 'bi', 'pm'
restarts = [100]
dimensions = [ 10,  20,  30,  40,  50,  60,  70,  80,  90, 100,
              110, 120, 130, 140, 150, 160, 170, 180, 190, 200]

if __name__ == '__main__':
    max_budget = 100000
    for fun_id in f_id:
        for r in restarts:
            for d in dimensions:
                for f in fitness:
                    for alg in ua:
                        bin_search.main(fun_id, r, 1000, d, newpath, f, alg)

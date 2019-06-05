#! /usr/bin/env python
# -*- coding: utf-8 -*-
import os
import analyse
import sys

directory='../IOHProfiler/Results/IOHExperimenter/5'

fls = [fl for fl in os.listdir(directory + '/all_zips') if fl.endswith('zip')]
sys.stdout.write('\n')
for i, fl in enumerate(fls):
    sys.stdout.write('\r\033[K\033[1F\033[K' + ('%.2f' % (float(i) / len(fls))) + '%\tAnalyzing:\t' + fl + '\n')
    sys.stdout.flush()
    analyse.process_zip(directory + '/all_zips/' + fl, 90)

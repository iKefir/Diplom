#! /usr/bin/env python
# -*- coding: utf-8 -*-
import os
import analyse
import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

p_directory='../IOHProfiler/Results/experiment_3.1/'

for func_id in ['1', '2']:
    directory = p_directory + func_id
    ress = {}

    fls = [fl for fl in os.listdir(directory + '/all_zips') if fl.endswith('zip')]
    sys.stdout.write('\n')
    for i, fl in enumerate(fls):
        sys.stdout.write('\r\033[K\033[1F\033[K' + ('%.0f' % (float(i*100) / len(fls))) + '%\tAnalyzing:\t' + fl + '\n')
        sys.stdout.flush()
        ress[fl] = analyse.process_zip(directory + '/all_zips/' + fl, 100)

    common_pref='001-fit'

    if not os.path.exists(os.path.join(directory, 'all_zips', 'comb_graphs')):
        os.mkdir(os.path.join(directory, 'all_zips', 'comb_graphs'))
    if not os.path.exists(os.path.join(directory, 'all_zips', 'comb_graphs', 'best_fitness')):
        os.mkdir(os.path.join(directory, 'all_zips', 'comb_graphs', 'best_fitness'))
    if not os.path.exists(os.path.join(directory, 'all_zips', 'comb_graphs', 'changes')):
        os.mkdir(os.path.join(directory, 'all_zips', 'comb_graphs', 'changes'))

    chgs = ['_bi', '_pm']
    freqs = ['_1', '_5', '_10', '_50', '_100', '_500', '_1000', '_5000']

    prefixes = [common_pref + chg + freq for chg in chgs for freq in freqs]
    prefixes += ['001-fit_stat_0']

    for comm_name in prefixes:
        stat_name = comm_name + '_stat.zip'
        ab_name = comm_name + '_ab.zip'
        stat_inds = ress[stat_name][0]
        ab_inds = ress[ab_name][0]
        stat_results = ress[stat_name][1]
        ab_results = ress[ab_name][1]
        plt.figure()
        plt.plot(stat_inds, stat_results)
        plt.plot(ab_inds, ab_results)
        func_id = os.path.basename(directory)
        plt.xlabel('evaluations (func_id: ' + func_id + ' run_params: '+ comm_name[8:] + ')')
        plt.ylabel('best f(x) since change')
        plt.savefig(os.path.join(directory, 'all_zips', 'comb_graphs', 'best_fitness', comm_name + '.png'), dpi=100)

        stat_changes = ress[stat_name][2]
        ab_changes = ress[ab_name][2]
        plt.figure()
        plt.plot(stat_changes)
        plt.plot(ab_changes)
        plt.xlabel('number of period between changes (func_id: ' + func_id + ' run_params: '+ comm_name[8:] + ')')
        plt.ylabel('percent of successful runs')
        plt.savefig(os.path.join(directory, 'all_zips', 'comb_graphs', 'changes', comm_name + '.png'), dpi=100)

        plt.close('all')

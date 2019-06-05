#! /usr/bin/env python
# -*- coding: utf-8 -*-

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import argparse
import zipfile
import os
import sys
import tempfile
import subprocess
from contextlib import closing

def parse_command_line():
    parser = argparse.ArgumentParser(description='Advanced plots maker.')
    parser.add_argument('path', nargs=1, help='Path of results zip.')
    parser.add_argument('best_f', nargs=1, help='Best fitness available.')
    return parser.parse_args()

def analyse(path, filename, best_fitness):
    results = []
    changes = [0]
    runs = 0
    ch_ind = 0
    can_add_run = True
    with closing(zipfile.ZipFile(path, 'a')) as zf:
        with zf.open(filename) as rr:
        # with open(path + '/data_f4/IOHProfiler_f4_DIM100_i1.cdat', 'r') as rr:
            for line in rr:
                # print line
                to_check = '"function evaluation" "current f(x)" "best-so-far f(x)" "current af(x)+b"  "best af(x)+b" "best_value" "mutation_rate" "next_budget_to_change_fitness" \n'
                # print line == to_check
                if line == to_check:
                    runs += 1
                    ch_ind = 0
                    can_add_run = True
                    sys.stdout.write('\r\truns:\t' + str(runs))
                    sys.stdout.flush()
                else:
                    ll = line.split(' ')
                    eval_num = int(ll[0]) - 1
                    best_f = float(ll[5])
                    # print eval_num
                    if (len(results) > eval_num):
                        results[eval_num] += best_f
                    else:
                        results.append(best_f)

                    if best_f < 0.0:
                        ch_ind += 1
                        can_add_run = True
                        if len(changes) <= ch_ind:
                            changes.append(0)

                    if can_add_run and best_f == best_fitness:
                        changes[ch_ind] += 1
                        can_add_run = False

        bp_filename = 'best_fitness_plot.png'
        cp_filename = 'changes_plot.png'

        try:
            files_to_del = [bp_filename, cp_filename]
            cmd=['zip', '-d', path] + files_to_del
            with open(os.devnull, 'w')  as FNULL:
                subprocess.check_call(cmd, stdout=FNULL, stderr=FNULL)
        except:
            pass

    with closing(zipfile.ZipFile(path, 'a')) as zf:
        tmpdir = tempfile.mkdtemp()

        # Ensure the file is read/write by the creator only
        bp_path = os.path.join(tmpdir, bp_filename)
        cp_path = os.path.join(tmpdir, cp_filename)
        figure_path = os.path.join(os.path.dirname(path), 'graphs')
        if not os.path.exists(figure_path):
            os.mkdir(figure_path)

        try:
            results = [num / runs for num in results if num >= 0.0]
            plt.figure()
            plt.plot(results)
            plt.xlabel('evaluations')
            plt.ylabel('best f(x) since change')
            plt.savefig(bp_path, dpi=100)
            plt.savefig(os.path.join(figure_path, os.path.basename(path)[:-4] + '_best_fitness.png'), dpi=100)
            zf.write(bp_path, os.path.basename(bp_path))

            changes = [change / 100.0 for change in changes]
            plt.figure()
            plt.plot(changes)
            plt.xlabel('number of period between changes')
            plt.ylabel('percent of successful runs')
            plt.savefig(cp_path, dpi=100)
            plt.savefig(os.path.join(figure_path, os.path.basename(path)[:-4] + '_changes.png'), dpi=100)
            zf.write(cp_path, os.path.basename(cp_path))

            plt.close('all')
        except IOError as e:
            print 'IOError'
            print e
        else:
            os.remove(bp_path)
            os.remove(cp_path)
        finally:
            os.rmdir(tmpdir)

def process_zip(path, best_fitness):
    with closing(zipfile.ZipFile(path)) as zfile:
        for info in zfile.infolist():
            if info.filename.endswith('.cdat'):
                analyse(path, info.filename, best_fitness)



if __name__ == '__main__':
    args = parse_command_line()
    process_zip(args.path[0], args.best_f[0])
    # main(args.f_id[0])

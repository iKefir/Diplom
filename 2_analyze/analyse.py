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
import csv
import math
from contextlib import closing
from io import TextIOWrapper


def parse_command_line():
    parser = argparse.ArgumentParser(description='Supa advanced plots maker.')
    parser.add_argument('path', nargs=1, help='Path of results zip.')
    parser.add_argument('best_f', nargs=1, help='Best fitness available.')
    parser.add_argument('analyse', nargs='?', default=False, help='Set True if need to reanalyse data.')
    return parser.parse_args()


def read_csv(path):
    inds = []
    results = []
    changes = []
    mutation_rate = []
    rea_mode_on = []
    with closing(zipfile.ZipFile(path, 'a')) as zf:
        with zf.open('best_fitness.csv') as csv_file:
            reader = csv.reader(TextIOWrapper(csv_file, 'utf-8'), delimiter=',')
            for i, row in enumerate(reader):
                if i == 0:
                    continue
                inds.append(int(row[0]))
                results.append(float(row[1]))
        with zf.open('changes.csv') as csv_file:
            reader = csv.reader(TextIOWrapper(csv_file, 'utf-8'), delimiter=',')
            for i, row in enumerate(reader):
                if i == 0:
                    continue
                changes.append(float(row[0]))
        with zf.open('mutation_rate.csv') as csv_file:
            reader = csv.reader(TextIOWrapper(csv_file, 'utf-8'), delimiter=',')
            for i, row in enumerate(reader):
                if i == 0:
                    continue
                mutation_rate.append(float(row[1]))
        with zf.open('rea_mode_on.csv') as csv_file:
            reader = csv.reader(TextIOWrapper(csv_file, 'utf-8'), delimiter=',')
            for i, row in enumerate(reader):
                if i == 0:
                    continue
                rea_mode_on.append(float(row[1]))

    return inds, results, changes, mutation_rate, rea_mode_on


def write_csv(path, inds, results, changes, mutation_rates, rea_mode_on):
    delete_files_from_zip(path, ['best_fitness.csv', 'changes.csv', 'mutation_rate.csv', 'rea_mode_on.csv'])

    with closing(zipfile.ZipFile(path, 'a')) as zf:
        tmpdir = tempfile.mkdtemp()

        bp_path = os.path.join(tmpdir, 'best_fitness.csv')
        cp_path = os.path.join(tmpdir, 'changes.csv')
        mp_path = os.path.join(tmpdir, 'mutation_rate.csv')
        rmp_path = os.path.join(tmpdir, 'rea_mode_on.csv')

        try:
            with open(bp_path, "w") as csv_file:
                writer = csv.writer(csv_file, delimiter=',')
                writer.writerow(['inds', 'results'])
                for row in zip(inds, results):
                    writer.writerow(row)
            zf.write(bp_path, os.path.basename(bp_path))

            with open(cp_path, "w") as csv_file:
                writer = csv.writer(csv_file, delimiter=',')
                writer.writerow(['changes'])
                for row in changes:
                    writer.writerow([row])
            zf.write(cp_path, os.path.basename(cp_path))

            with open(mp_path, "w") as csv_file:
                writer = csv.writer(csv_file, delimiter=',')
                writer.writerow(['inds', 'mutation_rate'])
                for row in zip(inds, mutation_rates):
                    writer.writerow(row)
            zf.write(mp_path, os.path.basename(mp_path))
            
            with open(rmp_path, "w") as csv_file:
                writer = csv.writer(csv_file, delimiter=',')
                writer.writerow(['inds', 'rea_mode_on'])
                for row in zip(inds, rea_mode_on):
                    writer.writerow(row)
            zf.write(rmp_path, os.path.basename(rmp_path))
        except IOError as e:
            print('IOError')
            print(e)
        else:
            os.remove(bp_path)
            os.remove(cp_path)
            os.remove(mp_path)
            os.remove(rmp_path)
        finally:
            os.rmdir(tmpdir)


def analyse_zip(path, filename, best_fitness):
    inds = []
    results = []
    changes = [0]
    mutation_rates = []
    rea_mode_on = []
    runs = 0
    ch_ind = 0
    can_add_run = True
    with closing(zipfile.ZipFile(path, 'a')) as zf:
        with TextIOWrapper(zf.open(filename), 'utf-8') as rr:
            for line in rr:
                to_check = '"function evaluation" "current f(x)" "best-so-far f(x)" "current af(x)+b"  "best af(x)+b" "best_value" "mutation_rate" "next_budget_to_change_fitness" "is_rea_working"\n'
                # to_check = '"function evaluation" "current f(x)" "best-so-far f(x)" "current af(x)+b"  "best af(x)+b" "best_value" "mutation_rate" "next_budget_to_change_fitness" \n'
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
                    m_rate = float(ll[6])
                    is_rea_on = float(ll[8]) 
                    # print eval_num
                    if (len(results) > eval_num):
                        results[eval_num] += best_f
                    else:
                        results.append(best_f)
                    if (len(rea_mode_on) > eval_num):
                        rea_mode_on[eval_num] += is_rea_on
                    else:
                        rea_mode_on.append(is_rea_on)


                    if best_f < 0.0:
                        ch_ind += 1
                        can_add_run = True
                        if len(changes) <= ch_ind:
                            changes.append(0)

                    if can_add_run and best_f == best_fitness:
                        changes[ch_ind] += 1
                        can_add_run = False

                    if (len(mutation_rates) > eval_num):
                        mutation_rates[eval_num] += m_rate
                    else:
                        mutation_rates.append(m_rate)

    new_results = []
    new_mutation_rates = []
    new_rea_mode_on = []
    for i, (r, m_r, rea) in enumerate(zip(results, mutation_rates, rea_mode_on)):
        if (r >= 0.0):
            inds.append(i)
            new_results.append(r / runs)
            new_mutation_rates.append(m_r / runs)
            new_rea_mode_on.append(rea / runs)

    changes = [change / 100.0 for change in changes]

    return inds, new_results, changes, new_mutation_rates, new_rea_mode_on


def delete_files_from_zip(path, files_to_del):
    try:
        cmd=['zip', '-d', path] + files_to_del
        with open(os.devnull, 'w')  as FNULL:
            subprocess.check_call(cmd, stdout=FNULL, stderr=FNULL)
    except:
        pass


def write_pngs(path, inds, results, changes, mutation_rates, rea_mode_on):
    bp_filename = 'best_fitness_plot.png'
    cp_filename = 'changes_plot.png'
    mp_filename = 'mutation_rate_plot.png'

    delete_files_from_zip(path, [bp_filename, cp_filename, mp_filename])

    with closing(zipfile.ZipFile(path, 'a')) as zf:
        tmpdir = tempfile.mkdtemp()

        bp_path = os.path.join(tmpdir, bp_filename)
        cp_path = os.path.join(tmpdir, cp_filename)
        mp_path = os.path.join(tmpdir, mp_filename)
        figure_path = os.path.join(os.path.dirname(path), 'graphs')
        if not os.path.exists(figure_path):
            os.mkdir(figure_path)
        if not os.path.exists(os.path.join(figure_path, 'best_fitness')):
            os.mkdir(os.path.join(figure_path, 'best_fitness'))
        if not os.path.exists(os.path.join(figure_path, 'changes')):
            os.mkdir(os.path.join(figure_path, 'changes'))
        if not os.path.exists(os.path.join(figure_path, 'mutation_rate')):
            os.mkdir(os.path.join(figure_path, 'mutation_rate'))
        try:
            plt.figure()
            plt.plot(inds, results)
            func_id = os.path.split(os.path.split(os.path.dirname(path))[0])[1]
            plt.xlabel('evaluations (func_id: ' + func_id + ' run_params: '+ os.path.basename(path)[8:-4] + ')')
            plt.ylabel('best f(x) since change')
            plt.savefig(bp_path, dpi=100)
            plt.savefig(os.path.join(figure_path, 'best_fitness', os.path.basename(path)[4:-4] + '.png'), dpi=100)
            zf.write(bp_path, os.path.basename(bp_path))

            plt.figure()
            plt.plot(changes)
            plt.xlabel('number of period between changes (func_id: ' + func_id + ' run_params: '+ os.path.basename(path)[8:-4] + ')')
            plt.ylabel('percent of successful runs')
            plt.savefig(cp_path, dpi=100)
            plt.savefig(os.path.join(figure_path, 'changes', os.path.basename(path)[4:-4]), dpi=100)
            zf.write(cp_path, os.path.basename(cp_path))

            plt.figure()
            plt.plot(inds, list(map(math.log2, mutation_rates)))
            plt.xlabel('evaluations (func_id: ' + func_id + ' run_params: '+ os.path.basename(path)[8:-4] + ')')
            plt.ylabel('mutation rate')
            plt.savefig(mp_path, dpi=100)
            plt.savefig(os.path.join(figure_path, 'mutation_rate', os.path.basename(path)[4:-4] + '.png'), dpi=100)
            zf.write(mp_path, os.path.basename(mp_path))

            plt.close('all')
        except IOError as e:
            print('IOError')
            print(e)
        else:
            os.remove(bp_path)
            os.remove(cp_path)
            os.remove(mp_path)
        finally:
            os.rmdir(tmpdir)


def process_zip(path, best_fitness, analyse=False):
    csvs = []
    cdats = []
    with closing(zipfile.ZipFile(path)) as zfile:
        csvs = [file.filename for file in zfile.infolist() if file.filename.endswith('.csv')]
        cdats = [file.filename for file in zfile.infolist() if file.filename.endswith('.cdat')]

    if (len(csvs) == 4) and (analyse == False):
        inds, results, changes, mutation_rates, rea_mode_on = read_csv(path)
        write_pngs(path, inds, results, changes, mutation_rates, rea_mode_on)
    else:
        inds, results, changes, mutation_rates, rea_mode_on = analyse_zip(path, cdats[0], best_fitness)
        write_csv(path, inds, results, changes, mutation_rates, rea_mode_on)
        write_pngs(path, inds, results, changes, mutation_rates, rea_mode_on)

    return inds, results, changes, mutation_rates, rea_mode_on


if __name__ == '__main__':
    args = parse_command_line()
    process_zip(args.path[0], args.best_f[0], args.analyse[0])

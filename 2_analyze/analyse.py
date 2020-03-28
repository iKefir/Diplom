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

    return inds, results, mutation_rate, rea_mode_on


def write_csv(path, inds, results, mutation_rates, rea_mode_on):
    delete_files_from_zip(path, ['best_fitness.csv', 'mutation_rate.csv', 'rea_mode_on.csv'])

    with closing(zipfile.ZipFile(path, 'a')) as zf:
        tmpdir = tempfile.mkdtemp()

        bp_path = os.path.join(tmpdir, 'best_fitness.csv')
        mp_path = os.path.join(tmpdir, 'mutation_rate.csv')
        rmp_path = os.path.join(tmpdir, 'rea_mode_on.csv')

        try:
            with open(bp_path, "w") as csv_file:
                writer = csv.writer(csv_file, delimiter=',')
                writer.writerow(['inds', 'results'])
                for row in zip(inds, results):
                    writer.writerow(row)
            zf.write(bp_path, os.path.basename(bp_path))

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
            os.remove(mp_path)
            os.remove(rmp_path)
        finally:
            os.rmdir(tmpdir)


def analyse_zip(path, filename, best_fitness):
    inds = []
    results = []
    mutation_rates = []
    rea_mode_on = []
    runs = 0
    with closing(zipfile.ZipFile(path, 'a')) as zf:
        with TextIOWrapper(zf.open(filename), 'utf-8') as rr:
            for line in rr:
                to_check = '"function evaluation"'
                if line.startswith(to_check):
                    runs += 1
                    sys.stdout.write('\r\truns:\t' + str(runs))
                    sys.stdout.flush()
                else:
                    ll = line.split(' ')
                    eval_num = int(ll[0]) - 1
                    if (len(ll) > 5):
                        best_f = float(ll[5])
                    else:
                        best_f = 0.0
                    if (len(ll) > 6):
                        m_rate = float(ll[6])
                    else:
                        m_rate = 0.0
                    if (len(ll) > 8):
                        is_rea_on = float(ll[8]) 
                    else:
                        is_rea_on = 0.0

                    if (len(results) > eval_num):
                        results[eval_num] += best_f
                    else:
                        results.append(best_f)

                    if (len(mutation_rates) > eval_num):
                        mutation_rates[eval_num] += m_rate
                    else:
                        mutation_rates.append(m_rate)

                    if (len(rea_mode_on) > eval_num):
                        rea_mode_on[eval_num] += is_rea_on
                    else:
                        rea_mode_on.append(is_rea_on)

    new_results = []
    new_mutation_rates = []
    new_rea_mode_on = []
    for i, (r, m_r, rea) in enumerate(zip(results, mutation_rates, rea_mode_on)):
        if (r >= 0.0):
            inds.append(i)
            new_results.append(r / runs)
            new_mutation_rates.append(m_r / runs)
            new_rea_mode_on.append(rea / runs)

    return inds, new_results, new_mutation_rates, new_rea_mode_on


def delete_files_from_zip(path, files_to_del):
    try:
        cmd=['zip', '-d', path] + files_to_del
        with open(os.devnull, 'w')  as FNULL:
            subprocess.check_call(cmd, stdout=FNULL, stderr=FNULL)
    except:
        pass


def process_zip(path, best_fitness, analyse=False):
    csvs = []
    cdats = []
    with closing(zipfile.ZipFile(path)) as zfile:
        csvs = [file.filename for file in zfile.infolist() if file.filename.endswith('.csv')]
        cdats = [file.filename for file in zfile.infolist() if file.filename.endswith('.cdat')]

    inds = []
    results = []
    mutation_rates = []
    rea_mode_on = []
    if (len(csvs) > 0) and (analyse == False):
        inds, results, mutation_rates, rea_mode_on = read_csv(path)
    else:
        inds, results, mutation_rates, rea_mode_on = analyse_zip(path, cdats[0], best_fitness)
        write_csv(path, inds, results, mutation_rates, rea_mode_on)

    return inds, results, mutation_rates, rea_mode_on


if __name__ == '__main__':
    args = parse_command_line()
    process_zip(args.path[0], args.best_f[0], args.analyse[0])

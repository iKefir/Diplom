#! /usr/bin/env python
# -*- coding: utf-8 -*-

import subprocess
import os.path
import argparse

import phase_transition_check

def parse_command_line():
    parser = argparse.ArgumentParser(description='Document analyzer.')
    parser.add_argument('f_id', nargs=1, help='Id of function to launch.')
    parser.add_argument('restarts', nargs=1, help='Amount of experiment launches.')
    parser.add_argument('bud_multiplier', nargs=1, help='How much evaluations per dimension is available.')
    parser.add_argument('dimension', nargs=1, help='Dimensionality of search space.')
    parser.add_argument('path', nargs=1, help='Path of document to analyze.')
    parser.add_argument('fitness', nargs=1, help='Kind of dynamicity of fitness function.')
    parser.add_argument('ua', nargs=1, help='Kind of user algorithm.')
    return parser.parse_args()

def lower_bound(f_id, restarts, bud_multiplier, dimension, path, fitness, ua, already_seen):
    ll = 0
    hh = 10000
    not_reached_size = 0
    reached_size = 0
    try:
        with open(path+'/not_reached.txt', 'r+') as rr:
            not_reached_size = len(list(rr))
    except:
        pass
    try:
        with open(path+'/reached.txt', 'r+') as rr:
            reached_size = len(list(rr))
    except:
        pass
    while ll + 1 < hh:
        mid = (ll + hh) / 2
        print 'LB', ll, mid, hh
        if mid in already_seen:
            if already_seen[mid] == 0:
                ll = mid
            else:
                hh = mid
            continue
        subprocess.check_call(['sh', 'execute_one_experiment.sh', fitness, str(mid), ua, dimension, restarts, path, f_id, bud_multiplier])
        try:
            with open(path+'/not_reached.txt') as rr:
                new_not_reached_size = len(list(rr))
                if (new_not_reached_size > not_reached_size):
                    already_seen[mid] = 0
                    not_reached_size = new_not_reached_size
                    ll = mid
                else:
                    already_seen[mid] = -1
                    hh = mid
        except:
            already_seen[mid] = -1
            hh = mid
        try:
            with open(path+'/reached.txt') as rr:
                new_reached_size = len(list(rr))
                if (new_reached_size > reached_size):
                    already_seen[mid] = 1
                    reached_size = new_reached_size
        except:
            pass
    print 'Found lower bound:\t' + str(hh)
    return hh

def upper_bound(f_id, restarts, bud_multiplier, dimension, path, fitness, ua, already_seen):
    ll = 0
    hh = 10000
    not_reached_size = 0
    reached_size = 0
    try:
        with open(path+'/not_reached.txt', 'r+') as rr:
            not_reached_size = len(list(rr))
    except:
        pass
    try:
        with open(path+'/reached.txt', 'r+') as rr:
            reached_size = len(list(rr))
    except:
        pass
    while ll + 1 < hh:
        mid = (ll + hh) / 2
        print 'UB', ll, mid, hh
        if mid in already_seen:
            if already_seen[mid] == 1:
                hh = mid
            else:
                ll = mid
            continue
        subprocess.check_call(['sh', 'execute_one_experiment.sh', fitness, str(mid), ua, dimension, restarts, path, f_id, bud_multiplier])
        try:
            with open(path+'/reached.txt') as rr:
                new_reached_size = len(list(rr))
                if (new_reached_size > reached_size):
                    already_seen[mid] = 1
                    reached_size = new_reached_size
                    hh = mid
                else:
                    already_seen[mid] = -1
                    ll = mid
        except:
            already_seen[mid] = -1
            ll = mid
        try:
            with open(path+'/not_reached.txt') as rr:
                new_not_reached_size = len(list(rr))
                if (new_not_reached_size > not_reached_size):
                    already_seen[mid] = 0
                    not_reached_size = new_not_reached_size
        except:
            pass
    print 'Found upper bound:\t' + str(hh)
    return hh

def eval_range(f_id, restarts, bud_multiplier, dimension, path, fitness, ua, lb, ub):
    for i in range(lb, ub):
        zip_path = path+'/all_zips/001-fit_' + fitness + '_' + str(i) + '_' + ua + '.zip'
        print 'CHECKING', zip_path
        if os.path.exists(zip_path):
            phase_transition_check.run_zip(path, zip_path, 100)
            # phase_transition_check.main(path, 'fit_bi_'+str(i)+'_ab/fit_bi_'+str(i)+'_ab', 100)
        else:
            print 'NOT EXISTS', zip_path
            subprocess.check_call(['sh', 'execute_one_experiment.sh', fitness, str(i), ua, dimension, restarts, path, f_id, bud_multiplier])

def main(f_id, restarts, bud_multiplier, dimension, path, fitness, ua):
    already_seen = {}
    f_id = str(f_id)
    restarts = str(restarts)
    bud_multiplier = str(bud_multiplier)
    dimension = str(dimension)
    if f_id == '1':
        path = path + '/OneMax'
    elif f_id == '2':
        path = path + '/LeadingOnes'
    else:
        path = path + '/' + f_id
    path = path + '/' + dimension
    lb = lower_bound(f_id, restarts, bud_multiplier, dimension, path, fitness, ua, already_seen)
    ub = upper_bound(f_id, restarts, bud_multiplier, dimension, path, fitness, ua, already_seen)
    eval_range(f_id, restarts, bud_multiplier, dimension, path, fitness, ua, lb, ub)
    print 'Found lower bound:\t' + str(lb) + '\tupper bound:\t' + str(ub)


if __name__ == '__main__':
    args = parse_command_line()
    main(args.f_id[0], args.restarts[0], args.bud_multiplier[0], args.dimension[0], args.path[0], args.fitness[0], args.ua[0])

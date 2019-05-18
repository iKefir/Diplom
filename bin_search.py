#! /usr/bin/env python
# -*- coding: utf-8 -*-

import subprocess
import os.path
import phase_transition_check

resultpath='../IOHProfiler/IOHExperimenter/code-experiments/build/c'
newpath='../IOHProfiler/Results/IOHExperimenter'
ua='ab'
fitness='bi'

already_seen = {}

def lower_bound(path):
    ll = 1
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
        subprocess.check_call(['./execute_one_experiment.sh ' + fitness + ' ' + str(mid) + ' ' + ua], shell=True)
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

def upper_bound(path):
    ll = 1
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
        subprocess.check_call(['./execute_one_experiment.sh ' + fitness + ' ' + str(mid) + ' ' + ua], shell=True)
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

def eval_range(lb, ub):
    for i in range(lb, ub):
        zip_path = newpath+'/all_zips/001-fit_bi_'+str(i)+'_ab.zip'
        if os.path.exists(zip_path):
            phase_transition_check.run_zip(newpath, zip_path, 100)
            # phase_transition_check.main(newpath, 'fit_bi_'+str(i)+'_ab/fit_bi_'+str(i)+'_ab', 100)
        else:
            print 'NOT EXISTS', newpath+'/all_zips/fit_bi_'+str(i)+'_ab.zip'
            subprocess.check_call(['./execute_one_experiment.sh ' + fitness + ' ' + str(i) + ' ' + ua], shell=True)

if __name__ == '__main__':
    lb = lower_bound(newpath)
    ub = upper_bound(newpath)
    eval_range(lb, ub)
    print 'Found lower bound:\t' + str(lb) + '\tupper bound:\t' + str(ub)

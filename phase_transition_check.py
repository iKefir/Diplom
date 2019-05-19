#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
import glob
import argparse
import zipfile
from contextlib import closing

def parse_command_line():
    parser = argparse.ArgumentParser(description='Document analyzer.')
    parser.add_argument('path', nargs=1, help='Path of document to analyze.')
    parser.add_argument('filename', nargs=1, help='File to analyze.')
    parser.add_argument('dimension', nargs=1, help='Dimensionality of problem.')
    return parser.parse_args()

# a bit messy here: had to make it work with zip as well as directory:
# if working with zip: path - path to log files, file - path to zip, filename - name of file in zip to work with
# if working with directory: path - path to log files (and also parent directory), file - relative path to directory, filename - full path to file
def process_filename(path, file, filename, max_value):
    l_list = 0
    reached = []
    not_reached = []
    with zipfile.ZipFile(file).open(filename) if file.endswith('zip') else open(filename,  'r') as rr:
        for i, line in enumerate(rr):
            if i == 2:
                reached = []
                not_reached = []
                list = line.split(',')
                l_list = len(list) - 1
                for j, res in enumerate(list[1:]):
                    res = res.strip()
                    run, value = res.split('|', 1)
                    _, run = run.split(':', 1)
                    # print 'val', value, 'max_val', max_value
                    if float(value) == max_value:
                        reached.append(j)
                    else:
                        not_reached.append(j)
                to_write = re.search(r'fit_\w{2,4}_\d+_\w{2,4}', filename).group(0)
                # print to_write.group(0), filename
                # exit(1)
                if len(not_reached) == 0:
                    with open(path+'/reached.txt', 'a+') as app:
                        app.write(to_write + '\n')
                elif len(reached) == 0:
                    with open(path+'/not_reached.txt', 'a+') as app:
                        app.write(to_write + '\n')
                else:
                    with open(path+'/mixed_reached.txt', 'a+') as app:
                        app.write(to_write + '\t' + str(100.0*float(len(reached))/float(l_list)) + '%\n')

def run_zip(path, filename, max_value):
    print "RUNZIP"
    max_value = max_value

    with closing(zipfile.ZipFile(filename)) as zfile:
        for info in zfile.infolist():
            if info.filename.endswith('.info'):
                process_filename(path, filename, info.filename, max_value)


def main(path, filename, max_value):
    max_value = max_value

    for fn in glob.glob(path+'/'+filename+'/*info'):
        process_filename(path, filename, fn, max_value)

if __name__ == '__main__':
    args = parse_command_line()
    main(args.path[0], args.filename[0], float(args.dimension[0]))

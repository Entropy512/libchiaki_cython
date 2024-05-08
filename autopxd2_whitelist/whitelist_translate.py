#!/usr/bin/env python3

import autopxd
import argparse
import os

ap = argparse.ArgumentParser()
ap.add_argument('-i', '--input', type=argparse.FileType('r'), required=True,
    help='path to input file')

args = vars(ap.parse_args())

infile = args['input']
filebase = os.path.splitext(os.path.basename(infile.name))[0]
with open('chiaki_' + filebase + '.pxd', 'w') as outfile:
    outfile.write(autopxd.translate(infile.read(), infile.name, ['-I.', infile.name], whitelist=[infile.name]))
#!/usr/bin/python3

from __future__ import annotations
from os import mkdir
from os.path import dirname, abspath, exists
from .util import request, parseExisitingData
from json import dump
from sys import argv

def _writeToJSON(data: Dict[str, Any], sink: str):
    with open(sink, 'w') as fd:
        dump(data, fd, indent=4)

def _makeSinkDir(sink: str):
    if not exists(sink):
        mkdir(sink)

def _handleCMDInputs():
    return argv[1] if len(argv) == 2 and argv[1].endswith('.json') else None

def main():
    sink = _handleCMDInputs()
    if not sink:
        print('Bad Input')
        return
    sink = abspath(sink)
    _makeSinkDir(dirname(sink))
    print('Working ...')
    data = request(parseExisitingData(sink))
    if data:
        _writeToJSON(data.toJSON(), sink)
        print('Success')
    else:
        print('Failed')
    return

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('\n[!]Terminated')
    finally:
        exit(0)

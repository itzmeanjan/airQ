#!/usr/bin/python3

from __future__ import annotations
from os import mkdir
from os.path import dirname, abspath, exists
from .util import request, parseExisitingData
from json import dump
from sys import argv
from subprocess import run

def _writeToJSON(data: Dict[str, Any], sink: str):
    with open(sink, 'w') as fd:
        dump(data, fd, indent=4)

def _makeSinkDir(sink: str):
    if not exists(sink):
        mkdir(sink)

def _handleCMDInputs():
    return argv[1] if len(argv) == 2 and argv[1].endswith('.json') else None

def collect(sinkFile: str, maxLimit: int):
    sinkFile = abspath(sinkFile)
    _makeSinkDir(dirname(sinkFile))
    data = request(parseExisitingData(sinkFile))
    if data:
        _writeToJSON(data.toJSON(maxLimit), sinkFile)
        return True
    else:
        return False

def _usage():
    print('\t$ airQ `sink-file-path_( *.json )_`\n\n \x1b[3;31;50mFor making modifications on airQ-collected data ( collected prior to this run ),\n pass that JSON path, while invoking airQ ;)\x1b[0m\n')

def _displayBanner():
    run('clear')
    print('\x1b[1;6;35;50mairQ - Air Quality Data Collector\x1b[0m\n')

def main(maxLimit: int = 24*3600):
    try:
        _displayBanner()
        sink = _handleCMDInputs()
        if not sink:
            _usage()
            print('Bad Input')
        else:
            print('Working ...')
            print('\x1b[1;37;42mSuccess\x1b[0m' if collect(sink, maxLimit) else '\x1b[1;37;41mFailed\x1b[0m')
    except KeyboardInterrupt:
        print('\n\x1b[1;37;41mTerminated\x1b[0m')
    finally:
        return

if __name__ == '__main__':
    main()

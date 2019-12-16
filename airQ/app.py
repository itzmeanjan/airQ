#!/usr/bin/python3

from __future__ import annotations
from os import mkdir
from os.path import dirname, abspath, exists
from .util import request, parse
from json import dump
from sys import argv
from subprocess import run
from typing import Dict, Any, Tuple


def _writeToJSON(data: Dict[str, Any], sink: str):
    with open(sink, 'w') as fd:
        dump(data, fd, indent=4)


def _makeSinkDir(sink: str):
    if not exists(sink):
        mkdir(sink)


def _handleCMDInputs() -> Tuple[str, int]:
    _inputs = ()
    try:
        _inputs = (argv[1], int(argv[2])) if len(
            argv) == 3 and argv[1].endswith('.json') else (None, None)
    except ValueError:
        _inputs = (None, None)
    finally:
        return _inputs


def _usage():
    print('\t$ airQ `sink-file-path_( *.json )_` `past-data-keeper-time-span_( in seconds )_` \
        \n\n \x1b[3;31;50mFor making modifications on airQ-collected data\n (collected prior to this run ), pass that JSON path,\n while invoking airQ ;)\x1b[0m\n')


def _displayBanner():
    run('clear')
    print('\x1b[1;6;35;50mairQ - Air Quality Data Collector\x1b[0m\n')


def collect(sinkFile: str, maxSpan: int) -> bool:
    '''
    Invoke this method from other script or applications,
    if you want to utilize airQ's data collection capability
    programmatically.

    Get it name of sink file, where to push data into, after collection.

    Well it may be the situation, that you're already having some data,
    collected by airQ, and you want to keep that data and collect new data on
    top of it. But you would also like to invalidate some data if that's older than
    a certain timerange, then you need to use this `collect()` method.

    Second arg of this method ( which is in second ), invalidates all data which are older than,

    (max-timestamp - maxLimit)

    i.e. having timestamp, which are lesser than previously computed value.
    '''
    sinkFile = abspath(sinkFile)
    _makeSinkDir(dirname(sinkFile))
    data = request(parse(sinkFile))
    if data:
        _writeToJSON(data.toJSON(maxSpan), sinkFile)
        return True
    else:
        return False


'''
    You're not supposed to be invoking this method externally.

    This is solely for script based invocation.
'''


def main():
    try:
        _displayBanner()
        sink, maxSpan = _handleCMDInputs()
        if not sink or maxSpan == None:
            _usage()
            print('Bad Input')
        else:
            print('Working ...')
            print('\x1b[1;37;42mSuccess\x1b[0m' if collect(
                sink, None if maxSpan < 0 else maxSpan) else '\x1b[1;37;41mFailed\x1b[0m')
    except KeyboardInterrupt:
        print('\n\x1b[1;37;41mTerminated\x1b[0m')
    finally:
        return


if __name__ == '__main__':
    main()

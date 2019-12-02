#!/usr/bin/python3

from __future__ import annotations

'''
    Holds record of a Pollutant, which are identified
    using one id.

    There're two very important fields `timeStamp` & `station`
'''
class Pollutant:
    def __init__(self, id: str, min: int, max: int, avg: int, unit: str, timestamp: int, station: str):
        self._id = id
        self._min = min
        self._max = max
        self._avg = avg
        self._unit = unit
        self._timestamp = timestamp
        self.forStation = station

if __name__ == '__main__':
    print('[!]This module is designed to be work as a backend handler')
    exit(0)
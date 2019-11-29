#!/usr/bin/python3

from __future__ import annotations

class Pollutant:
    def __init__(self, _id: str, _min: int, _max: int, _avg: int, _unit: str, _updatedAt: str, station: str):
        self._id = _id
        self._min = _min
        self._max = _max
        self._avg = _avg
        self._unit = _unit
        self._updatedAt = _updatedAt
        self.forStation = station

if __name__ == '__main__':
    print('[!]This module is designed to be work as a backend handler')
    exit(0)

#!/usr/bin/python3

from __future__ import annotations
from typing import Dict, Any
from datetime import datetime

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

    def toJSON(self) -> Dict[str, Any]:
        return {'id': self._id, 'min': self._min, 'max': self._max, 'avg': self._avg, 'unit': self._unit}

    @staticmethod
    def fromJSON(data: Dict[str, Any], timeStamp: int, station: str) -> Pollutant:
        return Pollutant(data['id'], int(data['min']) if data['min'].isnumeric() else 0,
                         int(data['max']) if data['max'].isnumeric() else 0,
                         int(data['avg']) if data['avg'].isnumeric() else 0, data['unit'], timeStamp, station)

    @property
    def timeStamp(self) -> datetime:
        return datetime.fromtimestamp(self._timestamp)


if __name__ == '__main__':
    print('[!]This module is designed to be work as a backend handler')
    exit(0)

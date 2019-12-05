#!/usr/bin/python3

from __future__ import annotations
from typing import Dict, List, Any
from .pollutant import Pollutant

class Station:
    def __init__(self, name: str, city: str, state: str, country: str, records: Dict[int, List[Pollutant]]):
        self.name = name
        self.city = city
        self.state = state
        self.country = country
        self.records = records

    def _checkRedundancy(self, pollutantId: str, container: List[Pollutant]) -> bool:
        return False if len([i for i in container if i._id == pollutantId]) == 0 \
            else True

    def push(self, record: Pollutant) -> Station:
        _holder = self.records.get(record._timestamp)
        if not _holder:
            _holder = [record]
            self.records[record._timestamp] = _holder
        else:
            if not self._checkRedundancy(record._id, _holder):
                _holder.append(record)
        return self

    def toJSON(self) -> Dict[str, Any]:
        return {'name': self.name, 'city': self.city, 'state': self.state, 'country': self.country, 'records': dict([(k, [i.toJSON() for i in v]) for k, v in self.records.items()])}

    @staticmethod
    def fromJSON(data: Dict[str, Any]) -> Station:
        return Station(data['name'], data['city'], data['state'], data['country'], dict([(int(k), [Pollutant.fromJSON(i, int(k), data['name']) for i in v]) for k, v in data['records'].items()]))

    def removeOutOfRangeValues(self, _range: int):
        for i in [i for i in self.records.keys() if i < _range]:
            self.records.pop(i)
        return self


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

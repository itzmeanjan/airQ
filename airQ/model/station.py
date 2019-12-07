#!/usr/bin/python3

from __future__ import annotations
from typing import Dict, List, Any, Tuple, Set
from .pollutant import Pollutant
from datetime import datetime, timedelta
from operator import sub

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

    '''
        Returns a tuple of datetime objects,
        where first one denotes oldest timestamp, at which we collected data,
        and second one denotes newest timestamp. We've pollutant data at this timestamp too.

        Difference of these two gives timespan, which is returned by method below ( self.getTimeSpan )
    '''
    @property
    def getTimeRange(self) -> Tuple[datetime, datetime]:
        _timestamps = list(self.records.keys())
        return datetime.fromtimestamp(min(_timestamps)), datetime.fromtimestamp(max(_timestamps))

    '''
        Returns calculated timedelta i.e. difference between
        highest timestamp and lowest timestamp
    '''
    @property
    def getTimeSpan(self) -> timedelta:
        def _swap(a, b):
            return b, a
        return sub(*_swap(*self.getTimeRange))

    '''
        How many # of records are present for this Station ?

        By record, I mean, how many number of times we collected data
        for this station ( possibly with 1 hour gap ), and that's present in this instance
    '''
    @property
    def recordCount(self) -> int:
        return len(self.records)

    '''
        Returns a set of all pollutant ids, for which we can lookup record

        Set returned, so that removal of duplicacy becomes easier.
    '''
    @property
    def getAvailablePollutants(self) -> Set[str]:
        return set([i._id for _, v in self.records.items() for i in v])

    '''
        Returns a list of Pollutant objects of a certain id.

        This method will be helpful, when plotting pollutant stat,
        for a certain pollutant type.
    '''
    def getPollutantStatByID(self, id: str) -> List[Pollutant]:
        return [i for _, v in self.records.items() for i in v if id == i._id]


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

#!/usr/bin/python3

from __future__ import annotations
from typing import List, Dict, Any
from .station import Station
from .pollutant import Pollutant

class Data:
    def __init__(self, stations: List[Station]):
        self._stations = stations

    def __push__(self, name: str, low: int, high: int) -> int:
        if low > high:
            return 0
        elif low == high:
            return low if self._stations[low].name > name else (low + 1)
        else:
            mid = low + (high - low) // 2
            return self.__push__(name, low, mid) \
                if self._stations[mid].name > name \
                else self.__push__(name, mid + 1, high)

    '''
        Insert a new Station object into Data object,
        while keeping sorted order intact.

        Well sorting is done
        using air quality monitoring station's names ( ascendingly )
    '''
    def push(self, record: Station) -> Data:
        self._stations.insert(self.__push__(record.name, 0, len(self._stations) - 1), record)
        return self

    def __get__(self, name: str, low: int, high: int) -> int:
        if low > high:
            return -1
        elif low == high:
            return low if self._stations[low].name == name else -1
        else:
            mid = low + (high - low) // 2
            return self.__get__(name, low, mid) \
                if self._stations[mid].name >= name \
                else self.__get__(name, mid + 1, high)

    '''
        Given a air quality monitoring station's name,
        it finds out Station instance with that name,
        using binary search ( well of course from a sorted array )
    '''
    def get(self, name: str) -> Station:
        _tmp = self.__get__(name, 0, len(self._stations) - 1)
        return None if _tmp == -1 else self._stations[_tmp]

    def updateStationRecord(self, record: Pollutant):
        self.get(record.forStation).push(record)
        return self

    '''
        Converts to JSON, to be invoked
        when we need to export collected data into JSON,
        for future reference
    '''
    def toJSON(self, _range: int) -> Dict[str, Any]:
        return {'stations' : [i.toJSON() for i in self._removeOutOfRangeValues(_range)._stations]}

    '''
        Parse JSON data, and return Data object, holding that
        dataset ( which was previously exported into JSON )
    '''
    @staticmethod
    def fromJSON(data: Dict[str, Any]) -> Data:
        return Data([Station.fromJSON(i) for i in data['stations']])

    '''
        Returns max time stamp ( i.e. most recent time stamp
        for which we've data ), which will be helpful in eliminating
        those records which are having time stamp lesser than limit
        set ( i.e. older than a certain time )
    '''
    @property
    def _getMaxTimeStamp(self) -> int:
        return max([i for i in self._stations[0].records.keys()])

    '''
        Remove those pollutant records which are having
        their corresponding timestamp lesser than time range set currently.
    '''
    def _removeOutOfRangeValues(self, _range: int):
        _tmp = self._getMaxTimeStamp - _range
        for i in self._stations:
            i.removeOutOfRangeValues(_tmp)
        return self

    '''
        Returns # of air quality monitoring station count,
        which is present in current dataset
    '''
    @property
    def getStationCount(self):
        return len(self._stations)

    '''
        Returns a dictionary, where keys are state names ( spread across India ),
        and corresponding values denote air quality monitoring station names,
        which are belonging to that city
    '''
    @property
    def getStationsGroupedByState(self) -> Dict[str, List[str]]:
        _grouped = {}
        for i in self._stations:
            _holder = _grouped.get(i.state)
            if _holder:
                _holder.append(i.name)
            else:
                _grouped[i.state] = [i.name]
        return _grouped

    '''
        Returns a dictionary, where keys are city names ( spread across India ),
        and corresponding values denote air quality monitoring station names,
        which are belonging to that city
    '''
    @property
    def getStationsGroupedByCity(self) -> Dict[str, List[str]]:
        _grouped = {}
        for i in self._stations:
            _holder = _grouped.get(i.city)
            if _holder:
                _holder.append(i.name)
            else:
                _grouped[i.city] = [i.name]
        return _grouped

    '''
        Returns a dictionary holding states as its key values,
        and a list of city names which are part of that State,
        from which we've air quality monitoring data
    '''
    @property
    def getCitiesUnderStates(self) -> Dict[str, List[str]]:
        return dict([(k, set([self.get(i).city for i in v])) for k, v in self.getStationsGroupedByState.items()])

    '''
        Returns a list of air quality monitoring station names
    '''
    @property
    def getStationNames(self) -> List[str]:
        return [i.name for i in self._stations]


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

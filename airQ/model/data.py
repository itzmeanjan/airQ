#!/usr/bin/python3

from __future__ import annotations
from typing import List
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

    def get(self, name: str) -> Station:
        _tmp = self.__get__(name, 0, len(self._stations) - 1)
        return None if _tmp == -1 else self._stations[_tmp]

    def updateStationRecord(self, record: Pollutant):
        self.get(record.forStation).push(record)
        return self


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)
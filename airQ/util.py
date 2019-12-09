#!/usr/bin/python3

from __future__ import annotations
from requests import get
from json import load
from typing import Dict, Any
from .model.url import RequestURL
from .model.data import Data
from .model.pollutant import Pollutant
from .model.station import Station


def _isStationAlreadyExisiting(name: str, data: Data) -> bool:
    return data.get(name) != None


'''
    Returns an instance of Station object, holding identifying
    information related to that Station.

    Pollutant objects ( i.e. air quality data collected ), 
    collected by this Station are to be stored under this Station object.
'''


def _makeStationObj(data: Dict[str, str]) -> Station:
    return Station(data['station'], data['city'], data['state'], data['country'], {})


'''
    Returns an instance of Pollutant object,
    holding data passed while invoking method.

    This instance is to be stored in resulting 
    Data object, under some Station object.
'''


def _makePollutantObj(data: Dict[str, str], timeStamp: int) -> Pollutant:
    return Pollutant(data['pollutant_id'], data['pollutant_min'], data['pollutant_max'], data['pollutant_avg'], data['pollutant_unit'], timeStamp, data['station'])


'''
    Parses fetched data and collects that into Data object,
    which is passed while invoking this method.
'''


def _parse(content: Dict[str, Any], data: Data):
    _timeStamp = content['updated']
    for v in content['records']:
        pollutantObj = _makePollutantObj(v, _timeStamp)
        if _isStationAlreadyExisiting(v['station'], data):
            data.updateStationRecord(pollutantObj)
        else:
            data.push(_makeStationObj(v)).updateStationRecord(pollutantObj)


'''
    Fetches data from specified URL.
'''


def _fetch(url: str) -> Dict[str, Any]:
    resp = get(url)
    content = resp.json() if resp.ok else None
    resp.close()
    return content


'''
    Collects air quality monitoring data from remote,
    and parsed data is put into instance of Data, which is
    passed while invoking method.

    Same instance gets modified and returned, after collection
    is completed.
'''


def request(_data: Data) -> Data:
    try:
        _req = RequestURL()
        for i in _req:
            _tmp = _fetch(i)
            if _tmp:
                _parse(_tmp, _data)
        return _data
    except Exception:
        return _data


'''
    If you've some data already collected by airQ,
    then passing that file path to this method,
    allows you to build an object to Data class,
    which is holding parsed data.

    Now you can simply modify this object
    i.e. send this Data object to `request()` method,
    written just above.

    Which will collect new data available, and when exported to JSON,
    will remove all data older than requested timestamp.
'''


def parse(source: str) -> Data:
    try:
        with open(source, 'r') as fd:
            return Data.fromJSON(load(fd))
    except Exception:
        return Data([])


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

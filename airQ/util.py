#!/usr/bin/python3

from __future__ import annotations
from requests import get
from json import load
from typing import Dict, Any
from .model.url import RequestURL
from .model.data import Data
from .model.pollutant import Pollutant
from .model.station import Station

def _isStationAlreadyExisiting(name: str, data: Data) -> boolean:
    return data.get(name) != None

def _makeStationObj(data: Dict[str, str]) -> Station:
    return Station(data['station'], data['city'], data['state'], data['country'], {})

def _makePollutantObj(data: Dict[str, str], timeStamp: int) -> Pollutant:
    return Pollutant(data['pollutant_id'], data['pollutant_min'], data['pollutant_max'], data['pollutant_avg'], data['pollutant_unit'], timeStamp, data['station'])

def _parse(content: Dict[str, Any], data: Data):
    _timeStamp = content['updated']
    for v in content['records']:
        pollutantObj = _makePollutantObj(v, _timeStamp)
        if _isStationAlreadyExisiting(v['station'], data):
            data.updateStationRecord(pollutantObj)
        else:
            data.push(_makeStationObj(v)).updateStationRecord(pollutantObj)

def _fetch(url: str) -> Dict[str, Any]:
    resp = get(url)
    content = resp.json() if resp.ok else None
    resp.close()
    return content

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

def parseExisitingData(source: str) -> Data:
    try:
        with open(source, 'r') as fd:
            return Data.fromJSON(load(fd))
    except Exception:
        return Data([])

if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

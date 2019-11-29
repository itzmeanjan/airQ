#!/usr/bin/python3

from __future__ import annotations
from json import load
from os.path import dirname, abspath, join

class RequestURL:
    def __init__(self, config: str = abspath(join(dirname(__file__), '../config.json'))):
        self._config = config
        with open(self._config) as fd:
            _data = load(fd)
            self._base = _data['url']
            self._api_key = _data['api-key']
            self._format = _data['format']
            self._offset = str(_data['offset'])
            self._limit = str(_data['limit'])

    @property
    def getURL(self) -> str:
        return self._base + '?' + 'api-key=' + self._api_key + '&format=' + self._format + '&offset=' + self._offset + '&limit=' + self._limit

    def updateOffset(self, offset: int) -> RequestURL:
        self._offset = str(offset)
        return self


if __name__ == "__main__":
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

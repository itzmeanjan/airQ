#!/usr/bin/python3

from __future__ import annotations
from json import load
from os.path import dirname, abspath, join
from requests import get

'''
    Create an instance of this class,
    and iterate over that, which will generate,
    some urls, where you can request for air quality monitoring data.

    Actually we've a large collection of data, from 180+ stations,
    so pushing all those data at a time, not a good decision.

    So API maintainers chose a good approach. They segmented dataset,
    into multiple small data chunks, which is why multiple GET requests required,
    ( which segment to be sent, decided based on url params ).

    Now assembling of data is done in Data object.
'''


class RequestURL:
    def __init__(self, config: str = abspath(join(dirname(__file__), '../config.json')), total: int = 10):
        self._config = config
        self._total = total
        with open(self._config) as fd:
            _data = load(fd)
            self._base = _data['url']
            self._api_key = _data['api-key']
            self._format = _data['format']
            self._offset = str(_data['offset'])
            self._limit = str(_data['limit'])
        self._setTotal()

    @property
    def _getTotal(self) -> int:
        return get(self._url).json().get('total')

    def _setTotal(self):
        self._total = self._getTotal

    @property
    def _url(self) -> str:
        return self._base + '?' + 'api-key=' + self._api_key + '&format=' + self._format + '&offset=' + self._offset + '&limit=' + self._limit

    def _updateOffset(self, offset: int) -> RequestURL:
        self._offset = str(offset)
        return self

    def __iter__(self):
        while int(self._offset) < self._total:
            yield self._url
            _tmp = int(self._offset) + 10
            self._updateOffset(0 if _tmp >= self._total else _tmp)
            if int(self._offset) == 0:
                break


if __name__ == "__main__":
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

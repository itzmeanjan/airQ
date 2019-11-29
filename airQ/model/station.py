#!/usr/bin/python3

from __future__ import annotations
from .pollutant import Pollutant
from typing import List

class Station:
    def __init__(self, name: str, city: str, state: str, country: str, records: List[Pollutant]):
        self.name = name
        self.city = city
        self.state = state
        self.country = country
        self.records = records


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

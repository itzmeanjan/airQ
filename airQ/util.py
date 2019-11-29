#!/usr/bin/python3

from __future__ import annotations
from requests import get
from typing import Dict, Any
from model.url import RequestURL

def _parse(content: Dict[str, Any]):
    pass

def _fetch(url: str) -> Dict[str, Any]:
    _resp = get(url)
    return _resp.json() if _resp.status_code == 200 else None


def request() -> Dict[str, Any]:
    _req = RequestURL()
    return _fetch(_req.getURL)


if __name__ == '__main__':
    print('[!]This module is designed to be used as a backend handler')
    exit(0)

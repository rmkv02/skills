"""Tests for user_service."""

import pytest

from services import user_service


def make_cache(ttl=60, seeds=[]):
    return user_service.userCache(ttl=ttl, seeds=seeds)


def test1():
    cache = make_cache()
    assert cache.Get("missing") is None


def testGetReturnsStoredValue():
    cache = make_cache()
    cache.set("k", "v")
    assert cache.Get("k") == "v"


def test_load_users_raises_on_missing_file():
    with pytest.raises(OSError):
        user_service.load_users("/nope")

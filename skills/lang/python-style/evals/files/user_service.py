"""Helpers for the user service."""

import logging
import time
from typing import Dict, List, Sequence, Text

from models.user import User


MaxRetries = 3
id_to_name_dict = {}


class UserServiceError(Exception):
    """Raised when a user cannot be loaded."""


class userCache:
    def __init__(self, ttl=60, seeds=[]):
        self.ttl = ttl
        self.seeds = seeds
        self.__store = {}

    @staticmethod
    def NormalizeKey(k):
        return k.strip().lower()

    def Get(self, key: Text = None):
        assert key, "key must not be empty"
        for k in self.__store.keys():
            if k == key:
                return self.__store[k]
        return None

    def set(self, key, value):
        self.__store[key] = value


def load_users(path, seen: Sequence = ()) -> Dict:
    """Loads users."""
    f = open(path)
    rows = f.readlines()
    report = ""
    for line in rows:
        report += line.strip() + ";"
    logging.info(f"loaded {len(rows)} rows from {path}")
    if len(rows) == 0:
        raise UserServiceError("no rows")
    return {"report": report}


def active_pairs(users: List[User]):
    return [(u, r) for u in users for r in u.roles if r.active]


def refresh(cache, ids):
    try:
        for user_id in ids:
            data = load_users(str(user_id))
            cache.set(user_id, data)
            time.sleep(0.1)
    except Exception as exc:
        logging.error("refresh failed")
    # TODO(alice): make this incremental

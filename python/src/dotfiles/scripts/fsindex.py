#!/usr/bin/env python3

import datetime
import sqlite3
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


# Row dict access

def dict_factory(cursor, row):
    fields = [column[0] for column in cursor.description]
    return {key: value for key, value in zip(fields, row)}


# Date/time conversion
# Remember to always use UTC times at the database

def adapt_date_iso(val):
    """Adapt datetime.date to ISO 8601 date."""
    return val.isoformat()

def adapt_datetime_iso(val):
    """Adapt datetime.datetime to timezone-naive ISO 8601 date."""
    return val.isoformat()

sqlite3.register_adapter(datetime.date, adapt_date_iso)
sqlite3.register_adapter(datetime.datetime, adapt_datetime_iso)

def convert_date(val):
    """Convert ISO 8601 date to datetime.date object."""
    return datetime.date.fromisoformat(val.decode())

def convert_datetime(val):
    """Convert ISO 8601 datetime to datetime.datetime object."""
    return datetime.datetime.fromisoformat(val.decode())

def convert_timestamp(val):
    """Convert Unix epoch timestamp to datetime.datetime object."""
    return datetime.datetime.fromtimestamp(int(val))

sqlite3.register_converter("date", convert_date)
sqlite3.register_converter("datetime", convert_datetime)
sqlite3.register_converter("timestamp", convert_timestamp)


# Schema and migration management

class _SchemaVersion:
    def __init__(self, version: int, sql: str):
        self.version = version
        self.sql = sql

    def execute(self, cur: sqlite3.Cursor):
        with cur.connection:
            cur.executescript(self.sql)
            cur.execute("insert into migrations (version) values (?)", (self.version,))


class _SchemaRegistry:
    _db_schemas: list[_SchemaVersion]

    @classmethod
    def from_list(cls, schemas: list[_SchemaVersion]) -> '_SchemaRegistry':
        self = cls()
        self._db_schemas = list(schemas)
        return self

    def __init__(self):
        self._db_schemas = []

    def add(self, schema: _SchemaVersion):
        self._db_schemas.append(schema)

    def get(self, version: int) -> _SchemaVersion:
        for schema in self._db_schemas:
            if schema.version == version:
                return schema
        return None

    def run_all(self, cur: sqlite3.Cursor, current_version: int = 0):
        for schema in self._db_schemas:
            if schema.version > current_version:
                schema.execute(cur)

    def migrate(self, cur: sqlite3.Cursor):
        tables = list_tables(cur)

        current_version = 0
        if 'migrations' in tables:
            res = cur.execute("select max(version) as version from migrations")
            current_version = res.fetchone()['version']
            if current_version is None:
                current_version = 0

        db_schemas.run_all(cur, current_version)


db_schemas = _SchemaRegistry.from_list([
    _SchemaVersion(1, """
    create table migrations (
        version integer primary key,
        created_at datetime not null default current_timestamp
    );

    create table library (
        id integer primary key autoincrement,
        name text not null,
        mount_path text,
        created_at datetime not null default current_timestamp,
        updated_at datetime not null default current_timestamp
    );

    create table file (
        id integer primary key autoincrement,
        library_id integer not null,
        path text not null,
        size integer not null,
        mtime datetime not null,
        name text not null,
        created_at datetime not null default current_timestamp,
        updated_at datetime not null default current_timestamp,
        deleted_at datetime
    );
    """),
])

@dataclass
class Library:
    id: int
    name: str
    mount_path: Optional[str] = None


@dataclass
class File:
    path: Path
    size: int
    mtime: datetime.datetime


def list_libraries(cur: sqlite3.Cursor) -> list[Library]:
    res = cur.execute("select id, name, mount_path from library")
    return [Library(**row) for row in res.fetchall()]


def add_library(cur: sqlite3.Cursor, name: str, mount_path: Optional[str] = None) -> Library:
    sql = "insert into library (name, mount_path) values (?, ?)"
    cur.execute(sql, (name, mount_path))
    return Library(
        id=cur.lastrowid,
        name=name,
        mount_path=mount_path,
    )


def add_file(cur: sqlite3.Cursor, library_id: int, fileinfo: File):
    sql = """
        insert into file (library_id, name, path, size, mtime)
        values (?, ?, ?, ?, ?);
    """
    params = (
        library_id,
        fileinfo.path.name,
        str(fileinfo.path),
        fileinfo.size,
        fileinfo.mtime,
    )
    cur.execute(sql, params)


def list_tables(cur: sqlite3.Cursor) -> set[str]:
    res = cur.execute("select name from sqlite_schema where type='table'")
    return {row['name'] for row in res.fetchall()}


def main():
    db_path = Path('~/Documents').expanduser() / 'fsindex.db'
    db_path.parent.mkdir(parents=True, exist_ok=True)

    con = sqlite3.connect(db_path, autocommit=False)
    con.row_factory = dict_factory

    cur = con.cursor()

    db_schemas.migrate(cur)

    # Check libraries

    libname, root = sys.argv[1:3]
    root = Path(root).expanduser()

    libraries = list_libraries(cur)
    libraries = [l for l in libraries if l.mount_path == str(root)]
    print(libraries)
    if not libraries:
        with con:
            lib = add_library(cur, libname, str(root))
    else:
        lib = libraries[0]

    # Main loop

    with con:
        for dirpath, dirnames, filenames in root.walk():
            fulldirpath = Path(dirpath)
            dirname = fulldirpath.relative_to(root)

            for filename in filenames:
                entry = dirname / filename
                stat = (fulldirpath / filename).stat(follow_symlinks=False)
                mtime = datetime.datetime.fromtimestamp(stat.st_mtime, datetime.UTC)

                fileinfo = File(
                    path=entry,
                    size=stat.st_size,
                    mtime=mtime,
                )
                print(fileinfo)
                add_file(cur, lib.id, fileinfo)

    # End

    con.close()


if __name__ == '__main__':
    main()

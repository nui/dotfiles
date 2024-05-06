#!/usr/bin/env python3

import re
import subprocess
import json
from pathlib import PurePath

def read_plugin_tuple():
    pattern = re.compile(r'^(\w\S+)\s+(\S+)')
    plugin_file = open('plugins', 'rt')
    for line in plugin_file.readlines():
        m = pattern.match(line)
        if m:
            yield m.groups()

def main():
    lock_db = {}
    for name, url in read_plugin_tuple():
        cwd=PurePath("bundle").joinpath(name)
        process = subprocess.run(['git', 'rev-parse', 'HEAD'], check=True, cwd=cwd, capture_output=True)
        output = process.stdout.decode().strip()
        lock_db[name] = output
    db=json.dumps(lock_db, sort_keys=True, indent=4)
    with open('plugins.lock.json', 'wt') as f:
        f.write(db)
    print(db)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
import requests
import sys
import time
url=sys.argv[1]
while True:
    r = requests.get(url)
    print(r.text.rstrip(), "-" , r.status_code, "-", r.elapsed)
    time.sleep(1)



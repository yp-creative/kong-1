#!/bin/bash

#e.g. setup_update -tag v2.0
if [ "-tag" != "$1" ]; then
    echo "usage: setup_update -tag <tagName> "
    exit 1
fi

shift

if [ "" == "$1" ]; then
    echo "usage: setup_update -tag <tagName> "
    exit 1
fi

cd kong

git checkout "$1" && cd .. && /usr/local/bin/luarocks install kong/kong-0.8.3-0.rockspec &&
echo "update lua module to tag:$1 success! " && echo "Please run 'kong restart -c <configuration>' to apply them."

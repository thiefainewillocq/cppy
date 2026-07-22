#!/bin/sh

set -e
cd "$(dirname "$0")"

CPPY="${CPPY:-$PWD/../cppy}"

if [ ! -x "$CPPY" ]; then
        echo "no cppy binary at $CPPY - run ./build.sh first" >&2
        exit 1
fi

mkdir -p build

"$CPPY" main.cppy world.cppy ../libcppy/*.cppy \
        -o build/example.cpp \
        -Hconfig.hpp \
        -Hlibcppy/types.hpp \
        -Hstdio.h -Hstdlib.h -Hstring.h

g++ build/example.cpp -o build/example -I.. -I. -DVERBOSE -Wall -Wextra -Werror
./build/example

printf '\nEXAMPLE PASSED\n'

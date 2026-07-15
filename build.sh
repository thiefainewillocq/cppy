#!/bin/sh
set -xe
cd "$(dirname "$0")"

./cppy src/*.cppy libcppy/*.cppy \
        -o cppy-unstable-bundle.cpp \
        -Hlibcppy/types.hpp \
        -Hstdio.h -Hstdlib.h -Hstring.h -Hsys/stat.h -Herrno.h

g++ cppy-unstable-bundle.cpp \
        -o cppy-unstable \
        -O3 -Wall -Wextra -Werror

rm cppy-unstable-bundle.cpp
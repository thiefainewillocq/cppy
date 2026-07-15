#!/bin/sh
# Transpiles, compiles and runs every example. Any failure stops the run.
#
# Examples are listed one per line rather than looped over, so each one
# can take the arguments it needs. Everything lands in examples/build/.
#
# Run a single example by copying its two commands out of this file;
# they are plain cppy and g++ invocations with nothing hidden behind
# them.

set -e
cd "$(dirname "$0")"

CPPY="${CPPY:-$PWD/../cppy}"

if [ ! -x "$CPPY" ]; then
        echo "no cppy binary at $CPPY - run ./build.sh first" >&2
        exit 1
fi

mkdir -p build

Banner() {
        printf '\n=== %s ===\n' "$1"
}

# One source file, one binary, one run. Extra arguments go to cppy.
#
# -I.. is what resolves -Hlibcppy/types.hpp, since the bundle lands in
# examples/build/ but the include is written relative to the repo root.
Simple() {
        name="$1"
        shift
        Banner "$name"
        "$CPPY" "$name.cppy" -o "build/$name.cpp" "$@"
        g++ "build/$name.cpp" -o "build/$name" -I.. -Wall -Wextra -Werror
        "./build/$name"
}

# Same, plus libcppy. Note how libcppy is used: the .cppy files are
# simply listed alongside your own. There is no include, no link step
# and no build system entry. types.hpp is the exception - it is a plain
# C++ header, pulled in with -H like any other.
Libcppy() {
        name="$1"
        Banner "$name"
        "$CPPY" "$name.cppy" ../libcppy/*.cppy \
                -o "build/$name.cpp" \
                -Hlibcppy/types.hpp \
                -Hstdio.h -Hstdlib.h -Hstring.h
        g++ "build/$name.cpp" -o "build/$name" -I.. -Wall -Wextra -Werror
        "./build/$name"
}

# The order below is the tour, easiest first.

# No -Hlibcppy/types.hpp: this one uses plain int, so it needs nothing
# from libcppy at all.
Simple hello-world -Hstdio.h

Simple any-order -Hlibcppy/types.hpp -Hstdio.h
Simple mutual-recursion -Hlibcppy/types.hpp -Hstdio.h
Simple tangled-types -Hlibcppy/types.hpp -Hstdio.h

Banner "no-headers"
# world.cppy is passed first even though it depends on entity.cppy.
# Swap the two and the bundle still compiles and behaves the same; only
# the order of the emitted text moves.
"$CPPY" no-headers/world.cppy no-headers/entity.cppy \
        -o build/no-headers.cpp \
        -Hlibcppy/types.hpp \
        -Hstdio.h
g++ build/no-headers.cpp -o build/no-headers -I.. -Wall -Wextra -Werror
./build/no-headers

Simple switch-no-fallthrough -Hlibcppy/types.hpp -Hstdio.h
Simple line-continuation -Hlibcppy/types.hpp -Hstdio.h
Simple fixed-width-types -Hlibcppy/types.hpp -Hstdio.h

Libcppy containers
Libcppy map-set-hash
Libcppy errors

Simple templates -Hlibcppy/types.hpp -Hstdio.h

Banner "namespaces-and-c"
"$CPPY" namespaces-and-c.cppy \
        -o build/namespaces-and-c.cpp \
        -Hlibcppy/types.hpp \
        -Hstdio.h -Hmath.h
g++ build/namespaces-and-c.cpp -o build/namespaces-and-c -I.. -Wall -Wextra -Werror -lm
./build/namespaces-and-c

Banner "cycle-error"
# This example asserts a *failure*: cppy must reject the by-value cycle
# and say which classes it could not place.
if "$CPPY" cycle-error.cppy -o build/cycle-error.cpp 2>build/cycle-error.txt; then
        echo "FAIL: cppy accepted a by-value cycle" >&2
        exit 1
fi
echo "cppy rejected it, as it should:"
echo
sed 's/^/    /' build/cycle-error.txt

Banner "header-mode"
# The same source, built two ways.
#
# --header emits declarations: class definitions, inline methods,
# template bodies, and `extern` for globals. Free functions are only
# declared, so the implementation bundle still has to be linked in.
#
# -H applies in header mode too, so api.hpp pulls in its own types and
# a caller needs nothing but the header.
"$CPPY" header-mode/mathlib.cppy -o build/api.hpp --header -Hlibcppy/types.hpp
"$CPPY" header-mode/mathlib.cppy -o build/mathlib.cpp -Hlibcppy/types.hpp -Hstdio.h
# main.cpp is ordinary C++: include the header, link the bundle.
g++ header-mode/main.cpp build/mathlib.cpp -Ibuild -I.. \
        -o build/header-mode \
        -Wall -Wextra -Werror
./build/header-mode
echo
echo "api.hpp:"
echo
grep -v '^$' build/api.hpp | sed 's/^/    /'

printf '\nALL EXAMPLES PASSED\n'
